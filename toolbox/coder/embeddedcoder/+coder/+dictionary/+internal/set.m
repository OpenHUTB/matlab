function set(modelName,aCategory,modelElement,varargin)




    import coder.mapping.internal.SimulinkFunctionMapping;

    category=lower(aCategory);
    switch category
    case 'simulinkfunction'
        SimulinkFunctionMapping.doEditTimeModelChecks(modelName);
        SimulinkFunctionMapping.set(modelName,modelElement,varargin{:});
    otherwise
        DAStudio.error('coderdictionary:api:InvalidCategory',aCategory);
    end

end


