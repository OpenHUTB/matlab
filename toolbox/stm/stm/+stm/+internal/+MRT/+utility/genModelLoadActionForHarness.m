function funcName=genModelLoadActionForHarness(outFolder,modelName,harnessString,...
    testId,simIndex)







    funcName=sprintf('modelLoadAction%d_%d',testId,simIndex);
    scriptFile=fullfile(outFolder,[funcName,'.m']);
    fid=fopen(scriptFile,'w');

    fprintf(fid,'%s\n','%% check if harnss is supported');
    fprintf(fid,'%s\n',['tmp = which(','''','Simulink.harness.load','''',');']);
    fprintf(fid,'if(isempty(tmp))\n');
    fprintf(fid,'    %s\n',['verInfo = ver(','''','matlab','''',');']);

    str=['stm.internal.MRT.share.error(','''','stm:MultipleReleaseTesting:HarnessAPINotFound',''''];
    str=[str,',verInfo.Release);'];
    fprintf(fid,'    %s\n',str);
    fprintf(fid,'end\n\n');

    fprintf(fid,'%s\n',['load_system(','''',modelName,'''',');']);

    str='[modelToRun, deactivateHarness, currHarness, oldHarness, ';
    str=[str,'wasHarnessOpen, harnessName, ownerName, componentUnderTest] = '];


    harnessString=stm.internal.MRT.utility.fixMultilineString(harnessString);

    str=[str,'stm.internal.util.resolveModelToRun(','''',modelName,'''',', sprintf(''',harnessString,'''));'];
    fprintf(fid,'%s\n',str);
    fclose(fid);
end