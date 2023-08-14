function[ang,r,angGapIdx]=insertValueAtGaps(val,ang,r)















    [~,angGapIdx]=findNonuniformAngleDifferences(ang);





    [ang,zi]=insertAfter(ang,angGapIdx,val);
    if nargin>2
        r=insertAfter(r,angGapIdx,val);
        angGapIdx=zi;
    else

        r=zi;
    end
