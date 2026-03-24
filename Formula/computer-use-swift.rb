class ComputerUseSwift < Formula
  desc "macOS desktop control CLI — screenshots, input simulation, app management"
  homepage "https://github.com/dnakov/computer-use"
  url "https://github.com/dnakov/computer-use/archive/refs/heads/main.tar.gz"
  version "0.1.0"
  license "MIT"

  depends_on :macos => :sonoma
  depends_on xcode: ["15.0", :build]

  def install
    system "swift", "build",
           "-c", "release",
           "--arch", "arm64",
           "--arch", "x86_64",
           "--disable-sandbox"

    release_dir = ".build/apple/Products/Release"
    bin.install "#{release_dir}/computer-use"

    system "swift", "build",
           "-c", "release",
           "--arch", "arm64",
           "--arch", "x86_64",
           "--disable-sandbox",
           "--product", "teach-overlay"

    app_dir = libexec/"TeachOverlay.app/Contents"
    (app_dir/"MacOS").mkpath
    cp "#{release_dir}/teach-overlay", app_dir/"MacOS/teach-overlay"
    (app_dir/"Info.plist").write <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleExecutable</key><string>teach-overlay</string>
        <key>CFBundleIdentifier</key><string>com.computer-use.teach-overlay</string>
        <key>CFBundleName</key><string>TeachOverlay</string>
        <key>CFBundleVersion</key><string>#{version}</string>
        <key>LSUIElement</key><true/>
        <key>NSHighResolutionCapable</key><true/>
        <key>LSMinimumSystemVersion</key><string>14.0</string>
      </dict>
      </plist>
    PLIST

    ln_sf libexec/"TeachOverlay.app", bin/"TeachOverlay.app"
  end

  def caveats
    <<~EOS
      computer-use requires macOS permissions:
        - Accessibility (for input simulation)
        - Screen Recording (for screenshots)
      Grant in System Settings > Privacy & Security.
    EOS
  end

  test do
    assert_match "displayId", shell_output("#{bin}/computer-use display list-all")
    assert_match version.to_s, shell_output("#{bin}/computer-use --version")
  end
end
