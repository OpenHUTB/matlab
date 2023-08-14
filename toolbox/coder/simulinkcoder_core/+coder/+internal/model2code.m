function registry=model2code(sids,varargin)








    [licenseCheck,MissingLicense]=rtw.report.checkOutLicenseForTraceability();
    if~licenseCheck
        DAStudio.error('RTW:report:Model2CodeLicenseError',strjoin(MissingLicense,', '));
    end
    try
        sids=Simulink.ID.getSID(sids);
    catch
    end

    if~iscell(sids)
        sids={sids};
    end
    model=strtok(sids{1},':/');
    if nargin>1
        target=varargin{1};
    else
        target='rtw';
    end
    switch target
    case 'rtw'
        traceInfo=RTW.TraceInfo.instance(model);
        if~isa(traceInfo,'RTW.TraceInfo')
            traceInfo=RTW.TraceInfo(model);
        end
    case 'hdl'
        traceInfo=slhdlcoder.TraceInfo.instance(model);
        if~isa(traceInfo,'slhdlcoder.TraceInfo')
            traceInfo=slhdlcoder.TraceInfo(model);
        end
    case 'plc'
        traceInfo=PLCCoder.TraceInfo.instance(model);
        if~isa(traceInfo,'PLCCoder.TraceInfo')
            traceInfo=PLCCoder.TraceInfo(model);
        end
    end
    if isempty(traceInfo.BuildDir)
        traceInfo.setBuildDir('');
        if strcmp(target,'hdl')||strcmp(target,'plc')
            traceInfo.loadTraceInfo;
        end
    end
    for i=numel(sids):-1:1
        sid=sids{i};
        reg=traceInfo.getRegistry(sid,'NeedMergeAllInlineTrace',false);
        if~isempty(reg)
            registry(i)=reg;
        else
            registry(i).sid=sid;
            registry(i).location=[];
        end
    end

    if strcmp(target,'rtw')
        rptInfo=rtw.report.getReportInfo(model);
        if~isempty(rptInfo.SourceSubsystem)
            inCodeTraceInfo=coder.trace.getTraceInfo(rptInfo.SourceSubsystem);
        else
            inCodeTraceInfo=coder.trace.getTraceInfo(model);
        end
        if~isempty(inCodeTraceInfo)
            files=inCodeTraceInfo.files;
            fileMap=cell(1,length(files));
            for i=1:length(inCodeTraceInfo.files)
                fileMap{i}=fullfile(inCodeTraceInfo.buildDir,files{i});
            end
            for idx=numel(sids):-1:1
                sid=sids{idx};
                if~isempty(rptInfo.SourceSubsystem)
                    sid=[rptInfo.ModelName,...
                    Simulink.ID.getSubsystemBuildSID(sid,rptInfo.SourceSubsystem)];
                end
                m2c=inCodeTraceInfo.getModelToCode(sid);
                if~isempty(m2c.tokens)
                    registry(idx)=coder.internal.mergeCodeLocation(registry(idx),m2c,fileMap);
                end
            end
        end
    end


