# Color Sprout

A coloring studio for children aged 2–5 that works offline. A child picks a colour and drags it (or taps it) onto one enclosed part of a picture. Only that part fills, and the black outlines stay crisp. A secondary Draw mode adds freehand marks with four distinct tools, and there is an eraser that removes only the child's own marks. Every picture autosaves, can be resumed later, and can be saved as a high-resolution PNG.

## Implementation report

### What is included

| Requirement | Where |
|---|---|
| 10 categories × 5 sketches (50 original templates) | `assets/coloring/<category>/<id>/` (`outline.svg`, `regions.json`, `template.json`, `thumbnail.png`), catalogue in `lib/data/coloring_catalog.dart` |
| Region engine (vector paths, stable IDs, z-order) | `lib/engines/region_coloring/` |
| Drag-to-fill + tap-to-fill, hover highlight, missed drops glide back to the palette | `coloring_canvas.dart`, `widgets/color_palette.dart` |
| Pencil, Crayon, Marker, Watercolor + 3 sizes + live preview | `engines/free_draw/stroke_renderer.dart`, `widgets/drawing_toolbar.dart` |
| Eraser (partial, non-destructive, undoable) | eraser strokes use `BlendMode.clear` on an isolated drawing layer |
| Undo / Redo / Clear Drawing / Reset Picture (with confirmation) | `engines/free_draw/drawing_history.dart` (bounded to 100 steps) |
| Autosave, resume, My Artwork (continue / preview / share / delete) | `services/artwork_persistence_service.dart`, `screens/my_artwork_screen.dart` |
| 2048 px PNG export, gallery save, share sheet | `engines/export/artwork_export_service.dart`, `services/gallery_save_service.dart`, `services/export_flow.dart` |
| Little Artist / Creative Explorer modes, parent gate, Parent Zone | `services/app_settings.dart`, `screens/parent_settings_screen.dart` |
| Stickers, first-use demo, idle hints, celebration on save, sounds, haptics, spoken prompts | `widgets/`, `services/sound_service.dart` |

### How the artwork works

The templates are authored as code in `tool/artwork/sketches/*.py`. Shapes are listed from back to front, and the builder (`tool/artwork/lib.py`, using shapely) turns that stack into a **planar partition**:

- Each region keeps only the part of it you can see. Regions never overlap, and neighbours share the same boundary.
- The outline is generated from those same boundaries plus the detail strokes (eyes, smiles, seeds). Line art and fills can't drift apart.
- Hit-testing is exact path containment in template coordinates, using the same `CanvasTransform` the painter uses. A 14 px tolerance only rescues near misses that fall *outside* every region (for example on the outer outline). It never takes a point that is clearly inside one region and gives it to another.

To regenerate the artwork (needs Python with `shapely` and `pillow`):

```
python3 tool/artwork/build.py [--preview DIR]
flutter test tool/render_thumbnails_test.dart     # thumbnails, drawn by the app's renderer
python3 tool/artwork/sounds.py                    # synthesised sound effects
```

### Rendering layers

1. White background
2. Region fills (with a 200 ms colour ripple)
3. Original outline
4. Drawing layer
5. Stickers
6. Temporary highlights (on screen only)

`ArtworkRenderer` is shared by the canvas, the thumbnails and the PNG exporter, so the saved image matches the screen. The export is drawn offscreen with `PictureRecorder`. It is not a screenshot, so app UI can't end up in it.

### Data

Each project is a small versioned JSON file in `<documents>/artworks/`. It holds the region→colour map, the strokes (template coordinates, rounded to 0.1 units), the stickers, timestamps and the last tool, colour and size used. Template geometry is never copied into a project.

- **Writes:** debounced, and written atomically (temp file, then rename).
- **App lifecycle:** pending saves are flushed when the app is paused.
- **Exports:** PNGs go to `<documents>/exports/` and are kept separate from projects. Deleting one never affects the other.

### Test results (all executed)

- `dart format --set-exit-if-changed lib test tool`: clean
- `flutter analyze`: **no issues**
- `flutter test`: **241 tests passed**. The suite covers:
  - `template_validation_test`: for each of the 50 templates, the assets exist, the metadata matches, IDs are unique, bounds fit the view box, every region is at least 1600 units² in area, and an interior sample point hits its own region. It also checks that filling a region never touches another, and that a grid scan finds no overlapping regions.
  - `region_engine_test`: red on one petal fills only that petal, regions fill independently, recolouring works, drops outside the picture do nothing, results are the same at several screen sizes and letterbox shapes, and points on boundaries resolve the same way every time.
  - `drawing_test`: the four tools render differently from each other, sizes go up in order, erasing is partial and reveals the fill underneath, the outline survives, undo/redo works across mixed actions, Clear and Reset behave correctly, history is capped, and stickers can be moved or removed.
  - `export_test`: the PNG signature is valid, the image is 2048×2048 with fill, outline and stroke pixels where expected, the outline is still visible next to a white region, and file names are sensible. Gallery outcomes are covered: success, permission denied, write failure, and an unsupported platform.
  - `persistence_test`: work resumes after a simulated restart (including the last tool, colour and size), saves are debounced, deleting one project leaves others alone, corrupt or future-version files are skipped, and settings persist.
  - `app_flow_test`: the **final acceptance flow on the real widgets**. It goes Home → Flowers → Flower, drags red onto a petal, tap-fills another petal blue, draws a blue pencil mark, erases it, undoes, saves a PNG, restarts the app from disk and continues the picture. It also checks that every gallery card opens the right template, and that the studio fits on a 320×568 phone and a 1366×1024 tablet with no overflow.
- **Builds:** `flutter build apk --debug` ✓, `flutter build ios --simulator --debug` ✓, `flutter build macos --debug` ✓. The macOS app launched cleanly in a smoke test.

### Platform notes

- **Android:** `WRITE_EXTERNAL_STORAGE` is requested only on API ≤ 29, and `requestLegacyExternalStorage` is set. Android 11+ saves through MediaStore with no permission. The TTS intent query is added for spoken prompts.
- **iOS / macOS:** only `NSPhotoLibraryAddUsageDescription` (add-only access). No album is created, which avoids asking for full library access. The macOS deployment target was raised to 11.0, which the `gal` plugin requires.
- **Network and privacy:** the app makes no network requests, collects no analytics, shows no ads and has no accounts.

### Outstanding limitations

- I couldn't test on a physical device or emulator, so these are unverified on real hardware: saving to the photo gallery, the share sheet, audio playback, haptics and text-to-speech. The gallery logic is tested against a fake gallery, and failures are reported without ever claiming false success.
- Spoken prompts use the device's text-to-speech engine and are **off by default**.
- These optional features were not built: decorative pattern stamps, the eyedropper, and pinch-to-zoom on the canvas.
- Opening a template resumes its latest project. The UI does not offer several separate copies of the same template.
- The sound effects are simple synthesised tones. A sound designer could replace them with richer ones.
- `thumbnail.png` files are bundled as required, but the gallery cards draw the template live with the same renderer. This guarantees the cards show the real artwork and the child's current colours.
