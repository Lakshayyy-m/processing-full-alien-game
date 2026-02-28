// ============================================================
// Entity.pde - ABSTRACT GRANDPARENT CLASS (Level 1 of hierarchy)
// Base class for all game entities (characters, bullets, trees)
// ============================================================

abstract class Entity {
  float x, y;       // Position
  boolean alive;     // Active state

  // Constructor
  Entity(float x, float y) {
    this.x = x;
    this.y = y;
    this.alive = true;
  }

  // Abstract methods - must be implemented by subclasses
  abstract void display();
  abstract void update();

  // Check if entity is alive
  boolean isAlive() {
    return alive;
  }

  // Set position
  void setPosition(float x, float y) {
    this.x = x;
    this.y = y;
  }

  // Calculate distance to another entity
  float distanceTo(Entity other) {
    return dist(x, y, other.x, other.y);
  }
}
