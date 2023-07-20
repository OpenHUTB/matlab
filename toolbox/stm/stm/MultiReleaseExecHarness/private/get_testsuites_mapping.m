function testSuites=get_testsuites_mapping(testName)

    testSuites={};

    switch lower(testName)
    case 'matlab_startup'
        testSuites={'matlab_startup'};
    case 'simulink_simulate'
        testSuites={'model_load','simulink_simulate'};
    end
