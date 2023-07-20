function[xt,xl,xr]=searchsolve(f,yt,xminmax)































    narginchk(3,3);
    validateattributes(f,{'function_handle'},{'scalar'},1);
    assert(nargin(f)==1,message("fixed:utility:expectedFcnWithOneInput"));
    validateattributes(yt,{'numeric'},{'real','nonnan','scalar'},2);
    validateattributes(xminmax,{'double','single'},{'real','nonnan','size',[1,2],'nondecreasing'},3);


    xt=cast([],'like',xminmax);
    xl=cast([],'like',xminmax);
    xr=cast([],'like',xminmax);
    xmin=xminmax(1);
    xmax=xminmax(2);


    y=f(xmin);
    if y>yt
        xr=xmin;
        return;
    elseif y==yt
        xt=xmin;
        return;
    end


    y=f(xmax);
    if y<yt
        xl=xmax;
        return;
    elseif y==yt
        xt=xmax;
        return;
    end



    xl=xmin;
    xr=xmax;
    while xr-xl>min(eps([xl,xr]))
        x=(xl+xr)/2;
        y=f(x);
        if y<yt
            xl=x;
        elseif y>yt
            xr=x;
        else
            xt=x;
            xl=cast([],'like',xminmax);
            xr=cast([],'like',xminmax);
            break;
        end
    end
end
