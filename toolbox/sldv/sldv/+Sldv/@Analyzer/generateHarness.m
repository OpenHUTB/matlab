



function fileNames=generateHarness(obj,sldvData,fileNames)
    testComp=obj.mTestComp;
    harnessopts=Sldv.HarnessUtils.getHarnessOpts;
    harnessopts.modelRefHarness=Sldv.HarnessUtils.isMdlRefHarnessEnabled(testComp);
    harnessopts.harnessFilePath=testComp.resolvedSettings.HarnessModelFileName;
    harnessopts.usedSignalsOnly=true;
    harnessopts.harnessSource=obj.mSldvOpts.HarnessSource;
    try
        [~,warnMsgs]=Sldv.HarnessUtils.make_model_harness(testComp.analysisInfo.extractedModelH,...
        sldvData,harnessopts,'sldvmakeharness');
        if~isempty(warnMsgs)

            for i=1:numel(warnMsgs)
                obj.logAll(sprintf('%s\n',getString(warnMsgs{i}),obj.activity()));
            end
        end

        fileNames.HarnessModel=testComp.resolvedSettings.HarnessModelFileName;
        obj.logAll(obj.html_spaced_label_val(getString(message('Sldv:SldvRun:HarnessModel')),...
        testComp.resolvedSettings.HarnessModelFileName));
    catch Mex
        obj.logNewLines(getString(message('Sldv:SldvRun:NoHarness')));
        obj.logAll(sprintf('%s\n',Mex.message));
        obj.logAll(newline);
        if isfield(testComp.resolvedSettings,'HarnessModelFileName')
            testComp.resolvedSettings=rmfield(testComp.resolvedSettings,'HarnessModelFileName');
        end
    end
end
