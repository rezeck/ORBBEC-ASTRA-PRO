# ORBBEC-ASTRA-PRO

Bringup ROS Noetic para **Orbbec Astra Pro** (depth/IR OpenNI `2bc5:0403` + RGB UVC `2bc5:0501`).

Mostra:
- nuvem **XYZ** e **XYZRGB**
- imagem **IR**
- imagem **RGB** (com clareamento opcional)

> O OrbbecViewer / Orbbec SDK v2 **não** lista a Astra Pro antiga. Use este stack (`ros_astra_camera` + OpenNI2).

## Requisitos

- Linux + Docker (+ NVIDIA Container Toolkit se tiver GPU)
- X11
- Câmera Astra Pro na USB (de preferência **direto na placa**, sem hub USB2)

## Setup (uma vez)

```bash
cd ~/Documents/verlab/ORBBEC-ASTRA-PRO
./scripts/setup_host.sh   # udev rules + grupo video
# reconecte a câmera / faça re-login se entrou no grupo video
```

Confirme:

```bash
lsusb | grep -i 2bc5
# deve aparecer Astra Pro (0403) e Astra Pro HD Camera (0501)
```

## Rodar preview

```bash
./scripts/preview.sh
```

Isso sobe um container `osrf/ros:noetic-desktop-full`, compila `astra_camera` + `astra_pro_bringup` e abre:

| Janela | Conteúdo |
|--------|----------|
| RViz | `/camera/depth/points` (XYZ) e `/camera/depth_registered/points` (XYZRGB) |
| rqt | `/camera/ir/image_raw` |
| rqt | `/camera/color/image_bright` (RGB clareada) |

Parar:

```bash
./scripts/stop.sh
```

## Tópicos principais

- `/camera/color/image_raw` — RGB nativa (costuma ficar escura na Astra Pro)
- `/camera/color/image_bright` — RGB com gain/bias em software
- `/camera/ir/image_raw`
- `/camera/depth/image_raw`
- `/camera/depth/points` — XYZ
- `/camera/depth_registered/points` — XYZRGB (depth aligned)

Fixed frame no RViz: `camera_color_optical_frame`.

## Problemas que este repo já contorna

1. **RGB abre a webcam errada** — `uvc_vendor_id`/`uvc_product_id` precisam ser **inteiros decimais** (`11205` / `1281`). Strings `0x2bc5` viram `0` e a libuvc pega o primeiro UVC do sistema.
2. **Nuvem XYZRGB com `inf`** — `color/camera_info` vinha com `fx=fy=0`. Incluímos `config/rgb_camera.yaml` aproximado (640×480).
3. **RViz glitch no resize/tabs (NVIDIA+Docker)** — RViz sobe com OpenGL software (`llvmpipe`); IR/RGB ficam no `rqt_image_view`.
4. **RGB escura** — exposição UVC da Astra Pro quase não responde; use `/camera/color/image_bright`.

## Layout

```
ORBBEC-ASTRA-PRO/
??? config/
?   ??? camera_info/rgb_camera.yaml
?   ??? udev/56-orbbec-usb.rules
??? orbbec_ws/src/
?   ??? ros_astra_camera/      # Orbbec OpenNI ROS driver (vendored + patch UVC IDs)
?   ??? astra_pro_bringup/    # launch, rviz, brighten
??? scripts/
    ??? setup_host.sh
    ??? preview.sh
    ??? stop.sh
```

## Licença

Código deste bringup: MIT.  
`ros_astra_camera` mantém a licença upstream Orbbec.
