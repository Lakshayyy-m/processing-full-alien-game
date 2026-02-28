// ============================================================
// Limb.pde - BODY PART CLASS
// Represents a hierarchical limb/body part with properties
// Used in static arrays (Limb[]) for character construction
// ============================================================

class Limb {
  float length;          // Length of the limb
  float angle;           // Current rotation angle
  float offsetX, offsetY; // Offset from parent attachment point
  color limbColor;       // Color of the limb
  float thickness;       // Stroke weight
  int limbType;          // 0=line, 1=ellipse(head), 2=rect(gun)
  float limbWidth;       // Width for ellipse/rect types
  float limbHeight;      // Height for ellipse/rect types

  // Constructor for line-type limbs
  Limb(float length, float angle, float offsetX, float offsetY,
       color limbColor, float thickness, int limbType) {
    this.length = length;
    this.angle = angle;
    this.offsetX = offsetX;
    this.offsetY = offsetY;
    this.limbColor = limbColor;
    this.thickness = thickness;
    this.limbType = limbType;
    this.limbWidth = 0;
    this.limbHeight = 0;
  }

  // Constructor for shape-type limbs (ellipse, rect)
  Limb(float length, float angle, float offsetX, float offsetY,
       color limbColor, float thickness, int limbType, float w, float h) {
    this(length, angle, offsetX, offsetY, limbColor, thickness, limbType);
    this.limbWidth = w;
    this.limbHeight = h;
  }

  // Draw the limb shape
  void drawLimb() {
    switch (limbType) {
      case 0: // Line
        stroke(limbColor);
        strokeWeight(thickness);
        line(0, 0, length, 0);
        break;
      case 1: // Ellipse (head)
        fill(limbColor);
        stroke(limbColor);
        strokeWeight(1);
        ellipse(0, 0, limbWidth, limbHeight);
        break;
      case 2: // Rectangle (gun)
        fill(limbColor);
        noStroke();
        rect(0, -limbHeight / 2, limbWidth, limbHeight);
        break;
    }
  }
}
