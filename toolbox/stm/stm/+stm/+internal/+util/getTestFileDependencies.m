function deps=getTestFileDependencies(testfile)






















    licChk=stm.internal.util.LicenseCheck.getLicenseCheckoutObject();

    licChk.setShouldCheckoutLicense(false);

    licCleanup=onCleanup(@()setShouldCheckoutLicense(licChk,true));

    deps=[];
    try
        isFileAlreadyOpen=stm.internal.isTestFileOpen(testfile);
        tf=sltest.testmanager.TestFile(testfile,false,false);
        oc=onCleanup(@()helperCloseTestFile(tf,isFileAlreadyOpen));
    catch me %#ok
        return;

    end


    setupCallback=tf.getProperty('SETUPCALLBACK');
    cleanupCallback=tf.getProperty('CLEANUPCALLBACK');


    val.Value=setupCallback;
    val.Type=getString(message('stm:Dependency:TestCallback'));
    val.ValueType='string';
    deps=[deps,val];

    val.Value=cleanupCallback;
    val.Type=getString(message('stm:Dependency:TestCallback'));
    val.ValueType='string';
    deps=[deps,val];


    tsObjs=tf.getTestSuites();

    for i=1:length(tsObjs)
        deps=[deps,getTestSuiteDependencies(tsObjs(i))];%#ok<AGROW>
    end
end

function helperCloseTestFile(tf,isFileAlreadyOpen)
    try

        if~isFileAlreadyOpen
            tf.close()
        end
    catch

    end
end


function deps=getTestSuiteDependencies(ts)

    deps=[];

    setupCallback=ts.getProperty('SETUPCALLBACK');
    cleanupCallback=ts.getProperty('CLEANUPCALLBACK');


    val.Value=setupCallback;
    val.Type=getString(message('stm:Dependency:TestCallback'));
    val.ValueType='string';
    deps=[deps,val];

    val.Value=cleanupCallback;
    val.Type=getString(message('stm:Dependency:TestCallback'));
    val.ValueType='string';
    deps=[deps,val];


    tcObjs=ts.getTestCases();
    for i=1:length(tcObjs)
        deps=[deps,getTestCaseDependencies(tcObjs(i))];%#ok<AGROW>
    end


    tsObjs=ts.getTestSuites();
    for i=1:length(tsObjs)
        deps=[deps,getTestSuiteDependencies(tsObjs(i))];%#ok<AGROW>
    end
end


function deps=getTestCaseDependencies(tc)
    deps=[];


    numSims=tc.NumSimulations;

    for i=1:numSims
        if tc.getProperty("LOADAPPFROM",i)==1

            mdlName=tc.getProperty('MODEL',i);


            if~isempty(mdlName)
                location=which(mdlName);
                if isempty(location)


                    location=[mdlName,'.slx'];
                end

                val.Value=location;
                val.Type=getString(message('stm:Dependency:SystemUnderTest'));
                val.ValueType='file';
                deps=[deps,val];%#ok<AGROW>
            end
        else
            if tc.getProperty("LOADAPPFROM",i)==2
                appname=tc.getProperty("TARGETAPPLICATION",i);
                if~isempty(appname)
                    location=which(appname);

                    if isempty(location)


                        [~,app,~]=fileparts(appname);
                        location=[app,'.mldatx'];
                    end

                    val.Value=location;
                    val.Type=getString(message('stm:Dependency:SystemUnderTest'));
                    val.ValueType='file';
                    deps=[deps,val];%#ok<AGROW>
                end
            end
        end

        if~tc.RunOnTarget{i}
            matFileLocation=tc.getProperty('CONFIGSETFILELOCATION',i);
            if~isempty(matFileLocation)
                val.Value=matFileLocation;
                val.Type=getString(message('stm:Dependency:ConfigSetReference'));
                val.ValueType='file';
                deps=[deps,val];%#ok<AGROW>
            end
        end

        pSets=tc.getParameterSets(i);
        for j=1:length(pSets)

            fPath=pSets(j).FilePath;

            if~isempty(fPath)
                val.Value=fPath;
                val.Type=getString(message('stm:Dependency:ParameterOverride'));
                val.ValueType='file';
                deps=[deps,val];%#ok<AGROW>
            end
        end


        preloadCallback=tc.getProperty('PRELOADCALLBACK',i);
        postloadCallback=tc.getProperty('POSTLOADCALLBACK',i);
        if tc.RunOnTarget{i}
            preStartRealTimeApplicationCallback=tc.getProperty('PRESTARTREALTIMEAPPLICATIONCALLBACK',i);
        else
            preStartRealTimeApplicationCallback='';
        end
        cleanupCallback=tc.getProperty('CLEANUPCALLBACK',i);


        val.Value=preloadCallback;
        val.Type=getString(message('stm:Dependency:TestCallback'));
        val.ValueType='string';
        deps=[deps,val];%#ok<AGROW>

        val.Value=postloadCallback;
        val.Type=getString(message('stm:Dependency:TestCallback'));
        val.ValueType='string';
        deps=[deps,val];%#ok<AGROW>

        val.Value=preStartRealTimeApplicationCallback;
        val.Type=getString(message('stm:Dependency:TestCallback'));
        val.ValueType='string';
        deps=[deps,val];%#ok<AGROW>

        val.Value=cleanupCallback;
        val.Type=getString(message('stm:Dependency:TestCallback'));
        val.ValueType='string';
        deps=[deps,val];%#ok<AGROW>


        try
            bc=tc.getBaselineCriteria();
            for k=1:length(bc)

                fPath=bc(k).FilePath;
                if~isempty(fPath)
                    val.Value=fPath;
                    val.Type=getString(message('stm:Dependency:Baseline'));
                    val.ValueType='file';
                    deps=[deps,val];%#ok<AGROW>
                end
            end
        catch

        end


        inps=tc.getInputs(i);
        for j=1:length(inps)

            fPath=inps(j).FilePath;

            if~isempty(fPath)
                val.Value=fPath;
                val.Type=getString(message('stm:Dependency:ExternalInput'));
                val.ValueType='file';
                deps=[deps,val];%#ok<AGROW>
            end
        end
    end


    customCriteria=tc.getCustomCriteria();
    callback=customCriteria.Callback;
    val.Value=callback;
    val.Type=getString(message('stm:Dependency:CustomCriteria'));
    val.ValueType='string';
    deps=[deps,val];



    try
        externalFile=tc.getProperty('TestDataPath');
        dptr_fname=tc.getProperty('Adapter');

        if~isempty(externalFile)
            val1.Value=externalFile;
            val1.Type=getString(message('stm:Dependency:ExternalTestData'));
            val1.ValueType='file';
            deps=[deps,val1];
        end

        if~isempty(dptr_fname)

            adapterPath=which(func2str(dptr_fname));
            if isempty(adapterPath)

                adapterPath=[func2str(dptr_fname),'.m'];
            end

            val2.Value=adapterPath;
            val2.Type=getString(message('stm:Dependency:TestAdapter'));
            val2.ValueType='file';
            deps=[deps,val2];
        end
    catch me %#ok
    end
end
