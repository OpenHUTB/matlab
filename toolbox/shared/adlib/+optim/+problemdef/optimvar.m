function x=optimvar(name,varargin)






    if(nargin==0)
        throwAsCaller(MException('shared_adlib:optimvar:NotEnoughInputs',...
        getString(message('shared_adlib:optimvar:NotEnoughInputs'))));
    end


    optim.internal.problemdef.mustBeCharVectorOrString(name,'Name');


    name=strip(string(name));


    if~isvarname(name)
        throwAsCaller(MException('shared_adlib:optimvar:NotMATLABVarName',...
        getString(message('shared_adlib:optimvar:NotMATLABVarName',name))));
    end


    ValidNVpairs=["Type","LowerBound","UpperBound"];

    [outNames,outSize,NVpair]=optim.internal.problemdef.formatDimensionInput(varargin);

    if any(outSize<=0)
        throwAsCaller(MException('shared_adlib:OptimizationVariable:CannotCreateEmptyOptimVar',...
        getString(message('shared_adlib:OptimizationVariable:CannotCreateEmptyOptimVar'))));
    end


    x=optim.problemdef.OptimizationVariable(name,outSize,outNames);


    for i=1:2:numel(NVpair)
        fieldName=validatestring(NVpair{i},ValidNVpairs);
        x.(char(fieldName))=NVpair{i+1};
    end

end

