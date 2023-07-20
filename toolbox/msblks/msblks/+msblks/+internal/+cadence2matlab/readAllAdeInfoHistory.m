function[dbTables,totalCorners,wfResults,wfCorners,wfOutput,History,scScalarInfo,scScalarOut,scCorners,waveformDB,simDBS,simDBC,paramTable,paramConditionTable]=readAllAdeInfoHistory(~)





























    import cadence.srrdata.*
    import cadence.Query.*
    import cadence.utils.*
    import cadence.simdata.*
    import cadence.srrsata.*
    import cadence.streamCalculator.*
    import cadence.utils.cdsPlot.*







    prompt={'Enter ADE Run Type','Enter total number of runs up to final Interactive/Ocean run number','Enter ADE Test Name','Enter Simulation Type'};
    dlgtitle='ADE Testbench Information';
    dims=[1,35];
    definput={'','','','',''};
    answer=inputdlg(prompt,dlgtitle,dims,definput);


    if isempty(answer)
        return;
    end

    runType=answer{1};
    runs=str2double(answer{2});
    testName=answer{3};
    simulationType=answer{4};


    if((isempty(runType))||(isempty(testName))||(isempty(runs))||(isempty(simulationType)))
        error(message('msblks:mixedsignalanalyzer:AdeInfoAllInput1'));
    elseif((strcmpi(runType,'Interactive')==0)&&(strcmpi(runType,'Ocean')==0))
        error(message('msblks:mixedsignalanalyzer:AdeInfoRunType'));
    elseif(testName=="")
        error(message('msblks:mixedsignalanalyzer:AdeInfoAllTestName'));
    elseif((strcmpi(simulationType,'all')==0)&&(strcmpi(simulationType,'tran')==0)&&(strcmpi(simulationType,'ac')==0)&&(strcmpi(simulationType,'dc')==0)&&(strcmpi(simulationType,'noise')==0))
        error(message('msblks:mixedsignalanalyzer:AdeinfoSimulationType'));
    end



    validateattributes(runType,{'char'},{'nonempty'});
    validateattributes(runs,{'numeric'},{'nonempty','scalar','finite','nonnan','integer','positive'});
    validateattributes(testName,{'char'},{'nonempty'});
    validateattributes(simulationType,{'char'},{'nonempty'});



    h=matlabshared.application.IgnoreWarnings;
    h.RethrowWarning=false;

    s1=runType;
    s2=runs;
    s3=testName;
    s4=simulationType;


    cadence.AdeInfoManager.loadResult();
    adeInfo=cadence.AdeInfoManager.getInstance();


    if adeInfo.adeDataPoint==-1
        adeInfo.loadResult();
        cadence.AdeInfoManager.loadResult();
        cadence.AdeInfoManager.loadResult('history',[s1,'.',num2str(s2)]);
        adeInfo.loadResult('test',s3,'DataPoint',1);
        [dbTables,totalCorners,wfResults,wfCorners,wfOutput,History,scScalarInfo,scScalarOut,scCorners,waveformDB,simDBS,simDBC,paramTable,paramConditionTable]=extractAllAdeInfoHistory(s1,s2,s3,s4);
    else
        [dbTables,totalCorners,wfResults,wfCorners,wfOutput,History,scScalarInfo,scScalarOut,scCorners,waveformDB,simDBS,simDBC,paramTable,paramConditionTable]=extractAllAdeInfoHistory(s1,s2,s3,s4);
    end
end

function[dbTables,totalCorners,wfResults,wfCorners,wfOutput,History,scScalarInfo,scScalarOut,scCorners,waveformDB,simDBS,simDBC,paramTable,paramConditionTable]=extractAllAdeInfoHistory(runType,runs,testName,simulationType)


























    if nargin<4
        error(message('msblks:mixedsignalanalyzer:AdeInfoAllInput2'));
    end


    validateattributes(runType,{'char'},{'nonempty'});
    validateattributes(runs,{'numeric'},{'nonempty','scalar','finite','nonnan','integer','positive'});
    validateattributes(testName,{'char'},{'nonempty'});
    validateattributes(simulationType,{'char'},{'nonempty'});



    import cadence.srrdata.*
    import cadence.Query.*
    import cadence.utils.*
    import cadence.simdata.*
    import cadence.srrsata.*
    import cadence.streamCalculator.*
    import cadence.utils.cdsPlot.*


    h=matlabshared.application.IgnoreWarnings;
    h.RethrowWarning=false;

    dbTables=[];
    signalTables=[];
    exprTables=[];
    totalCorners=[];
    simDBS=[];
    simDBC=[];
    paramTable=[];
    paramConditionTable=[];

    wResults.no={};
    wCorners.no={};
    wOutput.no={};
    waveformData.no={};

    j=1;
    s1=runType;
    s3=testName;

    for i=1:runs


        [~,adeInfo.no{j}]=evalc("cadence.AdeInfoManager.loadResult('history',[s1 '.' num2str(i-1,'%d')]);");
        [~,rdb.no{j}]=evalc("cadence.AdeInfoManager.loadResult('history',[s1 '.' num2str(i-1,'%d')]).adeRDB;");
        [~,dbTables.no{j}]=evalc("rdb.no{j}.query();");
        [~,signalTables.no{j}]=evalc('rdb.no{j}.where(Type == TypeValue.Signal).query();');
        [~,exprTables.no{j}]=evalc('rdb.no{j}.where(Type == TypeValue.Expr).query();');


        if isempty(dbTables.no{j})
            continue
        end









        dbTables.no{j}(~strcmpi(dbTables.no{j}.Test,s3),:)=[];

        totalCorners.no{j}=rdb.no{j}.corners;
        paramTable.no{j}=rdb.no{j}.params;
        paramConditionTable.no{j}=rdb.no{j}.paramConditions;




        iscell_dbTablesResult=iscell(dbTables.no{j}.Result);
        iscell_dbTablesCorner=iscell(dbTables.no{j}.Corner);
        iscell_dbTablesOutput=iscell(dbTables.no{j}.Output);








        initialSize=length(dbTables.no{j}.Result);
        wResults.no(j).results.no{initialSize}=[];
        wCorners.no(j).corners.no{initialSize}=[];
        wOutput.no(j).output.no{initialSize}=[];
        sValue.no{j}.value.no{initialSize}=[];
        sCorners.no(j).corners.no{initialSize}=[];
        sScalar.no{j}.scalar.no{initialSize}=[];




        wResultsCornersOutputLastUsedIndex=0;
        sValueCornersScalarLastUsedIndex=0;

        maxDpoint=max(dbTables.no{j}.DataPoint);
        dPoint=1;
        k=1;
        for m=1:maxDpoint
            [~,~]=evalc("cadence.AdeInfoManager.loadResult('dataPoint',dPoint);");

            try
                simDBS.no{j}=struct(adeInfo.no{j});
                if m==1

                    simDBC.no{simCnt}.simdbs.no{maxDpoint}=[];
                end
                simDBC.no{j}.simdbs.no{m}=struct(adeInfo.no{j});
            catch
            end
            sizeTable.no{j}=size(dbTables.no{j});
            z=sizeTable.no{j}(1);
            history.no{j}=[s1,'.',num2str(i-1,'%d')];

            count=1;

            for i1=1:z
                if iscell_dbTablesResult
                    if(((isa(dbTables.no{j}.Result{i1},'logical')==1)||(dbTables.no{j}.Result{i1}==false))...
                        &&(dbTables.no{j}.DataPoint(i1)==dPoint)&&startsWith(dbTables.no{j}.Output{i1},'/'))
                        count=count+1;
                        wResultsCornersOutputLastUsedIndex=k;
                        wResults.no(j).results.no{k}=dbTables.no{j}.Result{i1};
                        if iscell_dbTablesCorner
                            wCorners.no(j).corners.no{k}=dbTables.no{j}.Corner{i1};
                        else
                            wCorners.no(j).corners.no{k}=dbTables.no{j}.Corner(i1);
                        end
                        if iscell_dbTablesOutput
                            wOutput.no(j).output.no{k}=dbTables.no{j}.Output{i1};
                        else
                            wOutput.no(j).output.no{k}=dbTables.no{j}.Output(i1);
                        end

                        switch simulationType
                        case 'all'
                            kBegin=k;
                            for wfType=1:10
                                switch wfType
                                case 1
                                    waveform=getWaveform('VT',dbTables,j,i1);
                                case 2
                                    waveform=getWaveform('VS',dbTables,j,i1);
                                case 3
                                    waveform=getWaveform('VDC',dbTables,j,i1);
                                case 4
                                    waveform=getWaveform('VF',dbTables,j,i1);
                                case 5
                                    waveform=getWaveform('IF',dbTables,j,i1);
                                case 6
                                    waveform=getWaveform('IS',dbTables,j,i1);
                                case 7
                                    waveform=getWaveform('IDC',dbTables,j,i1);
                                case 8
                                    waveform=getWaveform('IT',dbTables,j,i1);
                                case 9
                                    waveform=getWaveform('VN',dbTables,j,i1);
                                case 10
                                    waveform=getWaveform('NG',dbTables,j,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(j).waveData.no(k-1),waveform))
                                    waveformData.no(j).waveData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        case 'tran'
                            kBegin=k;
                            for wfType=1:2
                                switch wfType
                                case 1
                                    waveform=getWaveform('VT',dbTables,j,i1);
                                case 2
                                    waveform=getWaveform('IT',dbTables,j,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(j).waveData.no(k-1),waveform))
                                    waveformData.no(j).waveData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        case 'ac'
                            kBegin=k;
                            for wfType=1:2
                                switch wfType
                                case 1
                                    waveform=getWaveform('VF',dbTables,j,i1);
                                case 2
                                    waveform=getWaveform('IF',dbTables,j,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(j).waveData.no(k-1),waveform))
                                    waveformData.no(j).waveData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        case 'dc'
                            kBegin=k;
                            for wfType=1:4
                                switch wfType
                                case 1
                                    waveform=getWaveform('VDC',dbTables,j,i1);
                                case 2
                                    waveform=getWaveform('VS',dbTables,j,i1);
                                case 3
                                    waveform=getWaveform('IDC',dbTables,j,i1);
                                case 4
                                    waveform=getWaveform('IS',dbTables,j,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(j).waveData.no(k-1),waveform))
                                    waveformData.no(j).waveData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        case 'noise'
                            kBegin=k;
                            for wfType=1:2
                                switch wfType
                                case 1
                                    waveform=getWaveform('VN',dbTables,j,i1);
                                case 2
                                    waveform=getWaveform('NG',dbTables,j,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(j).waveData.no(k-1),waveform))
                                    waveformData.no(j).waveData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        end




                    else
                        sValueCornersScalarLastUsedIndex=k;
                        sValue.no{j}.value.no{k}=dbTables.no{j}.Result{i1};
                        if iscell_dbTablesCorner
                            sCorners.no(j).corners.no{k}=dbTables.no{j}.Corner{i1};
                        else
                            sCorners.no(j).corners.no{k}=dbTables.no{j}.Corner(i1);
                        end
                        if iscell_dbTablesOutput
                            sScalar.no{j}.scalar.no{k}=dbTables.no{j}.Output{i1};
                        else
                            sScalar.no{j}.scalar.no{k}=dbTables.no{j}.Output(i1);
                        end
                    end

                else

                    if(((dbTables.no{j}.Result(i1)==0)||(dbTables.no{j}.Result(i1)==false))...
                        &&(dbTables.no{j}.DataPoint(i1)==dPoint)&&startsWith(dbTables.no{j}.Output(i1),'/'))
                        count=count+1;
                        wResultsCornersOutputLastUsedIndex=k;
                        wResults.no(j).results.no{k}=dbTables.no{j}.Result(i1);
                        if iscell_dbTablesCorner
                            wCorners.no(j).corners.no{k}=dbTables.no{j}.Corner{i1};
                        else
                            wCorners.no(j).corners.no{k}=dbTables.no{j}.Corner(i1);
                        end
                        if iscell_dbTablesOutput
                            wOutput.no(j).output.no{k}=dbTables.no{j}.Output{i1};
                        else
                            wOutput.no(j).output.no{k}=dbTables.no{j}.Output(i1);
                        end

                        switch simulationType
                        case 'all'
                            kBegin=k;
                            for wfType=1:10
                                switch wfType
                                case 1
                                    waveform=getWaveform('VT',dbTables,j,i1);
                                case 2
                                    waveform=getWaveform('VS',dbTables,j,i1);
                                case 3
                                    waveform=getWaveform('VDC',dbTables,j,i1);
                                case 4
                                    waveform=getWaveform('VF',dbTables,j,i1);
                                case 5
                                    waveform=getWaveform('IF',dbTables,j,i1);
                                case 6
                                    waveform=getWaveform('IS',dbTables,j,i1);
                                case 7
                                    waveform=getWaveform('IDC',dbTables,j,i1);
                                case 8
                                    waveform=getWaveform('IT',dbTables,j,i1);
                                case 9
                                    waveform=getWaveform('VN',dbTables,j,i1);
                                case 10
                                    waveform=getWaveform('NG',dbTables,j,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(j).waveData.no(k-1),waveform))
                                    waveformData.no(j).waveData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        case 'tran'
                            kBegin=k;
                            for wfType=1:2
                                switch wfType
                                case 1
                                    waveform=getWaveform('VT',dbTables,j,i1);
                                case 2
                                    waveform=getWaveform('IT',dbTables,j,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(j).waveData.no(k-1),waveform))
                                    waveformData.no(j).waveData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        case 'ac'
                            kBegin=k;
                            for wfType=1:2
                                switch wfType
                                case 1
                                    waveform=getWaveform('VF',dbTables,j,i1);
                                case 2
                                    waveform=getWaveform('IF',dbTables,j,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(j).waveData.no(k-1),waveform))
                                    waveformData.no(j).waveData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        case 'dc'
                            kBegin=k;
                            for wfType=1:4
                                switch wfType
                                case 1
                                    waveform=getWaveform('VDC',dbTables,j,i1);
                                case 2
                                    waveform=getWaveform('VS',dbTables,j,i1);
                                case 3
                                    waveform=getWaveform('IDC',dbTables,j,i1);
                                case 4
                                    waveform=getWaveform('IS',dbTables,j,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(j).waveData.no(k-1),waveform))
                                    waveformData.no(j).waveData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        case 'noise'
                            kBegin=k;
                            for wfType=1:2
                                switch wfType
                                case 1
                                    waveform=getWaveform('VN',dbTables,j,i1);
                                case 2
                                    waveform=getWaveform('NG',dbTables,j,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(j).waveData.no(k-1),waveform))
                                    waveformData.no(j).waveData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        end

                    else
                        sValueCornersScalarLastUsedIndex=k;
                        sValue.no{j}.value.no{k}=dbTables.no{j}.Result(i1);
                        if iscell_dbTablesCorner
                            sCorners.no(j).corners.no{k}=dbTables.no{j}.Corner{i1};
                        else
                            sCorners.no(j).corners.no{k}=dbTables.no{j}.Corner(i1);
                        end
                        if iscell_dbTablesOutput
                            sScalar.no{j}.scalar.no{k}=dbTables.no{j}.Output{i1};
                        else
                            sScalar.no{j}.scalar.no{k}=dbTables.no{j}.Output(i1);
                        end
                    end
                end
            end
            dPoint=dPoint+1;
        end
        if initialSize>wResultsCornersOutputLastUsedIndex

            for excess=initialSize:-1:wResultsCornersOutputLastUsedIndex+1
                wResults.no(j).results.no(excess)=[];
                wCorners.no(j).corners.no(excess)=[];
                wOutput.no(j).output.no(excess)=[];
            end
        end
        if initialSize>sValueCornersScalarLastUsedIndex

            for excess=initialSize:-1:sValueCornersScalarLastUsedIndex+1
                sValue.no{j}.value.no(excess)=[];
                sCorners.no(j).corners.no(excess)=[];
                sScalar.no{j}.scalar.no(excess)=[];
            end
        end
        j=j+1;
    end



    if exist('wResults','var')
        wfResults=wResults.no;
    else
        wfResults=[];
    end
    if exist('wCorners','var')
        wfCorners=wCorners.no;
    else
        wfCorners=[];
    end
    if exist('wOutput','var')
        wfOutput=wOutput.no;
    else
        wfOutput=[];
    end
    if exist('waveformData','var')
        waveformDB=waveformData.no;
    else
        waveformDB=[];
    end
    if exist('history','var')
        History=history.no;
    else
        History=[];
    end
    if exist('sValue','var')
        scScalarOut=sValue.no;
    else
        scScalarOut=[];
    end
    if exist('sCorners','var')
        scCorners=sCorners.no;
    else
        scCorners=[];
    end
    if exist('sScalar','var')
        scScalarInfo=sScalar.no;
    else
        scScalarInfo=[];
    end



    save('adeInfoAll.mat',...
    'dbTables','totalCorners','wfResults','wfCorners','wfOutput',...
    'History','scScalarInfo','scScalarOut','scCorners',...
    'waveformDB','simDBS','simDBC','paramTable','paramConditionTable',...
    'signalTables','exprTables');
end

function waveform=getWaveform(waveformType,dbTables,j,i1)

    import cadence.srrdata.*
    import cadence.Query.*
    import cadence.utils.*
    import cadence.simdata.*
    import cadence.srrsata.*
    import cadence.streamCalculator.*
    import cadence.utils.cdsPlot.*


    h=matlabshared.application.IgnoreWarnings;
    h.RethrowWarning=false;

    try
        switch upper(waveformType)
        case 'VT'
            [~,waveform]=evalc('struct(VT(dbTables.no{j}.Output{i1}));');
        case 'VS'
            [~,waveform]=evalc('struct(VS(dbTables.no{j}.Output{i1}));');
        case 'VDC'
            [~,waveform]=evalc('struct(VDC(dbTables.no{j}.Output{i1}));');
        case 'VF'
            [~,waveform]=evalc('struct(VF(dbTables.no{j}.Output{i1}));');
        case 'IF'
            [~,waveform]=evalc('struct(IF(dbTables.no{j}.Output{i1}));');
        case 'IS'
            [~,waveform]=evalc('struct(IS(dbTables.no{j}.Output{i1}));');
        case 'IDC'
            [~,waveform]=evalc('struct(IDC(dbTables.no{j}.Output{i1}));');
        case 'IT'
            [~,waveform]=evalc('struct(IT(dbTables.no{j}.Output{i1}));');
        case 'VN'
            [~,waveform]=evalc('struct(VN());');
        case 'NG'
            [~,waveform]=evalc('struct(NG(dbTables.no{j}.Output{i1}));');
        otherwise
            waveform=[];
        end
    catch
        waveform=[];
    end
end
