// ============================================================
// RolloverEffect.pde - UI COMPONENT #4 (Processing Sample Style)
// Highlights alien when mouse hovers near it
// Based on Processing rollover example pattern
// ============================================================

class RolloverEffect {
  boolean active;
  float targetX, targetY;
  float radius;
  float pulsePhase;

  // Constructor
  RolloverEffect() {
    this.active = false;
    this.radius = 50;
    this.pulsePhase = 0;
  }

  // Check if mouse is hovering near an entity
  void checkRollover(float entityX, float entityCenterY, float entityRadius) {
    float d = dist(mouseX, mouseY, entityX, entityCenterY);
    if (d < entityRadius + 20) {
      active = true;
      targetX = entityX;
      targetY = entityCenterY;
      radius = entityRadius;
    }
  }

  // Reset rollover state (call before checking each frame)
  void reset() {
    active = false;
  }

  // Draw the rollover highlight effect
  void display() {
    if (!active) return;
    pulsePhase += 0.08;

    float pulse = sin(pulsePhase) * 5;
    float r = radius + 15 + pulse;

    // Pulsing ring
    noFill();
    stroke(255, 255, 0, 120 + sin(pulsePhase) * 40);
    strokeWeight(2);
    ellipse(targetX, targetY, r * 2, r * 2);

    // Inner subtle ring
    stroke(255, 255, 0, 60);
    strokeWeight(1);
    ellipse(targetX, targetY, (r - 8) * 2, (r - 8) * 2);

    // Corner targeting brackets
    float s = r + 5;
    float bracketLen = 12;
    stroke(255, 255, 0, 200);
    strokeWeight(2);

    // Top-left bracket
    line(targetX - s, targetY - s, targetX - s + bracketLen, targetY - s);
    line(targetX - s, targetY - s, targetX - s, targetY - s + bracketLen);

    // Top-right bracket
    line(targetX + s, targetY - s, targetX + s - bracketLen, targetY - s);
    line(targetX + s, targetY - s, targetX + s, targetY - s + bracketLen);

    // Bottom-left bracket
    line(targetX - s, targetY + s, targetX - s + bracketLen, targetY + s);
    line(targetX - s, targetY + s, targetX - s, targetY + s - bracketLen);

    // Bottom-right bracket
    line(targetX + s, targetY + s, targetX + s - bracketLen, targetY + s);
    line(targetX + s, targetY + s, targetX + s, targetY + s - bracketLen);

    // "TARGET" label above
    fill(255, 255, 0, 180);
    noStroke();
    textSize(10);
    textAlign(CENTER, BOTTOM);
    text("TARGET", targetX, targetY - s - 8);

    // Distance indicator
    float mouseDist = dist(mouseX, mouseY, targetX, targetY);
    textSize(9);
    fill(255, 255, 0, 140);
    text("DIST: " + nf(mouseDist, 0, 0), targetX, targetY + s + 18);
  }
}
