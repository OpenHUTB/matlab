function[traceInfo,traceInfoDeclarationsSite]=extractProfilingTraceInfo...
    (srcFilesList,headerFilesList)



    featVal=slfeature('EmitCgObjId',0);
    oc=onCleanup(@()slfeature('EmitCgObjId',featVal));

    [srcFiles,hdrFiles,~,startExpr,endExpr]=...
    coder.internal.InstrProfilingInfo.buildRegexp(srcFilesList,...
    headerFilesList,...
    Simulink.ExecTimeTraceabilityProbes.BlockStartSymbol,...
    Simulink.ExecTimeTraceabilityProbes.BlockEndSymbol);


    traceInfo=coder.trace.TraceInfoBuilder('');
    traceInfo.buildDir=pwd;
    traceInfo.setTraceDelim('_')
    for i=1:length(srcFiles)
        srcFile=srcFiles{i};
        content=fileread(srcFiles{i});
        contentNew=regexprep(content,startExpr,'/*_>$1:$2*/');
        contentNew=regexprep(contentNew,endExpr,'/*_<$1:$2*/');
        fid=fopen(srcFile,'w');
        fwrite(fid,contentNew);
        fclose(fid);
    end

    traceInfo.extractTraceInfo(srcFiles);


    traceInfoDeclarationsSite=i_get_declarations_traceInfo(hdrFiles);


end



function traceInfoDeclarationsSite=i_get_declarations_traceInfo(headerFileNames)
    featVal=slfeature('EmitCgObjId',0);
    oc=onCleanup(@()slfeature('EmitCgObjId',featVal));

    declarationsExpr=sprintf('\\/\\*\\s*(%s)\\s*\\*\\/',...
    Simulink.ExecTimeTraceabilityProbes.DeclarationsPlaceholderSymbol);

    traceInfoDeclarationsSite=coder.trace.TraceInfoBuilder('');
    traceInfoDeclarationsSite.buildDir=pwd;
    traceInfoDeclarationsSite.setTraceDelim('_');

    for i=1:length(headerFileNames)
        hdrFile=headerFileNames{i};
        content=fileread(hdrFile);
        startIndex=regexp(content,declarationsExpr,'once');
        found=~isempty(startIndex);

        if found
            contentNew=regexprep(content,declarationsExpr,'/*_>$1*/');
            fid=fopen(hdrFile,'w');
            fwrite(fid,contentNew);
            fclose(fid);
        end
    end

    traceInfoDeclarationsSite.extractTraceInfo(headerFileNames);

end

