vec2 map(vec3 p) {
    // plane
    float planeDist = fPlane(p, vec3(0, 1, 0), 14.0);
    float planeID = 2.0;
    vec2 plane = vec2(planeDist, planeID);
    // sphere
    float sphereDist = fSphere(p, 9.0 + fDisplace(p));
    float sphereID = 1.0;
    vec2 sphere = vec2(sphereDist, sphereID);
    // manipulation operators
    pMirrorOctant(p.xz, vec2(50, 50));
    p.x = -abs(p.x) + 20;
    pMod1(p.z, 15);
    // roof
    vec3 pr = p;
    pr.y -= 15.5;
    pR(pr.xy, 0.6);
    pr.x -= 18.0;
    float roofDist = fBox2(pr.xy, vec2(20, 0.3));
    float roofID = 4.0;
    vec2 roof = vec2(roofDist, roofID);
    // box
    float boxDist = fBox(p, vec3(3, 9, 4));
    float boxID = 3.0;
    vec2 box = vec2(boxDist, boxID);
    // cylinder
    vec3 pc = p;
    pc.y -= 9.0;
    float cylinderDist = fCylinder(pc.yxz, 4, 3);
    float cylinderID = 3.0;
    vec2 cylinder = vec2(cylinderDist, cylinderID);
    // wall
    float wallDist = fBox2(p.xy, vec2(1, 15));
    float wallID = 3.0;
    vec2 wall = vec2(wallDist, wallID);
    // result
    vec2 res;
    res = fOpUnionID(box, cylinder);
    res = fOpDifferenceColumnsID(wall, res, 0.6, 3.0);
    res = fOpUnionChamferID(res, roof, 0.9);
    res = fOpUnionStairsID(res, plane, 4.0, 5.0);
    res = fOpUnionID(res, sphere);
    return res;
}