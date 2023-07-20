function[targetVersion,idx]=getTargetVersion(props)



    idx=find(arrayfun(@(x)isequal(x.Name,'TargetVersion'),props));
    if any(idx)
        try
            targetVersion=feval(props(idx(1)).GetMethod);
        catch ME
            warning(ME.identifier,ME.message);%#ok<MEXCEP>


            targetVersion=1;
        end
        if~isscalar(targetVersion)||~isa(targetVersion,'double')
            warning(ME.identifier,'Target version must be a scalar double.');
            targetVersion=1;
        end
    else
        targetVersion=[];
    end
end

