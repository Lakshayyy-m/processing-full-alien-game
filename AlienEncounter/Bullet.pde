// ============================================================
// Bullet.pde - PROJECTILE CLASS (extends Entity)
// Dynamic objects managed via ArrayList<Bullet>
// ============================================================

class Bullet extends Entity {
  float speed;           // Movement speed
  float angle;           // Direction of travel
  float size;            // Visual size
  boolean isPlayerBullet; // true = player's, false = enemy's
  float damage;          // Damage dealt on hit

  // Constructor
  Bullet(float x, float y, float angle, boolean isPlayerBullet) {
    super(x, y);
    this.angle = angle;
    this.isPlayerBullet = isPlayerBullet;
    this.speed = isPlayerBullet ? 12 : 6;
    this.size = isPlayerBullet ? 6 : 5;
    this.damage = isPlayerBullet ? 25 : 8;
  }

  // Move bullet and check bounds
  void update() {
    x += cos(angle) * speed;
    y += sin(angle) * speed;

    // Destroy if off-screen
    if (x < -50 || x > width + 50 || y < -50 || y > height + 50) {
      alive = false;
    }
  }

  // Draw bullet with trail effect
  void display() {
    pushMatrix();
    translate(x, y);
    rotate(angle);

    // Trail
    noFill();
    if (isPlayerBullet) {
      stroke(255, 200, 0, 80);
    } else {
      stroke(255, 50, 50, 80);
    }
    strokeWeight(2);
    line(0, 0, -size * 3, 0);

    // Bullet body (ellipse shape)
    noStroke();
    if (isPlayerBullet) {
      fill(255, 220, 50);
    } else {
      fill(255, 80, 80);
    }
    ellipse(0, 0, size, size * 0.6);

    // Bright center
    fill(255, 255, 255, 180);
    ellipse(0, 0, size * 0.4, size * 0.3);

    popMatrix();
  }
}
