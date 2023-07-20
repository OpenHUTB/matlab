function r=findRadiusOfBoundingSphere(p)

    if~isempty(p)
        xmax=max(abs(p(1,:)));
        ymax=max(abs(p(2,:)));
        zmax=max(abs(p(3,:)));
    else
        xmax=1;
        ymax=1;
        zmax=1;
    end
    r=2*sqrt(xmax^2+ymax^2+zmax^2);