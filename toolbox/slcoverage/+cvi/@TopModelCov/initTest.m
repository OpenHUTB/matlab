




function[testId,rootSlHandle]=initTest(coveng,modelH,modelcovId)
    testId=cv('get',modelcovId,'.activeTest');
    modelName=get_param(modelH,'name');
    rootSlHandle=0;

    if testId==0

        setupHarnessInfo(coveng);


        if(strcmpi(coveng.ownerType,'Simulink.BlockDiagram')||...
            strcmpi(coveng.ownerType,'Simulink.ModelReference'))&&...
            strcmpi(modelName,coveng.harnessModel)
            set_param(modelH,'RecordCoverage','off');



            return;
        end

        if SlCov.CodeCovUtils.isAtomicSubsystem(modelName)
            set_param(modelH,'RecordCoverage','off');
            set_param(modelH,'CovModelRefEnable','all');
            return
        end
        covPath=get_param(modelH,'CovPath');
        fullCovPath=cvi.TopModelCov.checkCovPath(modelName,covPath);
        if~isempty(coveng.unitUnderTestName)&&(modelH==coveng.topModelH)
            unitUnderTestName=coveng.unitUnderTestName;
            if contains(fullCovPath,coveng.unitUnderTestName)
                unitUnderTestName=fullCovPath;
            end
            cvt=cvtest(unitUnderTestName);
        else
            cvt=cvtest(fullCovPath);
        end

        testId=cvt.id;
        cv('set',testId,'.type','DLGENABLED_TST');
        activate(cvt,modelcovId);
    else
        cvt=cvtest(testId);
    end
    fullCovPath=cvi.TopModelCov.checkCovPath(modelName,cvt.rootPath);

    coveng.initHarnessInfo(modelcovId,testId);


    if~isempty(coveng.covModelRefData)&&~coveng.isCvCmdCall||...
        get_param(modelName,'IsPausing')==1
        copyMetricsFromModel(cvt,get_param(coveng.topModelH,'name'));
    end
    rootSlHandle=get_param(fullCovPath,'Handle');


