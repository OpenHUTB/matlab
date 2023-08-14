function outRange=intersectRange(inRangeOne,inRangeTwo)






    assert(inRangeOne(2)>=inRangeTwo(1),...
    'Disjoint ranges in Simulink.FixedPointAutoscaler.InternalRange.intersectRange');
    assert(inRangeOne(1)<=inRangeTwo(2),...
    'Disjoint ranges in Simulink.FixedPointAutoscaler.InternalRange.intersectRange');

    outRange=[max([inRangeOne(1),inRangeTwo(1)]),min([inRangeOne(2),inRangeTwo(2)])];


