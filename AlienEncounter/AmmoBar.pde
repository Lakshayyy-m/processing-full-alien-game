// ============================================================
// AmmoBar.pde - CUSTOM UI COMPONENT #1
// Displays ammo count as colored squares in a bar
// Built from scratch using basic shapes
// ============================================================

class AmmoBar {
  float x, y, w, h;

  // Constructor
  AmmoBar(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  // Draw the ammo bar
  void display(int currentAmmo, int maxAmmo, boolean isReloading) {
    pushMatrix();
    translate(x, y);

    // Label
    fill(200);
    textSize(11);
    textAlign(LEFT, BOTTOM);
    text("AMMO", 0, -4);

    // Background bar
    fill(30, 30, 40);
    stroke(80);
    strokeWeight(1);
    rect(0, 0, w, h, 3);

    // Individual ammo squares
    float padding = 3;
    float availableW = w - padding * 2;
    float squareGap = 1.5;
    float squareW = (availableW / maxAmmo) - squareGap;
    squareW = min(squareW, h - padding * 2);
    float squareH = h - padding * 2;

    for (int i = 0; i < maxAmmo; i++) {
      float sx = padding + i * (squareW + squareGap);
      float sy = padding;

      if (i < currentAmmo) {
        // Filled ammo: yellow gradient
        float t = map(i, 0, maxAmmo, 0.3, 1.0);
        fill(lerpColor(color(200, 160, 20), color(255, 230, 50), t));
      } else {
        // Empty slot: dark
        fill(40, 40, 50);
      }

      noStroke();
      rect(sx, sy, squareW, squareH, 1);
    }

    // Reload flash effect
    if (isReloading) {
      float flash = sin(frameCount * 0.3) * 0.5 + 0.5;
      fill(255, 200, 50, flash * 60);
      noStroke();
      rect(0, 0, w, h, 3);
    }

    // Border
    noFill();
    stroke(100);
    strokeWeight(1.5);
    rect(0, 0, w, h, 3);

    // Count text
    fill(isReloading ? color(255, 200, 50) : color(220));
    textSize(11);
    textAlign(LEFT, CENTER);
    String ammoText = isReloading ? "RELOADING" : currentAmmo + " / " + maxAmmo;
    text(ammoText, w + 8, h / 2);

    popMatrix();
  }
}
