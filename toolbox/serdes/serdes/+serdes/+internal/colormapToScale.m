function[mincval,maxcval]=colormapToScale(eye,map,target)







    if any(isnan(eye(:)))||any(isinf(eye(:)))

        mincval=0;
        maxcval=1;
    else
        maxcval=max(eye(:));
        ncmap=size(map,1);
        stepval=(maxcval-min(eye(:)))/(ncmap-1);
        mincval=target-stepval;
    end