function[g0,g]=mv_transform_te(obj,d)

























    n=obj.NumAssets;

    x0=obj.TrackingPort;
    tau=obj.TrackingError;
    C=obj.AssetCovar;

    d0=d(1:n);

    g0=(d0-x0)'*C*(d0-x0)-tau^2;
    g=C*(d0-x0);

    if numel(d)>n
        g=[g;zeros(n,1)];
    end

