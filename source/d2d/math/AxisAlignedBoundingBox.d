module d2d.math.AxisAlignedBoundingBox;

import std.algorithm;
import std.math;
import std.parallelism;
import std.range;
import std.traits;
import d2d.math.Segment;
import d2d.math.Vector;

/**
 * A rectangle is a box in 2d space
 * Because these rectangles are axis aligned, they don't have any rotation
 */
class AxisAlignedBoundingBox(T, ulong dimensions) {

    Vector!(T, dimensions) initialPoint; ///The initial or starting point of the AABB
    Vector!(T, dimensions) extent; ///The extent in each direction the AABB extends from the initial point (eg.)

    /**
     * Gives the AABB convenient 2d aliases
     * TODO: doesn't work! :(
     */
    static if (dimensions == 2) {
        alias x = this.initialPoint.x;
        alias y = this.initialPoint.y;
        alias w = this.extent.x;
        alias h = this.extent.y;
        @property Vector!(T, 2) topLeft() { return this.vertices[0]; }
        @property Vector!(T, 2) topRight() { return this.vertices[1]; }
        @property Vector!(T, 2) bottomLeft() { return this.vertices[3]; }
        @property Vector!(T, 2) bottomRight() { return this.vertices[2]; }
    }

    /**
     * Gets all the vertices of the AABB
     */
    @property Vector!(T, dimensions)[] vertices() {
        Vector!(T, dimensions)[] allVerts = [this.initialPoint];
        if (this.extent == new Vector!(T, dimensions)(0)) {
            return allVerts;
        }
        foreach (component; this.extent.components) {
            foreach (i; 0..dimensions) {
                AxisAlignedBoundingBox!(T, dimensions) copy = new AxisAlignedBoundingBox!(T, dimensions)(new Vector!(T, dimensions)(this.initialPoint.components), new Vector!(T, dimensions)(this.extent.components));
                if (copy.extent.components[i] == 0) {
                    continue;
                }
                copy.initialPoint.components[i] += copy.extent.components[i];
                copy.extent.components[i] = 0;
                foreach (vertex; copy.vertices) {
                    if (!allVerts.canFind(vertex)) {
                        allVerts ~= vertex;
                    }
                }
            }
        }
        return allVerts;
    }

    /**
     * Gets all the edges of the AABB
     */
    @property Segment!(T, dimensions)[] edges() {
        //TODO:
        return null;
    }

    /**
     * Gets the point that is the middle or center of the AABB
     */
    @property Vector!(T, dimensions) center() {
        return this.initialPoint + this.extent / 2;
    }

    /**
     * Creates an AABB from the initial point, and how much in each direction the box extends
     */
    this(Vector!(T, dimensions) initialPoint, Vector!(T, dimensions) extent) {
        this.initialPoint = initialPoint;
        this.extent = extent;
    }

    /**
     * Creates an AABB from the same as the vector constructor, but as a varargs input
     */
    this(T[] args...) {
        this.initialPoint = new Vector!(T, dimensions)(0);
        this.extent = new Vector!(T, dimensions)(0);
        foreach (i; 0..dimensions) {
            this.initialPoint.components[i] = args[i];
            this.extent.components[i] = args[i + dimensions];
        }
    }

    /**
     * Copy constructor for AABBs
     */
    this(AxisAlignedBoundingBox!(T, dimensions) toCopy) {
        this(new Vector!(T, dimensions)(toCopy.initialPoint), new Vector!(T, dimensions)(toCopy.extent));
    }

    /**
     * Returns whether the box contains the given point
     */
    bool contains(Vector!(T, dimensions) point) {
        bool isContained = true;
        foreach (i, component; (cast(T[]) point.components).parallel) {
            if (component < this.initialPoint.components[i] && component < this.extent.components[i] || component > this.initialPoint.components[i] && component > this.extent.components[i]) {
                isContained = false;
            }
        }
        return isContained;
    }

}

/**
 * Returns whether two rectangles intersect
 * TODO: untested
 */
bool intersects(T, U)(AxisAlignedBoundingBox!T first, AxisAlignedBoundingBox!U second) {
    bool doesIntersect = true;
    foreach (i; iota(0, first.initialPoint.components.length).parallel) {
        if (
            first.initialPoint.components[i] < second.initialPoint.components[i] &&
            first.initialPoint.components[i] + first.extent.components[i] < second.initialPoint.components[i] && 
            first.initialPoint.components[i] < second.initialPoint.components[i] + second.extent.components[i] &&
            first.initialPoint.components[i] + first.extent.components[i] < second.initialPoint.components[i] + second.extent.components[i]
            ||
            first.initialPoint.components[i] > second.initialPoint.components[i] &&
            first.initialPoint.components[i] + first.extent.components[i] > second.initialPoint.components[i] && 
            first.initialPoint.components[i] > second.initialPoint.components[i] + second.extent.components[i] &&
            first.initialPoint.components[i] + first.extent.components[i] > second.initialPoint.components[i] + second.extent.components[i]
        ) {
            doesIntersect = false;
        }
    }
    return doesIntersect;
}
