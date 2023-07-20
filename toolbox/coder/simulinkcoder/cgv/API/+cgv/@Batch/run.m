
















function TestResults=run(this)
    BatchRunOrigDir=pwd;
    assignin('base','BatchRunOrigDir',BatchRunOrigDir);
    C=onCleanup(@DoRestore);

    if isempty(this.TestList)
        DAStudio.error('RTW:cgv:NoTestsRequested');
    end

    this.StartTime=now;
    this.StartTic=tic;


    TestResults.Completed={};
    TestResults.Error={};
    TestResults.Pass={};
    TestResults.Fail={};
    TestResults.Details=[];


%#ok<*AGROW> Remove the asterisk to see which variables are growing
    errMsg='';
    for testNdx=1:length(this.TestList)
        test=this.TestList{testNdx};
        cgvObj1=test.cgvObj1;
        if cgvObj1.RunHasBeenCalled~=0
            errMsg=[errMsg,char(10),DAStudio.message('RTW:cgv:CgvRunAlreadyCalled',testNdx,inputname(1),testNdx)];
            continue;
        end
        if~isempty(test.cgvObj2)
            cgvObj2=test.cgvObj2;

            if cgvObj2.RunHasBeenCalled~=0
                errMsg=[errMsg,char(10),DAStudio.message('RTW:cgv:CgvRunAlreadyCalled',testNdx,inputname(1),testNdx)];
                continue;
            end
            if~isequal(cgvObj1.ModelName,cgvObj2.ModelName)
                errMsg=[errMsg,char(10),DAStudio.message('RTW:cgv:ModelNamesDoNotMatch',testNdx,inputname(1),testNdx)];
            end
            if~isequal(cgvObj1.UserDir,cgvObj2.UserDir)
                errMsg=[errMsg,char(10),DAStudio.message('RTW:cgv:UserDirDoNotMatch',testNdx,inputname(1),testNdx)];
            end
            if~isequal(cgvObj1.ExecEnv.Obj.ComponentType,cgvObj2.ExecEnv.Obj.ComponentType)
                errMsg=[errMsg,char(10),DAStudio.message('RTW:cgv:ComponentTypesDoNotMatch',testNdx,inputname(1),testNdx)];
            end



            i1=cgvObj1.InputData;
            i2=cgvObj2.InputData;
            if length(i1)~=length(i2)
                errMsg=[errMsg,char(10),DAStudio.message('RTW:cgv:InputDataLengthsDoNotMatch',testNdx,inputname(1),testNdx,inputname(1),testNdx)];
                continue;
            end
            for i=1:length(i1)
                if~strcmp(i1(i).nameOnly,i2(i).nameOnly)||...
                    ~strcmp(i1(i).pathAndName,i2(i).pathAndName)||...
                    ~strcmp(i1(i).label,i2(i).label)
                    errMsg=[errMsg,char(10),DAStudio.message('RTW:cgv:InputDatasDoNotMatch',testNdx,inputname(1),testNdx)];
                end
            end
        end
    end

    if~isempty(errMsg)
        DAStudio.error('RTW:cgv:BatchStartupErrors',errMsg);
    end


    if~isempty(this.HeaderReportFcn)
        this.HeaderReportFcn(this);
    end


    for testNdx=1:length(this.TestList)
        test=this.TestList{testNdx};
        cgvObj1=test.cgvObj1;
        model=cgvObj1.ModelName;
        TestResults.Details(testNdx).Index=testNdx;
        TestResults.Details(testNdx).Model=model;

        if~isempty(this.PreReportFcn)
            this.PreReportFcn(this,test);
        end
        cgvObj1.setWorkingDir(cgvObj1.OutputDir);
        cgvObj1.run();


        try
            TestResults.Details(testNdx).OutputFile{1}={cgvObj1.OutputData(:).filename};
        catch ME %#ok<NASGU>
            TestResults.Details(testNdx).OutputFile{1}=DAStudio.message('RTW:cgv:RsNone');
        end
        try
            TestResults.Details(testNdx).MetaFile{1}={cgvObj1.MetaData(:).metaFileName};
        catch ME %#ok<NASGU>
            TestResults.Details(testNdx).MetaFile{1}=DAStudio.message('RTW:cgv:RsNone');
        end






        status1=cgvObj1.getStatus();
        if isempty(test.cgvObj2)
            if strcmpi(status1,'completed')
                msg='RTW:cgv:RsCompleted';
                TestResults.Completed{end+1}=testNdx;
            elseif strcmpi(status1,'passed')
                msg='RTW:cgv:RsPass';
                TestResults.Pass{end+1}=testNdx;
            elseif strcmpi(status1,'failed')
                msg='RTW:cgv:RsFail';
                TestResults.Fail{end+1}=testNdx;
            else

                msg='RTW:cgv:RsError';
                TestResults.Error{end+1}=testNdx;
            end
        else

            cgvObj2=test.cgvObj2;

            cgvObj2.setWorkingDir(cgvObj2.OutputDir);
            cgvObj2.run();

            try
                TestResults.Details(testNdx).OutputFile{2}={cgvObj2.OutputData(:).filename};
            catch ME %#ok<NASGU>
                TestResults.Details(testNdx).OutputFile{2}=DAStudio.message('RTW:cgv:RsNone');
            end
            try
                TestResults.Details(testNdx).MetaFile{2}={cgvObj2.MetaData(:).metaFileName};
            catch ME %#ok<NASGU>
                TestResults.Details(testNdx).MetaFile{2}=DAStudio.message('RTW:cgv:RsNone');
            end

            status2=cgvObj2.getStatus();


            if strcmpi(status1,'error')||strcmpi(status2,'error')
                msg='RTW:cgv:RsError';
                TestResults.Error{end+1}=testNdx;
            elseif strcmpi(status1,'failed')||strcmpi(status2,'failed')
                msg='RTW:cgv:RsFail';
                TestResults.Fail{end+1}=testNdx;
            else

                passed=true;
                for inputIdx=1:length(cgvObj1.InputData)
                    label=cgvObj1.InputData(inputIdx).label;
                    if~isempty(label)
                        simout=cgvObj1.getOutputData(label);
                        simout2=cgvObj2.getOutputData(label);
                        if isempty(test.tolFile)
                            [~,~,mismatchNames,mismatchFigures]=cgv.CGV.compare(simout,simout2,...
                            'plot','mismatch');
                        else
                            [~,~,mismatchNames,mismatchFigures]=cgv.CGV.compare(simout,simout2,...
                            'plot','mismatch','toleranceFile',test.tolFile);
                        end
                        if~isempty(mismatchNames)
                            passed=false;
                            for figNdx=1:length(mismatchFigures)
                                figHndl=mismatchFigures{figNdx};


                                figFile=sprintf('baseline_%d_figure_%d',inputIdx,figNdx);
                                figFullName=fullfile(cgvObj1.OutputDir,[figFile,'.png']);
                                saveas(figHndl,figFullName);
                                test.errorPlotFile{inputIdx}{figNdx}=figFullName;
                                test.errorSignalName{inputIdx}{figNdx}=mismatchNames{figNdx};
                                close(figHndl);
                            end
                            this.TestList{testNdx}=test;
                        end
                    end
                end
                if passed
                    msg='RTW:cgv:RsPass';
                    TestResults.Pass{end+1}=testNdx;
                else
                    msg='RTW:cgv:RsFail';
                    TestResults.Fail{end+1}=testNdx;
                end
            end
        end
        TestResults.Details(testNdx).Result=DAStudio.message(msg);
        TestResults.Details(testNdx).Model=model;
        this.TestList{testNdx}.result=TestResults.Details(testNdx).Result;

        if~isempty(this.PostReportFcn)
            this.PostReportFcn(this,this.TestList{testNdx});
        end


        cd(BatchRunOrigDir);
        save(this.TestResultsFileName,'TestResults');
    end

    if~isempty(this.TrailerReportFcn)
        this.TrailerReportFcn(this,TestResults);
    end
end


function DoRestore()
    BatchRunOrigDir=evalin('base','BatchRunOrigDir');
    cd(BatchRunOrigDir);

    evalin('base','clear BatchRunOrigDir');
end


