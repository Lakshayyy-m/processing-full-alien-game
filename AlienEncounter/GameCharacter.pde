// ============================================================
// GameCharacter.pde - ABSTRACT PARENT CLASS (Level 2 of hierarchy)
// Extends Entity, implements Shootable interface
// Base for Human and Alien characters
// ============================================================

abstract class GameCharacter extends Entity implements Shootable {
  float health, maxHealth;
  int ammo, maxAmmo;
  float armAngle;              // Current arm/gun rotation
  Limb[] limbs;                // STATIC ARRAY for body parts
  ArrayList<Bullet> bullets;   // ARRAYLIST for dynamic projectiles
  color bodyColor;
  float speed;
  boolean facingRight;

  // Body measurements
  float bodyHeight = 70;
  float headRadius = 15;
  float upperArmLen = 30;
  float lowerArmLen = 25;
  float upperLegLen = 35;
  float lowerLegLen = 35;
  float gunLength = 20;

  // Shooting mechanics
  int shootCooldown = 0;
  int shootDelay = 15;

  // Constructor
  GameCharacter(float x, float y, float maxHealth, int maxAmmo, color bodyColor) {
    super(x, y);
    this.maxHealth = maxHealth;
    this.health = maxHealth;
    this.maxAmmo = maxAmmo;
    this.ammo = maxAmmo;
    this.armAngle = 0;
    this.bodyColor = bodyColor;
    this.speed = 2;
    this.facingRight = true;
    this.bullets = new ArrayList<Bullet>();
    initLimbs();
  }

  // Abstract methods for subclasses
  abstract void initLimbs();
  abstract void animate();

  // Take damage and check death
  void takeDamage(float dmg) {
    health -= dmg;
    if (health <= 0) {
      health = 0;
      alive = false;
    }
  }

  // Get health as percentage (0.0 to 1.0)
  float getHealthPercent() {
    return health / maxHealth;
  }

  // Interface method: can shoot if has ammo and cooldown is ready
  boolean canShoot() {
    return ammo > 0 && shootCooldown <= 0 && alive;
  }

  // Interface method: refill ammo
  void reload() {
    ammo = maxAmmo;
  }

  // Draw a health bar above the character
  void drawHealthBar(float barW, float barH, color barCol) {
    pushMatrix();
    translate(x - barW / 2, y - bodyHeight - headRadius * 2 - 25);

    // Background
    fill(50);
    noStroke();
    rect(0, 0, barW, barH);

    // Health fill
    fill(barCol);
    rect(0, 0, barW * getHealthPercent(), barH);

    // Border
    noFill();
    stroke(200);
    strokeWeight(1);
    rect(0, 0, barW, barH);

    popMatrix();
  }

  // Update all bullets owned by this character
  void updateBullets() {
    for (int i = bullets.size() - 1; i >= 0; i--) {
      Bullet b = bullets.get(i);
      b.update();
      if (!b.isAlive()) {
        bullets.remove(i);
      }
    }
  }

  // Draw all bullets owned by this character
  void drawBullets() {
    for (Bullet b : bullets) {
      b.display();
    }
  }
}
