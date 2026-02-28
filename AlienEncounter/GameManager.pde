// ============================================================
// GameManager.pde - GAME STATE MANAGER
// Controls game flow, modes, collision detection, spawning
// ============================================================

class GameManager {
  // Game states
  static final int STATE_MENU    = 0;
  static final int STATE_PLAYING = 1;
  static final int STATE_GAMEOVER = 2;
  static final int STATE_VICTORY = 3;

  // Game modes
  static final int MODE_SINGLE  = 0;
  static final int MODE_ENDLESS = 1;

  int gameState;
  int gameMode;

  // Game entities
  Human player;
  ArrayList<Alien> aliens;
  Tree[] trees;              // STATIC ARRAY for environment

  // UI components (4 total: 2 custom + 2 sample)
  AmmoBar ammoBar;           // Custom UI #1
  GunAngleSlider gunSlider;  // Custom UI #2
  ResetButton resetButton;   // Sample UI #3
  RolloverEffect rollover;   // Sample UI #4

  // Menu buttons
  ResetButton singleBtn;
  ResetButton endlessBtn;

  ImageFilter imgFilter;

  // Game variables
  int score;
  int spawnTimer;
  int groundY;
  int alienDifficulty;
  float starfieldOffset;

  // Constructor
  GameManager() {
    groundY = 480;
    gameState = STATE_MENU;
    gameMode = MODE_SINGLE;
    score = 0;
    starfieldOffset = 0;

    // Initialize background trees (static array)
    trees = new Tree[3];
    trees[0] = new Tree(550, groundY, 110);
    trees[1] = new Tree(780, groundY, 75);
    trees[2] = new Tree(340, groundY, 95);

    // Initialize UI components
    ammoBar     = new AmmoBar(20, 530, 220, 18);
    gunSlider   = new GunAngleSlider(20, 566, 180, 14);
    resetButton = new ResetButton(860, 545, 120, 32, "RESET GAME");
    rollover    = new RolloverEffect();
    imgFilter   = new ImageFilter();

    // Menu buttons
    singleBtn  = new ResetButton(320, 310, 160, 50, "Single Enemy",
                   color(40, 80, 40), color(60, 120, 60), color(220));
    endlessBtn = new ResetButton(520, 310, 160, 50, "Endless Mode",
                   color(80, 40, 40), color(120, 60, 60), color(220));
  }

  // Start a new game with the chosen mode
  void startGame(int mode) {
    gameMode = mode;
    gameState = STATE_PLAYING;
    score = 0;
    alienDifficulty = 0;

    // Create player at left side of screen
    player = new Human(150, groundY);
    aliens = new ArrayList<Alien>();

    // Spawn initial alien(s)
    if (mode == MODE_SINGLE) {
      Alien a = new Alien(800, groundY);
      a.health = 100;     // Tougher in single mode
      a.maxHealth = 100;
      aliens.add(a);
      spawnTimer = -1;     // No respawning
    } else {
      spawnAlien();
      spawnTimer = 200;
    }

    imgFilter.setGrayscale(false);
    imgFilter.redIntensity = 0;
    imgFilter.greenIntensity = 0;
  }

  // Spawn a new alien at the right edge
  void spawnAlien() {
    float spawnX = width + 30 + random(60);
    Alien a = new Alien(spawnX, groundY);

    // Scale difficulty in endless mode
    a.health = 30 + alienDifficulty * 3;
    a.maxHealth = a.health;
    a.moveSpeed = 0.6 + random(0.8) + alienDifficulty * 0.05;

    aliens.add(a);
  }

  // ---- MAIN UPDATE ----
  void update() {
    if (gameState != STATE_PLAYING) return;

    // Aim gun at mouse (unless slider is being dragged)
    if (!gunSlider.dragging) {
      player.aimAt(mouseX, mouseY);
    }

    player.update();

    // Update and process aliens
    for (int i = aliens.size() - 1; i >= 0; i--) {
      Alien a = aliens.get(i);
      a.setTarget(player.x, player.y - player.bodyHeight / 2);
      a.update();

      // --- Player bullets hitting this alien ---
      for (int j = player.bullets.size() - 1; j >= 0; j--) {
        Bullet b = player.bullets.get(j);
        float hitDist = dist(b.x, b.y, a.x, a.y - a.bodyHeight / 2);
        if (hitDist < 40) {
          a.takeDamage(b.damage);
          b.alive = false;
          player.bullets.remove(j);

          if (!a.isAlive()) {
            score += 100;
            alienDifficulty++;
            aliens.remove(i);
            break;
          }
        }
      }

      // --- Alien bullets hitting the player ---
      if (i < aliens.size() && aliens.get(i).isAlive()) {
        Alien al = aliens.get(i);
        for (int j = al.bullets.size() - 1; j >= 0; j--) {
          Bullet b = al.bullets.get(j);
          float hitDist = dist(b.x, b.y, player.x, player.y - player.bodyHeight / 2);
          if (hitDist < 35) {
            player.takeDamage(b.damage);
            b.alive = false;
            al.bullets.remove(j);
            imgFilter.triggerDamageFlash();

            if (!player.isAlive()) {
              gameState = STATE_GAMEOVER;
              imgFilter.setGrayscale(true);
            }
          }
        }
      }
    }

    // Remove dead aliens that may have been missed
    for (int i = aliens.size() - 1; i >= 0; i--) {
      if (!aliens.get(i).isAlive()) {
        aliens.remove(i);
      }
    }

    // Victory check (single mode)
    if (gameMode == MODE_SINGLE && aliens.isEmpty() && gameState == STATE_PLAYING) {
      gameState = STATE_VICTORY;
    }

    // Endless mode spawning
    if (gameMode == MODE_ENDLESS && gameState == STATE_PLAYING) {
      spawnTimer--;
      if (spawnTimer <= 0) {
        spawnAlien();
        // Spawn faster as difficulty increases
        spawnTimer = max(70, 200 - alienDifficulty * 8);
      }

      // Auto-reload in endless mode
      if (player.ammo <= 0 && !player.isReloading) {
        player.startReload();
      }
    }

    // Update environment
    for (int i = 0; i < trees.length; i++) {
      trees[i].update();
    }

    imgFilter.update();
  }

  // ---- MAIN DISPLAY ----
  void display() {
    // Sky gradient background
    drawBackground();

    if (gameState == STATE_MENU) {
      drawMenuTrees();
      displayMenu();
    } else {
      displayGame();

      if (gameState == STATE_GAMEOVER) {
        displayGameOver();
      } else if (gameState == STATE_VICTORY) {
        displayVictory();
      }
    }

    // Always draw a simple cursor so user can see pointer
    drawCursor();

    // Apply pixel-level image filter (damage flash / grayscale)
    imgFilter.apply();
  }

  // Draw gradient sky and ground
  void drawBackground() {
    // Sky gradient
    for (int i = 0; i < groundY; i++) {
      float t = map(i, 0, groundY, 0, 1);
      color c = lerpColor(color(15, 15, 40), color(35, 45, 65), t);
      stroke(c);
      line(0, i, width, i);
    }

    // Stars (subtle)
    noStroke();
    fill(255, 255, 255, 60);
    randomSeed(42); // Consistent star pattern
    for (int i = 0; i < 50; i++) {
      float sx = random(width);
      float sy = random(groundY * 0.7);
      float sz = random(1, 2.5);
      float twinkle = sin(frameCount * 0.02 + i) * 0.5 + 0.5;
      fill(255, 255, 255, 30 + twinkle * 50);
      ellipse(sx, sy, sz, sz);
    }
    randomSeed(millis()); // Restore random

    // Ground
    fill(40, 55, 35);
    noStroke();
    rect(0, groundY, width, height - groundY);

    // Ground line
    stroke(60, 85, 50);
    strokeWeight(2);
    line(0, groundY, width, groundY);

    // Ground texture lines
    stroke(50, 70, 40, 80);
    strokeWeight(1);
    for (int i = 0; i < width; i += 40) {
      line(i, groundY + 5, i + 20, groundY + 5);
    }
  }

  // Draw trees on menu screen
  void drawMenuTrees() {
    for (int i = 0; i < trees.length; i++) {
      trees[i].update();
      trees[i].display();
    }
  }

  // Display menu screen
  void displayMenu() {
    // Title shadow
    fill(0, 0, 0, 100);
    textSize(46);
    textAlign(CENTER, CENTER);
    text("2D ALIEN ENCOUNTER", width / 2 + 2, 142);

    // Title
    fill(100, 220, 100);
    text("2D ALIEN ENCOUNTER", width / 2, 140);

    // Subtitle
    fill(180);
    textSize(18);
    text("A Hierarchical 2D Shooting Game", width / 2, 190);

    // Decorative line
    stroke(100, 220, 100, 100);
    strokeWeight(1);
    line(width / 2 - 180, 215, width / 2 + 180, 215);

    // Mode selection label
    fill(200);
    textSize(20);
    text("Choose Game Mode:", width / 2, 270);

    // Mode buttons
    singleBtn.display();
    endlessBtn.display();

    // Mode descriptions
    fill(150);
    textSize(12);
    text("Defeat one alien enemy", 400, 375);
    text("Survive endless waves", 600, 375);

    // Controls info
    fill(140);
    textSize(13);
    text("Controls:", width / 2, 420);
    textSize(11);
    fill(120);
    text("Mouse: Aim  |  Click / Space: Shoot  |  E: Reload  |  ↑↓: Fine-tune angle  |  R: Reset alien", width / 2, 445);
    text("Press 1: Single Mode  |  Press 2: Endless Mode", width/2, 465);
  }

  // Display the active game
  void displayGame() {
    // Background trees
    for (int i = 0; i < trees.length; i++) {
      trees[i].display();
    }

    // Draw player
    player.display();

    // Draw aliens and check rollover
    rollover.reset();
    for (Alien a : aliens) {
      if (a.isAlive()) {
        a.display();
        // Check rollover for each alive alien
        rollover.checkRollover(a.x, a.y - a.bodyHeight / 2, 45);
      }
    }

    // Draw rollover highlight
    rollover.display();

    // Draw aiming crosshair
    if (gameState == STATE_PLAYING) {
      drawCrosshair();
    }

    // Draw UI panel
    drawUI();
  }

  // Draw crosshair at mouse position (during gameplay)
  void drawCrosshair() {
    noFill();
    stroke(255, 255, 0, 150);
    strokeWeight(1);
    float cSize = 12;
    // Cross lines
    line(mouseX - cSize, mouseY, mouseX + cSize, mouseY);
    line(mouseX, mouseY - cSize, mouseX, mouseY + cSize);
    // Outer ring
    ellipse(mouseX, mouseY, cSize * 2.5, cSize * 2.5);
  }

  // Draw a simple cursor arrow (menu / game-over screens)
  void drawCursor() {
    if (gameState == STATE_MENU || gameState == STATE_GAMEOVER || gameState == STATE_VICTORY) {
      fill(255, 255, 255, 200);
      noStroke();
      triangle(mouseX, mouseY, mouseX, mouseY + 14, mouseX + 10, mouseY + 10);
      stroke(0, 0, 0, 150);
      strokeWeight(1);
      noFill();
      triangle(mouseX, mouseY, mouseX, mouseY + 14, mouseX + 10, mouseY + 10);
    }
  }

  // Draw the UI panel at the bottom
  void drawUI() {
    // UI panel background
    fill(15, 15, 25, 220);
    noStroke();
    rect(0, 515, width, 85);

    // Separator line
    stroke(60, 60, 80);
    strokeWeight(1);
    line(0, 515, width, 515);

    // Ammo bar (Custom UI #1)
    ammoBar.display(player.ammo, player.maxAmmo, player.isReloading);

    // Gun angle slider (Custom UI #2)
    gunSlider.display(player.gunAngle);

    // Handle slider dragging
    if (gunSlider.dragging) {
      player.gunAngle = gunSlider.handleDrag();
    }

    // Reset button (Sample UI #3)
    resetButton.display();

    // Score display
    fill(255);
    textSize(16);
    textAlign(LEFT, TOP);
    text("SCORE: " + score, 20, 15);

    // Mode indicator
    String modeText = (gameMode == MODE_SINGLE) ? "SINGLE ENEMY" : "ENDLESS MODE";
    color modeColor = (gameMode == MODE_SINGLE) ? color(100, 200, 255) : color(255, 150, 100);
    fill(modeColor);
    textSize(14);
    textAlign(CENTER, TOP);
    text(modeText, width / 2, 15);

    // Health display
    fill(player.getHealthPercent() > 0.3 ? color(100, 255, 100) : color(255, 80, 80));
    textSize(14);
    textAlign(RIGHT, TOP);
    text("HP: " + (int)player.health + "/" + (int)player.maxHealth, width - 20, 15);

    // Aliens alive count (endless mode)
    if (gameMode == MODE_ENDLESS) {
      fill(200);
      textSize(12);
      textAlign(RIGHT, TOP);
      text("Aliens: " + aliens.size(), width - 20, 35);
    }

    // Controls reminder
    fill(80);
    textSize(9);
    textAlign(CENTER, BOTTOM);
    text("[Space/Click] Shoot   [E] Reload   [↑↓] Adjust   [R] Reset alien   [1/2] Mode", width / 2, height - 3);
  }

  // Game over overlay
  void displayGameOver() {
    // Dark overlay
    fill(0, 0, 0, 160);
    noStroke();
    rect(0, 0, width, height);

    // Game over text
    fill(255, 60, 60);
    textSize(52);
    textAlign(CENTER, CENTER);
    text("GAME OVER", width / 2, height / 2 - 50);

    // Score
    fill(255);
    textSize(26);
    text("Final Score: " + score, width / 2, height / 2 + 10);

    // Instructions
    fill(180);
    textSize(15);
    text("Click RESET or press R to return to menu", width / 2, height / 2 + 55);
  }

  // Victory overlay
  void displayVictory() {
    // Light overlay
    fill(0, 0, 0, 100);
    noStroke();
    rect(0, 0, width, height);

    // Victory text
    fill(80, 255, 80);
    textSize(52);
    textAlign(CENTER, CENTER);
    text("VICTORY!", width / 2, height / 2 - 50);

    // Message
    fill(255);
    textSize(22);
    text("You defeated the alien!", width / 2, height / 2 + 10);

    // Instructions
    fill(180);
    textSize(15);
    text("Click RESET or press R to return to menu", width / 2, height / 2 + 55);
  }

  // ---- INPUT HANDLERS ----

  void handleMousePressed() {
    if (gameState == STATE_MENU) {
      singleBtn.press();
      endlessBtn.press();
    } else if (gameState == STATE_PLAYING) {
      // Check UI interactions first
      if (resetButton.isMouseOver()) {
        resetButton.press();
      } else if (gunSlider.isMouseOver()) {
        gunSlider.press();
      } else {
        // Shoot if clicking in game area
        player.shoot();
      }
    } else {
      // Game over or victory
      resetButton.press();
    }
  }

  void handleMouseReleased() {
    // Menu buttons
    if (gameState == STATE_MENU) {
      if (singleBtn.release()) {
        startGame(MODE_SINGLE);
        return;
      }
      if (endlessBtn.release()) {
        startGame(MODE_ENDLESS);
        return;
      }
    }

    // Reset button (available in all states except menu)
    if (gameState != STATE_MENU) {
      if (resetButton.release()) {
        resetToMenu();
        return;
      }
    }

    // Release slider drag
    gunSlider.release();
  }

  void handleMouseDragged() {
    if (gameState == STATE_PLAYING && gunSlider.dragging) {
      player.gunAngle = gunSlider.handleDrag();
    }
  }

  void handleKeyPressed() {
    // Mode selection from any state
    if (key == '1') { startGame(MODE_SINGLE); return; }
    if (key == '2') { startGame(MODE_ENDLESS); return; }

    if (gameState == STATE_PLAYING) {
      // Shoot
      if (key == ' ') {
        player.shoot();
      }

      // Reload
      if (key == 'e' || key == 'E') {
        player.startReload();
      }

      // Fine-tune gun angle with arrow keys
      if (keyCode == UP) {
        player.gunAngle = constrain(player.gunAngle - 0.05, -PI/2, PI/3);
      }
      if (keyCode == DOWN) {
        player.gunAngle = constrain(player.gunAngle + 0.05, -PI/2, PI/3);
      }

      // Reset alien positions
      if (key == 'r' || key == 'R') {
        for (Alien a : aliens) {
          a.x = 700 + random(200);
          a.y = groundY;
          a.health = a.maxHealth;
          a.alive = true;
        }
      }
    }

    // Reset from game over / victory
    if (gameState == STATE_GAMEOVER || gameState == STATE_VICTORY) {
      if (key == 'r' || key == 'R') {
        resetToMenu();
      }
    }
  }

  // Return to main menu
  void resetToMenu() {
    gameState = STATE_MENU;
    imgFilter.setGrayscale(false);
    imgFilter.redIntensity = 0;
    imgFilter.greenIntensity = 0;
    score = 0;
  }
}
