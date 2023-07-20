function out=getSourceSubsystemHandle(model)




    out=[];
    h=get_param(model,'SubsystemHdlForRightClickBuild');
    if h~=0&&ishandle(h)
        out=h;
    end
