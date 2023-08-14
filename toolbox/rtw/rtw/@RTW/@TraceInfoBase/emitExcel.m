function emitExcel(~,fileName,eView,colText,selSheet,buildInfo,...
    buildDir,modelRoot,modelMap,header)




    if(nargin==10)
        [com,colIndx,lenCom,infoStr]=orderCol(colText,eView,header);
    else
        [com,colIndx,lenCom,infoStr]=orderCol(colText,eView);
    end

    knx=1;
    for inx=1:length(eView.name)
        try
            numReq=size(eView.req{inx},1);
            if(numReq>0)
                for qnx=1:numReq
                    knx=knx+1;
                    [infoStr]=updateInfoStr(infoStr,eView,inx,knx,colIndx,qnx,com,lenCom);
                end
            else
                knx=knx+1;
                [infoStr]=updateInfoStr(infoStr,eView,inx,knx,colIndx,0,com,lenCom);
            end
        catch

        end
    end


    warning('off','MATLAB:xlswrite:AddSheet');

    modelInfo=getModelInfo(modelMap,modelRoot);
    sheetStr=DAStudio.message('RTW:traceInfo:tInfoExcelInfoTab');
    writecell(modelInfo,fileName,'FileType','spreadsheet','Sheet',sheetStr);


    codeInfo=getCodeInfo(buildDir);
    sheetStr=DAStudio.message('RTW:traceInfo:tInfoExcelCodeInfoTab');
    writecell(codeInfo,fileName,'FileType','spreadsheet','Sheet',sheetStr);


    utilFormatted=formatUtils(buildInfo);
    sheetStr=DAStudio.message('RTW:traceInfo:tInfoExcelFileList');
    writecell(utilFormatted,fileName,'FileType','spreadsheet','Sheet',sheetStr);



    writecell(infoStr,fileName,'FileType','spreadsheet','Sheet',selSheet);


    cleanUpEmptySheets(fileName);
    warning('on','MATLAB:xlswrite:AddSheet');

end


function cleanUpEmptySheets(fileName)

    sheetsToCheck={'Sheet1','Sheet2','Sheet3'};



    try
        Excel=actxserver('excel.application');
        if strcmp(fileName(end-4:end),'.xlsx')||strcmp(fileName(end-3:end),'.xls')
            fileNameWithExt=fileName;
        else
            fileNameWithExt=[fileName,'.xls'];
        end
        file=Excel.Workbooks.Open(fileNameWithExt);
    catch exception %#ok
        MSLDiagnostic('RTW:traceInfo:ServerFail').reportAsWarning;
        return
    end

    for inx=1:length(sheetsToCheck)
        try
            [~,~,raw]=xlsread(fileName,sheetsToCheck{inx});
            if(isnan(raw{1}))

                s=Excel.Worksheets.get('Item',sheetsToCheck{inx});
                s.Delete;
            end
        catch

        end
    end


    file.Save;
    file.Close;
    Excel.Quit;
    delete(Excel);
end

function[utilFormated]=formatUtils(buildInfo)

    buildInfo.updateFilePathsAndExtensions;

    fnames=getFullFileList(buildInfo);
    utilFormated{1,1}=DAStudio.message('RTW:traceInfo:tInfoExcelFileLocation');
    utilFormated{1,2}=DAStudio.message('RTW:traceInfo:tInfoExcelFileName');
    for inx=1:length(fnames)
        [path,file,ext]=fileparts(fnames{inx});
        utilFormated{inx+1,1}=path;
        utilFormated{inx+1,2}=[file,ext];
    end
end


function[com,colIndx,lenCom,infoStr]=orderCol(colText,eView,header)

    com.number=0;
    com.name={};
    com.indx=[];





















    if(nargin==3)

        colIndx=[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1];

        for jnx=1:length(header)
            ind=strmatch(header{jnx},colText,'exact');
            if isempty(ind)&&(~isempty(header{jnx}))


                com.number=com.number+1;
                com.name{com.number}=header{jnx};
                com.indx(com.number)=jnx;
            else

                colIndx(ind)=jnx;
            end
        end
        numCols=length(header);

        reqCol=[1,2,3,4,5,6,7,12,18];
        for pnx=1:length(reqCol)
            if(colIndx(reqCol(pnx))==-1)
                numCols=numCols+1;
                colIndx(reqCol(pnx))=numCols;
            end
        end
    else






        colIndx=[1,3,4,5,6,7,8,-1,9,10,11,12,13,-1,2,-1,-1,14,-1];
        numCols=14;
    end


    infoStr{length(eView),numCols}='';


    for inx=1:length(colText)
        if(colIndx(inx)>0)
            infoStr{1,colIndx(inx)}=colText{inx};
        end
    end




    for inx=1:com.number
        com.indx(inx)=find(strcmp(com.name{inx},header));
        infoStr{1,com.indx(inx)}=com.name{inx};
    end


    lenCom=zeros(com.number,1);
    for inx=1:com.number
        lenCom(inx)=length(eView.comm(inx).text);
    end
end

function[retInfo]=getCodeInfo(buildDir)

    codeDescriptor=coder.internal.getCodeDescriptorInternal(buildDir,247362);
    codeInfo=codeDescriptor.getComponentInterface();
    if isempty(codeInfo)
        retInfo{1,1}=DAStudio.message('RTW:traceInfo:codeInfoNotAvailable');
        return
    end

    offset=0;
    if(~isempty(codeInfo.InitializeFunctions))

        for inx=1:length(codeInfo.InitializeFunctions)
            retInfo{1,1}=DAStudio.message('RTW:traceInfo:InitFun');
            retInfo{1,2}=codeInfo.InitializeFunctions(inx).Prototype.Name;
            retInfo{2,1}=DAStudio.message('RTW:traceInfo:FunRate');
            retInfo{2,2}=getRateInfoStr(codeInfo.InitializeFunctions(inx).Timing);
            retInfo{3,1}=DAStudio.message('RTW:traceInfo:FunProto');
            retInfo{3,2}=buildProt(codeInfo.InitializeFunctions(inx).Prototype);
            offset=offset+3;
        end
    else

    end

    if(~isempty(codeInfo.OutputFunctions))
        for inx=1:length(codeInfo.OutputFunctions)
            retInfo{offset+1,1}=DAStudio.message('RTW:traceInfo:StepFun');
            retInfo{offset+1,2}=codeInfo.OutputFunctions(inx).Prototype.Name;
            retInfo{offset+2,1}=DAStudio.message('RTW:traceInfo:FunRate');
            retInfo{offset+2,2}=getRateInfoStr(codeInfo.OutputFunctions(inx).Timing);
            retInfo{offset+3,1}=DAStudio.message('RTW:traceInfo:FunProto');
            retInfo{offset+3,2}=buildProt(codeInfo.OutputFunctions(inx).Prototype);
            offset=offset+3;
        end
    else

    end

    if(~isempty(codeInfo.TerminateFunctions))

        for inx=1:length(codeInfo.TerminateFunctions)
            retInfo{offset+1,1}=DAStudio.message('RTW:traceInfo:TermFun');
            retInfo{offset+1,2}=codeInfo.TerminateFunctions(inx).Prototype.Name;
            retInfo{offset+2,1}=DAStudio.message('RTW:traceInfo:FunRate');
            retInfo{offset+2,2}=getRateInfoStr(codeInfo.TerminateFunctions(inx).Timing);
            retInfo{offset+3,1}=DAStudio.message('RTW:traceInfo:FunProto');
            retInfo{offset+3,2}=buildProt(codeInfo.TerminateFunctions(inx).Prototype);
            offset=offset+3;
        end
    else

    end

    if(~isempty(codeInfo.UpdateFunctions))

        for inx=1:length(codeInfo.UpdateFunctions)
            retInfo{offset+1,1}=DAStudio.message('RTW:traceInfo:UpdateFun');
            retInfo{offset+1,2}=codeInfo.UpdateFunctions(inx).Prototype.Name;
            retInfo{offset+2,1}=DAStudio.message('RTW:traceInfo:FunRate');
            retInfo{offset+2,2}=getRateInfoStr(codeInfo.UpdateFunctions(inx).Timing);
            retInfo{offset+3,1}=DAStudio.message('RTW:traceInfo:FunProto');
            retInfo{offset+3,2}=buildProt(codeInfo.UpdateFunctions(inx).Prototype);
        end
    else

    end


end


function[rate]=getRateInfoStr(timeInfo)
    rate='';
    switch timeInfo.TimingMode
    case 'ONESHOT'
        rate=DAStudio.message('RTW:traceInfo:OneShot');
    case 'PERIODIC'
        rate=timeInfo.SamplePeriod;
    end
end

function[interface]=buildProt(protoInfo)

    if(isempty(protoInfo.Return))
        interface='void ';
    else
        interface=protoInfo.Return;
    end
    interface=[interface,protoInfo.Name,' ('];
    if(isempty(protoInfo.Arguments))
        interface=[interface,'void'];
    else
        space='    ';
        interface=[interface,10];
        for inx=1:length(protoInfo.Arguments)
            arg=protoInfo.Arguments(inx);
            str_arg=space;

            isPointer=arg.Type.isPointer;
            isMatrix=arg.Type.isMatrix;
            if arg.Type.ReadOnly
                str_arg=[str_arg,'const '];%#ok
            end
            if isMatrix||isPointer
                str_arg=[str_arg,arg.Type.BaseType.Identifier];%#ok
            else
                str_arg=[str_arg,arg.Type.Identifier];%#ok
            end
            if isPointer
                str_arg=[str_arg,' *'];%#ok
            end
            str_arg=[str_arg,' ',arg.Name];%#ok
            if isMatrix
                dim=arg.Type.Dimensions;
                dimAll=1;
                for i=1:length(dim)
                    dimAll=dimAll*dim(i);
                end
                str_arg=[str_arg,'[',num2str(dimAll),']'];%#ok
            end

            str_arg=[str_arg,',',10];%#ok
            interface=[interface,str_arg];%#ok
        end
        interface=interface(1:end-2);
    end
    interface=[interface,')'];
end


function[modelInfo]=getModelInfo(modelMap,model)
    if(length(modelMap)>1)
        isSub=1;
    else
        isSub=0;
    end
    modelInfo{1,1}=DAStudio.message('RTW:traceInfo:tInfoExcelModelName');
    modelInfo{1,2}=modelMap(end).pathname;
    if(isSub)
        modelInfo{1,3}=DAStudio.message('RTW:traceInfo:tInfoExcelSubsystemUsed');
    end

    modelInfo{2,1}=DAStudio.message('RTW:traceInfo:tInfoExcelModelVersion');
    modelInfo{2,2}=get_param(model,'ModelVersion');
    modelInfo{3,1}=DAStudio.message('RTW:traceInfo:tInfoExcelModelAuthor');
    modelInfo{3,2}=get_param(model,'Creator');
    modelInfo{4,1}=DAStudio.message('RTW:traceInfo:tInfoExcelModelCreationDate');
    modelInfo{4,2}=get_param(model,'Created');
    modelInfo{5,1}=DAStudio.message('RTW:traceInfo:tInfoExcelLastUpdateBy');
    modelInfo{5,2}=get_param(model,'LastModifiedBy');
    modelInfo{6,1}=DAStudio.message('RTW:traceInfo:tInfoExcelLastUpdate');
    modelInfo{6,2}=get_param(model,'ModifiedDate');



    try

        checkSum=get_param(bdroot(model),'ModelChecksum');

        checkSum=num2str(cat(1,checkSum'));
    catch %#ok<CTCH>
        checkSum=DAStudio.message('RTW:traceInfo:tInfoExcelCheckSumFailed');
    end
    modelInfo{7,1}=DAStudio.message('RTW:traceInfo:tInfoExcelModelCheckSum');
    modelInfo{7,2}=checkSum;

    modelInfo{8,1}=DAStudio.message('RTW:traceInfo:tInfoExcelSubsystemCheckSum');
    if(isSub)
        try
            checkSum=Simulink.SubSystem.getChecksum(modelMap(end).pathname);
            checkSum=num2str(cat(1,checkSum.Value'));
        catch
            checkSum=DAStudio.message('RTW:traceInfo:tInfoExcelCheckSumFailed');
        end
    else
        checkSum='NA';
    end
    modelInfo{8,2}=checkSum;



    [trc]=checkReportEnabled(model);
    modelInfo{9,1}=DAStudio.message('RTW:configSet:RTWReportTraceReportName');
    modelInfo{10,1}=DAStudio.message('RTW:configSet:RTWReportTraceReportSlName');
    modelInfo{11,1}=DAStudio.message('RTW:configSet:RTWReportTraceReportSfName');
    modelInfo{12,1}=DAStudio.message('RTW:configSet:RTWReportTraceReportEmlName');
    modelInfo{9,2}=trc.eliminatedVirtual;
    modelInfo{10,2}=trc.traceSimulink;
    modelInfo{11,2}=trc.traceStateflow;
    modelInfo{12,2}=trc.traceEML;

end

function[trc]=checkReportEnabled(modelRoot)
    trc.eliminatedVirtual=get_param(modelRoot,'GenerateTraceReport');
    trc.traceSimulink=get_param(modelRoot,'GenerateTraceReportSl');
    trc.traceStateflow=get_param(modelRoot,'GenerateTraceReportSf');
    trc.traceEML=get_param(modelRoot,'GenerateTraceReportEml');
    trc.disabledStr=[];
    if(strcmp(trc.traceEML,'off'))
        trc.disabledStr=[trc.disabledStr,10,...
        DAStudio.message('RTW:configSet:RTWReportTraceReportEmlName')];
    end
    if(strcmp(trc.traceStateflow,'off'))
        trc.disabledStr=[trc.disabledStr,10,...
        DAStudio.message('RTW:configSet:RTWReportTraceReportSfName')];
    end
    if(strcmp(trc.traceSimulink,'off'))
        trc.disabledStr=[trc.disabledStr,10,...
        DAStudio.message('RTW:configSet:RTWReportTraceReportSlName')];
    end
    if(strcmp(trc.eliminatedVirtual,'off'))
        trc.disabledStr=[trc.disabledStr,10,...
        DAStudio.message('RTW:configSet:RTWReportTraceReportName')];
    end











end

function[infoStr]=updateInfoStr(infoStr,eView,inx,knx,colIndx,qnx,com,lenCom)


    infoStr{knx,colIndx(1)}=eView.name{inx};
    infoStr{knx,colIndx(2)}=eView.path{inx};
    infoStr{knx,colIndx(3)}=eView.parent{inx};
    infoStr{knx,colIndx(4)}=eView.fileLoc{inx};
    infoStr{knx,colIndx(5)}=eView.file{inx};
    infoStr{knx,colIndx(6)}=eView.func{inx};
    infoStr{knx,colIndx(7)}=eView.line{inx};
    infoStr{knx,colIndx(12)}=eView.ssid{inx};
    infoStr{knx,colIndx(18)}=eView.comSum{inx};

    if(~isempty(eView.rat{inx}))
        infoStr{knx,colIndx(15)}='Yes';
    end


    if(colIndx(8)>0)
        infoStr{knx,colIndx(8)}=eView.relPos{inx};
    end
    if(colIndx(9)>0)
        infoStr{knx,colIndx(9)}=eView.eleType{inx};
    end
    if(colIndx(13)>0)
        infoStr{knx,colIndx(13)}=eView.rat{inx};
    end
    if(colIndx(14)>0)
        infoStr{knx,colIndx(14)}=eView.util{inx};
    end
    if(qnx>0)&&(colIndx(10)>0)



        infoStr{knx,colIndx(10)}=eView.req{inx}.doc;
        infoStr{knx,colIndx(11)}=[eView.req{inx}.description,':',eView.req{inx}.id];
    end

    for jnx=1:com.number
        if((inx<=lenCom(jnx))&&(eView.comm(jnx).row(inx)~=0))


            infoStr{knx,com.indx(jnx)}=eView.comm(jnx).text{inx};
        end
    end
end
