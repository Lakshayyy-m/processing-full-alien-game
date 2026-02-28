// ============================================================
// Alien.pde - CHILD CLASS (Level 3 of hierarchy)
// Extends GameCharacter → Entity (3-level inheritance)
// AI-controlled enemy that moves toward and shoots at the player
// ============================================================

class Alien extends GameCharacter {
  float targetX, targetY;     // Player position to aim at
  float stopX;                // X position where alien stops moving
  float bobOffset;            // Phase offset for idle bobbing
  float moveSpeed;            // Movement speed
  int shootTimer;             // Timer for AI shooting
  boolean isMoving;           // Whether alien is still walking
  float baseY;                // Ground Y (bob offset applied in display)

  // Constructor
  Alien(float spawnX, float groundY) {
    super(spawnX, groundY, 50, 20, color(50, 180, 50));
    this.facingRight = false;
    this.moveSpeed = 0.5 + random(1.0);
    this.bobOffset = random(TWO_PI);
    this.shootTimer = (int) random(90, 200);
    this.stopX = 350 + random(300);
    this.shootDelay = 20;
    this.bodyHeight = 65;
    this.headRadius = 14;
    this.gunLength = 16;
    this.baseY = groundY;
  }

  // Initialize the static Limb[] array for alien body parts
  void initLimbs() {
    limbs = new Limb[11];
    limbs[0]  = new Limb(bodyHeight, 0, 0, 0, color(50, 180, 50), 3, 0);
    limbs[1]  = new Limb(0, 0, 0, 0, color(180, 255, 180), 1, 1, headRadius*2, headRadius*2);
    limbs[2]  = new Limb(upperArmLen, 0, 0, 0, bodyColor, 2.5, 0);
    limbs[3]  = new Limb(lowerArmLen, 0, 0, 0, bodyColor, 2, 0);
    limbs[4]  = new Limb(gunLength, 0, 0, 0, color(120, 50, 50), 1, 2, 18, 6);
    limbs[5]  = new Limb(upperArmLen * 0.7, PI * 0.4, 0, 0, bodyColor, 2, 0);
    limbs[6]  = new Limb(lowerArmLen * 0.6, 0.2, 0, 0, bodyColor, 1.5, 0);
    limbs[7]  = new Limb(upperLegLen, PI/2 + 0.1, 0, 0, bodyColor, 3, 0);
    limbs[8]  = new Limb(lowerLegLen, -0.1, 0, 0, bodyColor, 2.5, 0);
    limbs[9]  = new Limb(upperLegLen, PI/2 - 0.1, 0, 0, bodyColor, 3, 0);
    limbs[10] = new Limb(lowerLegLen, 0.1, 0, 0, bodyColor, 2.5, 0);
  }

  // Set the target (player position) for aiming
  void setTarget(float tx, float ty) {
    this.targetX = tx;
    this.targetY = ty;
  }

  // Update alien AI: movement, aiming, shooting
  void update() {
    if (!alive) return;
    if (shootCooldown > 0) shootCooldown--;

    // Move toward stop position
    isMoving = x > stopX;
    if (isMoving) {
      x -= moveSpeed;
    }

    // Idle bob (applied via baseY to prevent drift)
    y = baseY + sin(frameCount * 0.03 + bobOffset) * 2;

    // Aim at player (from shoulder position)
    float shoulderY = y - bodyHeight;
    armAngle = atan2(targetY - shoulderY, targetX - x);
    // Add slight inaccuracy
    armAngle += sin(frameCount * 0.05 + bobOffset) * 0.08;

    // AI shooting logic
    shootTimer--;
    if (shootTimer <= 0 && !isMoving) {
      if (canShoot()) {
        shoot();
      }
      shootTimer = (int) random(80, 200);
    }

    // Auto-reload when out of ammo
    if (ammo <= 0) {
      reload();
    }

    updateBullets();
    animate();
  }

  // Walking and idle animation using limbs static array
  void animate() {
    if (limbs == null) return;

    if (isMoving) {
      // Walking cycle
      float walkCycle = sin(frameCount * 0.1 + bobOffset);
      limbs[7].angle = PI/2 + walkCycle * 0.3;
      limbs[8].angle = -walkCycle * 0.15;
      limbs[9].angle = PI/2 - walkCycle * 0.3;
      limbs[10].angle = walkCycle * 0.15;
      // Non-gun arm swing
      limbs[5].angle = PI * 0.4 + walkCycle * 0.2;
    } else {
      // Idle stance
      float sway = sin(frameCount * 0.04 + bobOffset) * 0.04;
      limbs[7].angle = PI/2 + 0.1 + sway;
      limbs[9].angle = PI/2 - 0.1 - sway;
      limbs[8].angle = -0.1;
      limbs[10].angle = 0.1;
      limbs[5].angle = PI * 0.4 + sin(frameCount * 0.03) * 0.05;
    }
  }

  // Interface method: fire a bullet toward the player
  void shoot() {
    if (canShoot()) {
      float totalLen = upperArmLen + lowerArmLen + gunLength + 3;
      float shoulderX = x;
      float shoulderY = y - bodyHeight;
      float tipX = shoulderX + cos(armAngle) * totalLen;
      float tipY = shoulderY + sin(armAngle) * totalLen;

      bullets.add(new Bullet(tipX, tipY, armAngle, false));
      ammo--;
      shootCooldown = shootDelay;
    }
  }

  // ---- HIERARCHICAL DISPLAY using pushMatrix/popMatrix ----
  void display() {
    if (!alive) return;

    pushMatrix();
    translate(x, y); // Position at HIP

    // === TORSO ===
    stroke(bodyColor);
    strokeWeight(limbs[0].thickness);
    line(0, 0, 0, -bodyHeight);

    // === HEAD with alien features ===
    pushMatrix();
      translate(0, -bodyHeight - headRadius);
      // Head shape
      fill(180, 255, 180);
      stroke(bodyColor);
      strokeWeight(1.5);
      ellipse(0, 0, headRadius * 2, headRadius * 2);           // Circle shape

      // Antenna stalks
      stroke(bodyColor);
      strokeWeight(2);
      line(-4, -headRadius, -10, -headRadius - 18);
      line(4, -headRadius, 10, -headRadius - 18);

      // Antenna tips (small circles)
      fill(255, 80, 80);
      noStroke();
      ellipse(-10, -headRadius - 18, 6, 6);
      ellipse(10, -headRadius - 18, 6, 6);

      // Alien ears/horns (TRIANGLE shapes)
      fill(50, 180, 50, 180);
      noStroke();
      triangle(-headRadius, -3, -headRadius - 8, -12, -headRadius - 2, -12);  // Triangle shape
      triangle(headRadius, -3, headRadius + 8, -12, headRadius + 2, -12);

      // Alien eyes (larger, oval)
      fill(20);
      noStroke();
      ellipse(-5, -2, 5, 7);
      ellipse(5, -2, 5, 7);

      // Eye glow
      fill(100, 255, 100, 100);
      ellipse(-5, -2, 3, 4);
      ellipse(5, -2, 3, 4);
    popMatrix();

    // === GUN ARM (hierarchical chain, aims at player) ===
    pushMatrix();
      translate(0, -bodyHeight);    // SHOULDER
      rotate(armAngle);             // Aim rotation

      stroke(bodyColor);
      strokeWeight(limbs[2].thickness);
      line(0, 0, upperArmLen, 0);   // Upper arm

      pushMatrix();
        translate(upperArmLen, 0);   // ELBOW

        strokeWeight(limbs[3].thickness);
        line(0, 0, lowerArmLen, 0); // Lower arm

        pushMatrix();
          translate(lowerArmLen, 0); // HAND

          // Alien gun
          fill(120, 50, 50);
          stroke(80, 30, 30);
          strokeWeight(1);
          rect(0, -3, gunLength, 6);                          // Rectangle shape

          // Gun glow tip
          if (shootCooldown > shootDelay - 3) {
            fill(255, 50, 50, 200);
            noStroke();
            ellipse(gunLength + 3, 0, 8, 8);
          }
        popMatrix();
      popMatrix();
    popMatrix();

    // === NON-GUN ARM ===
    pushMatrix();
      translate(0, -bodyHeight);
      rotate(limbs[5].angle);

      stroke(bodyColor);
      strokeWeight(limbs[5].thickness);
      line(0, 0, limbs[5].length, 0);

      pushMatrix();
        translate(limbs[5].length, 0);
        rotate(limbs[6].angle);
        strokeWeight(limbs[6].thickness);
        line(0, 0, limbs[6].length, 0);
      popMatrix();
    popMatrix();

    // === RIGHT LEG ===
    pushMatrix();
      translate(-7, 0);
      rotate(limbs[7].angle);

      stroke(bodyColor);
      strokeWeight(limbs[7].thickness);
      line(0, 0, limbs[7].length, 0);

      pushMatrix();
        translate(limbs[7].length, 0);
        rotate(limbs[8].angle);
        strokeWeight(limbs[8].thickness);
        line(0, 0, limbs[8].length, 0);
      popMatrix();
    popMatrix();

    // === LEFT LEG ===
    pushMatrix();
      translate(7, 0);
      rotate(limbs[9].angle);

      stroke(bodyColor);
      strokeWeight(limbs[9].thickness);
      line(0, 0, limbs[9].length, 0);

      pushMatrix();
        translate(limbs[9].length, 0);
        rotate(limbs[10].angle);
        strokeWeight(limbs[10].thickness);
        line(0, 0, limbs[10].length, 0);
      popMatrix();
    popMatrix();

    popMatrix(); // End CHARACTER transform

    // Health bar (red)
    drawHealthBar(50, 5, color(200, 50, 50));

    // Draw alien bullets
    drawBullets();
  }
}
