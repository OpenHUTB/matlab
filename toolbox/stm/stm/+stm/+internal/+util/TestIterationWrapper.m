classdef TestIterationWrapper<handle


    methods


        function[overridesCache,originalModelParameters,out]=applyIterationModelParameters(this,modelParams)
            out.messages={};
            out.errorOrLog={};

            len=length(modelParams);


            overridesCache=repmat({0,-1,char.empty}.',[1,len]);

            originalModelParameters=struct('System',{modelParams.System},...
            'Parameter',{modelParams.Parameter},'Value','','Skip',false);
            try
                for k=1:len
                    sysName=modelParams(k).System;

                    originalModelParameters(k).Value=get_param(sysName,modelParams(k).Parameter);

                    set_param(sysName,modelParams(k).Parameter,modelParams(k).Value);

                    overridesCache{1,k}=modelParams(k).Value;
                    overridesCache{2,k}=modelParams(k).Id;

                    [~,overridesCache{3,k}]=stm.internal.util.getDisplayValue(modelParams(k).Value);
                end
            catch me
                [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
                out.messages=[out.messages,tempErrors];
                out.errorOrLog=[out.errorOrLog,tempErrorOrLog];

                overridesCache=[];
                this.resetIterationModelParameters(originalModelParameters);
                originalModelParameters=[];
            end
        end

        function resetIterationModelParameters(~,original)
            arrayfun(@(param)set_param(param.System,param.Parameter,param.Value),...
            original(~[original.Skip]));
        end


        function variableParam=preprocessIterationVariableParameters(~,inVariableParam,modelToRun)
            variableParam=inVariableParam;
            for k=1:length(variableParam)

                if(strcmp(variableParam(k).Source,'base workspace')||strcmp(variableParam(k).Source,'model workspace'))
                    variableParam(k).SourceType=variableParam(k).Source;
                else


                    validSourceType=true;
                    try
                        stm.internal.MRT.share.getMaskParameter(variableParam(k).Source);
                        variableParam(k).SourceType='mask workspace';
                    catch
                        validSourceType=false;
                    end

                    if(~validSourceType)
                        try
                            if(strcmpi(variableParam(k).Source,'data dictionary'))
                                tmpVar=stm.internal.MRT.share.MRTFindVar(modelToRun,'Name',variableParam(k).Name,'SourceType','data dictionary');
                                slddFile=tmpVar(1).Source;
                            else
                                slddFile=variableParam(k).Source;
                            end
                            Simulink.data.dictionary.open(slddFile);
                            variableParam(k).SourceType=slddFile;
                            validSourceType=true;
                        catch
                            validSourceType=false;
                        end
                    end
                    if(~validSourceType)
                        error(message('stm:general:ModelVariableNotFoundBySource',variableParam(k).Source));
                    end
                end
                variableParam(k).RuntimeValue=variableParam(k).Value;
                variableParam(k).IsDerived=~ischar(variableParam(k).Value);
                variableParam(k).Value=variableParam(k).Value;
                variableParam(k).IsChecked=true;
                variableParam(k).IsOverridingChar=false;
            end
        end


        function[overridesCache,originalSigBuilderParameters,out]=applyIterationSigBuilderGroups(~,signalBuilderGroups)
            overridesCache=[];
            originalSigBuilderParameters=[];
            out.messages={};
            out.errorOrLog={};

            if(isempty(signalBuilderGroups))
                return;
            end
            len=length(signalBuilderGroups);


            overridesCache=repmat({0,-1,char.empty}.',[1,len]);

            sigBuilderMaps=cell(len,1);
            originalSigBuilderParameters=repmat(struct('System','','Index',0),len,1);
            try
                for k=1:len
                    blockName=signalBuilderGroups(k).System;
                    groupName=signalBuilderGroups(k).Group;

                    [origianlActiveIndex,~]=signalbuilder(blockName,'activegroup');

                    originalSigBuilderParameters(k).System=blockName;
                    originalSigBuilderParameters(k).Index=origianlActiveIndex;


                    [~,~,~,groupNames]=signalbuilder(blockName);
                    if(isempty(sigBuilderMaps{k}))
                        sigBuilderMaps{k}=Simulink.sdi.Map;
                        for i=1:length(groupNames)
                            sigBuilderMaps{k}.insert(groupNames{i},i);
                        end
                    end
                    if(~sigBuilderMaps{k}.isKey(groupName))
                        error(message('stm:general:SignalBuilderGroupNameNotFound',groupName,blockName));
                    end
                    newGroupIndex=sigBuilderMaps{k}.getDataByKey(groupName);

                    signalbuilder(blockName,'ActiveGroup',newGroupIndex);
                    originalSigBuilderParameters(k).Skip=false;

                    overridesCache{1,k}=signalBuilderGroups(k).System;
                    overridesCache{2,k}=signalBuilderGroups(k).Id;
                    overridesCache{3,k}=signalBuilderGroups(k).Group;
                end
            catch me
                [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
                out.messages=[out.messages,tempErrors];
                out.errorOrLog=[out.errorOrLog,tempErrorOrLog];
            end
        end

        function resetIterationSigBuilderGroups(~,originalSigBuilderParameters)
            for k=1:length(originalSigBuilderParameters)
                blockName=originalSigBuilderParameters(k).System;
                groupIndex=originalSigBuilderParameters(k).Index;
                signalbuilder(blockName,'ActiveGroup',groupIndex);
            end
        end
    end

    methods
        function to=copyStructContent(~,target,from)
            to=target;
            fields=fieldnames(from);
            for k=1:length(fields)
                to.(fields{k})=from.(fields{k});
            end
        end
    end
end
