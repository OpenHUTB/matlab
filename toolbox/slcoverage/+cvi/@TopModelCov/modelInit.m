




function modelInit(modelH,hiddenSubSys,~,isObserver)
    try




        if nargin<4
            isObserver=false;
        end

        compileForCoverage=strcmpi(get_param(modelH,'compileForCoverageInProgress'),'on');
        if~compileForCoverage&&~cvi.TopModelCov.checkLicense(modelH)
            return;
        end

        coveng=cvi.TopModelCov.getInstance(modelH);


        if~isempty(coveng)&&(~isempty(coveng.covModelRefData)||coveng.isCvCmdCall)
            modelcovId=get_param(modelH,'CoverageId');
        else
            [coveng,modelcovId]=cvi.TopModelCov.setup(modelH);
        end

        cv('set',modelcovId,'.isObserver',isObserver);

        if~compileForCoverage
            [testId,rootSlHandle]=initTest(coveng,modelH,modelcovId);
            if testId==0
                return;
            end
            if~cvprivate('cv_autoscale_settings','isForce',modelH)&&...
                ~SlCov.CoverageAPI.isCovToolUsedBySlicer(modelH)
                coveng.getResultSettings;
            end

            initFixptAutoscale(modelH,testId);
        else

            rootSlHandle=initCompileForCoverage(modelH);
            testId=0;
        end
        cv('ModelInit',modelH);
        cvi.TopModelCov.createRoot(modelcovId,rootSlHandle);

        cvi.TopModelCov.createSlsfHierarchy(modelH,hiddenSubSys);

        coveng.addModelcov(modelH);
        if~compileForCoverage
            cvt=cvtest(testId);
            isEnabledExternal=cvt.emlSettings.enableExternal;
        else
            isEnabledExternal=strcmpi(get_param(coveng.topModelH,'CovExternalEMLEnable'),'on');
        end

        if isEnabledExternal
            coveng.coderCov.modelInit(testId);
        end

    catch MEx
        rethrow(MEx);
    end

    function rootSlHandle=initCompileForCoverage(modelH)
        covPath=get_param(modelH,'CovPath');
        modelName=get_param(modelH,'name');
        fullCovPath=cvi.TopModelCov.checkCovPath(modelName,covPath);
        rootSlHandle=get_param(fullCovPath,'Handle');




        function initFixptAutoscale(modelH,testId)


            dirtyFlag=get_param(modelH,'Dirty');
            if sfprivate('is_sf_fixpt_autoscale',modelH)
                cvt=cvtest(testId);
                cvt.settings.sigrange=1;

                set_param(modelH,'CovAutoscale','on')
                if strcmpi(get_param(modelH,'MinMaxOverflowArchiveMode'),'overwrite')
                    evalin('base','clear global FixPtSimRanges');
                end
            else
                set_param(modelH,'CovAutoscale','off')
            end
            set_param(modelH,'Dirty',dirtyFlag);
