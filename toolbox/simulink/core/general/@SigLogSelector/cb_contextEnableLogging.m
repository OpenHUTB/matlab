function cb_contextEnableLogging(varargin)





    node=SigLogSelector.getSelectedSubsystem();
    if isempty(node)||~node.isLoaded||~node.isValid()
        return;
    end


    numArgs=length(varargin);
    bEnable=true;
    if numArgs>0
        bEnable=varargin{1};
    end
    sigType='all';
    if numArgs>1
        sigType=varargin{2};
    end
    bRecurse=false;
    if numArgs>2
        bRecurse=varargin{3};
    end


    me=SigLogSelector.getExplorer;
    act=me.getAction('VIEW_MASKS');
    if strcmpi(act.on,'on')
        maskOpt='all';
    else
        maskOpt='graphical';
    end
    act=me.getAction('VIEW_LINKS');
    if strcmpi(act.on,'on');
        linkOpt='on';
    else
        linkOpt='off';
    end


    bpath=node.getFullMdlRefPath();


    me.sleep;


    try
        mi=node.getModelLoggingInfo();
        mi=mi.enableLoggingOnPort(...
        bpath,...
        bEnable,...
        sigType,...
        bRecurse,...
        linkOpt,...
        maskOpt);
        node.setModelLoggingInfo(mi);
    catch e %#ok<NASGU>
    end


    node.refreshSignals;
    me.wake;

end