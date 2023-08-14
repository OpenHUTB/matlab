function geom=calcDialogGeometry(width,height,anchor,arg)



    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    canvas=allStudios(1).App.getActiveEditor.getCanvas;
    canvas_geom=canvas.GlobalPosition;
    if strcmp(anchor,'Block')
        blk_geom=get_param(arg,'position');
        anchor_pos=canvas.scenePointToViewPoint(blk_geom([1,4]));
        anchor_pos(1)=canvas_geom(1)+anchor_pos(1)+10;
        anchor_pos(2)=canvas_geom(2)+anchor_pos(2)-10;
    elseif strcmp(anchor,'Model')
        anchor_pos(1)=canvas_geom(1)+15;
        anchor_pos(2)=canvas_geom(2)+canvas_geom(4)-20;
    elseif strcmp(anchor,'ModelCenter')
        anchor_pos(1)=canvas_geom(1)+canvas_geom(3)/2-width/2;
        anchor_pos(2)=canvas_geom(2)+canvas_geom(4)/2-height/2;
    elseif strcmp(anchor,'Port')
        port_geom=get_param(arg,'position');
        anchor_pos=canvas.scenePointToViewPoint(port_geom([1,2]));
        anchor_pos(1)=canvas_geom(1)+anchor_pos(1)+20;
        anchor_pos(2)=canvas_geom(2)+anchor_pos(2)+25;
    elseif strcmp(anchor,'SingleSelectionFlyout')
        anchor_pos=canvas.scenePointToViewPoint(arg)/GLUE2.Util.getDpiScale;
        anchor_pos(1)=canvas_geom(1)+anchor_pos(1);
        anchor_pos(2)=canvas_geom(2)+anchor_pos(2);
    elseif strcmp(anchor,'GlobalPoint')
        anchor_pos(1)=arg(1)+10;
        anchor_pos(2)=arg(2)+10;
    else
        assert(false,'unknown anchor %s',anchor);
    end


    geom(1)=anchor_pos(1)-10;
    geom(2)=anchor_pos(2)-10;
    geom(3)=width;
    geom(4)=height;

    screen=Simulink.harness.internal.availableGeometry(anchor_pos(1),anchor_pos(2));


    geom(3)=min(geom(3),screen(3));
    geom(4)=min(geom(4),screen(4));
    if geom(1)<screen(1)
        geom(1)=screen(1);
    elseif geom(1)+geom(3)>screen(1)+screen(3)
        geom(1)=screen(1)+screen(3)-geom(3);
    end
    if geom(2)<screen(2)
        geom(2)=screen(2);
    elseif geom(2)+geom(4)>screen(2)+screen(4)
        geom(2)=screen(2)+screen(4)-geom(4);
    end
end
