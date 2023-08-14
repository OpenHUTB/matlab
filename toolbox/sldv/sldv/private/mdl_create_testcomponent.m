function[testcomp,errmsg]=mdl_create_testcomponent(objH,blockH,settings)



    check_slavtpackage;

    errmsg=getString(message('Sldv:private:mdlUtils:UnableInitializeSldvEngine'));
    if strcmp(get_param(objH,'Type'),'block')&&...
        strcmp(get_param(objH,'BlockType'),'SubSystem'),

        modelH=bdroot(objH);
        if ischar(modelH)
            modelH=get_param(modelH,'Handle');
        end
    else
        modelH=objH;
    end

    testcomp=SlAvt.TestComponent;
    testcomp.setProfileSession(get_param(modelH,'Name'));
    testcomp.analysisInfo=sldvprivate('getDefaultAnalysisInfo',modelH);

    if~isa(settings,'Sldv.Options')
        slavtcc=configcomp_get(modelH);
        if isempty(slavtcc)
            dirty=get_param(modelH,'Dirty');
            configcomp_attach(modelH,blockH);
            set_param(modelH,'Dirty',dirty);
            slavtcc=configcomp_get(modelH);
        else
            slavtcc.SubsystemToAnalyze=blockH;
        end
        if~isempty(slavtcc)
            settings=Sldv.Options(modelH);
        end
    end

    if~isa(settings,'Sldv.Options')
        delete(testcomp);
        testcomp=[];
        return;
    end


    testcomp.activeSettings=settings;


    if strcmp(testcomp.activeSettings.Mode,'PropertyProving')&&...
        strcmp(testcomp.activeSettings.ProvingStrategy,'FindViolation')&&...
        slavteng('feature','ReportValidWithinBound')
        testcomp.isBoundedCheck=true;
    else
        testcomp.isBoundedCheck=false;
    end

    testcomp.recordDvirSim=boolean(slavteng('feature','DvirSim'));

    errmsg='';


