classdef PeripheralsConfigCheck<handle
















    properties
ModelName
    end

    properties
ConfigSet
MdlInfo
PeripheralInfo
PeripheralEntries
    end

    properties(Access=protected)
PeripheralDefinition
    end

    methods
        function obj=PeripheralsConfigCheck(modelName)
            if~ischar(modelName)
                obj.ModelName=get_param(getModel(modelName),'Name');
                obj.ConfigSet=modelName;
            else
                if~bdIsLoaded(modelName)
                    load_system(modelName);
                end
                obj.ModelName=modelName;
                obj.ConfigSet=getActiveConfigSet(modelName);
            end

            [obj.MdlInfo,obj.PeripheralInfo]=codertarget.peripherals.utils.getPeripheralInfoFromRefModels(modelName);
            if~isempty(obj.PeripheralInfo)
                obj.PeripheralEntries=fieldnames(obj.PeripheralInfo);
            end


            defFile=codertarget.peripherals.utils.getDefFileNameForBoard(obj.ConfigSet);
            obj.PeripheralDefinition=codertarget.peripherals.PeripheralInfo(defFile);
        end

        function paramValues=allDifferent(obj,peripheralType,paramsCombination)
            paramValues=[];
            paramsCombination=convertStringsToChars(paramsCombination);
            if~iscell(paramsCombination)
                paramsCombination={paramsCombination};
            end


            if any(strcmp(obj.PeripheralEntries,peripheralType))
                pInfo=obj.PeripheralInfo.(peripheralType);
                paramValues=obj.checkAllDifferentPeripheralInfo(pInfo,peripheralType,paramsCombination);
            end
        end

        function paramValues=allDifferentWithConstraint(obj,peripheralType,paramsCombination,paramCondition,underGroupInfo)
            if nargin<5
                underGroupInfo=[];
            end
            paramValues=[];
            paramsCombination=convertStringsToChars(paramsCombination);
            paramCondition=convertStringsToChars(paramCondition);
            assert(iscell(paramCondition),'paramCondition expected to be an array of cells containing condition.');
            assert(numel(paramCondition)==3,'Should be an array of cells size 3.');


            if any(strcmp(obj.PeripheralEntries,peripheralType))
                pInfo=obj.PeripheralInfo.(peripheralType);
                if~isempty(underGroupInfo)
                    pInfo=obj.getPeripheralGroupInfo(pInfo,underGroupInfo);
                end
                checkSatisfied=arrayfun(@(x)obj.isConstraintSatisfied(x,paramCondition{1},paramCondition{2},paramCondition{3}),pInfo);
                if~isempty(checkSatisfied)
                    pInfo=pInfo(checkSatisfied);
                    paramValues=obj.checkAllDifferentPeripheralInfo(pInfo,peripheralType,paramsCombination);
                end
            end
        end
    end

    methods(Hidden)
        function prompts=getParametersPrompt(obj,peripheralType,paramList,encloseInQuotes)
            if nargin<4
                encloseInQuotes=true;
            else
                encloseInQuotes=logical(encloseInQuotes);
            end

            prompts='';
            if~iscell(paramList)
                paramList={paramList};
            end
            for i=1:numel(paramList)
                prompts=sprintf('%s, %s',prompts,getParameterValue(obj.PeripheralDefinition,peripheralType,paramList{i}).Name);
            end
            prompts(1)=[];
            prompts=strtrim(prompts);
            if~isempty(prompts)
                prompts=regexprep(prompts,'\:\s*\,',',');
            end
            if isequal(prompts(end),':')
                prompts(end)=[];
            end


            if encloseInQuotes
                prompts=sprintf('"%s"',prompts);
                prompts=strrep(prompts,', ','", "');
            end
        end

        function paramValues=checkAllDifferentPeripheralInfo(obj,pInfo,peripheralType,paramsCombination)
            paramValues=arrayfun(@(x)obj.getParameterCombinationString(x,paramsCombination),...
            pInfo,'UniformOutput',false);


            uniqueParamValues=unique(paramValues);
            if~isequal(numel(uniqueParamValues),numel(paramValues))
                paramsList=getParametersPrompt(obj,peripheralType,paramsCombination);

                blocksList='';
                for i=1:numel(uniqueParamValues)
                    sameIdxs=find(strcmp(paramValues,uniqueParamValues{i}));
                    if numel(sameIdxs)>1
                        for j=1:numel(sameIdxs)
                            blockPath=codertarget.peripherals.utils.getBlockPath(pInfo(sameIdxs(j)).ID);

                            blockPathHyp=regexprep(blockPath,'\n',''' newline ''');
                            str=message('codertarget:peripherals:HiliteSystemBlockHyperLink',blockPath,blockPathHyp).getString;
                            blocksList=sprintf('%s, %s\n',str,blocksList);
                        end
                        blocksList=strtrim(blocksList);
                    end
                end
                blocksList=strtrim(blocksList);
                blocksList(end)=[];

                exc=MSLException(message('codertarget:peripherals:ConflictErrorMessage',peripheralType,paramsList,blocksList));
                throwAsCaller(exc);
            end
        end
    end

    methods(Static,Hidden)
        function ret=getParameterCombinationString(peripheralStruct,paramsCombination)
            ret='';
            for i=1:numel(paramsCombination)
                if isfield(peripheralStruct,paramsCombination{i})
                    paramValue=peripheralStruct.(paramsCombination{i});
                    if isnumeric(paramValue)||islogical(paramValue)
                        paramChars=num2str(paramValue);
                    else
                        paramChars=strtrim(convertStringsToChars(paramValue));
                        paramChars=regexprep(paramChars,'\s+','');
                    end
                    ret=sprintf('%s_%s',ret,paramChars);
                end
            end
            if~isempty(ret)
                ret(1)=[];
            end
        end

        function ret=isConstraintSatisfied(peripheralStruct,paramToCheck,checkOpertation,checkValue)
            paramToCheck=convertStringsToChars(paramToCheck);
            checkValue=convertStringsToChars(checkValue);
            checkOpertation=convertStringsToChars(checkOpertation);

            assert(~iscell(checkValue),'checkValue cannot be a cell.');
            validatestring(checkOpertation,{'==','>=','<=','>','>'});
            assert(~iscell(paramToCheck),'paramToCheck should char or string');

            ret=false;
            if isfield(peripheralStruct,paramToCheck)
                validatestring(checkOpertation,{'==','>=','<=','>','>'});
                checkValue=convertStringsToChars(checkValue);


                if isequal(checkOpertation(1),'>')||isequal(checkOpertation(1),'<')
                    validateattributes(checkValue,{'numeric','logical'},{'scalar','nonnan','finite','scalar','real'},'','checkValue');
                end
                switch checkOpertation(1)
                case '>'
                    evalParamValue=evalin('base',peripheralStruct.(paramToCheck));
                    ret=checkValue>evalParamValue;
                case '<'
                    evalParamValue=evalin('base',peripheralStruct.(paramToCheck));
                    ret=checkValue<evalParamValue;
                end

                if isequal(ret,false)&&...
                    (isequal(checkOpertation(1),'=')||(isequal(numel(checkOpertation),2)&&isequal(checkOpertation(2),'=')))
                    if isequal(checkOpertation(1),'=')
                        if isnumeric(checkValue)
                            if~isnumeric(peripheralStruct.(paramToCheck))
                                evalParamValue=evalin('base',peripheralStruct.(paramToCheck));
                            else
                                evalParamValue=peripheralStruct.(paramToCheck);
                            end
                        elseif islogical(checkValue)
                            if~isnumeric(peripheralStruct.(paramToCheck))&&~islogical(peripheralStruct.(paramToCheck))
                                evalParamValue=evalin('base',peripheralStruct.(paramToCheck));
                                evalParamValue=logical(evalParamValue);
                            else
                                evalParamValue=logical(peripheralStruct.(paramToCheck));
                            end
                        else
                            evalParamValue=peripheralStruct.(paramToCheck);
                        end
                    else


                    end

                    ret=isequal(evalParamValue,checkValue);
                end
            end
        end

        function pInfo=getPeripheralGroupInfo(pInfo,groupingInfo)
            groupingInfo=convertStringsToChars(groupingInfo);
            assert(numel(groupingInfo)==2,'groupingInfo should be array of cell elements with two.');
            isSatisfied=arrayfun(@(x)codertarget.peripherals.utils.PeripheralsConfigCheck.isConstraintSatisfied(x,groupingInfo{1},'==',groupingInfo{2}),pInfo);
            if~isempty(isSatisfied)
                pInfo=pInfo(isSatisfied);
            end
        end
    end
end


