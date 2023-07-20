












































classdef(ConstructOnLoad)Configuration<handle


    properties(Constant)
        cEmbeddedCoderPlacement='Embedded Coder default';
        cFlatPlacement='Single folder';
        cCodePlacementMap=containers.Map({slci.Configuration.cEmbeddedCoderPlacement,...
        slci.Configuration.cFlatPlacement},{0,1})
        cDialogTag='SLCIConfigure';
        cSharedUtilityFile='shared_file.dmr';
    end

    properties(Access=private,Transient)
        fDialogHandle=[];
        fCloseListener=[];
        fPostSaveListener=[];
        fInspectProgressBar=[];

        fDisplayResults='None';

        fShowReport=[];

        fEDGOptions=[];

        fUseCustomerSetting=false;

        fUseCustomParserOptions=false;

        fCustomParserOptions=struct('compiler','','target','');

        fSlVerForSLCI=-1;

        fModelObj;

        fCodeInfoTable=containers.Map;

        fWSVarInfoTable=containers.Map;

        fStructFieldsTable=containers.Map;

        fStructIndicesTable=containers.Map;

        fParamsTable=containers.Map;

        fEngineInterface=[];

        fModelMappingTable=[];
        fCustomerReportData=[];
    end

    properties(Access=private)
        fViaGUI=0;
        fModelName='';
        fGenerateCode=false;
        fTerminateOnIncompatibility=false;
        fTopModel=true;
        fFollowModelLinks=false;
        fCodePlacement=slci.Configuration.cEmbeddedCoderPlacement;
        fCodeFolder='';
        fDerivedCodeFolder='';
        fDerivedHeaderPath='';
        fReportFolder='';
        fCompReportFolder='';
        fModelAdvisorReportFolder='';
        fVerbose=false;
        fUtilVerbose=false;
        fTagVerbose=false;
        fRefMdls={};
        fSimulinkCoderVer='';
        fCodeGenDate='';
        fGenTraceability=true;
        fGenVerification=true;
        fGenUtils=true;
        fIncludeTopModelChecksumForRef=false;
        fRefSharedUtilsFolder='';
        fDisableReport=false;
        fReturnReportResults=true;
        fEnableParallel=false;
        fDisableNonInlinedFuncBodyVerification=false;
        fModelSymbolTable=[];
        fIsServicePlatform=false;
    end

    methods(Access=private)
        buildInfo=loadBuildInfoFile(aObj)
        HandleException(aObj,varargin)
        checkForGeneratedCodeExistance(aObj)
        modelLoaded=LoadModel(aObj)
        InitModel(aObj)
        summary=checkModelCompatibility(aObj)
        slprjDir=SlprjFolder(aObj)
        sharedUtilsDir=SharedUtilitiesFolder(aObj)
        childModelDir=ChildModelFolder(aObj,aChildModel)
        ComputeHeaderPath(aObj)
        Result=ExecuteSCI(aObj)
        results=FixSubModels(aObj)
        subModelsSummary=CheckSubModels(aObj)
        summary=genReport(aObj)
        genSummaryReport(aObj,summary)
        createReportFolder(aObj)
        ValidateProperties(aObj)
        configuration=createConfigurationForSubModel(aObj,mdl)
        subModelsSummary=InspectSubModels(aObj)
        summary=CollateResults(aObj,displayMessage,Result,Incompatibilities,...
        FatalIncompatibility,TerminateOnIncompatibility)
        reportResults=returnResultsOnError(aObj,displayResults)
        parseInputsForInspect(aObj,varargin)
        buildCodeInfoTable(aObj)
        buildWSVarInfoStructFieldsTables(aObj)


        setModelSymbolTable(aObj)


        function setServicePlatform(aObj)



            platformType=coder.dictionary.internal.getPlatformType(aObj.fModelName);
            aObj.fIsServicePlatform=strcmpi(platformType,'FunctionPlatform');
        end

        function setModelName(aObj,aName)
            aObj.fModelName=aName;
        end

        function setSimulinkCoderVer(aObj,aSimulinkCoderVer)
            aObj.fSimulinkCoderVer=aSimulinkCoderVer;
        end

        function out=getSimulinkCoderVer(aObj)
            out=aObj.fSimulinkCoderVer;
        end


        function setCodeGenDate(aObj,aCodeGenDate)
            aObj.fCodeGenDate=aCodeGenDate;
        end

        function out=getCodeGenDate(aObj)
            out=aObj.fCodeGenDate;
        end

        function setModelObj(aObj,aModelObj)
            if isa(aModelObj,'slci.simulink.Model')
                aObj.fModelObj=aModelObj;
            else
                DAStudio.error('Slci:compatibility:InvalidModelObjType');
            end
        end

        function setDefaultEDGOptions(aObj)
            aEDGOptions=internal.cxxfe.FrontEndOptions;
            aEDGOptions.KeepRedundantCasts=1;
            aObj.fEDGOptions=aEDGOptions;
        end

        function setRefMdls(aObj,aRefMdls)
            aObj.fRefMdls=aRefMdls;
        end

        function out=getCodePlacementMap(aObj)
            out=aObj.cCodePlacementMap;
        end


        function setReportFolderToDefault(aObj)
            out=aObj.getWorkDir('','check');
            aObj.setReportFolder(out);
        end

        function createSummaryReportFolder(aObj)


            aObj.createReportFolder();
        end

        function setDerivedCodeFolder(aObj,aDerivedCodeFolder)
            if ischar(aDerivedCodeFolder)||isstring(aDerivedCodeFolder)
                aObj.fDerivedCodeFolder=char(aDerivedCodeFolder);
            else
                DAStudio.error('Slci:slci:DerivedCodeFolderMustBeString')
            end
        end


        summary=callInspect(aObj);
        dispResults=getDefaultDisplayResults(aObj);
        showReport=getDefaultShowReport(aObj);
        launchReport(aObj,reportSummary);
        displayResults(aObj,reportSummary);

        function setDisplayResults(aObj,aDisplayResults)
            if strcmpi(aDisplayResults,'None')||strcmpi(aDisplayResults,'Summary')
                aObj.fDisplayResults=aDisplayResults;
            else
                DAStudio.error('Slci:slci:ErrDisplayResults');
            end
        end

        function out=getDisplayResults(aObj)
            out=aObj.fDisplayResults;
        end


        function appendExtraEDGOptions(aObj)
            assert(aObj.fUseCustomParserOptions==true,...
            'No additional parser options present');

            extensions=aObj.getExtraParserOptions();

            aObj.fEDGOptions.ExtraOptions{end+1}='--syntax_extensions_compiler';
            aObj.fEDGOptions.ExtraOptions{end+1}=extensions.compiler;
            aObj.fEDGOptions.ExtraOptions{end+1}='--syntax_extensions_target';
            aObj.fEDGOptions.ExtraOptions{end+1}=extensions.target;
            aObj.fEDGOptions.ExtraOptions{end+1}='--syntax_extensions_file';
            aObj.fEDGOptions.ExtraOptions{end+1}=fullfile(matlabroot,...
            'polyspace','verifier','extensions','extensions.xml');
        end


        function customReportDataSanityCheck(aObj,aStructData,allowInnerStruct)
            dataField=fields(aStructData);
            for i=1:numel(aStructData)
                aSData=aStructData(i);
                for j=1:numel(dataField)
                    if~iscell(dataField)
                        DAStudio.error('Slci:slci:CELL_FIELD_CUSTOM_REPORT_DATA');
                    end

                    structFieldData=aSData.(dataField{j});

                    if(j==1)
                        if isempty(structFieldData)

                            DAStudio.error('Slci:slci:EMPTY_STRUCT_FIELD_DATA')
                        end

                        if~isa(structFieldData,'char')
                            DAStudio.error('Slci:slci:STRING_CUSTOM_REPORT_DATA')
                        end
                    else
                        if isempty(structFieldData)

                            continue;
                        end

                        if~isa(structFieldData,'char')...
                            &&~isa(structFieldData,'struct')
                            DAStudio.error('Slci:slci:STRING_OR_STRUCT_CUSTOM_REPORT_DATA')
                        end

                        if isa(structFieldData,'struct')
                            if allowInnerStruct
                                aObj.customReportDataSanityCheck(structFieldData,false);
                            else

                                DAStudio.error('Slci:slci:STRING_STRUCT_CUSTOM_REPORT_DATA')
                            end
                        end
                    end
                end
            end
        end

    end

    methods(Access=public,Hidden=true)

        result=fixIncompatibilities(aObj)
        dlg=getDialogSchema(aObj,~)
        out=getSLVerForSLCI(aObj)
        out=getTag(aObj,widget)
        out=getWidgetId(aObj,widget)
        out=getWidgetValue(aObj,widget)
        setWidgetValue(aObj,widget,value)
        Progressbar=createCheckProgressBar(aObj)
        createInspectProgressBar(aObj)
        setInspectProgressBarLabel(aObj,aStage)
        deleteInspectProgressBar(aObj)
        title=CreateTitle(aObj)
        summary=genReportSubModels(aObj)
        out=getMatFile(aObj)
        out=getReportFile(aObj)
        out=getSummaryReportFile(aObj)
        disp(aObj)
        [success,msg]=ApplyCB(aObj,dlg,action)
        CloseCB(aObj)
        CheckCompatibilityCB(aObj,dlg)
        CheckCompatibilityTSCB(aObj)
        InspectCB(aObj,dlg)
        out=InspectTSCB(aObj)
        ReportFolderBrowseCB(aObj)
        CodeFolderBrowseCB(aObj)
        incrementHeaderPath(aObj,aHeaderPath)
        reportSummary=callReport(aObj)
        ComputeDerivedCodeFolder(aObj)
        out=getMatlabUtilsMap(aObj)
        out=getSharedUtilsMap(aObj)
        out=getSharedUtilsFile(aObj)
        out=getCodeGenFiles(aObj)
        out=getModelBusSymbolTable(aObj,busName)
        out=getBusNames(aObj);
        out=getModelEnumSymbolTable(aObj);
        SetupRefMdls(aObj)
        GenerateTheCode(aObj)


        function out=getRefMdls(aObj)
            out=aObj.fRefMdls;
        end

        function out=getSfCharts(aObj)
            mdlObj=aObj.getModelObject();
            out=mdlObj.getCharts();
        end

        function out=getEMCharts(aObj)
            mdlObj=aObj.getModelObject();
            out=mdlObj.getEMCharts();
        end

        function aEnableParallel=getEnableParallel(aObj)
            aEnableParallel=aObj.fEnableParallel;
        end

        function setEnableParallel(aObj,aEnableParallel)
            aObj.fEnableParallel=aEnableParallel;
        end

        function aModelObj=getModelObject(aObj)
            aModelObj=aObj.fModelObj;
        end

        function out=getDerivedCodeFolder(aObj)
            out=aObj.fDerivedCodeFolder;
        end

        function out=getSharedUtilsFolder(aObj)
            out=SharedUtilitiesFolder(aObj);
        end

        function out=getFileMapFiles(aObj)
            filename='filemap';
            fileext='.mat';
            mapfilename=fullfile(getSharedUtilsFolder(aObj),...
            [filename,fileext]);
            out='';
            if(exist(mapfilename,'file'))
                matObj=matfile(mapfilename);
                varname='fileMap';
                if(~isempty(who(matObj,varname)))

                    v=values(matObj.fileMap);


                    out=unique(cellfun(@(x)(x.file(1:strfind(x.file,'.')-1)),v,...
                    'UniformOutput',false));
                end
            end
        end

        function out=getModelPath(aObj)%#ok
            out=pwd;
        end


        function out=getFundamentalStepSize(aObj)
            out=aObj.getModelObject.getFundamentalStepSize();
        end

        function out=getHeaderPath(aObj)
            out=aObj.fDerivedHeaderPath;
        end

        function setDisableReport(aObj,disableReport)
            if islogical(disableReport)
                aObj.fDisableReport=disableReport;

                aObj.setReturnReportResults(false);
            else
                DAStudio.error('Slci:slci:ArgMustBeLogical',disableReport);
            end
        end

        function setReturnReportResults(aObj,aReturnReportResults)
            if islogical(aReturnReportResults)
                if aReturnReportResults&&aObj.getDisableReport()
                    DAStudio.error('Slci:slci:ReturnReportResultsError');
                end
                aObj.fReturnReportResults=aReturnReportResults;
            else
                DAStudio.error('Slci:slci:ArgMustBeLogical',aReturnReportResults);
            end
        end


        function out=getDisableReport(aObj)
            out=aObj.fDisableReport;
        end

        function out=getReturnReportResults(aObj)
            out=aObj.fReturnReportResults;
        end

        function setVerbose(aObj,aVerbose)
            if islogical(aVerbose)
                aObj.fVerbose=aVerbose;
            else
                DAStudio.error('Slci:slci:VerboseMustBeLogical')
            end
        end

        function out=getVerbose(aObj)
            out=aObj.fVerbose;
        end


        function setUtilVerbose(aObj,aVerbose)
            if islogical(aVerbose)
                aObj.fUtilVerbose=aVerbose;
            else
                DAStudio.error('Slci:slci:VerboseMustBeLogical')
            end
        end


        function out=getUtilVerbose(aObj)
            out=aObj.fUtilVerbose;
        end


        function setTagVerbose(aObj,aVerbose)
            if islogical(aVerbose)
                aObj.fTagVerbose=aVerbose;
            else
                DAStudio.error('Slci:slci:VerboseMustBeLogical')
            end
        end


        function out=getTagVerbose(aObj)
            out=aObj.fTagVerbose;
        end


        function setViaGUI(aObj,aViaGUI)
            aObj.fViaGUI=aViaGUI;
        end

        function out=getTargetName(aObj)
            systemTargetFile=get_param(aObj.getModelName(),'SystemTargetFile');
            [~,out,~]=fileparts(systemTargetFile);
        end

        function out=getTargetLangSuffix(aObj)
            if strcmpi(get_param(aObj.getModelName(),'TargetLang'),'C')
                out='.c';
            else
                out='.cpp';
            end
        end

        function out=getEDGOptions(aObj)
            out={aObj.fEDGOptions};
        end

        function setUseCustomerSetting(aObj,aUseCustomerSetting)
            if islogical(aUseCustomerSetting)
                aObj.fUseCustomerSetting=aUseCustomerSetting;
            else
                DAStudio.error('Slci:slci:ArgMustBeLogical',aUseCustomerSetting);
            end
        end




        function setExtraParserOptions(aObj)

            extraOptionsMap=slci.internal.EDGExtraOptions();

            prodTargetName=get_param(aObj.fModelName,'ProdHWDeviceType');
            if extraOptionsMap.hasTargetOptions(prodTargetName)
                results=extraOptionsMap.getExtraOptionsForTarget(prodTargetName);

                aObj.fUseCustomParserOptions=true;

                aObj.fCustomParserOptions.compiler=results.compiler;
                aObj.fCustomParserOptions.target=results.target;
            end
        end


        function out=getExtraParserOptions(aObj)
            out=struct('compiler','','target','');
            if aObj.fUseCustomParserOptions
                out=aObj.fCustomParserOptions;
            end
        end

        function setEDGOptions(aObj,aEDGOptions)
            if isa(aEDGOptions,'internal.cxxfe.FrontEndOptions');
                aObj.fEDGOptions=aEDGOptions;
            else
                DAStudio.error('Slci:slci:ArgTypeError',aEDGOptions,'internal.cxxfe.FrontEndOptions');
            end
        end

        function out=getCodeInfo(aObj,mdl_name)
            if isKey(aObj.fCodeInfoTable,mdl_name)
                out=aObj.fCodeInfoTable(mdl_name);
            else
                out=[];
            end
        end

        function out=getWSVarInfoTable(aObj)
            out=aObj.fWSVarInfoTable;
        end

        function out=getStructFieldsTable(aObj)
            out=aObj.fStructFieldsTable;
        end

        function out=getStructIndicesTable(aObj)
            out=aObj.fStructIndicesTable;
        end


        function out=getParamsTable(aObj)
            out=aObj.fParamsTable;
        end

        dmgr=createDataManager(obj,aModelName);

        function setGenVerification(aObj,aGenVerification)
            if islogical(aGenVerification)
                aObj.fGenVerification=aGenVerification;
            else
                DAStudio.error('Slci:slci:ArgMustBeLogical','ShowVerification');
            end
        end

        function out=getGenVerification(aObj)
            out=aObj.fGenVerification;
        end

        function setGenTraceability(aObj,aGenTraceability)
            if islogical(aGenTraceability)
                aObj.fGenTraceability=aGenTraceability;
            else
                DAStudio.error('Slci:slci:ArgMustBeLogical','ShowTraceability');
            end
        end

        function out=getGenTraceability(aObj)
            out=aObj.fGenTraceability;
        end


        function setGenUtils(aObj,aGenUtils)
            if islogical(aGenUtils)
                aObj.fGenUtils=aGenUtils;
            else
                DAStudio.error('Slci:slci:ArgMustBeLogical','ShowUtils');
            end
        end


        function out=getGenUtils(aObj)
            out=aObj.fGenUtils;
        end


        function tf=hasModelMapping(aObj)
            tf=~isempty(aObj.fModelMappingTable)...
            &&aObj.fModelMappingTable.hasModelMapping();
        end


        function out=getModelMappingTable(aObj)
            out=aObj.fModelMappingTable;
        end


        function out=getCustomerReportData(aObj)
            out=aObj.fCustomerReportData;
        end

        dmgr=getDataManager(obj,varargin);










































        function out=getModelAdvisorReportFolder(aObj)
            if isempty(aObj.fModelAdvisorReportFolder)
                BuildDirInfo=RTW.getBuildDir(aObj.getModelName());
                folder=BuildDirInfo.CacheFolder;
                aObj.fModelAdvisorReportFolder=fullfile(folder,'slprj',...
                'modeladvisor','__SYSTEM__By_20Product__Simulink_20Code_20Inspector_',aObj.getModelName);
            end
            out=aObj.fModelAdvisorReportFolder;
        end


        function setModelAdvisorReportFolder(aObj,aDir)
            aObj.fModelAdvisorReportFolder=aDir;
        end


        function out=getModelManager(aObj)
            out='';
            justificationJsonFileName=fullfile(aObj.getReportFolder(),...
            [aObj.getModelName(),'_justification.json']);
            if isfile(justificationJsonFileName)
                out=slci.view.ModelManager(justificationJsonFileName);
            end
        end
    end

    methods(Access=public)

        results=checkCompatibility(aObj,varargin)
        inspectResults=inspect(aObj,varargin)








        function obj=Configuration(varargin)
            if nargin>0



                aModelName=varargin{1};
                if(ischar(aModelName)||isstring(aModelName))...
                    &&~isempty(aModelName)
                    obj.fModelName=char(aModelName);
                else
                    DAStudio.error('Slci:slci:ModelNameMustBeString')
                end

                isHarnessBD=false;
                try
                    isHarnessBD=Simulink.harness.isHarnessBD(aModelName);
                catch ME %#ok<NASGU>

                end
                if isHarnessBD
                    DAStudio.error('Simulink:Harness:SLCINotSupported');
                end
            end

            obj.setDefaultEDGOptions();
        end

        function delete(aObj)
            if~isempty(aObj.fEngineInterface)
                slfeature('EngineInterface',aObj.fEngineInterface);
            end
        end


        function out=isServicePlatform(aObj)
            out=aObj.fIsServicePlatform;
        end

        function out=getModelName(aObj)





























            out=aObj.fModelName;
        end

        function setGenerateCode(aObj,aGenerateCode)








































            if islogical(aGenerateCode)
                aObj.fGenerateCode=aGenerateCode;
            else
                DAStudio.error('Slci:slci:GenerateCodeMustBeLogical')
            end
        end

        function out=getGenerateCode(aObj)












































            out=aObj.fGenerateCode;
        end

        function setTerminateOnIncompatibility(aObj,aTerminateOnIncompatibility)











































            if islogical(aTerminateOnIncompatibility)
                aObj.fTerminateOnIncompatibility=aTerminateOnIncompatibility;
            else
                DAStudio.error('Slci:slci:TerminateOnIncompatibilityMustBeLogical')
            end
        end

        function out=getTerminateOnIncompatibility(aObj)














































            out=aObj.fTerminateOnIncompatibility;
        end

        function setTopModel(aObj,aTopModel)














































            if islogical(aTopModel)
                aObj.fTopModel=aTopModel;
            else
                DAStudio.error('Slci:slci:TopModelMustBeLogical')
            end
        end

        function out=getTopModel(aObj)

















































            out=aObj.fTopModel;
        end

        function setFollowModelLinks(aObj,aFollowModelLinks)












































            if islogical(aFollowModelLinks)
                aObj.fFollowModelLinks=aFollowModelLinks;
            else
                DAStudio.error('Slci:slci:FollowModelLinksMustBeLogical')
            end
        end

        function out=getFollowModelLinks(aObj)















































            out=aObj.fFollowModelLinks;
        end

        function setCodePlacement(aObj,aCodePlacement)























































            map=aObj.getCodePlacementMap();
            if(ischar(aCodePlacement)||isstring(aCodePlacement))...
                &&isKey(map,char(aCodePlacement))
                aObj.fCodePlacement=char(aCodePlacement);
            else
                DAStudio.error('Slci:slci:CodePlacementMustBeString',...
                slci.Configuration.cEmbeddedCoderPlacement,...
                slci.Configuration.cFlatPlacement);
            end
        end

        function out=getCodePlacement(aObj)




















































            out=aObj.fCodePlacement;
        end

        function setCodeFolder(aObj,aCodeFolder)



















































            if ischar(aCodeFolder)||isstring(aCodeFolder)
                aObj.fCodeFolder=char(aCodeFolder);
            else
                DAStudio.error('Slci:slci:CodeFolderMustBeString')
            end
        end

        function out=getCodeFolder(aObj)


















































            out=aObj.fCodeFolder;
        end

        function setReportFolder(aObj,aReportFolder)













































            if(ischar(aReportFolder)||isstring(aReportFolder))...
                &&~isempty(aReportFolder)
                aObj.checkReportFolder(aReportFolder);
                aObj.fReportFolder=char(aReportFolder);
            else
                DAStudio.error('Slci:slci:ReportFolderMustBeString');
            end
        end

        function out=getReportFolder(aObj)















































            if isempty(aObj.fReportFolder)
                aObj.setReportFolderToDefault();
            end
            out=aObj.fReportFolder;
        end


        function out=getCompReportFolder(aObj)






































            if isempty(aObj.fCompReportFolder)
                BuildDirInfo=RTW.getBuildDir(aObj.getModelName());
                folder=BuildDirInfo.CacheFolder;
                aObj.fCompReportFolder=fullfile(folder,'slprj','modeladvisor',aObj.getModelName);
            end
            out=aObj.fCompReportFolder;
        end

        function setIncludeTopModelChecksumForRefModels(aObj,flag)












































            if~islogical(flag)
                DAStudio.error('Slci:slci:ArgMustBeLogical',...
                'getIncludeTopModelChecksumForRefModels');
            else
                aObj.fIncludeTopModelChecksumForRef=flag;
            end
        end

        function out=getIncludeTopModelChecksumForRefModels(aObj)









































            out=aObj.fIncludeTopModelChecksumForRef;
        end
















        function out=getRefSharedUtilsFolder(aObj)
            if isempty(aObj.fRefSharedUtilsFolder)
                aObj.fRefSharedUtilsFolder=...
                fullfile(matlabroot,'toolbox','slci','slci','internal','refutils');
            end
            out=aObj.fRefSharedUtilsFolder;
        end

        function out=getSummaryReportFolder(aObj)

            out=aObj.getReportFolder();
        end

        function setShowReport(aObj,aShowReport)
            if islogical(aShowReport)
                aObj.fShowReport=aShowReport;
            else
                DAStudio.error('Slci:slci:ArgMustBeLogical','ShowReport');
            end
        end

        function out=getShowReport(aObj)
            out=aObj.fShowReport;
        end

        function setCustomerReportDataJson(aObj,jsonfile)



















































            if~exist(jsonfile,'file')
                DAStudio.error('Slci:slci:FILE_NOT_EXISTS',jsonfile);
            end

            try
                txt=fileread(jsonfile);
            catch
                DAStudio.error('Slci:slci:FILE_READ_ERROR',jsonfile);
            end
            aCustomerReportData=jsondecode(txt);

            aObj.setCustomerReportData(aCustomerReportData);
        end

        function setCustomerReportData(aObj,aCustomerReportData)










































            if~isa(aCustomerReportData,'struct')
                DAStudio.error('Slci:slci:STRUCT_CUSTOM_REPORT_DATA');
            end

            aObj.customReportDataSanityCheck(aCustomerReportData,true);

            aObj.fCustomerReportData=aCustomerReportData;
        end


        function setDisableNonInlinedFuncBodyVerification(aObj,aDisableNonInlinedFuncBodyVerification)












































            aObj.fDisableNonInlinedFuncBodyVerification=aDisableNonInlinedFuncBodyVerification;
        end

        function out=getDisableNonInlinedFuncBodyVerification(aObj)













































            out=aObj.fDisableNonInlinedFuncBodyVerification;
        end

    end

    methods(Static=true,Hidden=true)
        saveObjToFile(mdlName,confObj)
        checkReportFolder(aReportFolder);
        checkWorkDir(dir);
        WorkDir=getWorkDir(mdlName,action)
        confObj=loadObjFromFile(mdlName)
        map=ModelToDialogMap();
        CloseListener(aEventSrc,aEventData,aObj)
        PostSaveListener(aBlockDiagramObj,aEventData,aObj)
        summary=formatResults(summary)

        function deleteReportFile(htmlReportFile)
            if exist(htmlReportFile,'file')
                delete(htmlReportFile);
            end
        end


        function out=getSetInspectSharedUtilsValue(varargin)
            persistent Var;
            if nargin
                Var=varargin{1};
            end
            if isempty(Var)

                Var=false;
            end
            out=Var;
        end

        function out=getInspectSharedUtils






















            out=slcifeature('InspectSharedUtils')...
            &&slci.Configuration.getSetInspectSharedUtilsValue;
        end

        function setInspectSharedUtils(aInspectSharedUtils)






















            if islogical(aInspectSharedUtils)
                slci.Configuration.getSetInspectSharedUtilsValue(aInspectSharedUtils);
            else
                DAStudio.error('Slci:slci:InspectSharedUtilsMustBeLogical')
            end
        end

    end
end





