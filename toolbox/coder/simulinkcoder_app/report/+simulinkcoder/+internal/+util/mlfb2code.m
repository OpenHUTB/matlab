function mlfb2code(studio,sid)


    mdl=studio.App.blockDiagramHandle;
    rptInfo=simulinkcoder.internal.util.getReportInfo(mdl);
    traceInfo=coder.trace.getTraceInfoByReportInfo(rptInfo);
    r=traceInfo.getModelToCode(sid);
    files=traceInfo.files;
    tks=r.tokens;
    n=length(tks);
    tokens=cell(n,1);
    for i=1:n
        tk=tks(i);
        token=[];
        token.file=files{tk.fileIdx+1};
        token.line=tk.line;
        token.col=tk.beginCol;
        tokens{i}=token;
    end
    record=[];
    record.sid=r.SID;
    record.tokens=tokens;

    cr=simulinkcoder.internal.Report.getInstance;
    mdlName=get_param(mdl,'Name');
    cr.publish(mdlName,'record2code',record);
