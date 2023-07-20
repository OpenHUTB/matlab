function patterns=assertPatterns








    patterns={
    {'id0 <  0','physmod:simscape:compiler:patterns:checks:LessThanZero'};
    {'id0 <= 0','physmod:simscape:compiler:patterns:checks:LessThanOrEqualZero'};
    {'id0 >  0','physmod:simscape:compiler:patterns:checks:GreaterThanZero'};
    {'id0 >= 0','physmod:simscape:compiler:patterns:checks:GreaterThanOrEqualZero'};
    {'id0 == 0','physmod:simscape:compiler:patterns:checks:EqualZero'};
    {'id0 ~= 0','physmod:simscape:compiler:patterns:checks:NotZero'};
    {'id0 <  id1','physmod:simscape:compiler:patterns:checks:LessThan'};
    {'id0 <  lit1','physmod:simscape:compiler:patterns:checks:LessThan'};
    {'id0 <= id1','physmod:simscape:compiler:patterns:checks:LessThanOrEqual'};
    {'id0 <= lit1','physmod:simscape:compiler:patterns:checks:LessThanOrEqual'};
    {'id0 >  id1','physmod:simscape:compiler:patterns:checks:GreaterThan'};
    {'id0 >  lit1','physmod:simscape:compiler:patterns:checks:GreaterThan'};
    {'id0 >= id1','physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual'};
    {'id0 >= lit1','physmod:simscape:compiler:patterns:checks:GreaterThanOrEqual'};
    {'id0 == id1','physmod:simscape:compiler:patterns:checks:Equal'};
    {'id0 == lit1','physmod:simscape:compiler:patterns:checks:Equal'};
    {'id0 ~= id1','physmod:simscape:compiler:patterns:checks:NotEqual'};
    {'id0 ~= lit1','physmod:simscape:compiler:patterns:checks:NotEqual'};
    {'isfinite(id0)','physmod:simscape:compiler:patterns:checks:Finite'};
    {'mod(id0, 1) == 0','physmod:simscape:compiler:patterns:checks:Integer'};
    {'mod(id0, id1) == 0','physmod:simscape:compiler:patterns:checks:EvenlyDivisible'};
    {'mod(id0, lit1) == 0','physmod:simscape:compiler:patterns:checks:EvenlyDivisible'};
    {'abs(id0) <  id1','physmod:simscape:compiler:patterns:checks:MagnitudeLessThan'};
    {'abs(id0) <  lit1','physmod:simscape:compiler:patterns:checks:MagnitudeLessThan'};
    {'abs(id0) <= id1','physmod:simscape:compiler:patterns:checks:MagnitudeLessThanOrEqual'};
    {'abs(id0) <= lit1','physmod:simscape:compiler:patterns:checks:MagnitudeLessThanOrEqual'};
    {'all(id0    <  0)','physmod:simscape:compiler:patterns:checks:ArrayLessThanZero'};
    {'all(id0(:) <  0)','physmod:simscape:compiler:patterns:checks:ArrayLessThanZero'};
    {'all(id0    <= 0)','physmod:simscape:compiler:patterns:checks:ArrayLessThanOrEqualZero'};
    {'all(id0(:) <= 0)','physmod:simscape:compiler:patterns:checks:ArrayLessThanOrEqualZero'};
    {'all(id0    >  0)','physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero'};
    {'all(id0(:) >  0)','physmod:simscape:compiler:patterns:checks:ArrayGreaterThanZero'};
    {'all(id0    >= 0)','physmod:simscape:compiler:patterns:checks:ArrayGreaterThanOrEqualZero'};
    {'all(id0(:) >= 0)','physmod:simscape:compiler:patterns:checks:ArrayGreaterThanOrEqualZero'};
    {'all(id0    <  id1)','physmod:simscape:compiler:patterns:checks:ArrayLessThan'};
    {'all(id0    <  lit1)','physmod:simscape:compiler:patterns:checks:ArrayLessThan'};
    {'all(id0(:) <  id1)','physmod:simscape:compiler:patterns:checks:ArrayLessThan'};
    {'all(id0(:) <  lit1)','physmod:simscape:compiler:patterns:checks:ArrayLessThan'};
    {'all(id0    <= id1)','physmod:simscape:compiler:patterns:checks:ArrayLessThanOrEqual'};
    {'all(id0    <= lit1)','physmod:simscape:compiler:patterns:checks:ArrayLessThanOrEqual'};
    {'all(id0(:) <= id1)','physmod:simscape:compiler:patterns:checks:ArrayLessThanOrEqual'};
    {'all(id0(:) <= lit1)','physmod:simscape:compiler:patterns:checks:ArrayLessThanOrEqual'};
    {'all(id0    >  id1)','physmod:simscape:compiler:patterns:checks:ArrayGreaterThan'};
    {'all(id0    >  lit1)','physmod:simscape:compiler:patterns:checks:ArrayGreaterThan'};
    {'all(id0(:) >  id1)','physmod:simscape:compiler:patterns:checks:ArrayGreaterThan'};
    {'all(id0(:) >  lit1)','physmod:simscape:compiler:patterns:checks:ArrayGreaterThan'};
    {'all(id0    >= id1)','physmod:simscape:compiler:patterns:checks:ArrayGreaterThanOrEqual'};
    {'all(id0    >= lit1)','physmod:simscape:compiler:patterns:checks:ArrayGreaterThanOrEqual'};
    {'all(id0(:) >= id1)','physmod:simscape:compiler:patterns:checks:ArrayGreaterThanOrEqual'};
    {'all(id0(:) >= lit1)','physmod:simscape:compiler:patterns:checks:ArrayGreaterThanOrEqual'};
    {'all(id0    == id1)','physmod:simscape:compiler:patterns:checks:ArrayEqual'};
    {'all(id0    == lit1)','physmod:simscape:compiler:patterns:checks:ArrayEqual'};
    {'all(id0(:) == id1)','physmod:simscape:compiler:patterns:checks:ArrayEqual'};
    {'all(id0(:) == lit1)','physmod:simscape:compiler:patterns:checks:ArrayEqual'};
    {'all(id0    ~= id1)','physmod:simscape:compiler:patterns:checks:ArrayNotEqual'};
    {'all(id0    ~= lit1)','physmod:simscape:compiler:patterns:checks:ArrayNotEqual'};
    {'all(id0(:) ~= id1)','physmod:simscape:compiler:patterns:checks:ArrayNotEqual'};
    {'all(id0(:) ~= lit1)','physmod:simscape:compiler:patterns:checks:ArrayNotEqual'};
    {'all(id0(:) <  id1(:))','physmod:simscape:compiler:patterns:checks:ArrayLessThanArray'};
    {'all(id0(:) <= id1(:))','physmod:simscape:compiler:patterns:checks:ArrayLessThanOrEqualArray'};
    {'all(id0(:) >  id1(:))','physmod:simscape:compiler:patterns:checks:ArrayGreaterThanArray'};
    {'all(id0(:) >= id1(:))','physmod:simscape:compiler:patterns:checks:ArrayGreaterThanOrEqualArray'};
    {'all(id0(:) == id1(:))','physmod:simscape:compiler:patterns:checks:ArrayEqualArray'};
    {'all(id0(:) ~= id1(:))','physmod:simscape:compiler:patterns:checks:ArrayNotEqualArray'};
    {'all(diff(id0) > 0 )','physmod:simscape:compiler:patterns:checks:StrictlyAscendingVec'};
    {'all(diff(id0) >= 0)','physmod:simscape:compiler:patterns:checks:AscendingVec'};
    {'all(diff(id0) <  0)','physmod:simscape:compiler:patterns:checks:StrictlyDescendingVec'};
    {'all(diff(id0) <= 0)','physmod:simscape:compiler:patterns:checks:DescendingVec'};
    {'all(diff(id0) > 0) || all(diff(id0) < 0)','physmod:simscape:compiler:patterns:checks:StrictlyAscendingOrDescendingVec'};
    {'all(diff(id0) < 0) || all(diff(id0) > 0)','physmod:simscape:compiler:patterns:checks:StrictlyAscendingOrDescendingVec'};
    {'all(diff(id0) >= 0) || all(diff(id0) <= 0)','physmod:simscape:compiler:patterns:checks:AscendingOrDescendingVec'};
    {'all(diff(id0) <= 0) || all(diff(id0) >= 0)','physmod:simscape:compiler:patterns:checks:AscendingOrDescendingVec'};
    {'all(all(diff(id0, 1, 1) >  0))','physmod:simscape:compiler:patterns:checks:StrictlyAscendingColumns'};
    {'all(all(diff(id0, 1, 1) >= 0))','physmod:simscape:compiler:patterns:checks:AscendingColumns'};
    {'all(all(diff(id0, 1, 1) <  0))','physmod:simscape:compiler:patterns:checks:StrictlyDescendingColumns'};
    {'all(all(diff(id0, 1, 1) <= 0))','physmod:simscape:compiler:patterns:checks:DescendingColumns'};
    {'all(all(diff(id0, 1, 2) >  0))','physmod:simscape:compiler:patterns:checks:StrictlyAscendingRows'};
    {'all(all(diff(id0, 1, 2) >= 0))','physmod:simscape:compiler:patterns:checks:AscendingRows'};
    {'all(all(diff(id0, 1, 2) <  0))','physmod:simscape:compiler:patterns:checks:StrictlyDescendingRows'};
    {'all(all(diff(id0, 1, 2) <= 0))','physmod:simscape:compiler:patterns:checks:DescendingRows'};
    {'all(isfinite(id0   ))','physmod:simscape:compiler:patterns:checks:ArrayFinite'};
    {'all(isfinite(id0(:)))','physmod:simscape:compiler:patterns:checks:ArrayFinite'};
    {'all(mod(id0   , 1) == 0)','physmod:simscape:compiler:patterns:checks:ArrayInteger'};
    {'all(mod(id0(:), 1) == 0)','physmod:simscape:compiler:patterns:checks:ArrayInteger'};
    {'length(id0) <  lit1','physmod:simscape:compiler:patterns:checks:LengthLessThan'};
    {'numel(id0)  <  lit1','physmod:simscape:compiler:patterns:checks:LengthLessThan'};
    {'length(id0) <= lit1','physmod:simscape:compiler:patterns:checks:LengthLessThanOrEqual'};
    {'numel(id0)  <= lit1','physmod:simscape:compiler:patterns:checks:LengthLessThanOrEqual'};
    {'length(id0) >  lit1','physmod:simscape:compiler:patterns:checks:LengthGreaterThan'};
    {'numel(id0)  >  lit1','physmod:simscape:compiler:patterns:checks:LengthGreaterThan'};
    {'length(id0) >= lit1','physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual'};
    {'numel(id0)  >= lit1','physmod:simscape:compiler:patterns:checks:LengthGreaterThanOrEqual'};
    {'length(id0) == lit1','physmod:simscape:compiler:patterns:checks:LengthEqual'};
    {'numel(id0)  == lit1','physmod:simscape:compiler:patterns:checks:LengthEqual'};
    {'length(id0) == id1','physmod:simscape:compiler:patterns:checks:LengthEqual'};
    {'numel(id0)  == id1','physmod:simscape:compiler:patterns:checks:LengthEqual'};
    {'length(id0) == length(id1)','physmod:simscape:compiler:patterns:checks:LengthEqualLength'};
    {'numel(id0)  == numel(id1)','physmod:simscape:compiler:patterns:checks:LengthEqualLength'};
    {'ndims(id0)  == lit1','physmod:simscape:compiler:patterns:checks:NDimension'};
    {'all(size(id0) == [lit1, lit2])','physmod:simscape:compiler:patterns:checks:Size2D'};
    {'all(size(id0) == [lit1, lit2, lit3])','physmod:simscape:compiler:patterns:checks:Size3D'};
    {'all(size(id0) == [lit1, lit2, lit3, lit4])','physmod:simscape:compiler:patterns:checks:Size4D'};
    {'all(size(id0) == [length(id1), length(id2)])','physmod:simscape:compiler:patterns:checks:Size2DEqual'};
    {'all(size(id0) == [numel(id1),  numel(id2)])','physmod:simscape:compiler:patterns:checks:Size2DEqual'};
    {'all(size(id0) == [length(id1), length(id2), length(id3)])','physmod:simscape:compiler:patterns:checks:Size3DEqual'};
    {'all(size(id0) == [numel(id1),  numel(id2),  numel(id3)])','physmod:simscape:compiler:patterns:checks:Size3DEqual'};
    {'all(size(id0) == [length(id1), length(id2), length(id3), length(id4)])','physmod:simscape:compiler:patterns:checks:Size4DEqual'};
    {'all(size(id0) == [numel(id1),  numel(id2),  numel(id3),  numel(id4)])','physmod:simscape:compiler:patterns:checks:Size4DEqual'};
    {'all(size(id0) == size(id1))','physmod:simscape:compiler:patterns:checks:SizeEqualSize'};
    };

end
