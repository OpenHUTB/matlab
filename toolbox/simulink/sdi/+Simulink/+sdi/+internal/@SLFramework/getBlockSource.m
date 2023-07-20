function out=getBlockSource(~,bpath,sid)



    out=bpath;
    try
        bpath=Simulink.ID.getFullName(sid);
    catch me %#ok<NASGU>
        return
    end
    out=bpath;
end
