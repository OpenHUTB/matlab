function simdFcn=createSimdFunction(varargin)
    p=inputParser;
    p.addParameter('Name','');
    p.addParameter('Operation',[]);
    p.addParameter('ReturnType','void');
    p.addParameter('InputTypes',{'void'});
    p.addParameter('Includes','');
    p.addParameter('SystemIncludes',{});

    p.parse(varargin{:});
    result=p.Results;

    if ismember('Name',p.UsingDefaults)
        error('Name must be set for a target simd function');
    end
    simdFcn=target.internal.create('Function','Name',result.Name);

    if ismember('Operation',p.UsingDefaults)
        error('Operation must be set for a target simd function');
    end
    simdFcn.Operation=result.Operation;

    simdFcn.ReturnType=result.ReturnType;
    if~isempty(result.InputTypes)
        inputs=loc_createInputs(result.InputTypes);
        simdFcn.Inputs=inputs;
    end

    if~isempty(result.Includes)
        simdFcn.Includes={result.Includes};
    end

    if~isempty(result.SystemIncludes)
        simdFcn.SystemIncludes=result.SystemIncludes;
    end

end

function inputs=loc_createInputs(inputTypesArray)
    assert(~isempty(inputTypesArray));

    numInput=length(inputTypesArray);
    for i=1:numInput
        inputName=['u',num2str(i)];
        inputType=inputTypesArray{i};
        inputs(i)=target.internal.create('Input','Name',inputName,'Type',inputType);
    end
end