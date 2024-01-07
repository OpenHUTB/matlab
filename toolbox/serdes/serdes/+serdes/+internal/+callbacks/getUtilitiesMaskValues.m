function[utilitiesMaskNamesValues,utilitiesMaskObj]=getUtilitiesMaskValues(model,utilitiesBlockName,varargin)

    if nargin==2
        targetUtilitiesBlock=find_system(model,'SearchDepth',1,...
        'BlockType','SubSystem',...
        'ReferenceBlock',['serdesUtilities/',utilitiesBlockName]);
        targetUtilitiesBlockSize=size(targetUtilitiesBlock,1);
        if isempty(targetUtilitiesBlock)
            targetUtilitiesBlock=find_system(model,'SearchDepth',1,'BlockType','SubSystem','Name',utilitiesBlockName);
            if~isempty(targetUtilitiesBlock)&&size(targetUtilitiesBlock,1)==1
                warning(message('serdes:callbacks:LinkedUtilitiesBlockNotFound',utilitiesBlockName))
            else
                error(message('serdes:callbacks:UtilitiesBlockNotFound',utilitiesBlockName));
            end
        elseif~isempty(targetUtilitiesBlock)&&targetUtilitiesBlockSize>1
            error(message('serdes:callbacks:UtilitiesBlockMoreThanOne',utilitiesBlockName));
        end

        if iscell(targetUtilitiesBlock)
            targetUtilitiesBlock=targetUtilitiesBlock{1};
        end
    elseif nargin==3
        targetUtilitiesBlock=varargin{1};
    end
    utilitiesMaskObj=Simulink.Mask.get(targetUtilitiesBlock);
    utilitiesMaskNames={utilitiesMaskObj.Parameters.Name};
    utilitiesMaskTypes={utilitiesMaskObj.Parameters.Type};
    utilitiesMaskValues={utilitiesMaskObj.Parameters.Value};
    utilitiesVariablesAllowed=serdes.internal.callbacks.InitConstants.utilitiesVariablesAllowed;

    errorParameters={};
    for paramIdx=1:numel(utilitiesMaskNames)
        if strcmp(utilitiesMaskTypes{paramIdx},'edit')||strcmp(utilitiesMaskTypes{paramIdx},'promote')
            paramAsDouble=str2double(utilitiesMaskValues{paramIdx});
            if isnan(paramAsDouble)
                paramAsNum=str2num(utilitiesMaskValues{paramIdx});%#ok<ST2NM>
                if isempty(paramAsNum)&&~any(strcmp(utilitiesVariablesAllowed,utilitiesMaskNames{paramIdx}))
                    errorParameters{end+1}=utilitiesMaskNames{paramIdx};%#ok<AGROW>
                elseif any(strcmp(utilitiesVariablesAllowed,utilitiesMaskNames{paramIdx}))
                    utilitiesMaskValues{paramIdx}=slResolve(utilitiesMaskValues{paramIdx},model);
                else
                    utilitiesMaskValues{paramIdx}=paramAsNum;
                end
            else
                utilitiesMaskValues{paramIdx}=paramAsDouble;
            end
        end
    end
    if~isempty(errorParameters)
        error(message('serdes:callbacks:VarNotResolved',strjoin(errorParameters,', ')));
    end

    utilitiesMaskNamesValues=cell2struct(utilitiesMaskValues,utilitiesMaskNames,2);
end