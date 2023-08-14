function[status,fileNames,msg,fullCvgFlag]=sldvAnalysisForBackToBackMode(topModel,model,opts,...
    showUI,harnessOwner,isLibraryHarness,correspondingSILHarnessCodePath)









    initCovData=[];
    opts.ModelCoverageObjectives='EnhancedMCDC';

    isModelInsideCUT=false;

    [useDefaultModeOfEMCDC,potentialDetectionSites]=getDetectionSitesFromCodeDescriptor(...
    topModel,model,[],harnessOwner,isLibraryHarness,correspondingSILHarnessCodePath,isModelInsideCUT);
    if useDefaultModeOfEMCDC
        customEMCDCOpts=[];
    else
        customEMCDCOpts.potentialDetectionSites=potentialDetectionSites;
    end


    preExtract=[];
    sldvClient=Sldv.SessionClient.SimulinkTest;

    [status,fileNames,~,msg,fullCvgFlag]=sldvprivate('sldvRunAnalysis',...
    model,opts,showUI,initCovData,preExtract,...
    customEMCDCOpts,sldvClient);
end

function[useDefaultModeOfEMCDC,potentialDetectionSites]=getDetectionSitesFromCodeDescriptor(topModel,model,...
    potentialDetectionSites,harnessOwner,isLibraryHarness,correspondingSILHarnessCodePath,isModelInsideCUT)





    refMdls=[];
    useDefaultModeOfEMCDC=false;
    isAnalysingHarness=strcmp(get_param(model,'isHarness'),'on');
    if isAnalysingHarness
        CUT=harnessOwner;
    else
        CUT=model;
    end

    if isLibraryHarness
        try






            return;
            harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(model);%#ok<UNRCH>
            [libCodeFolder,contextCodeFolder]=...
            rtw.pil.RLSUtils.getRLSFoldersFromHarnessInfo(harnessInfo);
        catch Mex %#ok<NASGU>

            return;
        end
    elseif~isempty(correspondingSILHarnessCodePath)





        return;
    elseif strcmp(get_param(CUT,'type'),'block')&&...
        strcmp(get_param(CUT,'blockType'),'SubSystem')


        buildDirInfo=RTW.getBuildDir(topModel);
        isTopModel=isfile(...
        fullfile(buildDirInfo.BuildDirectory,'codedescriptor.dmr'));
        useRefModelBuildDir=~isTopModel;
    else
        useRefModelBuildDir=false;
        modelToUseForBuildInfo=model;
        if~isempty(harnessOwner)&&...
            strcmp(get_param(harnessOwner,'Type'),'block_diagram')

            modelToUseForBuildInfo=get_param(harnessOwner,'Name');
        elseif~isempty(harnessOwner)&&...
            strcmp(get_param(harnessOwner,'blockType'),'ModelReference')

            modelToUseForBuildInfo=get_param(harnessOwner,'modelname');
            useRefModelBuildDir=true;
        elseif isModelInsideCUT

            useRefModelBuildDir=true;
        end
        buildDirInfo=RTW.getBuildDir(modelToUseForBuildInfo);
        if~isModelInsideCUT


            modelToExcludeToFetchModelrefs=modelToUseForBuildInfo;



            [refMdls,~]=find_mdlrefs(modelToUseForBuildInfo,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
        end
    end

    try
        if isLibraryHarness
            codeDesc=coder.getCodeDescriptor(contextCodeFolder);%#ok<NODEF>
        elseif useRefModelBuildDir
            codeDesc=coder.getCodeDescriptor(buildDirInfo.ModelRefRelativeBuildDir);
        else
            codeDesc=coder.getCodeDescriptor(buildDirInfo.BuildDirectory);
        end
        bhierarchy=codeDesc.getMF0BlockHierarchyMap;


        [~,loggedSignals]=rtw.connectivity.CodeInfoUtils.getLoggableSignals(bhierarchy);






    catch Mex %#ok<NASGU>


        useDefaultModeOfEMCDC=true;
        return;
    end

    if isAnalysingHarness
        harnessName=get_param(model,'Name');


        modelRefsUsedInCUT=find_mdlrefs(harnessName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'ReturnTopModelAsLastElement',false);
    end

    if~isempty(loggedSignals)
        for i=1:length(loggedSignals)
            portURL=Simulink.URL.parseURL(loggedSignals(i).sid);
            loggedBlock=portURL.getParent;
            loggedOutport=portURL.getIndex;


            if isAnalysingHarness
                loggedBlock=getSIDInHarness(loggedBlock,harnessOwner,harnessName,modelRefsUsedInCUT);
            end
            if isLibraryHarness


                splitStr=regexp(loggedBlock,':','split');
                loggedBlock=model;
                for idx=2:length(splitStr)
                    loggedBlock=[loggedBlock,':',splitStr{idx}];%#ok<AGROW>
                end
            end

            if strcmp(portURL.getKind,'out')
                if isempty(potentialDetectionSites)
                    potentialDetectionSites=struct(...
                    'block',loggedBlock,'outport',loggedOutport);
                else
                    potentialDetectionSites(end+1).block=loggedBlock;%#ok<AGROW>
                    potentialDetectionSites(end).outport=loggedOutport;
                end
            end
        end
    end

    for refMdlsIdx=1:length(refMdls)
        if~strcmp(refMdls{refMdlsIdx},modelToExcludeToFetchModelrefs)

            [useDefaultModeOfEMCDC,potentialDetectionSites]=getDetectionSitesFromCodeDescriptor(...
            topModel,refMdls{refMdlsIdx},potentialDetectionSites,'',false,'',true);
            if useDefaultModeOfEMCDC
                break;
            end
        end
    end
end


function sidOut=getSIDInHarness(sidIn,harnessOwner,harnessName,modelRefsUsedInCUT)
    parts=split(sidIn,':');
    modelName=parts{1};
    idNumber=parts{2};

    if ismember({modelName},modelRefsUsedInCUT)||...
        strcmp(modelName,harnessName)
        sidOut=sidIn;
    else
        inBlockFullName=getfullname(sidIn);
        if strcmp(inBlockFullName,harnessOwner)
            sidOut=[harnessName,':1'];
        elseif startsWith(inBlockFullName,harnessOwner)
            sidOut=[harnessName,':1:',idNumber];
        else
            sidOut=sidIn;
        end
    end
end


