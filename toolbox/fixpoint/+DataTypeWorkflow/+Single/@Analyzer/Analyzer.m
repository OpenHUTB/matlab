classdef Analyzer<handle





    properties(Hidden,Access=private)

        SelectedSystem=''

        TopModel=''

        AllSystemsToScale={}


        SelectedSystemsToScale={}

        MdlRefAccelOnly={}


        MLFBConverter=[]
    end

    properties(SetAccess=private,GetAccess=public)
        DirtyModels={};
    end


    properties(Constant,Access=private)

        ResultFactory=DataTypeWorkflow.Single.ResultFactory

        Settings=struct('SglStr','single',...
        'DblStr','double',...
        'TLSStr','TargetLangStandard',...
        'DefDTStr','DefaultUnderspecifiedDataType',...
        'C89Str','C89/C90 (ANSI)',...
        'C99Str','C99 (ISO)',...
        'DTOStr','DataTypeOverride',...
        'DTOOffStr','Off',...
        'DTOLocalStr','UseLocalSettings',...
        'DTOAppStr','DataTypeOverrideAppliesTo',...
        'DTOAppFpStr','Floating-point',...
        'GenerateComments','on',...
        'ParameterPrecisionLossMsg','none',...
        'DefaultUnderspecifiedDataType','single')
    end


    methods


        function analyzer=Analyzer(analyzerScope,mlfbConverter)
            analyzer.SelectedSystem=analyzerScope.SelectedSystem;
            analyzer.TopModel=analyzerScope.TopModel;
            analyzer.AllSystemsToScale=analyzerScope.AllSystemsToScale;
            analyzer.MdlRefAccelOnly=analyzerScope.MdlRefAccelOnly;
            analyzer.MLFBConverter=mlfbConverter;


            analyzer.SelectedSystemsToScale=analyzerScope.SelectedSystemsToScale;
            analyzer.DirtyModels={};
            analyzer.refreshDirtyModelsList();
        end
    end


    methods

        function reportInfo=check(analyzer)
            reportInfo=analyzer.init();





            reportInfo.TLSSettings=analyzer.updateTLSSettings();


            reportInfo.DTOSettings=analyzer.removeDTOSettings();


            [reportInfo.SolverSettings,reportInfo.configSettings]=analyzer.updateConfigSettings();



            analyzer.refreshDirtyModelsList();









            [reportInfo.err,dblIOs]=analyzer.getDoubleIOs();

            if~isempty(reportInfo.err)
                return
            end




            reportInfo.IncompatibleBlks=analyzer.getIncompatibleBlocks();
            if~isempty(reportInfo.IncompatibleBlks)
                reportInfo.ready=false;
                return;
            end





            [reportInfo.err,reportInfo.StowawayDblBlks,reportInfo.UnsupportedBlks]=analyzer.getStowawayDoubleResults();

            if~isempty(reportInfo.err)
                reportInfo.ready=false;
                return
            end


            if isempty(reportInfo.StowawayDblBlks)
                reportInfo.ready=true;
                return;
            end






            [reportInfo.DTLockedDblBlks]=analyzer.getDTLockedDblBlocks(reportInfo.StowawayDblBlks,dblIOs);

            if~isempty(reportInfo.DTLockedDblBlks)


                reportInfo.ready=true;
                return;
            end



            reportInfo.ready=isempty(reportInfo.UnsupportedBlks);
        end
    end


    methods(Access=private)

        function reportInfo=init(~)









            reportInfo=struct('IncompatibleBlks',[],'TLSSettings',[],...
            'DTOSettings',[],'SolverSettings',[],...
            'StowawayDblBlks',[],'DTLockedDblBlks',[],...
            'UnsupportedBlks',[],'err',[],'ready',false);
        end


        function[err,dblIOs]=getDoubleIOs(analyzer)
            DataTypeWorkflow.Utils.updateDirtyModels(analyzer.DirtyModels,'off');
            dblIOs={};

            err=DataTypeWorkflow.Utils.compileModel(analyzer.TopModel);

            if~isempty(err)
                return
            end

            IOs=analyzer.getIOs();

            for i=1:numel(IOs)
                obj=get_param(IOs{i},'Object');


                if~isempty(obj.CompiledPortDataTypes)
                    if strcmpi(obj.CompiledPortDataTypes.Outport,analyzer.Settings.DblStr)||...
                        strcmpi(obj.CompiledPortDataTypes.Inport,analyzer.Settings.DblStr)
                        blkID=fxptds.SimulinkIdentifier(obj);
                        dblIOs{end+1}=analyzer.ResultFactory.createResult(...
                        struct('ID',blkID,...
                        'SpecifiedDT',obj.OutDataTypeStr,...
                        'CompiledDT',analyzer.Settings.DblStr));%#ok<AGROW>
                    end
                end
            end

            err=DataTypeWorkflow.Utils.termModel(analyzer.TopModel);
            DataTypeWorkflow.Utils.updateDirtyModels(analyzer.DirtyModels,'on');
        end


        function IOs=getIOs(analyzer)
            IOs={};
            for i=1:numel(analyzer.SelectedSystemsToScale)
                system=analyzer.SelectedSystemsToScale{i};


                IOs=vertcat(IOs,find_system(system,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'IncludeCommented','off',...
                'RegExp','on',...
                'BlockType','\<Inport\>|\<Outport\>'));%#ok<AGROW>
            end
        end


        function incompatibleBlks=getIncompatibleBlocks(analyzer)
            incompatibleBlks={};
            for i=1:numel(analyzer.SelectedSystemsToScale)

                sysObj=get_param(analyzer.SelectedSystemsToScale{i},'Object');
                [activeBlks,~]=SimulinkFixedPoint.AutoscalerUtils.getAllBlockList(sysObj);
                for j=1:numel(activeBlks)

                    blkObj=activeBlks(j);
                    if~analyzer.isSingleCompatible(blkObj)
                        data.ID=fxptds.SimulinkIdentifier(blkObj);
                        result=analyzer.ResultFactory.createResult(data);
                        incompatibleBlks{end+1}=result;%#ok<AGROW>
                    end
                end
            end
        end



        function DTLockedDblBlks=getDTLockedDblBlocks(~,stowawayDblBlks,dblIOs)
            DTLockedDblBlks={};



            dblResults=[stowawayDblBlks,dblIOs];

            for i=1:numel(dblResults)
                result=dblResults{i};
                obj=result.ID.getObject();

                if isa(obj,'Simulink.Block')
                    blkAutoscaler=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface().getAutoscaler(obj);
                    pathItems=blkAutoscaler.getPathItems(obj);

                    for j=1:numel(pathItems)



                        isEntryLocked=SimulinkFixedPoint.AutoscalerUtils.IsLocked(obj);


                        if isEntryLocked
                            DTLockedDblBlks{end+1}=result;%#ok<AGROW>
                            break;
                        end
                    end
                end
            end
        end


        function isCompatible=isSingleCompatible(~,blkObj)
            capabilities=blkObj.Capabilities;
            isSingleAnswer=capabilities.supports('single',capabilities.CurrentMode);
            isTypeAgnosticConstruct=DataTypeWorkflow.Advisor.CapabilityManager.knownBlockTypeAgnostic(blkObj);
            isCompatible=strcmpi(isSingleAnswer,'Yes')||isTypeAgnosticConstruct;
        end


        function models=updateTLSSettings(analyzer)
            models=analyzer.getModelsWithTLSC89();
            analyzer.setModelsToTLSC99(models);
        end


        function models=getModelsWithTLSC89(analyzer)
            models={};
            for i=1:numel(analyzer.AllSystemsToScale)
                model=analyzer.AllSystemsToScale{i};
                if~DataTypeWorkflow.Single.Utils.checkConfigSetRef(model)
                    if DataTypeWorkflow.Single.Utils.getIsCheckTLS(model,analyzer.Settings.TLSStr,analyzer.Settings.C89Str,analyzer.Settings.C99Str)
                        models{end+1}=model;%#ok<AGROW>
                    end
                end
            end
        end


        function setModelsToTLSC99(analyzer,models)
            for i=1:numel(models)
                set_param(models{i},analyzer.Settings.TLSStr,analyzer.Settings.C99Str);
            end
        end


        function DTOResults=removeDTOSettings(analyzer)
            DTOResults={};
            setting=analyzer.Settings.DTOLocalStr;
            for i=1:numel(analyzer.SelectedSystemsToScale)
                system=analyzer.SelectedSystemsToScale{i};

                DTOResults=[DTOResults,analyzer.setDTOSetting(system,setting)];%#ok<AGROW>



                subsystems=setdiff(find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem'),system);
                for j=1:numel(subsystems)
                    subsys=subsystems{j};
                    DTOResults=[DTOResults,analyzer.setDTOSetting(subsys,setting)];%#ok<AGROW>
                end
            end

            if~strcmp(analyzer.TopModel,analyzer.SelectedSystem)
                DTOResults=[DTOResults,analyzer.setDTOSetting(analyzer.TopModel,setting)];
            end
        end






        function DTOResults=setDTOSetting(analyzer,system,setting)
            DTOResults={};
            orgSetting=get_param(system,analyzer.Settings.DTOStr);
            if~strcmpi(orgSetting,setting)
                set_param(system,analyzer.Settings.DTOStr,setting);

                DTOResults{end+1}=struct('System',system,...
                'OriginalDTOSetting',orgSetting,'AfterDTOSettings',setting);
            end
        end



        function models=setDefDTSettings(analyzer)
            models={};
            for i=1:numel(analyzer.AllSystemsToScale)
                model=analyzer.AllSystemsToScale{i};
                defDT=get_param(analyzer.TopModel,analyzer.Settings.DefDTStr);
                if~strcmpi(defDT,analyzer.Settings.SglStr)
                    models{end+1}=model;%#ok<AGROW>
                end
            end
        end


        function restoreDefDTSettings(analyzer,models)
            for i=1:numel(models)
                set_param(models{i},analyzer.Settings.DefDTStr,analyzer.Settings.DblStr);
            end
        end


        function applyDTOSingle(analyzer)
            for i=1:numel(analyzer.SelectedSystemsToScale)
                system=analyzer.SelectedSystemsToScale{i};
                set_param(system,analyzer.Settings.DTOStr,analyzer.Settings.SglStr);
                set_param(system,analyzer.Settings.DTOAppStr,analyzer.Settings.DTOAppFpStr);
            end
        end


        function restoredblIOs(~,IOResults)
            for i=1:numel(IOResults)
                result=IOResults{i};
                obj=result.ID.getObject();

                obj.OutDataTypeStr=result.SpecifiedDT;
            end
        end

    end


    methods

        function reportInfo=verify(analyzer)
            reportInfo={};
            reportInfo.StowawayDblBlks={};
            reportInfo.err={};
            [reportInfo.err,reportInfo.StowawayDblBlks,~]=analyzer.getStowawayDoubleResults();
        end

    end

    methods

        function sudSID=getSIDunderSUD(analyzer,listResultSIDs)

            sysSIDs=cellfun(@(x)(Simulink.ID.getSID(x)),analyzer.SelectedSystemsToScale,'UniformOutput',false);

            numResultSIDs=length(listResultSIDs);
            sudSIDsIndx=zeros(1,numResultSIDs);
            for i=1:numResultSIDs
                selectedSID=listResultSIDs{i};
                if Simulink.ID.isValid(selectedSID)
                    for j=1:length(sysSIDs)


                        if Simulink.ID.isDescendantOf(sysSIDs{j},selectedSID)||...
                            strcmp(sysSIDs{j},Simulink.ID.getSimulinkParent(selectedSID))
                            sudSIDsIndx(i)=true;
                            break;
                        end
                    end
                end
            end


            sudSID=listResultSIDs(logical(sudSIDsIndx(:)));
        end
    end


    methods


        function[err,stowDblResults,maybeUnsupported]=getStowawayDoubleResults(analyzer)
            stowDblResults={};
            maybeUnsupported={};

            [err,irResultSIDs]=analyzer.execStowawayDoubleCheck();

            if isempty(irResultSIDs)||~isempty(err)

                return;
            end



            listResultSIDs=unique(irResultSIDs);


            sudSID=analyzer.getSIDunderSUD(listResultSIDs);

            indexNull=[];

            for index=1:numel(sudSID)

                curSID=sudSID{index};

                if Simulink.ID.isValid(curSID)





                    pos=strsplit(curSID,'-');
                    if numel(pos)==2


                        sudSID{index}=Simulink.ID.getParent(curSID);
                    end
                else

                    indexNull(end+1)=index;%#ok<AGROW>
                end
            end

            sudSID(indexNull)=[];
            updatedListResultSIDs=unique(sudSID);
            dataArrayHandler=fxptds.SimulinkDataArrayHandler;
            for idx=1:numel(updatedListResultSIDs)

                blkH=Simulink.ID.getHandle(updatedListResultSIDs{idx});


                if isnumeric(blkH)
                    blkObject=get_param(blkH,'Object');
                else

                    blkObject=blkH;
                end
                if isa(blkObject,'Stateflow.Junction')||...
                    isa(blkObject,'Stateflow.Transition')
                    continue;
                end

                blkID=dataArrayHandler.getUniqueIdentifier(struct('Object',blkObject,'ElementName','1'));

                if~isempty(find(blkObject,'-isa','Stateflow.EMChart','-depth',1))&&...
                    ~SimulinkFixedPoint.TracingUtils.IsUnderLibraryLink(blkObject)





                    [blkErr,msgs]=analyzer.MLFBConverter.check(blkObject.getFullName);

                    resultStruct=struct('ID',blkID,'ErrorMsgs',{msgs});
                    stowDblResults{end+1}=analyzer.ResultFactory.createResult(resultStruct);%#ok<AGROW>

                    if blkErr
                        maybeUnsupported{end+1}=analyzer.ResultFactory.createResult(resultStruct);%#ok<AGROW>
                    end

                    continue
                end

                stowDblResults{end+1}=analyzer.ResultFactory.createResult(struct('ID',blkID));%#ok<AGROW>

                if~isempty(find(blkObject,'-isa','Stateflow.LinkChart',...
                    '-depth',1))||isa(blkObject,'Simulink.MATLABSystem')


                    maybeUnsupported{end+1}=analyzer.ResultFactory.createResult(struct('ID',blkID));%#ok<AGROW>
                end
            end
        end

        function[err,irResults]=execStowawayDoubleCheckSingleModel(~,models)
            err={};
            irResults={};

            for i=1:length(models)



                try
                    checkObj=DataTypeWorkflow.Utils.execStowawayDoubleCheck(models{i});
                catch err
                    return;
                end




                if~checkObj.Success&&(checkObj.ErrorSeverity==100)

                    err=MException('SimulinkFixedPoint:singleconverter:StowawayDoubleErrorDetected',...
                    message('SimulinkFixedPoint:singleconverter:StowawayDoubleErrorDetected').getString());
                    break;
                else
                    irResults=[irResults,checkObj.ProjectResultData];%#ok<AGROW>
                end
            end

        end


        function[err,irResults]=execStowawayDoubleCheck(analyzer)


            analyzer.setupAdvisor();

            modelsForStowawayDoubleCheck=[{analyzer.TopModel},analyzer.MdlRefAccelOnly{:}]';
            [err,irResults]=analyzer.execStowawayDoubleCheckSingleModel(modelsForStowawayDoubleCheck);


            DataTypeWorkflow.Utils.updateDirtyModels(analyzer.DirtyModels,'on');
        end



        function setupAdvisor(analyzer)
            DataTypeWorkflow.Utils.updateDirtyModels(analyzer.DirtyModels,'off');
        end




        function refreshDirtyModelsList(analyzer)
            analyzer.DirtyModels={};
            for i=1:numel(analyzer.AllSystemsToScale)
                if strcmpi(get_param(analyzer.AllSystemsToScale{i},'Dirty'),'on')
                    analyzer.DirtyModels{end+1}=analyzer.AllSystemsToScale{i};
                end
            end
        end


    end
end



