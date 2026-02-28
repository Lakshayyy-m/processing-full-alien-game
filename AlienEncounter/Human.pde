// ============================================================
// Human.pde - CHILD CLASS (Level 3 of hierarchy)
// Extends GameCharacter → Entity (3-level inheritance)
// Player-controlled human character with gun aiming
// ============================================================

class Human extends GameCharacter {
  // Limb indices in the static array:
  // 0: body(torso), 1: head, 2: R upper arm, 3: R lower arm
  // 4: gun, 5: L upper arm, 6: L lower arm
  // 7: R upper leg, 8: R lower leg, 9: L upper leg, 10: L lower leg

  float gunAngle;        // Aim angle controlled by mouse/slider
  int reloadTimer;       // Timer for reload delay
  boolean isReloading;

  // Constructor - position is the HIP location
  Human(float x, float y) {
    super(x, y, 100, 30, color(70, 130, 180));
    this.gunAngle = 0;
    this.facingRight = true;
    this.shootDelay = 10;
    this.reloadTimer = 0;
    this.isReloading = false;
  }

  // Initialize the static Limb[] array with 11 body parts
  void initLimbs() {
    limbs = new Limb[11];
    limbs[0]  = new Limb(bodyHeight, 0, 0, 0, color(70, 130, 180), 3, 0);                    // torso
    limbs[1]  = new Limb(0, 0, 0, 0, color(200, 200, 210), 1, 1, headRadius*2, headRadius*2); // head
    limbs[2]  = new Limb(upperArmLen, 0, 0, 0, bodyColor, 3, 0);                              // R upper arm
    limbs[3]  = new Limb(lowerArmLen, 0, 0, 0, bodyColor, 2.5, 0);                            // R lower arm
    limbs[4]  = new Limb(gunLength, 0, 0, 0, color(80), 1, 2, 22, 8);                         // gun
    limbs[5]  = new Limb(upperArmLen * 0.8, PI * 0.6, 0, 0, bodyColor, 2, 0);                 // L upper arm
    limbs[6]  = new Limb(lowerArmLen * 0.7, 0.3, 0, 0, bodyColor, 2, 0);                      // L lower arm
    limbs[7]  = new Limb(upperLegLen, PI/2 + 0.15, 0, 0, bodyColor, 3, 0);                    // R upper leg
    limbs[8]  = new Limb(lowerLegLen, -0.15, 0, 0, bodyColor, 2.5, 0);                        // R lower leg
    limbs[9]  = new Limb(upperLegLen, PI/2 - 0.15, 0, 0, bodyColor, 3, 0);                    // L upper leg
    limbs[10] = new Limb(lowerLegLen, 0.15, 0, 0, bodyColor, 2.5, 0);                         // L lower leg
  }

  // Update player state
  void update() {
    if (!alive) return;

    if (shootCooldown > 0) shootCooldown--;

    // Handle reload timer
    if (isReloading) {
      reloadTimer--;
      if (reloadTimer <= 0) {
        ammo = maxAmmo;
        isReloading = false;
      }
    }

    updateBullets();
    animate();
  }

  // Idle animation: subtle leg sway
  void animate() {
    if (limbs == null) return;
    float sway = sin(frameCount * 0.05) * 0.05;
    limbs[7].angle = PI/2 + 0.15 + sway;
    limbs[9].angle = PI/2 - 0.15 - sway;

    // Subtle left arm sway
    limbs[5].angle = PI * 0.6 + sin(frameCount * 0.03) * 0.03;
  }

  // Aim gun toward a target point (mouse position)
  void aimAt(float targetX, float targetY) {
    float shoulderX = x;
    float shoulderY = y - bodyHeight;
    gunAngle = atan2(targetY - shoulderY, targetX - shoulderX);
    gunAngle = constrain(gunAngle, -PI/2, PI/3);
  }

  // Interface method: fire a bullet from the gun tip
  void shoot() {
    if (canShoot() && !isReloading) {
      float totalLen = upperArmLen + lowerArmLen + gunLength + 5;
      float shoulderX = x;
      float shoulderY = y - bodyHeight;
      float tipX = shoulderX + cos(gunAngle) * totalLen;
      float tipY = shoulderY + sin(gunAngle) * totalLen;

      bullets.add(new Bullet(tipX, tipY, gunAngle, true));
      ammo--;
      shootCooldown = shootDelay;
    }
  }

  // Start reload process
  void startReload() {
    if (!isReloading && ammo < maxAmmo) {
      isReloading = true;
      reloadTimer = 45; // ~0.75 seconds at 60fps
    }
  }

  // ---- HIERARCHICAL DISPLAY using pushMatrix/popMatrix ----
  void display() {
    if (!alive) return;

    pushMatrix();
    translate(x, y); // Position at HIP

    // === TORSO (body line from hip UP to shoulder) ===
    stroke(bodyColor);
    strokeWeight(limbs[0].thickness);
    line(0, 0, 0, -bodyHeight);

    // === HEAD (circle at top) ===
    pushMatrix();
      translate(0, -bodyHeight - headRadius);
      fill(200, 200, 210);
      stroke(bodyColor);
      strokeWeight(1.5);
      ellipse(0, 0, headRadius * 2, headRadius * 2);        // Shape 1: Circle
      // Eyes
      fill(40);
      noStroke();
      ellipse(-4, -2, 3, 3);
      ellipse(4, -2, 3, 3);
      // Mouth
      stroke(80);
      strokeWeight(1);
      line(-3, 4, 3, 4);                                     // Shape 2: Line
    popMatrix();

    // === RIGHT ARM - GUN ARM (hierarchical chain) ===
    pushMatrix();
      translate(0, -bodyHeight);          // Move to SHOULDER
      rotate(gunAngle);                   // Rotate entire arm chain

      // Upper arm
      stroke(bodyColor);
      strokeWeight(limbs[2].thickness);
      line(0, 0, upperArmLen, 0);                            // Shape 2: Line

      pushMatrix();
        translate(upperArmLen, 0);        // Move to ELBOW

        // Lower arm (forearm)
        strokeWeight(limbs[3].thickness);
        line(0, 0, lowerArmLen, 0);

        pushMatrix();
          translate(lowerArmLen, 0);      // Move to HAND

          // Gun body
          fill(80, 80, 90);
          stroke(50);
          strokeWeight(1);
          rect(0, -4, gunLength, 8);                         // Shape 3: Rectangle

          // Gun barrel (extended)
          fill(60, 60, 70);
          rect(gunLength - 2, -2.5, 10, 5);

          // Muzzle flash hint
          if (shootCooldown > shootDelay - 3) {
            fill(255, 200, 50, 200);
            noStroke();
            triangle(gunLength + 8, -5, gunLength + 15, 0, gunLength + 8, 5); // Shape 4: Triangle
          }

        popMatrix();                     // End HAND
      popMatrix();                       // End ELBOW
    popMatrix();                         // End SHOULDER (right arm)

    // === LEFT ARM (non-gun arm, hanging) ===
    pushMatrix();
      translate(0, -bodyHeight);          // SHOULDER
      rotate(limbs[5].angle);             // Hanging angle from limbs array

      stroke(bodyColor);
      strokeWeight(limbs[5].thickness);
      line(0, 0, limbs[5].length, 0);

      pushMatrix();
        translate(limbs[5].length, 0);    // ELBOW
        rotate(limbs[6].angle);
        strokeWeight(limbs[6].thickness);
        line(0, 0, limbs[6].length, 0);
      popMatrix();
    popMatrix();

    // === RIGHT LEG (hierarchical: upper → knee → lower) ===
    pushMatrix();
      translate(-8, 0);                   // Offset from HIP center
      rotate(limbs[7].angle);             // Angle from limbs static array

      stroke(bodyColor);
      strokeWeight(limbs[7].thickness);
      line(0, 0, limbs[7].length, 0);     // Upper leg

      pushMatrix();
        translate(limbs[7].length, 0);     // KNEE
        rotate(limbs[8].angle);
        strokeWeight(limbs[8].thickness);
        line(0, 0, limbs[8].length, 0);   // Lower leg
      popMatrix();
    popMatrix();

    // === LEFT LEG ===
    pushMatrix();
      translate(8, 0);
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

    // Health bar (green)
    drawHealthBar(60, 6, color(50, 200, 50));

    // Draw bullets
    drawBullets();

    // Reload indicator
    if (isReloading) {
      fill(255, 200, 50);
      textSize(12);
      textAlign(CENTER);
      text("RELOADING...", x, y - bodyHeight - headRadius * 2 - 35);
    }
  }
}
