// ============================================================
// AlienEncounter.pde - MAIN SKETCH FILE
// 2D Alien Encounter - A Hierarchical 2D Shooting Game
//
// Project Requirements Met:
//   (a) ArrayList<Bullet> for dynamic projectile management
//   (b) Limb[] static array for fixed body parts, Tree[] for env
//   (c) Separate class files for each class
//   (d) 3-level hierarchy: Entity → GameCharacter → Human/Alien
//       Abstract classes: Entity, GameCharacter
//       Interface: Shootable
//   (e) pushMatrix()/popMatrix() stack for hierarchical transforms
//   (f) Custom movement methods: animate(), aimAt(), AI logic
//   (g) Mouse interaction: aiming, clicking to shoot
//   (h) Keyboard interaction: Space shoot, E reload, arrows, R reset
//   (i) Custom image filter with pixel-level manipulation
//   (j) 4 UI components:
//       - AmmoBar (custom #1)
//       - GunAngleSlider (custom #2)
//       - ResetButton (Processing sample #3)
//       - RolloverEffect (Processing sample #4)
//
// Hierarchy Structure:
//   Entity (abstract grandparent)
//     ├── GameCharacter (abstract parent, implements Shootable)
//     │     ├── Human (child - player)
//     │     └── Alien (child - enemy)
//     ├── Bullet (projectile)
//     └── Tree (environmental object)
//
// Shapes Used: Circle, Line, Rectangle, Triangle, Arc (5+)
//
// Game Modes:
//   1 - Single Enemy: Defeat one alien to win
//   2 - Endless Mode: Survive waves of aliens, track score
// ============================================================

GameManager gameManager;

void setup() {
  size(1000, 600);
  smooth();
  noCursor(); // We draw our own crosshair
  gameManager = new GameManager();
}

void draw() {
  gameManager.update();
  gameManager.display();
}

// ---- Mouse Event Handlers ----

void mousePressed() {
  gameManager.handleMousePressed();
}

void mouseReleased() {
  gameManager.handleMouseReleased();
}

void mouseDragged() {
  gameManager.handleMouseDragged();
}

// ---- Keyboard Event Handlers ----

void keyPressed() {
  gameManager.handleKeyPressed();
}
