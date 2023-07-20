




function varargout=cachedCodegen(cmd,varargin)
    if ischar(cmd)
        cmd=str2func(cmd);
        assert(~isempty(cmd));
    end

    [genHtmlReport,launchReport,config,fc,codegen_args]=extractReportOptions(varargin);%#ok<ASGLU>
    pure_codegen_args=copyCodegenArgs(codegen_args);


    mexPath=getMexPath(codegen_args);
    assert(~isempty(mexPath));

    [res,report]=loadCache(mexPath,cmd,codegen_args);
    if res
        if nargout==1
            varargout{1}=report;
        end

        if genHtmlReport
            genReportLinks(report);
        end
        return;
    end

    report=feval(cmd,codegen_args{:},'--extraOutputs','designInspector');



    if genHtmlReport&&isfield(report,'summary')&&isfield(report.summary,'passed')...
        &&report.summary.passed
        report.summary.directory=getReportPath(mexPath);
        [report.openHRef,report.summary.mainhtml]=generateCodegenReport(report,config,fc);
        genReportLinks(report);
    end
    report=rmfield(report,'extraOutputs');

    if isfield(report,'summary')&&isfield(report.summary,'passed')
        if report.summary.passed


            cacheInvocation(mexPath,cmd,pure_codegen_args,report);
        end
    end

    if nargout==1
        varargout{1}=report;
    end
end

function args=copyCodegenArgs(args)
    for ii=1:numel(args)
        a=args{ii};
        args{ii}=a;
        args{ii}=a;
    end
end


function genReportLinks(report)
    try
        action='compilation';
        if~report.summary.passed
            result='Failed';
        elseif isempty(report.summary.messageList)
            result='Succeeded';
        elseif strcmp(getMessageTypeName(report),'Info')
            result='SucceededWithInfos';
        else
            result='SucceededWithWarnings';
        end
        msgid=sprintf('%s%s',action,result);
        msgText=DAStudio.message(['Coder:reportGen:',msgid],report.openHRef);
        disp(msgText);
    catch ex
    end
end

function msgTypeName=getMessageTypeName(report)
    msgTypeName='';
    if isempty(report.summary.messageList)
        msgTypeName='';
        return;
    end

    found=false;
    function searchFor(messageList,what)
        for messageId=1:numel(messageList)
            msg=messageList{messageId};
            if strcmpi(msg.MsgTypeName,what)&&~msg.isFcnCallFailed
                found=true;
                msgTypeName=what;
                break;
            end
        end
    end
    searchFor(report.summary.coderMessages,'Error');
    if~found
        searchFor(report.summary.coderMessages,'Warning');
    end
    if~found
        searchFor(report.summary.messageList,'Error');
    end
    if~found
        searchFor(report.summary.messageList,'Warning');
    end
end

function[genHtmlReport,launchReport,config,fc,codegen_args]=extractReportOptions(codegen_args)
    launchReport=false;
    genHtmlReport=false;
    pos=[];
    config=[];
    fc=[];
    for ii=1:numel(codegen_args)
        arg=codegen_args{ii};
        if ischar(arg)
            if strcmp(arg,'-report')
                pos(end+1)=ii;
                genHtmlReport=true;
            elseif strcmp(arg,'-launchreport')
                pos(end+1)=ii;
                launchReport=true;
            elseif strcmp(arg,'-config')
                config=codegen_args{ii+1};
            elseif strcmp(arg,'-feature')
                fc=codegen_args{ii+1};
            end

        end
    end
    codegen_args(pos)=[];
end

function mexName=getMexPath(args)
    mexName='';
    for ii=1:numel(args)
        if ischar(args{ii})
            if strcmp(args{ii},'-o')&&(ii+1)<=numel(args)
                mexName=args{ii+1};
                break;
            end
        end
    end
    if~isempty(mexName)
        [p,f,~]=fileparts(mexName);
        mexName=fullfile(p,[f,'.',mexext]);
    end
end

function reportPath=getReportPath(mexPath)
    [p,m,~]=fileparts(mexPath);
    reportPath=fullfile(p,'reports',m);
end

function cacheInvocation(mexPath,cmd,inputs,report)
    try
        if~isempty(mexPath)
            cache.matlabroot=matlabroot;
            cache.cmd=cmd;
            cache.inputs=inputs;
            cache.report=report;

            Scripts=cache.report.inference.Scripts;
            ts_new=getTimeStampOfScripts(Scripts);
            cache.timestamps=ts_new;

            save(getCacheFile(mexPath),'cache');
        end
    catch ex
    end
end

function[res,report]=loadCache(mexPath,cmd,inputs)
    res=0;
    report=[];
    try
        if~isempty(mexPath)&&isMexFileUpToDate(mexPath)
            cacheFile=getCacheFile(mexPath);
            if exist(cacheFile,'file')
                cacheF=load(cacheFile);
                cache=cacheF.cache;
                if isequaln(cmd,cache.cmd)&&strcmp(cache.matlabroot,matlabroot)
                    if isEqualInputs(inputs,cache.inputs)
                        if checkTimeStamps(cache)
                            res=1;
                            report=cache.report;
                            return;
                        end
                    end
                end
            end
        end
    catch ex

    end
end

function f=getCacheFile(mexPath)
    [p,f,~]=fileparts(mexPath);
    cacheDir=fullfile(p,'cache_dir');
    if~exist(cacheDir,'dir')
        mkdir(cacheDir);
    end
    f=fullfile(cacheDir,[f,'_codegenCache.mat']);
end

function res=isEqualInputs(inputs1,inputs2)
    res=0;
    if numel(inputs1)==numel(inputs2)
        for ii=1:numel(inputs1)
            inp1=inputs1{ii};
            inp2=inputs2{ii};
            res=strcmp(class(inp1),class(inp2));
            if res
                if isa(inp1,'coder.internal.FeatureControl')
                    res=isEqualFeatureControl(inp1,inp2);
                else
                    res=isequaln(inp1,inp2);
                end
                if~res
                    return;
                end
            else
                return;
            end
        end
    end
end

function res=isEqualFeatureControl(fc1,fc2)

    res=0;
    try
        props2=properties(fc2);
        props=properties(fc1);
        numelProps=length(props);

        if length(props2)~=numelProps


            return;
        end
        for ii=1:numelProps
            prop=props{ii};
            if strcmp(prop,'Developer')

                continue;
            end
            if~isequaln(fc1.(prop),fc2.(prop))
                return;
            end
        end
        res=1;
    catch ex %#ok<NASGU>

    end
end

function result=isMexFileUpToDate(mexFile)
    result=coder.internal.TestBenchManager.verifyResolvedFunctions(mexFile);
end

function ts=getTimeStamp(filePath)
    d=dir(filePath);
    ts=d.datenum;
end

function ts=getTimeStampOfScripts(scripts)
    ts={};
    for ii=1:numel(scripts)



        if scripts(ii).IsUserVisible
            ts{end+1}=getTimeStamp(scripts(ii).ScriptPath);
        end
    end
end

function r=checkTimeStamps(cache)
    r=0;
    try
        Scripts=cache.report.inference.Scripts;
        ts_new=getTimeStampOfScripts(Scripts);
        r=isequaln(ts_new,cache.timestamps);
    catch ex
    end
end

function[href,mainReportFile]=generateCodegenReport(report,config,fc)
    href='';
    mainReportFile='';

    if~isempty(report.summary.directory)&&(~isfield(report.summary,'mainhtml')||isempty(report.summary.mainhtml))
        reportContext=coder.report.ReportContext(report);
        reportContext.Config=config;
        reportContext.FeatureControl=fc;
        reportContext.ClientType='float2fixed';
        if isfield(report,'extraOutputs')&&isfield(report.extraOutputs,'designInspector')&&...
            ~isempty(report.extraOutputs.designInspector)
            reportContext.useDesignInspectorResults(report.extraOutputs.designInspector);
        end
        try
            reportFiles=codergui.ReportServices.Generator.run(reportContext);
        catch ex %#ok<NASGU>
            return
        end
        mainReportFile=reportFiles.reportFile;
        href=sprintf('matlab: emlcprivate(''emcOpenReport'',''%s'');',mainReportFile);
    elseif isfield(report.summary,'mainhtml')
        mainReportFile=report.summary.mainhtml;
    end
end