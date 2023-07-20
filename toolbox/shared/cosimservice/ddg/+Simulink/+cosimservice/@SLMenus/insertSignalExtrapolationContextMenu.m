function schema=insertSignalExtrapolationContextMenu(cbinfo)




    schema=sl_action_schema;
    schema.label='&Insert Signal Extrapolation Block';
    schema.tag='Simulink:CoSimulation:Extrapolation';
    schema.callback=@insertSignalExtrapolationBlock;
    schema.autoDisableWhen='Busy';

end

function insertSignalExtrapolationBlock(cbinfo)
    block_half_size=10;


    menu_position=cbinfo.studio.App.getActiveEditor.mapFromGlobal(cbinfo.contextMenuPosition);

    current_line_pts=get_param(cbinfo.target.handle,'Points');
    downstream_line_pts=CheckConnect(cbinfo.target.handle);




    [closest_idx,closest_pt]=FindClosestIndex(current_line_pts,menu_position);


    angle=atan2(current_line_pts(closest_idx+1,2)-current_line_pts(closest_idx,2),...
    current_line_pts(closest_idx+1,1)-current_line_pts(closest_idx,1))/pi*180;
    if angle<=45&&angle>=-45
        orientation='right';
    elseif angle<-135||angle>135
        orientation='left';
    elseif angle<0
        orientation='up';
    else
        orientation='down';
    end


    sys=get_param(cbinfo.target.handle,'Parent');
    blkh=add_block('built-in/PredictionCorrectionBlock',[sys,'/PredictionCorrectionBlock'],'MakeNameUnique','on',...
    'Position',[closest_pt-block_half_size,closest_pt+block_half_size],'Orientation',orientation,'ShowName','off');
    blkph=get_param(blkh,'PortHandles');


    ip_pos=get_param(blkph.Inport(1),'Position');
    op_pos=get_param(blkph.Outport(1),'Position');
    current_line_pts(closest_idx+2:end,:)=[];
    current_line_pts(closest_idx+1,:)=ip_pos;
    downstream_line_pts{end}(closest_idx,:)=op_pos;
    downstream_line_pts{end}(1:closest_idx-1,:)=[];



    delete_line(cbinfo.target.handle);
    add_line(sys,current_line_pts);
    add_line(sys,downstream_line_pts);

    open_system(blkh);
end

function[index,proj_pt]=FindClosestIndex(pts,blk_center)
    min_dist=inf;
    index=1;
    proj_pt=blk_center;
    for i=1:size(pts,1)-1
        [dist,pt]=MinimumDistance(pts(i,:),pts(i+1,:),blk_center);
        if min_dist>dist
            min_dist=dist;
            index=i;
            proj_pt=pt;
        end
    end
end

function[dist,proj_pt]=MinimumDistance(ptA,ptB,pt)

    l2=sum((ptA-ptB).^2);
    if l2<=0
        dist=norm(pt-ptB);
        proj_pt=ptB;
        return;
    end

    t=max(0,min(1,dot(pt-ptA,ptB-ptA)/l2));
    proj_pt=ptA+t*(ptB-ptA);
    dist=norm(proj_pt-pt);
end

function all_lines=CheckConnect(lh)

    all_lines={};
    kids=get_param(lh,'LineChildren');
    if~isempty(kids)
        for i=1:length(kids)
            temp=CheckConnect(kids(i));
            all_lines={all_lines{:},temp{:}};
        end
    end
    all_lines{end+1}=get_param(lh,'Points');
end
