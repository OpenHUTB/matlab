function M=getViewProjectionMatrix(a)

    up=a.Camera.Viewport;
    up.Units='pixels';
    pos=up.Position;
    x=pos(1);
    y=pos(2);
    w=pos(3);
    h=pos(4);
    vpm=[w/2,0,0,(w-1)/2+x;
    0,h/2,0,(h-1)/2+y;
    0,0,1,0;
    0,0,0,1];
    mvp=a.Camera.GetProjectionMatrix()*a.Camera.GetViewMatrix();
    M=vpm*mvp;
