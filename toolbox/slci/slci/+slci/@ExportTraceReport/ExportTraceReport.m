














































classdef ExportTraceReport
    methods(Access=public)

        function obj=ExportTraceReport(config,trace_file_name,trace_file_path,excel_head)


            if(~ispc)
                DAStudio.error('RTW:traceInfo:NotAPC');
            end


            if nargin<1
                DAStudio.error('Slci:slci:InvalidNumberOfArguments');
            end

            if~isa(config,'slci.Configuration')
                DAStudio.error('Slci:slci:ArgTypeError',config,'slci.Configuration');
            end

            if exist('trace_file_path','var')&&~ischar(trace_file_path)
                DAStudio.error('Slci:slci:ArgTypeError',trace_file_path,'char');
            end

            if exist('trace_file_name','var')&&~ischar(trace_file_name)
                DAStudio.error('Slci:slci:ArgTypeError',trace_file_name,'char');
            end

            if exist('excel_head','var')&&~ischar(excel_head)
                DAStudio.error('Slci:slci:ArgTypeError',excel_head,'char');
            end


            modelRoot=config.getModelName();


            mgr=slci.internal.ModelStateMgr(modelRoot);
            mgr.loadModel;

            if(exist('trace_file_path','var')&&~isempty(trace_file_path))
                if~slci.internal.isAbsolutePath(trace_file_path)
                    trace_file_path=fullfile(pwd,trace_file_path);
                end
                path=trace_file_path;
            else
                path=pwd;
            end
            if(exist('trace_file_name','var')&&~isempty(trace_file_name))
                file=trace_file_name;
            else
                file=[modelRoot,'_Trace_',datestr(now,30)];
            end

            excelFile=fullfile(path,file);
            tInfo=RTW.TraceInfoBase;
            colText=tInfo.defineColText();
            [excelInfo,sheet]=tInfo.getExcelInfo(excelFile,colText);
            if(exist('excel_head','var')&&~isempty(excel_head))
                head=excel_head;
            else
                head=[];
            end
            if(excelInfo.opened==-1)
                DAStudio.error('RTW:traceInfo:tInfoExcelError_ExcelFileFiledToOpen',excelFile);
            elseif(excelInfo.opened==1)&&(isempty(head))


                head=excelInfo.header;
            else

            end
            config.ComputeDerivedCodeFolder();
            buildDir=config.getDerivedCodeFolder();
            build_info_file=fullfile(buildDir,'buildInfo.mat');
            if~exist(build_info_file,'file')
                DAStudio.error('Slci:report:MissingBuildInfo');
            end
            bi=load(build_info_file);


            fnames=bi.buildInfo.getFullFileList;
            [cumSum]=tInfo.getCommentCheckSum(fnames{1});
            for inx=2:numel(fnames)
                [cumSum]=tInfo.getCommentCheckSum(fnames{inx},cumSum,inx);
            end
            [eView]=unrollSLCI(tInfo,...
            modelRoot,...
            excelInfo,...
            cumSum,...
            buildDir,...
            config.getDataManager());



            modelMap.pathname=modelRoot;
            if isempty(head)
                tInfo.emitExcel(excelFile,...
                eView,...
                colText,...
                sheet,...
                bi.buildInfo,...
                buildDir,...
                modelRoot,...
                modelMap);
            else
                tInfo.emitExcel(excelFile,...
                eView,...
                colText,...
                sheet,...
                bi.buildInfo,...
                buildDir,...
                modelRoot,...
                modelMap,...
                head);
            end
        end
    end
end

function[eView]=unrollSLCI(tInfo,model,excelInfo,cSum,buildDir,dm)




    [comm,eView]=tInfo.defineStruct();
    hdl=get_param(model,'Handle');


    allBlocks=find_system(hdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);

    allBlocks=allBlocks(2:end);
    [comm,eView]=extractInfo(eView,allBlocks,'Block',...
    tInfo,excelInfo,cSum,buildDir,comm,dm);




    sfBlocks=find_system(hdl,'AllBlocks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','on',...
    'FollowLinks','on',...
    'LookUnderReadProtectedSubsystems','on',...
    'SFBlockType','Chart');

    for k=1:numel(sfBlocks)
        blkH=sfBlocks(k);


        chartId=sfprivate('block2chart',blkH);
        chartUDDObj=idToHandle(sfroot,chartId);
        if Stateflow.SLUtils.isChildOfStateflowBlock(blkH)

            [comm,eView]=extractInfo(eView,chartUDDObj,'AtomicSubchart',...
            tInfo,excelInfo,cSum,buildDir,comm,dm);
            continue;
        end

        transitionObjs=slci.internal.getSFActiveObjs(...
        chartUDDObj.find('-isa','Stateflow.Transition'));
        [comm,eView]=extractInfo(eView,transitionObjs,'Transition',...
        tInfo,excelInfo,cSum,buildDir,comm,dm);
    end

    eView.comm=comm;

end

function[comm,eView]=extractInfo(eView_in,objs,type,...
    tInfo,excelInfo,cSum,buildDir,comm_in,dm)
    assert(logical(exist('eView_in','var')));
    assert(logical(exist('comm_in','var')));
    assert(strcmp(type,'Transition')...
    ||strcmp(type,'AtomicSubchart')...
    ||strcmp(type,'Block'));

    eView=eView_in;
    comm=comm_in;
    for i=1:numel(objs)
        hObj=objs(i);
        [curSID,name,path,parent,bt,reqT]=getCommInfo(hObj,type);

        hasReq=~isempty(reqT);
        bo=[];
        if dm.hasObject('BLOCK',curSID)
            bo=dm.getObject('BLOCK',curSID);
        end

        reqLoop=max(size(reqT,1),1);

        for knx=1:reqLoop
            if(isempty(bo)||isempty(bo.getTraceArray))

                eView.name{end+1}=name;
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


                eView.ssid{end+1}=curSID;


                cnt=numel(eView.ssid);
                rat='';
                if~isempty(bo)



                    rat=bo.getTraceSubstatus();
                end

                eView.rat{end+1}=rat;
                eView.relPos{end+1}='';
                eView.comSum{end+1}='';
                eView.util{end+1}=DAStudio.message('RTW:traceInfo:tInfoExcelNone');

                comm=tInfo.findCommentMatch(comm,eView,cnt,excelInfo);
            else
                taLoc=bo.getTraceArray();
                for jnx=1:numel(taLoc)
                    eView.name{end+1}=name;
                    eView.path{end+1}=path;
                    eView.parent{end+1}=parent;
                    sc=dm.getObject('CODE',taLoc{jnx});
                    eView.fileLoc{end+1}=sc.getFilePath();
                    eView.file{end+1}=sc.getFileName();
                    eView.line{end+1}=num2str(sc.getLineNumber());
                    if(ischar(eView.line{end}))
                        line=str2double(eView.line{end})-1;
                    else
                        line=eView.line{end}-1;
                    end
                    eView.comSum{end+1}=tInfo.getCheckSumFromCodeAndLine(...
                    cSum,fullfile(sc.getFilePath(),sc.getFileName()),...
                    line);
                    eView.func{end+1}=cell2mat(sc.getFunctionScope);
                    if(hasReq)
                        eView.req{end+1}=reqT(knx);
                    else
                        eView.req{end+1}={};
                    end

                    eView.eleType{end+1}=bt;

                    eView.ssid{end+1}=curSID;


                    cnt=numel(eView.ssid);
                    comm=tInfo.findCommentMatch(comm,eView,cnt,excelInfo);
                    eView.rat{end+1}='';
                    eView.relPos{end+1}=DAStudio.message('RTW:traceInfo:tInfoExcelNone');
                    eView.util{end+1}=DAStudio.message('RTW:traceInfo:tInfoExcelNone');
                end
            end
        end
    end
end

function[sid,name,path,parent,blockType,reqT]=getCommInfo(obj,type)
    if strcmp(type,'Block')
        blockType=get_param(obj,'BlockType');
        if~isempty(blockType)
            reqT=rmi('get',obj);
        end
        sid=Simulink.ID.getSID(obj);
        name=get_param(obj,'Name');
        locBo=get_param(obj,'Object');
        path=locBo.Path;
    else
        assert(strcmp(type,'Transition')...
        ||strcmp(type,'AtomicSubchart'));


        reqT=rmi('get',obj);
        blockType=type;

        name=['Transition: ',num2str(obj.SSIdNumber)];
        path=obj.Path;
        sid=Simulink.ID.getSID(obj);
    end
    parentPath=regexp(path,'/','split');
    parent=parentPath{end};
end

