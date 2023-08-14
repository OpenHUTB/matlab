function vecval=adjustAngleLimForFullCircle(p,val,idx)













    AngleLimFullCircleThreshold=0.1;
    if nargin<3
        vecval=val;
        idx=2;
        val=vecval(idx);
    else
        vecval=p.pAngleLim;
    end
    otherIdx=3-idx;
    if abs(val-vecval(otherIdx))<=AngleLimFullCircleThreshold




...
...
...
...
...
...
...
...
...





        vecval(idx)=vecval(otherIdx);
    else
        vecval(idx)=val;
    end
    p.pAngleLim=vecval;
