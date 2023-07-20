function validatedP=validateAttachedAssetScalarParameter(p,numAssets,functionName,varName)





%#codegen

    coder.allowpcode('plain');


    if coder.target('MATLAB')
        scalarOrVector='vector';
    else
        scalarOrVector='scalar';
    end
    validateattributes(p,...
    {'numeric'},...
    {'nonempty','finite','real',scalarOrVector},...
    functionName,varName);



    if numAssets>1&&~isscalar(p)
        validateattributes(p,...
        {'double'},...
        {'numel',numAssets},...
        functionName,varName);
    end


    validatedP=reshape(p,1,[]);
end

