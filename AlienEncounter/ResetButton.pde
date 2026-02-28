// ============================================================
// ResetButton.pde - UI COMPONENT #3 (Processing Sample Style)
// Simple rectangular button with hover and press states
// Based on Processing button example pattern
// ============================================================

class ResetButton {
  float x, y, w, h;
  String label;
  boolean over;
  boolean pressed;
  color baseColor, hoverColor, pressColor, textColor;

  // Constructor
  ResetButton(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.over = false;
    this.pressed = false;
    this.baseColor = color(55, 55, 70);
    this.hoverColor = color(80, 80, 100);
    this.pressColor = color(40, 40, 55);
    this.textColor = color(220);
  }

  // Alternate constructor with custom colors
  ResetButton(float x, float y, float w, float h, String label,
              color baseCol, color hoverCol, color textCol) {
    this(x, y, w, h, label);
    this.baseColor = baseCol;
    this.hoverColor = hoverCol;
    this.textColor = textCol;
  }

  // Update and draw button
  void display() {
    over = isMouseOver();

    // Choose fill based on state
    if (pressed && over) {
      fill(pressColor);
    } else if (over) {
      fill(hoverColor);
    } else {
      fill(baseColor);
    }

    // Border
    stroke(over ? 180 : 120);
    strokeWeight(over ? 2 : 1);
    rect(x, y, w, h, 5);

    // Label text
    fill(over ? 255 : textColor);
    textSize(13);
    textAlign(CENTER, CENTER);
    text(label, x + w / 2, y + h / 2 - 1);
  }

  // Check if mouse is over button
  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + w &&
           mouseY >= y && mouseY <= y + h;
  }

  // Handle press event
  void press() {
    if (over) pressed = true;
  }

  // Handle release event - returns true if button was clicked
  boolean release() {
    boolean wasClicked = pressed && over;
    pressed = false;
    return wasClicked;
  }
}
