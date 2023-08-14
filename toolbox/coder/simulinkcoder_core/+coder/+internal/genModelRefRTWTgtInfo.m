function[exMdlInfos]=genModelRefRTWTgtInfo...
    (model,tgtType,pilModelBlocks,lParentModel)









    protectedMdlRefs={};
    protectedMdlRefInfoStructMap=containers.Map('KeyType','char','ValueType','any');
    isXIL=~isempty(pilModelBlocks);
    if isXIL
        lParentSystemTargetFile=...
        strtrim(coder.internal.getCachedAccelOriginalSTF(lParentModel,false));
        mdlRefsAll=pilModelBlocks;
        isProtected=false(size(mdlRefsAll));
        for i=1:length(isProtected)
            isProtected(i)=slInternal('getReferencedModelFileInformation',mdlRefsAll{i});
        end
        lSystemTargetFiles=cell(size(mdlRefsAll));
        lSystemTargetFiles(isProtected)=...
        repmat({lParentSystemTargetFile},size(mdlRefsAll(isProtected)));
        lSystemTargetFiles(~isProtected)=...
        get_param(mdlRefsAll(~isProtected),'SystemTargetFile');
    else


        lParentSystemTargetFile=get_param(lParentModel,'SystemTargetFile');





        infoStruct=coder.internal.infoMATPostBuild...
        ('load','minfo',model,tgtType,lParentSystemTargetFile);
        mdlRefs=unique(infoStruct.modelRefs);
        mdlRefsAll=mdlRefs';

        [protectedMdlRefs,iOrder]=unique(infoStruct.protectedModelRefs);
        protectedMdlRefBuildDirs=infoStruct.protectedModelRefsBuildDirsAll(iOrder);

        for imdl=1:length(mdlRefs)



            infoStructRef=i_loadBinfoForRTW(mdlRefs{imdl},lParentSystemTargetFile);

            mdlRefsAll=unique([mdlRefsAll,infoStructRef.modelRefsAll]);
            if~isempty(infoStructRef.protectedModelRefs)
                [protectedMdlRefs,iOrder]=unique([protectedMdlRefs,infoStructRef.protectedModelRefs],'stable');
                protectedMdlRefBuildDirs=[protectedMdlRefBuildDirs,infoStructRef.protectedModelRefsBuildDirsAll];
                protectedMdlRefBuildDirs=protectedMdlRefBuildDirs(iOrder);
            end
        end


        imdl=1;
        while imdl<=length(protectedMdlRefs)
            pModel=protectedMdlRefs{imdl};
            pBuildDir=protectedMdlRefBuildDirs{imdl};
            if isempty(pBuildDir)
                pBuildDir=RTW.getBuildDir(pModel,'ModelRefRelativeBuildDir');
            end

            binfoPath=fullfile(Simulink.fileGenControl('get','CodeGenFolder'),pBuildDir,'tmwinternal','binfo_mdlref.mat');
            infoStructRef=coder.internal.infoMATFileMgr...
            ('loadPostBuild','binfo',pModel,'RTW',binfoPath,false);
            [protectedMdlRefs,iOrder]=unique([protectedMdlRefs,infoStructRef.modelRefsAll],'stable');
            protectedMdlRefBuildDirs=[protectedMdlRefBuildDirs,infoStructRef.modelRefsBuildDirsAll];
            protectedMdlRefBuildDirs=protectedMdlRefBuildDirs(iOrder);
            protectedMdlRefInfoStructMap(pModel)=infoStructRef;
            imdl=imdl+1;
        end

        lSystemTargetFiles=repmat({lParentSystemTargetFile},size(mdlRefsAll));
    end






    mdlInfoLength=length(mdlRefsAll);
    protMdlInfoLength=length(protectedMdlRefs);
    exMdlInfos={};
    for imdl=1:mdlInfoLength
        mdlRef=mdlRefsAll{imdl};
        coder.internal.modelRefUtil(mdlRef,'setupFolderCacheForReferencedModel',model);
        exMdlInfos=loc_populateTgt(mdlRef,lSystemTargetFiles{imdl},exMdlInfos,isXIL);
    end

    for imdl=1:protMdlInfoLength
        pModel=protectedMdlRefs{imdl};
        exMdlInfos=loc_populateTgt(pModel,lParentSystemTargetFile,...
        exMdlInfos,isXIL,protectedMdlRefInfoStructMap(pModel));
    end
end


function[exMdlInfos]=loc_populateTgt(currentMdl,lSystemTargetFile,exMdlInfos,isXIL,infoStructRef)

    imdl=length(exMdlInfos)+1;

    if nargin<5


        infoStructRef=i_loadBinfoForRTW(currentMdl,lSystemTargetFile);
    end

    if isfield(infoStructRef.modelInterface,'Inports')
        numInputs=numel(infoStructRef.modelInterface.Inports);
    else
        numInputs=0;
    end


    if numInputs==0
        inputInfo.DirectFeedThrough=[];
    else
        if numInputs==1
            inputInfo.DirectFeedThrough=infoStructRef.modelInterface.Inports.DirectFeedThrough;
        else
            ports=[infoStructRef.modelInterface.Inports{:}];
            inputInfo.DirectFeedThrough=[ports.DirectFeedThrough];
        end
    end

    inputInfo.InputGlobal=infoStructRef.modelInterface.InputPortGlobal;
    inputInfo.InputNotReusable=infoStructRef.modelInterface.InputPortNotReusable;
    inputInfo.InputOverWritable=infoStructRef.modelInterface.InputPortOverWritable;
    inputInfo.InputAlignment=infoStructRef.modelInterface.InputPortAlignment;

    outputInfo.OutputGlobal=infoStructRef.modelInterface.OutputPortGlobal;
    outputInfo.OutputNotReusable=infoStructRef.modelInterface.OutputPortNotReusable;
    outputInfo.OutputAlignment=infoStructRef.modelInterface.OutputPortAlignment;

    if isfield(infoStructRef.modelInterface,'Outports')
        numOuts=numel(infoStructRef.modelInterface.Outports);
    else
        numOuts=0;
    end
    outputSampleTimes=zeros(1,numOuts*2);
    for i=1:numOuts
        if numOuts==1
            outportInfo=infoStructRef.modelInterface.Outports;
        else
            outportInfo=infoStructRef.modelInterface.Outports{i};
        end
        if strcmp(outportInfo.SampleTime.Period,'mxGetInf()')
            period=Inf;
        else
            period=str2double(outportInfo.SampleTime.Period);
        end
        outputSampleTimes(2*i-1)=period;
        if strcmp(outportInfo.SampleTime.Offset,'mxGetInf()')
            offset=Inf;
        else
            offset=str2double(outportInfo.SampleTime.Offset);
        end
        outputSampleTimes(2*i)=offset;
    end
    outputInfo.OutputSampleTimes=outputSampleTimes;
    exMdlInfos{imdl}.mdlRefsAll=infoStructRef.modelRefsAll;
    exMdlInfos{imdl}.mdlName=infoStructRef.modelName;
    exMdlInfos{imdl}.mdlInfos=infoStructRef.mdlInfos.mdlInfo;
    exMdlInfos{imdl}.inputInfo=inputInfo;
    exMdlInfos{imdl}.outputInfo=outputInfo;
    exMdlInfos{imdl}.startFcnExists=isfield(infoStructRef.modelInterface,'StartFcn');
    exMdlInfos{imdl}.updateFcnExists=locDoesUpdateFcnExist(infoStructRef);
    exMdlInfos{imdl}.initializeFcnExists=isfield(infoStructRef.modelInterface,'InitializeFcn');
    exMdlInfos{imdl}.systemInitializeFcnExists=isfield(infoStructRef.modelInterface,'SystemInitializeFcn');
    exMdlInfos{imdl}.systemResetFcnExists=isfield(infoStructRef.modelInterface,'SystemResetFcn');
    exMdlInfos{imdl}.enableFcnExists=isfield(infoStructRef.modelInterface,'EnableFcn');
    exMdlInfos{imdl}.disableFcnExists=isfield(infoStructRef.modelInterface,'DisableFcn');
    exMdlInfos{imdl}.targetLang=locTargetLang(infoStructRef);
    exMdlInfos{imdl}.mdlRefClassName='';
    exMdlInfos{imdl}.buildDir=infoStructRef.BuildDir;
    exMdlInfos{imdl}.usesFPC=false;
    if isfield(infoStructRef.modelInterface,'FPC')
        localFPC=infoStructRef.modelInterface.FPC;
        if~isempty(localFPC)
            if isfield(localFPC,'ModelClassName')
                exMdlInfos{imdl}.mdlRefClassName=localFPC.ModelClassName;
            end
            if~(isfield(localFPC,'IsAuto')&&1==localFPC.IsAuto)
                exMdlInfos{imdl}.usesFPC=true;
            end
        end
    end
    exMdlInfos{imdl}.numBlockFcns=infoStructRef.modelInterface.NumBlockFcns;
    if exMdlInfos{imdl}.numBlockFcns>0
        exMdlInfos{imdl}.blockFcns=infoStructRef.modelInterface.BlockFcns;
    else
        exMdlInfos{imdl}.blockFcns={};
    end

    exMdlInfos=locHandleTLCArrayOfStruct(infoStructRef,'InheritedFcnCallSystems',...
    exMdlInfos,imdl,'inheritedFcnCallSys');

    exMdlInfos{imdl}.needAbsoluteTime=infoStructRef.modelInterface.NeedAbsoluteTime;
    exMdlInfos{imdl}.modelRefTsInheritanceAllowed=infoStructRef.modelInterface.ModelRefTsInheritanceAllowed;
end







function exMdlInfos=locHandleTLCArrayOfStruct(infoStructRef,infoStructFieldName,...
    exMdlInfos,imdl,mdlInfoFieldName)
    if(isfield(infoStructRef.modelInterface,infoStructFieldName))
        if(length(infoStructRef.modelInterface.(infoStructFieldName))==1)
            toAssign={infoStructRef.modelInterface.(infoStructFieldName)};
        else
            toAssign=infoStructRef.modelInterface.(infoStructFieldName);
        end
    else
        toAssign={};
    end

    exMdlInfos{imdl}.(mdlInfoFieldName)=toAssign;
end








function doesExist=locDoesUpdateFcnExist(infoStruct)

    fields=fieldnames(infoStruct.modelInterface);

    updateRG=regexp(fields,'\<UpdateTID\d+Fcn');
    updateST=regexp(fields,'\<UpdateFcn');

    doesExist=any(~cellfun(@isempty,updateRG))||any(~cellfun(@isempty,updateST));

end



function langVal=locTargetLang(infoStruct)
    if strcmp(infoStruct.targetLanguage,'C')
        langVal=0;
    elseif strcmp(infoStruct.targetLanguage,'C++')
        langVal=1;
    elseif strcmp(infoStruct.targetLanguage,'C++ (Encapsulated)')
        langVal=2;
    else
        assert(false,'Unexpected language setting');
    end

end



function infoStruct=i_loadBinfoForRTW(model,systemTargetFile)

    infoStruct=coder.internal.infoMATPostBuild...
    ('load','binfo',model,'RTW',systemTargetFile);


    if isempty(infoStruct)

        matFileName=coder.internal.infoMATFileMgr...
        ('getMatFileName','binfo',model,'RTW',systemTargetFile);
        msg=message('RTW:buildProcess:infoMATFileMgrMatFileNotFound',...
        matFileName);
        error(msg);
    end
end



