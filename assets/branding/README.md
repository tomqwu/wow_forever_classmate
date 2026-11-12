# Forever Classmate logo

The master PNG is `forever-classmate-logo.png`. It is the project artwork for
GitHub and CurseForge: a golden compass-star surrounded by nine colored gems,
representing one adaptive companion for the nine current Forever classes.

The design uses no lettering so it remains recognizable as a small minimap icon.
The transparent master is exported as an uncompressed 256 × 256 RGBA TGA at
`addons/ForeverUtilities/Textures/ForeverClassmate.tga` for the minimap button
and WoW addon list.

The previous Hunter's Friend artwork remains in source history, but new pages and
packages should use the Forever Classmate assets.

## Class crests, frame, divider and glow

`addons/ForeverUtilities/Textures/Classes/<TOKEN>.tga`, `Textures/IconFrame.tga` and `Textures/Divider.tga`
come from the author's ForeverHUD project (`tomqwu/wow_forever_weakaura`): the
AI-painted masters and prompts are in its `assets/ai`, exported by its
`scripts/media.py`. `scripts/import_class_art.py` only box-filters those 256 × 256
crests and the 128 × 128 frame to 64 × 64 and the divider to 256 × 16. The frame
and divider are converted to greyscale so the addon can tint them per class; the
crests keep their original colors. `Textures/Glow.tga` is a plain generated
radial falloff. Nothing is redrawn. Game spell and item icons are still read
from the client at runtime and are not bundled.
