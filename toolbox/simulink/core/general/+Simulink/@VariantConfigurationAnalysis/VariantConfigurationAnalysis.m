classdef(Sealed)VariantConfigurationAnalysis<matlab.mixin.Copyable











































































    properties(SetAccess=private,GetAccess=public)
        ModelName char;
        Configurations cell;
    end

    properties(Access=private,Hidden)

        mBDMgr vmgrcfgplugin.VariantConfigurationManager;

        mBlkAnalysisInfo;

        mAnalysisUI webcfganalysis.AnalysisUI;

        mIsCacheSuccess logical;

        configInfoCell cell;

        configurationI;
    end

    methods

        function obj=VariantConfigurationAnalysis(modelName,varargin)




            [isInstalled,err]=slvariants.internal.utils.getVMgrInstallInfo('Variant Analyzer');
            if~isInstalled
                throwAsCaller(err);
            end

            if nargin==1

                errmsg=message('Simulink:VariantManager:ConfigNotSpec');
                err=MException(errmsg);
                throwAsCaller(err);
            end


            persistent p
            if isempty(p)
                p=inputParser;
                p.FunctionName='Simulink.VariantConfigurationAnalysis';
                p.StructExpand=false;
                p.PartialMatching=false;
                checkModelName=@(x)validateattributes(x,{'char','string'},{'scalartext'});
                addRequired(p,'ModelName',checkModelName);
                addParameter(p,'NamedConfigurations',{},...
                @(x)validateattributes(x,{'char','cell','string'},{'nonempty','vector'}));
                if slfeature('VariableGroupSupportConfigAnalysis')>0
                    addParameter(p,'VariableGroups',{},...
                    @(x)validateattributes(x,{'struct'},{'nonempty','vector'}));
                end

            end


            try
                parse(p,modelName,varargin{:});
            catch ME
                throwAsCaller(ME);
            end

            if slfeature('VariableGroupSupportConfigAnalysis')>0&&~isempty(p.Results.NamedConfigurations)&&~isempty(p.Results.VariableGroups)
                errid='Simulink:VariantManager:MultipleConfigSpecified';
                errmsg=message(errid);
                err=MException(errmsg);
                throwAsCaller(err);
            end

            modelName=i_convertStringsToChar(modelName);



            try
                isBdLoaded=bdIsLoaded(modelName);
            catch ME
                throwAsCaller(ME);
            end

            if~isBdLoaded
                errmsg=message('Simulink:VariantManager:ModelNotLoaded',modelName);
                err=MException(errmsg);
                throwAsCaller(err);
            end



            dirty=get_param(modelName,'dirty');
            if strcmp(dirty,'on')


                errid='Simulink:Variants:InvalidModelArgDirty';
                errmsg=message(errid,modelName);
                err=MException(errmsg);
                throwAsCaller(err);
            end

            if Simulink.variant.utils.getIsSimulationPausedOrRunning(modelName)



                errid='Simulink:VariantManager:AnalyzingWhileRunningSimulationNotSupported';
                errmsg=message(errid,modelName);
                err=MException(errmsg);
                throwAsCaller(err);
            end

            if Simulink.variant.utils.getIsModelInCompiledState(modelName)


                errid='Simulink:VariantManager:AnalyzingWhileCompiledNotSupported';
                errmsg=message(errid,modelName);
                err=MException(errmsg);
                throwAsCaller(err);
            end

            if~isempty(p.Results.NamedConfigurations)
                configNames=p.Results.NamedConfigurations;

                obj.configurationI=Simulink.variant.configurationstrategy.NamedConfiguration(modelName);

                if isempty(Simulink.variant.utils.getConfigurationDataNoThrow(modelName))
                    msgId='Simulink:Variants:VCDONotFound';
                    errmsg=message(msgId,modelName);
                    err=MException(errmsg);
                    throwAsCaller(err);
                end

            elseif slfeature('VariableGroupSupportConfigAnalysis')>0

                try


                    validateGroups(p.Results.VariableGroups);
                catch ME


                    msgId='Simulink:VariantManager:InvalidGroupSyntax';
                    msg=message(msgId);
                    topException=MException(msg);
                    topException=topException.addCause(ME);
                    throwAsCaller(topException);
                end

                [configNames,configCell]=createVariableGroups(p.Results.VariableGroups,modelName);
                obj.configInfoCell=configCell;
                obj.configurationI=Simulink.variant.configurationstrategy.VariableConfiguration(modelName);

            end
            configNames=i_convertStringsToChar(configNames);

            if(~iscell(configNames))
                configNames={configNames};
            end


            configNames=unique(configNames);


            obj.ModelName=modelName;
            obj.Configurations=configNames;



            modelHandle=get_param(modelName,'Handle');
            Simulink.addBlockDiagramCallback(modelHandle,...
            'PreClose','variantconfigurationanalysis',...
            @()Simulink.VariantConfigurationAnalysis.handleModelClose(modelHandle),true);
            Simulink.addBlockDiagramCallback(modelHandle,...
            'PostNameChange','variantconfigurationanalysis',...
            @()Simulink.VariantConfigurationAnalysis.handleModelRename(modelName),true);

            obj.mIsCacheSuccess=false;
        end


        function delete(obj)


            if~isempty(obj.ModelName)&&bdIsLoaded(obj.ModelName)
                modelHandle=get_param(obj.ModelName,'Handle');
                modelObject=get_param(modelHandle,'Object');
                id='variantconfigurationanalysis';
                if modelObject.hasCallback('PreClose',id)
                    Simulink.removeBlockDiagramCallback(modelHandle,'PreClose',id);
                end
                if modelObject.hasCallback('PostNameChange',id)
                    Simulink.removeBlockDiagramCallback(modelHandle,'PostNameChange',id);
                end
            end

            obj.mAnalysisUI.delete;

        end


        activeBlocks=getActiveBlocks(obj,configName)



        alwaysActiveBlocks=getAlwaysActiveBlocks(obj)



        diffBlocks=getBlockDifferences(obj)



        neverActiveBlocks=getNeverActiveBlocks(obj)



        depLibs=getDependentLibraries(obj,configName)


        depModels=getDependentModels(obj,configName)



        showUI(obj)


        hideUI(obj)


        varCond=getVariantCondition(obj,configName,blockPath);

    end

    methods(Access=public,Hidden)
        function toggleDatamodelEditFlag(obj)
            obj.mBDMgr.toggleModelEditFlag();
        end
    end

    methods(Access=private,Hidden)

        blockInfoStructVec=analyzeBlocks(obj)


        cacheData(obj,analyze)
    end

    methods(Access=private,Hidden,Static)

        isSubsysType=getIsSubsystemType(blockType)


        function handleModelClose(modelHandle)

            modelName=get_param(modelHandle,'Name');
            if webcfganalysis.AnalysisUI.isWindowOpen(modelName)
                analysisUIMgr=webcfganalysis.AnalysisUIMgr.getInstance();
                analysisUI=analysisUIMgr.getAnalysisUI(modelName);
                if~isempty(analysisUI)
                    analysisUI.delete;
                end
            end
        end


        function handleModelRename(oldModelName)

            if webcfganalysis.AnalysisUI.isWindowOpen(oldModelName)
                analysisUIMgr=webcfganalysis.AnalysisUIMgr.getInstance();
                analysisUI=analysisUIMgr.getAnalysisUI(oldModelName);
                if~isempty(analysisUI)
                    analysisUI.delete;
                end
            end
        end
    end

    methods(Hidden,Access={?mwslvariants.configanalysis.BlockTester})
        function url=getUrl(obj)
            if isempty(obj.mAnalysisUI)
                obj.cacheData(false);

                obj.mAnalysisUI=webcfganalysis.AnalysisUI(obj.mBDMgr);
            end
            url=obj.mAnalysisUI.getUrl();
        end


        writeModelToJSON(obj)
    end

    methods(Hidden,Access=public,Static)
        function help

            helpview(fullfile(docroot,'toolbox','simulink','helptargets.map'),'variantconfigurationanalysis');
        end
    end

end


function output=i_convertStringsToChar(input)
    if isstring(input)
        output=convertStringsToChars(input);
    elseif iscell(input)
        output=cellfun(@(x)i_convertStringsToChar(x),input,'UniformOutput',false);
    else
        output=input;
    end
end


function[configNames,configCell]=createVariableGroups(varGroupData,modelName)
    configInfos=varGroupData;


    configInfos=Simulink.variant.reducer.utils.preprocessConfigInfo(configInfos,false);

    configImplObj=Simulink.variant.variablegroups.MFModelImpl(modelName,configInfos);

    vtcObj=Simulink.variant.variablegroups.VarsToConfigImpl();
    vtcObj.convertVarsToObject(configImplObj);

    configCell=configImplObj.updatedConfigGroups;

    configNames=cell(1,length(configCell));
    for cVar=1:length(configCell)
        configNames{cVar}=configCell{cVar}{1};
    end
end

function validateGroups(groups)



    validateGroupStruct(groups);



    for grpId=1:numel(groups)
        try
            validateGroupName(groups(grpId).Name);
            validateControlVars(groups(grpId).VariantControls);
        catch ME
            msgid='Simulink:VariantManager:InvalidGroup';
            msg=message(msgid,groups(grpId).Name);
            excep=MException(msg);
            excep=excep.addCause(ME);
            throw(excep);
        end
    end
end

function validateGroupStruct(groups)
    actualFields=sort(fields(groups));
    expectedFields={'Name';'VariantControls'};
    if~isequal(actualFields,expectedFields)


        msgid='Simulink:VariantManager:InvalidGroupStruct';
        excep=MException(message(msgid));
        throw(excep);
    end
end

function validateGroupName(groupName)
    if~isvarname(groupName)


        msgid='Simulink:VariantManager:InvalidGroupName';
        msg=message(msgid,groupName);
        excep=MException(msg);
        throw(excep);
    end
end

function validateControlVars(varCtrls)

    if mod(numel(varCtrls),2)~=0


        msgid='Simulink:VariantManager:InvalidGroupNameValue';
        msg=message(msgid);
        excep=MException(msg);
        throw(excep);
    end

    for varCtrlId=1:2:numel(varCtrls)-1

        validateCtrlVarName(varCtrls{varCtrlId});


        validateCtrlVarValue(varCtrls{varCtrlId},varCtrls{varCtrlId+1});
    end
end

function validateCtrlVarName(varCtrlName)
    if~isvarname(varCtrlName)


        msgid='Simulink:VariantManager:InvalidCtrlVarName';
        msg=message(msgid,varCtrlName);
        excep=MException(msg);
        throw(excep);
    end
end

function validateCtrlVarValue(varCtrlName,varCtrlValue)
    if~isa(varCtrlValue,'Simulink.Parameter')&&...
        ~isa(varCtrlValue,'Simulink.VariantControl')&&...
        (any(~isnumeric(varCtrlValue))||any(~isfinite(varCtrlValue)))


        msgid='Simulink:VariantManager:InvalidCtrlVarValue';
        msg=message(msgid,varCtrlName);
        excep=MException(msg);
        throw(excep);
    end
end



