function[R,maxPt]=findMaxDistanceFromBoundary(B)


    x_max=max(cellfun(@(x)max(abs(x(:,1))),B));
    y_max=max(cellfun(@(x)max(abs(x(:,2))),B));
    z_max=max(cellfun(@(x)max(abs(x(:,3))),B));
    R=sqrt(x_max^2+y_max^2+z_max^2);
    maxPt=[x_max,y_max,z_max];