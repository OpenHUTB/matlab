function out=getNewSubsystemName(model)




    out='';
    h=get_param(model,'NewSubsystemHdlForRightClickBuild');
    if h~=0
        out=getfullname(h);
    end


