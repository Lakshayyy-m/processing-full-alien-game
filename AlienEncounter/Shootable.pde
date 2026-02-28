// ============================================================
// Shootable.pde - INTERFACE CLASS
// Defines contract for entities that can shoot projectiles
// ============================================================

interface Shootable {
  void shoot();
  boolean canShoot();
  void reload();
}
