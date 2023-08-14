function testCase=importSLDVResults(SLDVMatFile,testFilePath,model,harness)





    if nargin==4
        hStruct=[];
        if~isempty(harness)

            hStruct=sltest.harness.find(model,'Name',harness);
            if isempty(hStruct)
                error(message('stm:general:CouldNotFindHarness',harness,model));
            end
        end
    else

        hStruct=model;
        model=hStruct.model;
    end


    [~,~,ext]=fileparts(SLDVMatFile);
    if isempty(ext)
        SLDVMatFile=[SLDVMatFile,'.mat'];
    end



    fileToUse=which(SLDVMatFile);
    if isempty(fileToUse)
        fileToUse=SLDVMatFile;
    end




    if~exist(testFilePath,'file')

        tf=sltest.testmanager.TestFile(testFilePath,false);
        ts=tf.getTestSuites;
        tc=ts.getTestCases;


        setupCoverageSettings(tf,model);
    else

        tf=sltest.testmanager.TestFile(testFilePath,false);
        ts=tf.createTestSuite;
        tc=ts.createTestCase;
    end




    stm.internal.setupTestCase(tc,model,hStruct,fileToUse);

    tf.saveToFile;
    testCase=tc;
end

function setupCoverageSettings(tf,model)
    cs=tf.getCoverageSettings;

    cs.RecordCoverage=true;

    cs.MdlRefCoverage=true;

    cs.MetricSettings=get_param(model,'CovMetricSettings');
end
