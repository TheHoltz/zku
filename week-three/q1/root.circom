pragma circom 2.0.0;

include "../circomlib/circuits/comparators.circom";
include "../circomlib/circuits/gates.circom";

template HasEnergy() {
  signal input energy;
  signal input a[2];
  signal input b[2];

  signal output is_enough;

  // calculate distance between two points
  component points_distance = ComputePointsDistance();
  points_distance.a[0] <== a[0];
  points_distance.a[1] <== a[1];
  points_distance.b[0] <== b[0];
  points_distance.b[1] <== b[1];

  // 32 bits comparisson
  component distanceComparator = LessEqThan(32);

  // due to the complexity of square root calculations, we will keep the quadratic distance
  distanceComparator.in[0] <== energy * energy;
  distanceComparator.in[1] <== points_distance.computed_distance;

  is_enough <== distanceComparator.out;
}

template CheckValidTriangle() {
  signal input a[2];
  signal input b[2];
  signal input c[2];

  signal output is_valid;

  signal side_ab;
  signal side_bc;
  signal side_ca;

  signal abx;
  signal aby;
  signal bcx;
  signal bcy;
  signal cax;
  signal cay;

  signal abx2;
  signal aby2;
  signal bcx2;
  signal bcy2;
  signal cax2;
  signal cay2;

  // compute each size of triangles
  abx <== a[0] - b[0];
  aby <== a[1] - b[1];
  bcx <== b[0] - c[0];
  bcy <== b[1] - c[1];
  cax <== c[0] - a[0];
  cay <== c[1] - a[1];

  abx2 <== abx * abx;
  aby2 <== aby * aby;
  bcx2 <== bcx * bcx;
  bcy2 <== bcy * bcy;
  cax2 <== cax * cax;
  cay2 <== cay * cay;

  side_ab <== abx2 + aby2;
  side_bc <== bcx2 + bcy2;
  side_ca <== cax2 + cay2;

  // checks if sums of two sides are bigger than another one
  component geqt_a = GreaterEqThan(32);
  component geqt_b = GreaterEqThan(32);
  component geqt_c = GreaterEqThan(32);

  geqt_a.in[0] <== side_ab + side_bc; 
  geqt_a.in[1] <== side_ca * side_ca; 

  geqt_b.in[0] <== side_ab + side_ca;
  geqt_b.in[1] <== side_bc * side_bc; 

  geqt_c.in[0] <== side_bc + side_ca; 
  geqt_c.in[1] <== side_ab * side_ab; 

  component multi_and_gate = MultiAND(3);
  multi_and_gate.in[0] <== geqt_a.out;
  multi_and_gate.in[1] <== geqt_b.out;
  multi_and_gate.in[2] <== geqt_c.out;

  is_valid <== multi_and_gate.out;
}

template ComputePointsDistance() {
  signal input a[2];
  signal input b[2];

  signal x_delta;
  signal y_delta;

  signal x2_delta;
  signal y2_delta;

  signal output computed_distance;

  x_delta <== a[0] - b[0];
  y_delta <== a[1] - b[1];

  x2_delta <== x_delta * x_delta;
  y2_delta <== y_delta * y_delta;


  computed_distance <== x2_delta + y2_delta;
}

template TriangleJump() {
  signal input energy;
  signal input a[2];
  signal input b[2];
  signal input c[2];
  
  signal output out;

  // compute if has enough energy to distance
  component ab_has_energy = HasEnergy();
  component bc_has_energy = HasEnergy();

  ab_has_energy.energy <== energy;
  ab_has_energy.a[0] <== a[0];
  ab_has_energy.a[1] <== a[1];
  ab_has_energy.b[0] <== b[0];
  ab_has_energy.b[1] <== b[1];

  bc_has_energy.energy <== energy;
  bc_has_energy.a[0] <== b[0];
  bc_has_energy.a[1] <== b[1];
  bc_has_energy.b[0] <== c[0];
  bc_has_energy.b[1] <== c[1];

  // check if coordinates froms a valid triangle
  component is_valid_triangle = CheckValidTriangle();
  is_valid_triangle.a[0] <== a[0];
  is_valid_triangle.a[1] <== a[1];
  is_valid_triangle.b[0] <== b[0];
  is_valid_triangle.b[1] <== b[1];
  is_valid_triangle.c[0] <== c[0];
  is_valid_triangle.c[1] <== c[1];

  component multi_and_gate = MultiAND(3);
  multi_and_gate.in[0] <== ab_has_energy.is_enough;
  multi_and_gate.in[1] <== bc_has_energy.is_enough;
  multi_and_gate.in[2] <== is_valid_triangle.is_valid;

  out <== multi_and_gate.out; 
}

component main = TriangleJump(); 
