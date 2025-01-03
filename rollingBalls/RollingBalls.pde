ArrayList<Ball> balls = new ArrayList<Ball>(); // List to store all balls
float circleRadius = 380;
float holeAngle = 0; // Angle of the hole along the radius
float holeWidth = 0.8; // Angular width of the hole (in radians)
float rotationSpeed = 0.08; // Speed of rotation

void setup() {
  size(1024, 768);
  // Add a few initial balls
  balls.add(new Ball(width / 2 - 30, height / 2, random(-3, 3), random(-3, 3), 20));
  balls.add(new Ball(width / 2 + 30, height / 2, random(-3, 3), random(-3, 3), 20));
}

void draw() {
  background(0);

  // Update the hole angle to make the hole rotate
  holeAngle += rotationSpeed;
  if (holeAngle > TWO_PI) holeAngle -= TWO_PI;

  // Draw the rotating circle with the hole
  drawRotatingCircle();

  // Update and draw all balls
  for (int i = balls.size() - 1; i >= 0; i--) {
    Ball ball = balls.get(i);
    ball.update();
    ball.draw();

    // If the ball is completely out of the screen, remove it
    if (ball.isCompletelyOutside()) {
      balls.remove(i);
    }
  }

  // Check for collisions between all pairs of balls
  for (int i = 0; i < balls.size(); i++) {
    for (int j = i + 1; j < balls.size(); j++) {
      checkBallCollision(balls.get(i), balls.get(j));
    }
  }
}

void mousePressed() {
  // Add a new ball at the mouse position with random velocity
  balls.add(new Ball(mouseX, mouseY, random(-3, 3), random(-3, 3), 20));
}

void drawRotatingCircle() {
  noFill();
  stroke(255);
  strokeWeight(3);

  // Calculate the start and end angle of the hole
  float startAngle = holeAngle - holeWidth / 2;
  float endAngle = holeAngle + holeWidth / 2;

  // Normalize angles to ensure proper rotation
  startAngle = (startAngle + TWO_PI) % TWO_PI;
  endAngle = (endAngle + TWO_PI) % TWO_PI;

  // Draw the circle, skipping the hole region
  for (float a = 0; a < TWO_PI; a += 0.01) {
    // Check if the current angle is outside the hole area
    boolean skipHole = false;

    if (startAngle < endAngle) {
      // Case where the hole does not wrap around the circle
      if (a > startAngle && a < endAngle) {
        skipHole = true;
      }
    } else {
      // Case where the hole wraps around the circle
      if (a > startAngle || a < endAngle) {
        skipHole = true;
      }
    }

    // If we're not in the hole region, draw the circle
    if (!skipHole) {
      float x = width / 2 + cos(a) * circleRadius;
      float y = height / 2 + sin(a) * circleRadius;
      point(x, y);
    }
  }
}

class Ball {
  float x, y, vx, vy, radius;
  boolean escaped = false;  // Track if the ball has escaped the circle

  Ball(float x, float y, float vx, float vy, float radius) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.radius = radius;
  }

  void update() {
    // Apply gravity
    vy += 0.2;

    // Update position
    x += vx;
    y += vy;

    // Check if the ball is outside the circle
    float distFromCenter = dist(x, y, width / 2, height / 2);

    if (distFromCenter + radius > circleRadius) {
      // If the ball is outside the circle, we need to handle the bounce
      float angle = atan2(y - height / 2, x - width / 2);
      if (angle < 0) angle += TWO_PI; // Normalize angle to [0, TWO_PI]

      // Check if the ball is in the hole region
      if (abs(angle - holeAngle) < holeWidth / 2 || distFromCenter > circleRadius) {
        escaped = true;
        return; // Ball escapes through the hole
      } else {
        // Bounce off the circle boundary (on the outside)
        float overlap = distFromCenter + radius - circleRadius;
        x -= overlap * cos(angle);
        y -= overlap * sin(angle);

        // Calculate the normal vector at the point of collision (towards the outside)
        float normalX = cos(angle);
        float normalY = sin(angle);

        // Reflect the velocity along the normal (away from the circle)
        float dot = vx * normalX + vy * normalY;
        vx -= 2 * dot * normalX;
        vy -= 2 * dot * normalY;
      }
    }
  }

  void draw() {
    fill(255);
    noStroke();
    ellipse(x, y, radius * 2, radius * 2);
  }

  boolean isCompletelyOutside() {
    // If the ball is far enough out of the screen in both directions, it's completely outside
    return (x < 0 || x > width || y < 0 || y > height);
  }
}

void checkBallCollision(Ball b1, Ball b2) {
  float dx = b2.x - b1.x;
  float dy = b2.y - b1.y;
  float dist = sqrt(dx * dx + dy * dy);

  if (dist < b1.radius + b2.radius) {
    float normalX = dx / dist;
    float normalY = dy / dist;

    float relVX = b2.vx - b1.vx;
    float relVY = b2.vy - b1.vy;

    float dot = relVX * normalX + relVY * normalY;

    b1.vx += dot * normalX;
    b1.vy += dot * normalY;
    b2.vx -= dot * normalX;
    b2.vy -= dot * normalY;

    // Resolve overlap
    float overlap = b1.radius + b2.radius - dist;
    b1.x -= overlap / 2 * normalX;
    b1.y -= overlap / 2 * normalY;
    b2.x += overlap / 2 * normalX;
    b2.y += overlap / 2 * normalY;
  }
}
