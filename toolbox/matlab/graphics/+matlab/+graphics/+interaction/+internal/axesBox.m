function s=axesBox(ax,vp)





    cc=get_box_in_ndc(ax.ActiveDataSpace,ax.Camera,vp);


    cc(1,:)=cc(1,:)./cc(4,:);
    cc(2,:)=cc(2,:)./cc(4,:);


    ndc(1,:)=(1+cc(1,:))/2;
    ndc(2,:)=(1+cc(2,:))/2;
    sx=vp(3)/vp(3);
    sy=vp(4)/vp(4);
    ox=vp(1)/vp(3);
    oy=vp(2)/vp(4);
    ndc(1,:)=ndc(1,:)*sx+ox;
    ndc(2,:)=ndc(2,:)*sy+oy;

    s.corners=ndc;




    if strcmpi(ax.Projection,'orthographic')
        z=cc(3,:)./cc(4,:);



        maxz=find(z==max(z),1);

        xy=[1,2,4,3;...
        5,6,8,7];
        if any(xy(1,:)==maxz)
            s.backxy=xy(1,:);
        elseif any(xy(2,:)==maxz)
            s.backxy=xy(2,:);
        end

        yz=[1,3,7,5;...
        2,4,8,6];
        if any(yz(1,:)==maxz)
            s.backyz=yz(1,:);
        elseif any(yz(2,:)==maxz)
            s.backyz=yz(2,:);
        end
        zx=[1,5,6,2;...
        3,7,8,4];
        if any(zx(1,:)==maxz)
            s.backzx=zx(1,:);
        elseif any(zx(2,:)==maxz)
            s.backzx=zx(2,:);
        end
    else


        xy=[1,2,4,3;...
        5,6,8,7];
        s.backxy=xy(1,:);
        s.frontxy=xy(2,:);

        yz=[1,3,7,5;...
        2,4,8,6];
        s.backyz=yz(1,:);
        s.frontyz=yz(2,:);

        zx=[1,5,6,2;...
        3,7,8,4];
        s.backzx=zx(1,:);
        s.frontzx=zx(2,:);
    end


    function corners=get_box_in_ndc(ds,cam,ref)

        xlim=ds.XLim_I;
        ylim=ds.YLim_I;
        zlim=ds.ZLim_I;

        iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
        iter.XData=[xlim(1),xlim(2),xlim(1),xlim(2),xlim(1),xlim(2),xlim(1),xlim(2)];
        iter.YData=[ylim(1),ylim(1),ylim(2),ylim(2),ylim(1),ylim(1),ylim(2),ylim(2)];
        iter.ZData=[zlim(1),zlim(1),zlim(1),zlim(1),zlim(2),zlim(2),zlim(2),zlim(2)];
        vd=TransformPoints(ds,eye(4),iter);

        vmat=cam.GetProjectionMatrix*cam.GetViewMatrix*ds.getMatrix;

        vp=cam.Viewport;

        initial_units=vp.Units;
        vp.Units='pixels';

        pos=vp.Position;
        adjust_scale=[pos(3)/ref(3),...
        pos(4)/ref(4),...
        1.];
        center(1)=pos(1)+(pos(3)/2);
        center(2)=pos(2)+(pos(4)/2);

        reframecenter(1)=ref(1)+ref(3)/2;
        reframecenter(2)=ref(2)+ref(4)/2;

        adjust_offset=[2.*(center(1)-reframecenter(1))/ref(3),...
        2.*(center(2)-reframecenter(2))/ref(4),...
        0.];

        translate=[1,0,0,adjust_offset(1);
        0,1,0,adjust_offset(2);
        0,0,1,adjust_offset(3);
        0,0,0,1];
        scale=[adjust_scale(1),0,0,0;
        0,adjust_scale(2),0,0;
        0,0,adjust_scale(3),0;
        0,0,0,1];
        vmat=translate*scale*vmat;

        vp.Units=initial_units;

        vd2=double(vd);
        vd2(4,:)=ones(1,8);

        corners=vmat*vd2;