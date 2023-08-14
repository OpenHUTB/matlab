function hNewBlk=replaceXYViewer(hBlk,action)







    try

        hBD=bdroot(hBlk);
        d=get_param(hBD,'Dirty');
        tmp2=onCleanup(@()set_param(hBD,'Dirty',d));


        params=locGetParams(hBlk);


        delete_block(params.BlockPath);


        params=locAddNewBlock(params);
        hNewBlk=params.hNewBlk;


        locConnectBlocks(params);


        locGenMessage(params);


        switch action
        case 'open'
            open_system(hNewBlk);
        otherwise
            assert(isempty(action));
        end
    catch me %#ok<NASGU>

        hNewBlk=0;
    end
end


function ret=locGetParams(hBlk)

    ret=struct('XBlock','','XPort',0,'YBlock','','YPort',0);


    ret.BlockPath=getfullname(hBlk);
    ret.OrigName=get_param(hBlk,'Name');


    params={'Position','xmin','xmax','ymin','ymax','st'};
    for idx=1:numel(params)
        ret.(params{idx})=get_param(hBlk,params{idx});
    end


    sigs=get_param(hBlk,'IOSignals');
    if sigs{1}.Handle
        try
            ret.XBlock=get_param(sigs{1}.Handle,'Parent');
            ret.XPort=get_param(sigs{1}.Handle,'PortNumber');
        catch me %#ok<NASGU>
            ret.XPort=0;
        end
    end
    if sigs{2}.Handle
        try
            ret.YBlock=get_param(sigs{2}.Handle,'Parent');
            ret.YPort=get_param(sigs{2}.Handle,'PortNumber');
        catch me %#ok<NASGU>
            ret.YPort=0;
        end
    end
end


function params=locAddNewBlock(params)




    if~isempty(params.XBlock)
        newParent=get_param(params.XBlock,'Parent');
        params.BlockPath=[newParent,'/',params.OrigName];
    end


    load_system('simulink');
    params.hNewBlk=add_block(...
    'simulink/Sinks/XY Graph',...
    params.BlockPath,...
    'Position',params.Position,...
    'xmin',params.xmin,...
    'xmax',params.xmax,...
    'ymin',params.ymin,...
    'ymax',params.ymax,...
    'st',params.st);



    w=params.Position(3)-params.Position(1);
    h=(params.Position(4)-params.Position(2))/3;
    leftPos=params.Position(1)-2*w;
    rightPos=leftPos+w;


    parentSS=get_param(params.BlockPath,'Parent');


    pos=[leftPos,params.Position(2),rightPos,params.Position(2)+h];
    if params.XPort
        params.hFromX=add_block(...
        'built-in/From',...
        [parentSS,'/From'],...
        'MAKENAMEUNIQUE','ON',...
        'Position',pos);
    else

        params.hFromX=add_block(...
        'built-in/Ground',...
        [parentSS,'/Ground'],...
        'MAKENAMEUNIQUE','ON',...
        'Position',pos);
    end
    add_line(parentSS,...
    [locGetBlockName(params.hFromX),'/1'],...
    [locGetBlockName(params.hNewBlk),'/1']);


    pos=[leftPos,params.Position(4)-h,rightPos,params.Position(4)];
    if params.YPort
        params.hFromY=add_block(...
        'built-in/From',...
        [parentSS,'/From'],...
        'MAKENAMEUNIQUE','ON',...
        'Position',pos);
    else

        params.hFromY=add_block(...
        'built-in/Ground',...
        [parentSS,'/Ground'],...
        'MAKENAMEUNIQUE','ON',...
        'Position',pos);
    end
    add_line(parentSS,...
    [locGetBlockName(params.hFromY),'/1'],...
    [locGetBlockName(params.hNewBlk),'/2']);
end


function locConnectBlocks(params)



    baseTag=strrep(Simulink.ID.getSID(params.hNewBlk),':','_');
    FIXED_HEIGHT=14;
    FIXED_WIDTH=35;


    if params.XPort

        pos=get_param(params.XBlock,'Position');
        pos(1)=pos(3)+FIXED_WIDTH;
        pos(3)=pos(1)+FIXED_WIDTH;
        pos(2)=pos(2)-2*FIXED_HEIGHT;
        pos(4)=pos(2)+FIXED_HEIGHT;


        curTag=[baseTag,'_X'];


        parentSS=get_param(params.XBlock,'Parent');


        hGoto=add_block(...
        'built-in/Goto',...
        [parentSS,'/Goto'],...
        'MAKENAMEUNIQUE','ON',...
        'Position',pos,...
        'GotoTag',curTag,...
        'TagVisibility','global');


        add_line(parentSS,...
        [locGetBlockName(params.XBlock),'/',num2str(params.XPort)],...
        [locGetBlockName(hGoto),'/1']);


        set_param(params.hFromX,'GotoTag',curTag);
    end


    if params.YPort

        pos=get_param(params.YBlock,'Position');
        pos(1)=pos(3)+FIXED_WIDTH;
        pos(3)=pos(1)+FIXED_WIDTH;
        pos(2)=pos(2)-2*FIXED_HEIGHT;
        pos(4)=pos(2)+FIXED_HEIGHT;


        curTag=[baseTag,'_Y'];


        parentSS=get_param(params.YBlock,'Parent');


        hGoto=add_block(...
        'built-in/Goto',...
        [parentSS,'/Goto'],...
        'MAKENAMEUNIQUE','ON',...
        'Position',pos,...
        'GotoTag',curTag,...
        'TagVisibility','global');


        add_line(parentSS,...
        [locGetBlockName(params.YBlock),'/',num2str(params.YPort)],...
        [locGetBlockName(hGoto),'/1']);


        set_param(params.hFromY,'GotoTag',curTag);
    end
end


function ret=locGetBlockName(blk)


    ret=get_param(blk,'Name');
    ret=strrep(ret,'/','//');
end


function locGenMessage(params)

    mdl=bdroot(params.BlockPath);


    Simulink.output.Stage(...
    message('Simulink:SLMsgViewer:Update_Diagram_Stage_Name').getString(),...
    'ModelName',mdl,...
    'UIMode',true);


    msg=message('record_playback:errors:XYViewerReplaced',params.BlockPath);
    Simulink.output.info(msg.getString());
end
