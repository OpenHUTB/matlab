function cvenable(model,testName,varargin)













    [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    if status==0
        error(message(msgId));
    end

model_name_refresh


    modelH=get_param(bdroot(model),'Handle');
    cvModel=get_param(modelH,'CoverageId');
    if(cvModel>0)

        set_param(modelH,'RecordCoverage','on');
    else
        [~,cvModel]=cvi.TopModelCov.setup(modelH);
        set_param(modelH,'RecordCoverage','on');
    end

    testName=convertStringsToChars(testName);


    test=cvtest.create(cvModel);
    cv('set',test...
    ,'.label',testName...
    ,'.settings.decision',1...
    ,'.settings.condition',0...
    );


    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
        cv('set',test,varargin{:});
    end


    cv('set',cvModel,'.activeTest',test);


