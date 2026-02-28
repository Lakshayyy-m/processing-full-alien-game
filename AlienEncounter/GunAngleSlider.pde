// ============================================================
// GunAngleSlider.pde - CUSTOM UI COMPONENT #2
// A slider that controls and displays gun aim angle
// Built from scratch with custom arc indicator
// ============================================================

class GunAngleSlider {
  float x, y, w, h;
  float minAngle, maxAngle;
  float currentAngle;
  boolean dragging;

  // Constructor
  GunAngleSlider(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.minAngle = -PI / 2;
    this.maxAngle = PI / 3;
    this.currentAngle = 0;
    this.dragging = false;
  }

  // Draw the slider UI
  void display(float angle) {
    this.currentAngle = angle;

    pushMatrix();
    translate(x, y);

    // Label
    fill(200);
    textSize(11);
    textAlign(LEFT, BOTTOM);
    text("GUN ANGLE", 0, -4);

    // Track background
    fill(30, 30, 40);
    stroke(80);
    strokeWeight(1);
    rect(0, 0, w, h, 8);

    // Calculate handle position
    float normalized = map(currentAngle, minAngle, maxAngle, 0, 1);
    normalized = constrain(normalized, 0, 1);

    // Gradient fill bar
    for (int i = 0; i < (int)(w * normalized) - 1; i++) {
      float t = map(i, 0, w, 0, 1);
      color c = lerpColor(color(50, 140, 255), color(255, 120, 50), t);
      stroke(c);
      strokeWeight(1);
      line(i + 1, 2, i + 1, h - 2);
    }

    // Handle (circle on track)
    float handleX = normalized * (w - 4) + 2;
    // Handle glow
    if (dragging) {
      fill(255, 180, 80, 60);
      noStroke();
      ellipse(handleX, h / 2, h + 14, h + 14);
    }
    // Handle body
    fill(dragging ? color(255, 200, 100) : color(220));
    stroke(dragging ? color(255, 180, 50) : color(160));
    strokeWeight(1.5);
    ellipse(handleX, h / 2, h + 4, h + 4);

    // Small tick marks on track
    for (int i = 0; i <= 4; i++) {
      float tx = map(i, 0, 4, 4, w - 4);
      stroke(80);
      strokeWeight(1);
      line(tx, h - 1, tx, h + 2);
    }

    // --- Arc angle indicator ---
    pushMatrix();
      translate(w + 35, h / 2);
      float arcR = 18;

      // Background arc (full range)
      noFill();
      stroke(60);
      strokeWeight(1.5);
      arc(0, 0, arcR * 2, arcR * 2, minAngle, maxAngle);       // Arc shape (Shape 5)

      // Active arc (current angle)
      stroke(100, 200, 255);
      strokeWeight(2);
      if (currentAngle >= 0) {
        arc(0, 0, arcR * 2, arcR * 2, 0, currentAngle);
      } else {
        arc(0, 0, arcR * 2, arcR * 2, currentAngle, 0);
      }

      // Direction line
      stroke(255, 180, 50);
      strokeWeight(2);
      line(0, 0, cos(currentAngle) * arcR, sin(currentAngle) * arcR);

      // Endpoint dot
      fill(255, 180, 50);
      noStroke();
      ellipse(cos(currentAngle) * arcR, sin(currentAngle) * arcR, 5, 5);
    popMatrix();

    // Angle text
    fill(180);
    textSize(10);
    textAlign(LEFT, CENTER);
    text(nf(degrees(currentAngle), 0, 1) + "°", w + 58, h / 2);

    popMatrix();
  }

  // Check if mouse is hovering over the slider
  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + w &&
           mouseY >= y - 3 && mouseY <= y + h + 3;
  }

  // Handle drag input and return new angle
  float handleDrag() {
    if (dragging) {
      float normalized = constrain((mouseX - x) / w, 0, 1);
      return map(normalized, 0, 1, minAngle, maxAngle);
    }
    return currentAngle;
  }

  // Start dragging
  void press() {
    if (isMouseOver()) {
      dragging = true;
    }
  }

  // Stop dragging
  void release() {
    dragging = false;
  }
}
