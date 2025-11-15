import vapoursynth as vs
import sys, os

core = vs.core

infile = os.environ['SOURCE_VIDEO']

# === PLUGINS ===
plugin_dir = os.path.expanduser(os.environ['PLUGIN_LOCATION'])
core.std.LoadPlugin(os.path.join(plugin_dir, "libffms2.so.5.0.1"))
core.std.LoadPlugin(os.path.join(plugin_dir, "libmvtools.so"))
core.std.LoadPlugin(os.path.join(plugin_dir, "libeedi3m.so"))
core.std.LoadPlugin(os.path.join(plugin_dir, "libfmtconv.so"))
core.std.LoadPlugin(os.path.join(plugin_dir, "vsznedi3.so"))
core.std.LoadPlugin(os.path.join(plugin_dir, "libknlmeanscl.so"))
core.std.LoadPlugin(os.path.join(plugin_dir, "libbm3d.so"))
core.std.LoadPlugin(os.path.join(plugin_dir, "libremovegrain.so"))
core.std.LoadPlugin(os.path.join(plugin_dir, "libaddgrain.so"))
core.std.LoadPlugin(os.path.join(plugin_dir, "libdfttest.so"))
exit;
# Adiciona qtgmc.py
sys.path.append(plugin_dir)
import qtgmc

# === INPUT ===
clip = core.ffms2.Source(infile)

# Força o formato interno para 16 bits para preservar qualidade no pipeline
clip = core.fmtc.bitdepth(clip, bits=16)

# === PASSO 1: Deinterlace / reconstrução temporal (CPU+SIMD) ===
clip = qtgmc.QTGMC(
    clip,
    Preset="Slow",
    TFF=True,
    SourceMatch=1,
    Lossless=2,
    Sharpness=0.3,
    TR2=2
)

# === PASSO 2: Denoise principal via GPU (OpenCL) ===
# Este filtro remove ruído VHS e artefatos de compressão.
clip = core.knlm.KNLMeansCL(
    clip,
    d=3,  # profundidade temporal
    a=3,  # raio espacial
    s=4,  # tamanho do bloco
    h=1.25,  # força do filtro
    device_type='GPU'
)

# === PASSO 3: BM3D (GPU-friendly se disponível via OpenCL)
# Remove ruído fino e texturas espúrias, preservando contornos.
clip = core.bm3d.Basic(clip, sigma=[2.0, 1.8, 1.5])

# === PASSO 4: Correção de cores via fmtconv (executa no OpenCL)
clip = core.fmtc.transfer(clip, transs="601", transd="709")
clip = core.fmtc.matrix(clip, mats="601", matd="709", col_fam=vs.YUV)
clip = core.fmtc.bitdepth(clip, bits=8)  # converte de volta pra 8-bit pro encode final

# === PASSO 5: Correção de níveis de brilho/contraste ===
clip = core.std.Levels(
    clip,
    min_in=16,
    max_in=235,
    min_out=0,
    max_out=255,
    gamma=1.02
)

# === PASSO 6: Texturização suave para evitar "plastic look" ===
clip = core.grain.Add(clip, var=0.3, uvar=0.2)

# === SAÍDA ===
clip.set_output()

