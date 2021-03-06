import java.awt.*;
import java.awt.event.*;
import java.awt.geom.*;
import java.io.*;
import java.util.*;
import javax.imageio.*;
import javax.swing.*;

public class Grid {
  protected int _radius, _hexCount;
  protected double _centerX, _centerY, _hexRadius;
  protected Hex[][][] _grid;
  protected ArrayList<Hex> _list, _active;

  public Grid(int radius, int width, int height) {
    _radius = radius;
    _hexCount = numHexes(radius);
    _grid = new Hex[2 * radius + 1][2 * radius + 1][2 * radius + 1];
    _list = new ArrayList<Hex>();
    _active = new ArrayList<Hex>();
    _centerX = width / 2.0;
    _centerY = height / 2.0;
    _hexRadius = (double) (Math.min(width, height) * 0.75) / (4 * radius);

    // Uses hex coordinates; see http://www.redblobgames.com/grids/hexagons
    for (int x = 0; x < 2 * radius + 1; x++) {
      for (int y = 0; y < 2 * radius + 1; y++) { 
        for (int z = 0; z < 2 * radius + 1; z++) { 
          if (isHex(x, y, z)) {
            double hexCenterX = _centerX + (x - radius) * 1.5 * _hexRadius;
            double hexCenterY = _centerY + (y - z) * Math.sqrt(3) / 2 * _hexRadius;
            _grid[x][y][z] = new Hex(x, y, z,
                                     hexCenterX, hexCenterY, _hexRadius);
            _list.add(_grid[x][y][z]);
          }
        }
      }
    }
  }

  // Recursive method to find number of hexes in a grid of a given radius
  public int numHexes(int r) {
    if (r == 0)
      return 1;

    return 6 * r + numHexes(r - 1);
  }

  // Determines whether (x, y, z) point to a valid hex
  public boolean isHex(int x, int y, int z) {
    return ((x >= 0 && x < 2 * _radius + 1) &&
            (y >= 0 && y < 2 * _radius + 1) &&
            (z >= 0 && z < 2 * _radius + 1)) && x + y + z == 3 * _radius;
  }

  public int getRadius() {
    return _radius;
  }

  public int getHexCount() {
    return _hexCount;
  }

  public Hex getHex(int x, int y, int z) {
    return _grid[x][y][z];
  }

  public double getHexRadius() {
    return _hexRadius;
  }

  // Converts cube coordinates to pixel coordinates; unused
  public double[] cubeToPixel(int x, int y, int z) {
    double[] ret = new double[2];
    ret[0] = _centerX + x * 1.5 * _hexRadius;
    ret[1] = _centerY + (y - z) * Math.sqrt(3) / 2 * _hexRadius;
    return ret;
  }

  // Converts pixel coordinates to cube coordinates; unused
  public int[] pixelToCube(double xcor, double ycor) {
    int[] ret = new int[3];
    ret[0] = (int) ((xcor - _centerX) / (1.5 * _hexRadius));
    ret[1] = (int) ((ycor - _centerY) * (2 * _hexRadius / Math.sqrt(3)) - 2 * ret[0]);
    ret[2] = -ret[0] - ret[1];
    return ret;
  }

  // Determines which hex is being hovered over
  public Hex whichHex(double xcor, double ycor) {
    for (Hex hex : _list)
      if (hex.contains(xcor, ycor))
        return hex;

    return null;
  }

  public ArrayList<Hex> gridToAL() {
    return _list;
  }

  public ArrayList<Hex> getActive() {
    return _active;
  }

  public void addActive(Hex hex) {
    _active.add(hex);
  }

  public void removeActive(Hex hex) {
    _active.remove(hex);
  }
  
  public void resetActive() {
    _active = new ArrayList<Hex>();
  }

  // Returns a priority queue of hexes ordered by distance from a center hex 
  public PriorityQueue<Hex> gridToPQ(Hex center) {
    Comparator<Hex> c = new HexComparator(center);
    PriorityQueue<Hex> ret = new PriorityQueue<Hex>(_hexCount, c);

    for (Hex hex : _list) 
      ret.offer(hex);

    return ret;
  }

  // Returns a list of hexes in a given radius
  public ArrayList<Hex> hexesInRadius(Hex hex, int r) {
    PriorityQueue<Hex> pq = gridToPQ(hex);
    ArrayList<Hex> ret = new ArrayList<Hex>();

    Hex cur = pq.poll();

    while (cur != null && cur.distanceTo(hex) <= r) {
      ret.add(cur);
      cur = pq.poll();
    }
    
    return ret;
  }
}
