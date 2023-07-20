function out=get(modelName,aCategory,varargin)




    import coder.mapping.internal.*;

    category=lower(aCategory);
    switch category
    case 'simulinkfunction'
        SimulinkFunctionMapping.doEditTimeModelChecks(modelName);

        if~isempty(varargin)
            modelElement=varargin{1};
            if~ischar(modelElement)
                DAStudio.error(...
                'coderdictionary:api:IdentifierNeedsStringForValue',aCategory);
            end
            SimulinkFunctionMapping.validatePublicFunction(modelName,modelElement);
        end

        if length(varargin)==1
            out=SimulinkFunctionMapping.get(modelName,varargin{1});
        else
            out=SimulinkFunctionMapping.getField(modelName,varargin{1},varargin{2});
        end
    case 'subsystemfunction'
        SimulinkFunctionMapping.doEditTimeModelChecks(modelName);

        if~isempty(varargin)
            modelElement=varargin{1};
            if~ischar(modelElement)
                DAStudio.error(...
                'coderdictionary:api:IdentifierNeedsStringForValue',aCategory);
            end
        end

        if length(varargin)==1
            out=coder.dictionary.internal.SubsystemFunctionMapping.get(modelName,varargin{1});
        else
            out=coder.dictionary.internal.SubsystemFunctionMapping.getField(modelName,varargin{1},varargin{2});
        end
    otherwise
        DAStudio.error('coderdictionary:api:InvalidCategory',aCategory);
    end

end


