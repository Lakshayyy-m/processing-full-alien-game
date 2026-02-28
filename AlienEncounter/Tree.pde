// ============================================================
// Tree.pde - ENVIRONMENTAL HIERARCHICAL OBJECT (extends Entity)
// 3rd hierarchical object requirement: tree with trunk, branches, leaves
// Uses pushMatrix/popMatrix and Limb[] static array for branches
// ============================================================

class Tree extends Entity {
  float trunkHeight;
  float trunkWidth;
  float leafRadius;
  Limb[] branches;       // STATIC ARRAY for tree branches
  int numBranches;
  float swayAngle;
  color trunkColor;
  color leafColor;

  // Constructor
  Tree(float x, float y, float trunkHeight) {
    super(x, y);
    this.trunkHeight = trunkHeight;
    this.trunkWidth = max(6, trunkHeight / 10);
    this.leafRadius = trunkHeight / 3;
    this.numBranches = 5;
    this.swayAngle = 0;
    this.trunkColor = color(100, 70, 35);
    this.leafColor = color(45, 120, 45);
    branches = new Limb[numBranches];
    initBranches();
  }

  // Initialize branch static array
  void initBranches() {
    for (int i = 0; i < numBranches; i++) {
      float angle = map(i, 0, numBranches - 1, -PI/2.5, PI/2.5);
      float len = trunkHeight * 0.25 + random(trunkHeight * 0.15);
      branches[i] = new Limb(len, angle, 0, 0, trunkColor, max(1.5, 3 - i * 0.3), 0);
    }
  }

  // Gentle wind sway animation
  void update() {
    swayAngle = sin(frameCount * 0.015 + x * 0.01) * 0.03;
  }

  // Hierarchical tree drawing
  void display() {
    pushMatrix();
    translate(x, y);
    rotate(swayAngle);              // Whole tree sways

    // === TRUNK (rectangle) ===
    fill(trunkColor);
    stroke(80, 50, 20);
    strokeWeight(1);
    rect(-trunkWidth / 2, -trunkHeight, trunkWidth, trunkHeight);

    // === BRANCHES (hierarchical from trunk) ===
    pushMatrix();
      translate(0, -trunkHeight * 0.6); // Branch origin on trunk

      for (int i = 0; i < numBranches; i++) {
        pushMatrix();
          float branchY = -i * (trunkHeight * 0.08);
          translate(0, branchY);

          // Each branch sways slightly differently
          float branchSway = swayAngle * (1.5 + i * 0.3) * (i % 2 == 0 ? 1 : -1);
          rotate(branches[i].angle + branchSway);

          // Draw branch line
          stroke(trunkColor);
          strokeWeight(branches[i].thickness);
          line(0, 0, branches[i].length, 0);

          // === LEAVES at end of branch (ellipses) ===
          pushMatrix();
            translate(branches[i].length, 0);
            noStroke();
            fill(leafColor, 200);
            ellipse(0, 0, leafRadius * 0.7, leafRadius * 0.55);
            fill(60, 140, 50, 160);
            ellipse(3, -3, leafRadius * 0.5, leafRadius * 0.4);
          popMatrix();

        popMatrix();
      }
    popMatrix();

    // === MAIN CANOPY (large leaf cluster) ===
    pushMatrix();
      translate(0, -trunkHeight - leafRadius * 0.15);
      noStroke();
      fill(leafColor, 180);
      ellipse(0, 0, leafRadius * 2, leafRadius * 1.5);
      fill(55, 130, 55, 150);
      ellipse(-leafRadius * 0.3, leafRadius * 0.15, leafRadius * 1.4, leafRadius);
      ellipse(leafRadius * 0.3, leafRadius * 0.15, leafRadius * 1.4, leafRadius);
    popMatrix();

    popMatrix(); // End tree
  }
}
