function[testcomp,errmsg]=eng_attach_testcomponent(modelH,blockH,opts)





    testcomp=[];
    inAutoScaleMode=strcmp(get_param(modelH,'InRangeAnalysisMode'),'on');
    if inAutoScaleMode
        invalid=false;
    else
        invalid=~SlCov.CoverageAPI.checkCvLicense();
        if invalid
            errmsg=getString(message('Sldv:Setup:CoverageNotLicensed'));
            return;
        end
        invalid=builtin('_license_checkout','SL_Verification_Validation','quiet');
        if invalid
            errmsg=getString(message('Sldv:Setup:SlvnvNotLicensed'));
            return;
        end
    end
    if~invalid
        errmsg='';
        testcomp=mdl_create_testcomponent(modelH,blockH,opts);
        if isempty(testcomp)
            errmsg=getString(message('Sldv:eng_attach_testcomponent:UnableInitializeSldvEngine'));
        end
    end
