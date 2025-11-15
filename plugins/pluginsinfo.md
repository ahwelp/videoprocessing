
## fmtconv
clone https://gitlab.com/EleonoreMizo/fmtconv.git
cd fmtconv/build/unix/
./autogen.sh && ./configure && make

## mvtools
clone https://github.com/dubhater/vapoursynth-mvtools.git
cd vapoursynth-mvtools
meson setup build && ninja -C build

## znedi3
https://github.com/sekrit-twc/znedi3.git
https://github.com/HomeOfVapourSynthEvolution/VapourSynth-NNEDI3CL/blob/master/NNEDI3CL/nnedi3_weights.bin
cd znedi3
make X86=1

## AddGrain
git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-AddGrain.git
cd VapourSynth-AddGrain
meson build && ninja -C build #&& ninja -C build install

## ffms2
git clone https://github.com/FFMS/ffms2.git
cd ffms2
./autogen && make #&& make install

## KNLMeansCL
git clone https://github.com/Khanattila/KNLMeansCL.git
sudo pacman -S opencl-headers
cd KNLMeansCL
meson build && ninja -C build #&& ninja -C build install

## VapourSynth-BM3D
git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-BM3D.git
cd VapourSynth-BM3D
meson build && ninja -C build

## VapourSynth-DFTTest
git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DFTTest.git
cd VapourSynth-DFTTest
meson build && ninja -C build #&& ninja -C build install

## VapourSynth-EEDI3
git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-EEDI3.git
meson build && ninja -C build #&& ninja -C build install


