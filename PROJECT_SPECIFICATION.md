# 2D Alien Encounter - Project Specification

## Overall Theme

**2D Alien Encounter** is a simple side-view 2D shooting scene. A human character stands on screen holding a gun, aims toward an alien, and shoots projectiles. 

The focus is **not** on realism or complex gameplay, but on demonstrating:
- Hierarchical character construction
- Animation
- Interaction using Processing (Java)

---

## Programming Details

### Class Structure
- **Multiple classes**: `Entity`, `Character`, `Human`, `Alien`, `Bullet`, and `Limb`
- **Three-level inheritance hierarchy**: grandparent → parent → child

### Data Structures
- **ArrayList<Bullet>** for dynamic objects (projectiles)
- **Static arrays** for fixed body parts (e.g., human limbs)

### Transformations
- Uses **pushMatrix() / popMatrix()** for hierarchical transformations

### Custom Methods
Handle various animations and behaviors:
- Arm rotation
- Alien idle movement
- Shooting mechanics

### Image Filter
- Includes a **custom image filter** applied during gameplay events

---

## User Interface & Interaction

### Mouse Interaction
- **Mouse position** aims the gun
- **Mouse click** fires bullets

### Keyboard Interaction
- **Keys** rotate the arm/gun
- **Spacebar** shoots
- **Key** resets alien position

### UI Components (4 Required)
1. **Custom ammo bar** (custom UI)
2. **Custom gun-angle slider** (custom UI)
3. **Button to reset the game** (can use Processing sample)
4. **Rollover highlight** when hovering over the alien (can use Processing sample)

---

## Game Modes

### 1. Single Enemy Mode
- One alien/enemy appears on screen
- Player shoots and kills the enemy
- Game ends when enemy is defeated

### 2. Endless Mode
- Multiple enemies continuously spawn
- Player keeps shooting and killing them
- Survival-based gameplay
- Tracks score/kills
- Game continues until player's health reaches zero

---

## Visual Design

### Human Character (Player)
- Stick figure design
- Gray circular head
- Body made of lines (limbs)
- Hierarchical arm with gun
- Health bar (green)
- Ammo counter (yellow squares)

### Alien/Enemy Character
- Stick figure design
- Gray circular head
- Body made of lines (limbs)
- Gun in hand
- Health bar (red)
- Multiple instances in endless mode

### Environment
- Simple white background
- Mode indicator text
- UI elements at bottom/side of screen

---

## Implementation Notes

### Hierarchy Requirements Met
1. **Grandparent**: `Entity` (abstract base class)
2. **Parent**: `Character` (extends Entity)
3. **Child**: `Human` and `Alien` (extend Character)

### Interface/Abstract Classes
- Abstract methods for movement and rendering
- Interface for shootable entities

### Minimum 5 Different Shapes
1. Circle (head)
2. Line (body)
3. Line (arms)
4. Line (legs)
5. Rectangle (gun)
6. Rectangle (health bars)
7. Rectangle (UI elements)

---

## Technical Implementation Checklist

- [ ] `Entity` class (grandparent - abstract)
- [ ] `Character` class (parent - extends Entity)
- [ ] `Human` class (child - extends Character)
- [ ] `Alien` class (child - extends Character)
- [ ] `Limb` class for hierarchical body parts
- [ ] `Bullet` class for projectiles
- [ ] ArrayList for bullet management
- [ ] Static array for limb storage
- [ ] pushMatrix/popMatrix stack implementation
- [ ] Mouse aiming system
- [ ] Mouse click shooting
- [ ] Keyboard controls for arm rotation
- [ ] Spacebar shooting
- [ ] Reset key functionality
- [ ] Custom ammo bar UI
- [ ] Custom gun-angle slider UI
- [ ] Reset button UI
- [ ] Rollover highlight UI
- [ ] Custom image filter
- [ ] Single enemy mode
- [ ] Endless mode with spawning
- [ ] Health system
- [ ] Collision detection
- [ ] Score tracking (endless mode)
