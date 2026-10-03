{ config, pkgs, ... }:

let
  videoNr = 10;
  sink = "phonecam-sink";

  # Android phone as webcam and microphone over USB; needs USB debugging enabled.
  phonecam = pkgs.writeShellApplication {
    name = "phonecam";
    runtimeInputs = [ pkgs.scrcpy ];
    # scrcpy plays the mic through SDL, which picks PipeWire or PulseAudio at
    # runtime, and each backend reads its own variable. Unrouted, the mic
    # plays on the default output instead.
    runtimeEnv = {
      PIPEWIRE_NODE = sink;
      PULSE_SINK = sink;
    };
    text = ''
      # 180: the mount holds the phone upside down relative to its sensor.
      exec scrcpy \
        --video-source=camera --camera-facing=front --camera-size=1920x1080 \
        --capture-orientation=180 --audio-source=mic \
        --no-window --v4l2-sink=/dev/video${toString videoNr} "$@"
    '';
  };
in
{
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];

  # video_nr is pinned so the sink path stays valid if a real camera is ever
  # plugged in. Chromium-based browsers only list the device with exclusive_caps=1.
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=${toString videoNr} exclusive_caps=1 card_label="Phone Camera"
  '';

  # A sink for scrcpy to play into, re-exposed as a source apps can pick as a mic.
  services.pipewire.extraConfig.pipewire."50-phonecam" = {
    "context.modules" = [
      {
        name = "libpipewire-module-loopback";
        args = {
          "audio.position" = [ "FL" "FR" ];
          "capture.props" = {
            "media.class" = "Audio/Sink";
            "node.name" = sink;
            "node.description" = "Phone Microphone (scrcpy feed)";
          };
          "playback.props" = {
            "media.class" = "Audio/Source";
            "node.name" = "phonecam-mic";
            "node.description" = "Phone Microphone";
          };
        };
      }
    ];
  };

  environment.systemPackages = [ phonecam ];
}
