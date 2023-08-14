function out=isBuiltinNoRmi(in)







    mdlName=getMdlName(convertStringsToChars(in));
    if isempty(mdlName)
        out=true;
        return;
    end

    exclusionMgr=rmiut.RMExclusionMgr.getInstance();

    out=exclusionMgr.checkCached(mdlName);
    if~isempty(out)
        return;
    end

    [mdlPath,inside_mlroot]=getMdlPath(mdlName);

    if isempty(mdlPath)

        out=exclusionMgr.cache(mdlName,false);
    elseif inside_mlroot

        out=exclusionMgr.check(mdlPath,mdlName);
    else

        out=exclusionMgr.cache(mdlName,false);
    end

end

function mdlName=getMdlName(in)

    if ischar(in)
        mdlName=in;
    else
        try
            mdlName=get_param(in,'Name');
        catch ex




            MSLDiagnostic(ex.identifier,'%s',ex.message).reportAsWarning;
            mdlName='';
        end
    end
end

function[mdlPath,inside_mlroot]=getMdlPath(mdlName)

    inside_mlroot=false;
    if isvarname(mdlName)&&dig.isProductInstalled('Simulink')&&bdIsLoaded(mdlName)
        mdlPath=get_param(mdlName,'FileName');
        if~isempty(mdlPath)
            [mdlPath,inside_mlroot]=Simulink.loadsave.resolveFile(mdlPath);
        end
    else

        [mdlPath,inside_mlroot]=Simulink.loadsave.resolveFile(mdlName);
    end
end




