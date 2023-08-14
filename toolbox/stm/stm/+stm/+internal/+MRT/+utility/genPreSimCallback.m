function genPreSimCallback(outputRoot,releaseName,resultId,simIndex)




    relDir=fullfile(outputRoot,'TestInfo',releaseName);
    if(~exist(relDir,'dir'))
        return;
    end

    workerSysPath=fullfile(outputRoot,'Workers');
    tcrLoc=fullfile(outputRoot,['TestCaseResult_',sprintf('%d',resultId)]);
    simOutputLoc=fullfile(tcrLoc,sprintf('PermutationOutput_%d',simIndex));

    saveRunTo=fullfile(simOutputLoc,'Run.mat');
    covSaveTo=fullfile(simOutputLoc,'CovData.cvt');
    inputDataSetsRunFile=fullfile(simOutputLoc,'ExternalInputRunDataSets.mat');
    inputSignalGroupRunFile=fullfile(simOutputLoc,'InputSignalGroupRunFile.mat');






    simSettingFile=fullfile(['simSettings_',sprintf('%d',resultId),'.mat']);
    params={simSettingFile,sprintf('%d',simIndex),'0',...
    workerSysPath,...
    saveRunTo,covSaveTo,inputDataSetsRunFile,inputSignalGroupRunFile...
    };
    paramStr=join(params,''',''');

    fileName=fullfile(relDir,['preSimCallback_',sprintf('%d_%d',resultId,simIndex),'.m']);
    fid=fopen(fileName,'w');
    fprintf(fid,'%s\n',['simOut = stm.internal.MRT.utility.runTestConfigurationMRT(''',paramStr{1},''');']);
    fclose(fid);
end
