# T129 – dkgl glGenerateMipmap (DKGL_TODO §7.0 G, part 1) (AI-assisted)

Goal: jak2 skull gems are flat orange discs because the GL TextureAnimator calls
`glGenerateMipmap(GL_TEXTURE_2D)` and dkgl does nothing, so the small mips stay empty.
Implement it inside dkgl. No native renderer. Do not edit `opengl_renderer/`.

Facts (do not re-search):
- GL hooks: `game/graphics/deko3d_renderer/dkgl/dkgl_glad.cpp`. Pattern: `dkgl_glBlitFramebuffer`
  (~line 131). `install_glad()` (~268) sets the `glad_gl*` pointers: add `glad_glGenerateMipmap`.
- Textures: `dkgl_texture.cpp` — `TexObj`, `materialize` (~99, uses
  `dktexgpu::create_render_target_mipped`), `bind_texture` (~158), `blit_framebuffer` (~358).
- Queued blits: `dkgl_frame.cpp` `blit_frame_to_tex` (~662) adds a blit `Segment`; `record_bucket`
  (~2270) replays it with `dkCmdBufBlitImage`.
- deko3d (checked in `docs/deko3d-ref/include/deko3d.h`): `dkImageViewDefaults(&view, img)`, then pick
  ONE mip level by setting the fields `view.mipLevelOffset = level; view.mipLevelCount = 1;`
  (there is NO setter function). `dkCmdBufBlitImage(cmd, &src, &srcRect, &dst, &dstRect,
  DkBlitFlag_FilterLinear, 0)`. Barrier between levels: `dkCmdBufBarrier(cmd, DkBarrier_Full,
  DkInvalidateFlags_Image)`.

Plan: `dkgl_glGenerateMipmap` -> `generate_mipmap()` on the bound texture: for level 1..N-1 queue a
blit level-1 (w,h) -> level (w/2,h/2), with a barrier after each. If the texture has 1 level,
do nothing. Read only the line ranges above (max ~200 lines each).

If anything is unclear or an API seems missing: STOP and write the question in the report.

Done-check:
- `python3 scripts/ai/check-dk.py` -> `dk-lint: PASS`
- `scripts/ai/check-switch.sh jak2` -> `PASS: jak2 ... md5=...`

Don't commit, push or deploy. Append `## T129 – PASS/FAIL`, changed files, md5 and doubts to
`docs/deko3d/qwen-tasks/QWEN_REPORT.md`.
