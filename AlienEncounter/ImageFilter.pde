// ============================================================
// ImageFilter.pde - CUSTOM IMAGE FILTER
// Pixel-level manipulation using loadPixels()/updatePixels()
// Applies damage flash (red tint) and game-over (grayscale)
// ============================================================

class ImageFilter {
  float redIntensity;       // Red tint strength (damage flash)
  float greenIntensity;     // Green tint strength (heal flash)
  boolean grayscaleActive;  // Grayscale mode (game over)
  int effectDuration;       // Remaining frames for tint effect

  // Constructor
  ImageFilter() {
    redIntensity = 0;
    greenIntensity = 0;
    grayscaleActive = false;
    effectDuration = 0;
  }

  // Trigger a red damage flash
  void triggerDamageFlash() {
    redIntensity = 120;
    effectDuration = 18;
  }

  // Trigger a green heal flash
  void triggerHealFlash() {
    greenIntensity = 80;
    effectDuration = 12;
  }

  // Enable/disable grayscale (game over effect)
  void setGrayscale(boolean active) {
    grayscaleActive = active;
  }

  // Decay the flash effects over time
  void update() {
    if (effectDuration > 0) {
      effectDuration--;
      redIntensity *= 0.82;
      greenIntensity *= 0.82;
    } else {
      redIntensity = 0;
      greenIntensity = 0;
    }
  }

  // Apply the filter to the entire screen (pixel-level manipulation)
  void apply() {
    boolean hasRed = redIntensity > 2;
    boolean hasGreen = greenIntensity > 2;

    if (!hasRed && !hasGreen && !grayscaleActive) return;

    loadPixels();

    for (int i = 0; i < pixels.length; i++) {
      float r = (pixels[i] >> 16) & 0xFF;
      float g = (pixels[i] >> 8) & 0xFF;
      float b = pixels[i] & 0xFF;

      // Grayscale conversion (weighted luminance)
      if (grayscaleActive) {
        float gray = 0.299 * r + 0.587 * g + 0.114 * b;
        // Slight blue tint for dramatic effect
        r = constrain(gray * 0.85, 0, 255);
        g = constrain(gray * 0.85, 0, 255);
        b = constrain(gray * 1.0, 0, 255);
      }

      // Red tint (damage)
      if (hasRed) {
        r = constrain(r + redIntensity, 0, 255);
        g = constrain(g - redIntensity * 0.4, 0, 255);
        b = constrain(b - redIntensity * 0.4, 0, 255);
      }

      // Green tint (heal/pickup)
      if (hasGreen) {
        g = constrain(g + greenIntensity, 0, 255);
        r = constrain(r - greenIntensity * 0.2, 0, 255);
        b = constrain(b - greenIntensity * 0.2, 0, 255);
      }

      pixels[i] = color(r, g, b);
    }

    updatePixels();
  }
}
