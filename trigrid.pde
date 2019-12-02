color[] colors = {
  #1a2d4f, 
  #9d3490, 
  #9d5634, 
  #349d80 };
color line = color(120, 120, 120, 40);

int[] states;
int rows, cols;

int sideLength = 50;
PMatrix2D C, Ci;

void setup() {
  // default renderer has gaps between adjacent triangles
  // size(screen.width, screen.height);
  size(957, 543, P2D);

  noLoop();

  // each equilateral triangle with sideLength int the standard basis
  // becomes half of a unit square in the basis formed by the cols of C
  C = new PMatrix2D(sqrt(3)/2*sideLength, 0, 0, -sideLength/2, sideLength, 0);
  Ci = C.get();
  Ci.invert();

  // finds number of triangles need to cover the window
  int[] corner = toTriGrid(width, 0);
  cols = corner[0] + 1;
  corner = toTriGrid(0, height);
  rows = corner[1] + 1;
  states = new int[cols * rows * 2];
  print(cols, rows);

  redraw();
}

// Takes an XY coordinate and returns the coordinates of the 
// containing triangle in the C basis and direction
int[] toTriGrid(int x, int y) {
  float u = Ci.multX(x, y);
  float v = Ci.multY(x, y);
  int[] coord = { int(u), int(v), 0 };
  if (u - floor(u) > v - floor(v)) {
    coord[2] = 1;
  }
  return coord;
}

// Takes the coordinate in the C basis, direction and state of
// a triangle and draws in the XY plane
void drawTri(int u, int v, int w, int state) {
  beginShape();
  fill(colors[state]);
  if (state == 0) {
    strokeWeight(0.5);
    stroke(line);
  } else {
    strokeWeight(1);
    stroke(colors[state]);
  }
  vertex(C.multX(u, v), C.multY(u, v));
  vertex(C.multX(u+1, v+1), C.multY(u+1, v+1));
  vertex(C.multX(u+w, v+1-w), C.multY(u+w, v+1-w));
  endShape(CLOSE);
}

void mousePressed() {
  int[] c = toTriGrid(mouseX, mouseY);
  // triGrid coordinates (u, v) for triangles in the window 
  // follow 0 <= u < cols, u/2 <= v < u/2+rows
  // index insures position in states[] matches 2*rows*i + 2*j,
  // where 0 <= i < cols, 0 <= j < cols to remove empty space in array
  int index = 2*rows*c[0] + 2*c[1] - int(c[0]/2)*2 + c[2];
  // cycles 0, 1, 2, 3, 0, 1, ...
  states[index] = (states[index] < 3) ? states[index] + 1 : 0;
  redraw();
}

void draw() {
  background(colors[0]);
  for (int i = 0; i < cols; i++)
    for (int j = 0; j < rows; j++) {
      int index = 2*rows*i + 2*j;
      drawTri(i, j + int(i/2), 0, states[index]);
      drawTri(i, j + int(i/2), 1, states[index + 1]);
    }
}
