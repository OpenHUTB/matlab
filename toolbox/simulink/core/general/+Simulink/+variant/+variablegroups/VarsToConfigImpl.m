classdef VarsToConfigImpl<handle




    properties
    end
    methods
        function obj=VarsToConfigImpl()
        end

        function convertVarsToObject(~,groupI)

            modelName=groupI.modelName;
            origModelName=groupI.origModelName;
            variableGroups=groupI.variableGroups;

            function isSLVarCtrl=getIsSLVarCtrl(ctrlVarValue)
                isSLVarCtrl=isa(ctrlVarValue,'Simulink.VariantControl');
            end








            cVarsSpecified=Simulink.VariantManager.findVariantControlVars(origModelName);

            GroupNameMultipleCountsMap=[];
            if isstruct(variableGroups)&&Simulink.variant.reducer.utils.isVarGroupNameSyntaxStructValid(variableGroups)
                GroupNameMultipleCountsMap=containers.Map('KeyType','char','ValueType','logical');
                fn=fieldnames(variableGroups);
                groupNames={variableGroups.(fn{1})};
                for i=1:numel(groupNames)
                    if GroupNameMultipleCountsMap.isKey(groupNames{i})&&~GroupNameMultipleCountsMap(groupNames{i})




                        GroupNameMultipleCountsMap(groupNames{i})=true;
                    else
                        GroupNameMultipleCountsMap(groupNames{i})=false;
                    end
                end
            end
            GroupNamePrefixMap=containers.Map('KeyType','char','ValueType','double');
            isVarGroupNameSyntax=isstruct(variableGroups)&&Simulink.variant.reducer.utils.isVarGroupNameSyntaxStructValid(variableGroups);
            if isVarGroupNameSyntax
                varGroupNameStructSyntaxFields=fields(variableGroups);
            end
            for i=1:numel(variableGroups)
                if isVarGroupNameSyntax


                    configurationPrefix=variableGroups(i).(varGroupNameStructSyntaxFields{1});
                    controlVarNameValuePairs=variableGroups(i).(varGroupNameStructSyntaxFields{2});
                else
                    configurationPrefix='Configuration';
                    controlVarNameValuePairs=variableGroups{i};
                end
                controlVarNames=controlVarNameValuePairs(1:2:(end-1));
                controlVarValues=controlVarNameValuePairs(2:2:end);



                isSLVarCtrlVec=cellfun(@(value)(getIsSLVarCtrl(value)),controlVarValues,'UniformOutput',true);
                slVarCtrlNameValueMap=containers.Map;
                for varCtrlIdx=1:numel(isSLVarCtrlVec)
                    if isSLVarCtrlVec(varCtrlIdx)
                        slVarCtrlNameValueMap(controlVarNames{varCtrlIdx})=controlVarValues{varCtrlIdx};
                    end
                end
                controlVarValues(isSLVarCtrlVec)=cellfun(@(varCtrl)(varCtrl.Value),controlVarValues(isSLVarCtrlVec),'UniformOutput',false);

                numControlVarNames=numel(controlVarNames);
                numControlVarValues=zeros(1,numControlVarNames);

                for k=1:numControlVarNames
                    numControlVarValues(1,k)=numel(controlVarValues{k});
                end


                numConfigs=prod(numControlVarValues);

                if numConfigs==0


                    strEmptyVal=i_cellOfStringsToCSV(controlVarNames(numControlVarValues==0));
                    errid='Simulink:VariantReducer:VarConfigWithEmptyValues';
                    err=MException(message(errid,strEmptyVal,origModelName));
                    throwAsCaller(err);
                end

                matrixOfControlVariableValues=cell(1,numControlVarNames);







                if~isempty(numControlVarValues)
                    [matrixOfControlVariableValues{end:-1:1}]=ii_ndgrid(controlVarValues{end:-1:1});
                end





                if slfeature('VMGRV2UI')>0
                    searchReferencedModels=true;
                    [~,ctrlVarsUsageMap]=slvariants.internal.manager.core.getVariantControlVarInBlocksWithSources(modelName,searchReferencedModels);
                else
                    optArgs=Simulink.variant.utils.getControlVariableNamesFromVariantExpressionsOptArgs();
                    optArgs.RecurseIntoModelReferences=true;optArgs.KnownControlVariables=controlVarNames;
                    [~,~,sourceInfo]=...
                    Simulink.variant.utils.getControlVariableNamesFromVariantExpressions(modelName,optArgs);
                    varsToDataDictionaryMap=Simulink.variant.utils.i_invertMap(sourceInfo.DataDictionaryToVarsMap);
                end

                for k=1:numConfigs
                    if GroupNamePrefixMap.isKey(configurationPrefix)
                        GroupNamePrefixMap(configurationPrefix)=GroupNamePrefixMap(configurationPrefix)+1;
                    else
                        if isempty(GroupNameMultipleCountsMap)||GroupNameMultipleCountsMap(configurationPrefix)||(numConfigs>1)


                            GroupNamePrefixMap(configurationPrefix)=1;
                        end
                    end

                    if GroupNamePrefixMap.isKey(configurationPrefix)
                        configSuffix=['_',Simulink.variant.reducer.utils.i_num2str(GroupNamePrefixMap(configurationPrefix))];
                    else


                        configSuffix='';
                    end

                    nameOfConfig=[configurationPrefix,configSuffix];


                    ctrlVariables=struct('Name',{},'Value',{},'Source',{});

                    ctrlVarIdx=0;
                    for kk=1:numel(controlVarNames)
                        sourcesForCtrlVar={};
                        if slfeature('VMGRV2UI')>0
                            if ctrlVarsUsageMap.isKey(controlVarNames{kk})
                                sourcesForCtrlVar=ctrlVarsUsageMap(controlVarNames{kk});
                            end
                        else
                            if varsToDataDictionaryMap.isKey(controlVarNames{kk})
                                sourcesForCtrlVar=varsToDataDictionaryMap(controlVarNames{kk});
                            end
                        end
                        nSourcesForCtrlVar=numel(sourcesForCtrlVar);

                        for kkk=0:nSourcesForCtrlVar
                            if kkk==0&&nSourcesForCtrlVar~=0
                                continue;
                            end
                            ctrlVarIdx=ctrlVarIdx+1;
                            ctrlVariables(ctrlVarIdx).Name=controlVarNames{kk};
                            if nSourcesForCtrlVar~=0
                                ctrlVariables(ctrlVarIdx).Source=sourcesForCtrlVar{kkk};
                            else
                                ctrlVariables(ctrlVarIdx).Source='';
                            end
                            cvIdx=Simulink.variant.reducer.utils.searchNameInCell(controlVarNames{kk},{cVarsSpecified.Name});
                            cvvSpecified=0;
                            if~isempty(cvIdx)

                                cvvSpecified=cVarsSpecified(cvIdx).Value;
                            end


                            cvv=matrixOfControlVariableValues{kk}(k);
                            cvv=groupI.getControlVariableValue(cvv,cvvSpecified,slVarCtrlNameValueMap.isKey(controlVarNames{kk}));
                            ctrlVariables(ctrlVarIdx).Value=cvv;
                        end
                    end




                    groupI.createConfig(nameOfConfig,ctrlVariables,slVarCtrlNameValueMap);
                end
            end
        end
    end
end

function varargout=ii_ndgrid(varargin)






    nout=max(nargout,nargin);
    if nargin==1
        if nargout<2
            varargout{1}=varargin{1}(:);
            return



        end
    else
        jIdx=1:nout;
        siz=cellfun(@numel,varargin);
    end

    varargout=cell(1,max(nargout,1));
    if nout==2
        x=(varargin{jIdx(1)}(:));
        y=(varargin{jIdx(2)}(:)).';
        varargout{1}=repmat(x,size(y));
        varargout{2}=repmat(y,size(x));
    else
        for iIdx=1:max(nargout,1)
            x=(varargin{jIdx(iIdx)});
            s=ones(1,nout);
            s(iIdx)=numel(x);
            x=reshape(x,s);
            s=siz;
            s(iIdx)=1;
            varargout{iIdx}=repmat(x,s);
        end
    end
end



function stringCSV=i_cellOfStringsToCSV(cellArrayOfStrings)


    stringCSV=strjoin(cellArrayOfStrings,', ');
end


