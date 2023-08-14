function validate(modelName,aCategory,varargin)


    import coder.mapping.internal.*;

    modelElement=[];
    if~isempty(varargin)
        modelElement=varargin{1};
    end

    category=lower(aCategory);
    switch category
    case 'simulinkfunction'
        SimulinkFunctionMapping.doEditTimeModelChecks(modelName);
        if~isempty(modelElement)
            SimulinkFunctionMapping.validate(modelName,modelElement);
        else
            SimulinkFunctionMapping.validateAll(modelName);
        end
    otherwise
        DAStudio.error('coderdictionary:api:InvalidCategory',aCategory);
    end

end

