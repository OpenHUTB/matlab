function out=isTargetDefined(targetName)



    narginchk(1,1);
    tgs=slrealtime.Targets;
    try
        if isempty(targetName)
            out=~isempty(tgs.getTarget());
        else
            out=~isempty(tgs.getTarget(targetName));
        end
    catch
        out=false;
    end
end

