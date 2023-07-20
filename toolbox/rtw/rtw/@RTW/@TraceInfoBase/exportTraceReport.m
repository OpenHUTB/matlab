function exportTraceReport(tInfo,file,path,head,lic,rootModel)






























































































    if nargin>1
        file=convertStringsToChars(file);
    end

    if nargin>2
        path=convertStringsToChars(path);
    end

    if nargin>3
        if isstring(head)
            head=cellstr(head);
        end
    end

    if nargin>4
        lic=convertStringsToChars(lic);
    end

    if nargin>5
        rootModel=convertStringsToChars(rootModel);
    end

    if(~ispc)
        DAStudio.error('RTW:traceInfo:NotAPC');
    end



    env.Lic=false;
    if(exist('lic','var'))&&(~isempty(lic))
        try


            if(license('test',lic))
                env.Lic=license('checkout',lic);
            end
        catch

        end
    else

        if(license('test','Cert_Kit_IEC'))
            env.Lic=license('checkout','Cert_Kit_IEC');
        elseif(license('test','Qual_Kit_DO'))
            env.Lic=license('checkout','Qual_Kit_DO');
        end
    end
    if~env.Lic
        DAStudio.error('RTW:traceInfo:IECLicenseNotAvailable');
    end

    colText=tInfo.defineColText();



    if(exist('head','var'))&&(~isempty(head))
        if(~iscell(head))
            DAStudio.error('RTW:traceInfo:tInfoExcelError_BadHeader');
        end
    end




    if isempty(tInfo.BuildDir)
        disp(['### ',DAStudio.message('RTW:traceInfo:NoBuildDir')]);
    end

    load([tInfo.BuildDir,filesep,'buildInfo.mat']);
    buildInfo.findIncludeFiles;

    if(nargin==2)
        path=pwd;
        head=[];
    elseif(nargin==3)
        head=[];
    end
    modelMap=tInfo.SystemMap;
    inx=1;
    modelRoot=[];
    while((inx<=length(modelMap))&&(isempty(modelRoot)))
        if(~isempty(modelMap(inx).name))
            modelRoot=modelMap(inx).name;
            modelMap=modelMap(1:inx);
        end
        inx=inx+1;
    end
    if(nargin==1)
        path=pwd;

        file=[modelRoot,'_Trace_',datestr(now,30)];
        head=[];
    end
    excelFile=[path,filesep,file];







    [excelInfo,sheet]=tInfo.getExcelInfo(excelFile,colText);
    if(excelInfo.opened==-1)
        DAStudio.error('RTW:traceInfo:tInfoExcelError_ExcelFileFiledToOpen',excelFile);
    elseif(excelInfo.opened==1)&&(isempty(head))


        head=excelInfo.header;
    else

    end



    fnames=getFullFileList(buildInfo);
    [cumSum]=tInfo.getCommentCheckSum(fnames{1});
    for inx=2:length(fnames)
        [cumSum]=tInfo.getCommentCheckSum(fnames{inx},cumSum,inx);
    end


    [eView]=unroll(tInfo,excelInfo,cumSum);


    if(exist('rootModel','var'))&&(~isempty(rootModel))
        modelRoot=rootModel;
    end


    if isempty(head)
        tInfo.emitExcel(excelFile,eView,colText,sheet,buildInfo,tInfo.BuildDir,...
        modelRoot,modelMap);
    else
        tInfo.emitExcel(excelFile,eView,colText,sheet,buildInfo,tInfo.BuildDir,...
        modelRoot,modelMap,head);
    end
end

function[eView]=unroll(tInfo,excelInfo,cSum)






    eInfo=tInfo.getRegistryWithScope();
    [comm,eView]=tInfo.defineStruct();
    reasonMap=tInfo.getBlockReductionReasons;

    closeModels={};
    for inx=1:length(eInfo)
        reqT='';
        try
            bt=get_param(eInfo(inx).pathname,'BlockType');
            hObj=1;
        catch %#ok<CTCH> : Note using the try catch to get the



            hObj=sfprivate('ssIdToHandle',eInfo(inx).pathname);
            bt=class(hObj);
            bt=bt(11:end);
        end

        if(isa(hObj,'Stateflow.EMChart'))


            colLoc=findstr(':',eInfo(inx).pathname);
            reqT=rmi('get',eInfo(inx).pathname(1:colLoc(1)-1));
        elseif(hObj==1)
            reqT=rmi('get',eInfo(inx).pathname);

            libBlock=get_param(eInfo(inx).pathname,'ReferenceBlock');
            if~isempty(libBlock)
                if~isValidSlObject(slroot,libBlock)
                    model=strtok(libBlock,'/');
                    load_system(model);
                    closeModels{end+1}=onCleanup(@()bdclose(model));%#ok<AGROW>
                end
                libBlockReq=rmi('get',libBlock);
                if~isempty(libBlockReq)
                    reqT=[reqT;libBlockReq];%#ok<AGROW>
                end
            end
        elseif(~isa(hObj,'Stateflow.Event'))
            reqT=rmi('get',hObj);
        end
        hasReq=0;
        if(~isempty(reqT))
            hasReq=1;
        end
        identLoc=findstr('>',eInfo(inx).rtwname);
        sstr=eInfo(inx).rtwname(identLoc+1:end);
        identLoc=findstr(sstr,eInfo(inx).pathname);
        path=eInfo(inx).pathname(1:identLoc-1);
        lastSlash=findstr('/',path);
        if(isempty(lastSlash))
            parent=path;
        else
            parent=path(lastSlash(end)+1:end);
        end


        reqLoop=max(numel(reqT),1);

        reg=eInfo(inx);

        for knx=1:reqLoop
            if(isempty(reg.location))

                eView.name{end+1}=reg.name;
                eView.path{end+1}=path;
                eView.parent{end+1}=parent;
                eView.file{end+1}='';
                eView.fileLoc{end+1}='';
                eView.line{end+1}='';
                eView.func{end+1}='';
                if(hasReq)
                    eView.req{end+1}=reqT(knx);
                else
                    eView.req{end+1}={};
                end
                eView.eleType{end+1}=bt;



                eView.ssid{end+1}=reg.sid;


                cnt=length(eView.ssid);
                rat=tInfo.getReason(reasonMap,reg);
                if(strfind(rat,'RTW:traceInfo:'))
                    rat=rat(15:end);
                end

                eView.rat{end+1}=rat;
                eView.relPos{end+1}='';
                eView.comSum{end+1}='';
                eView.util{end+1}=DAStudio.message('RTW:traceInfo:tInfoExcelNone');

                comm=tInfo.findCommentMatch(comm,eView,cnt,excelInfo);
            else
                for jnx=1:length(reg.location)
                    eView.name{end+1}=reg.name;

                    eView.path{end+1}=path;
                    eView.parent{end+1}=parent;
                    [loc,name,ext]=fileparts(reg.location(jnx).file);
                    eView.fileLoc{end+1}=loc;
                    eView.file{end+1}=[name,ext];
                    eView.line{end+1}=reg.location(jnx).line;
                    eView.comSum{end+1}=tInfo.getCheckSumFromCodeAndLine(cSum,...
                    reg.location(jnx).file,...
                    eView.line{end});
                    if(isempty(reg.location(jnx).scope))
                        eView.func{end+1}=DAStudio.message('RTW:traceInfo:tInfoExcelGlobal');
                    else
                        eView.func{end+1}=reg.location(jnx).scope;
                    end
                    if(hasReq)
                        eView.req{end+1}=reqT(knx);
                    else
                        eView.req{end+1}={};
                    end

                    eView.eleType{end+1}=bt;


                    eView.ssid{end+1}=reg.sid;


                    cnt=length(eView.ssid);
                    comm=tInfo.findCommentMatch(comm,eView,cnt,excelInfo);
                    eView.rat{end+1}='';
                    eView.relPos{end+1}=DAStudio.message('RTW:traceInfo:tInfoExcelNone');
                    eView.util{end+1}=DAStudio.message('RTW:traceInfo:tInfoExcelNone');
                end
            end
        end
    end
    eView.comm=comm;
end



