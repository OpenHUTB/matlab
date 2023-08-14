function[x,y,z,u,v,w,msg]=preProcessData(hObj)




    u=hObj.UData;
    v=hObj.VData;
    x=hObj.XData;
    y=hObj.YData;


    [m,n,p]=size(u);
    if~isequal(size(x),size(hObj.UData))
        x=x(:).';
        x=repmat(x,m,1,p);
    end
    if~isequal(size(y),size(hObj.UData))
        y=y(:);
        y=repmat(y,1,n,p);
    end














    if hObj.is3D
        z=hObj.ZData;
        [msg,x,y,z]=xyzchk(x,y,z);
        w=hObj.WData;
    else
        [msg,x,y,u,v]=xyzchk(x,y,u,v);
        z=zeros(size(x));
        w=zeros(size(u));
    end















    if strcmp(hObj.AutoScale,'on')
        [u,v,w]=doAutoScaleUVWValues(hObj,hObj.is3D,x,y,z,u,v,w);
    end


    x=x(:).';y=y(:).';
    u=u(:).';v=v(:).';
    if hObj.is3D
        z=z(:).';
        w=w(:).';
    end
