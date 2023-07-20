function[dbTables,totalCorners,wfResults,wfCorners,wfOutput,scScalarInfo,scScalarOut,waveformDB,simDBS,simDBC,paramTable,paramConditionTable]=readAdeInfo(~)




























    import cadence.srrdata.*
    import cadence.Query.*
    import cadence.utils.*
    import cadence.simdata.*
    import cadence.srrsata.*
    import cadence.streamCalculator.*
    import cadence.utils.cdsPlot.*


    prompt={'Enter ADE Test Name','Enter Simulation Type'};
    dlgtitle='ADE Testbench Information';
    dims=[1,35];
    definput={'',''};
    answer=inputdlg(prompt,dlgtitle,dims,definput);


    if isempty(answer)
        return;
    end

    testName=answer{1};
    simulationType=answer{2};


    if((isempty(testName))||(isempty(simulationType)))
        error(message('msblks:mixedsignalanalyzer:CurrentAdeinfoInput1'));
    elseif((strcmpi(simulationType,'all')==0)&&(strcmpi(simulationType,'tran')==0)&&(strcmpi(simulationType,'ac')==0)&&(strcmpi(simulationType,'dc')==0)&&(strcmpi(simulationType,'noise')==0))
        error(message('msblks:mixedsignalanalyzer:AdeinfoSimulationType'));
    end


    validateattributes(testName,{'char'},{'nonempty'});
    validateattributes(simulationType,{'char'},{'nonempty'});


    h=matlabshared.application.IgnoreWarnings;
    h.RethrowWarning=false;

    s1=testName;


    cadence.AdeInfoManager.loadResult();
    adeInfo=cadence.AdeInfoManager.getInstance();

    if adeInfo.adeDataPoint==-1
        adeInfo.loadResult();
        cadence.AdeInfoManager.loadResult();
        adeInfo.loadResult('test',s1,'DataPoint',1);
        [dbTables,totalCorners,wfResults,wfCorners,wfOutput,scScalarInfo,scScalarOut,waveformDB,simDBS,simDBC,paramTable,paramConditionTable]=extractAdeInfo(simulationType,s1);
    else
        adeInfo.loadResult('test',s1,'DataPoint',1);
        [dbTables,totalCorners,wfResults,wfCorners,wfOutput,scScalarInfo,scScalarOut,waveformDB,simDBS,simDBC,paramTable,paramConditionTable]=extractAdeInfo(simulationType,s1);
    end
end

function[dbTables,totalCorners,wfResults,wfCorners,wfOutput,scScalarInfo,scScalarOut,waveformDB,simDBS,simDBC,paramTable,paramConditionTable]=extractAdeInfo(simulationType,s1)




















    if nargin<2
        error(message('msblks:mixedsignalanalyzer:CurrentAdeinfoInput2'));
    end



    import cadence.srrdata.*
    import cadence.Query.*
    import cadence.utils.*
    import cadence.simdata.*
    import cadence.srrsata.*
    import cadence.streamCalculator.*
    import cadence.utils.cdsPlot.*


    h=matlabshared.application.IgnoreWarnings;
    h.RethrowWarning=false;

    simDBS=[];
    simDBC=[];



    [~,~]=evalc("cadence.AdeInfoManager.loadResult();");
    [~,rdb]=evalc("cadence.AdeInfoManager.loadResult().adeRDB;");
    [~,dbTables]=evalc('rdb.query();');
    [~,signalTables]=evalc('rdb.where(Type == TypeValue.Signal).query();');
    [~,exprTables]=evalc('rdb.where(Type == TypeValue.Expr).query();');









    dbTables(~strcmpi(dbTables.Test,s1),:)=[];

    totalCorners=rdb.corners;
    paramTable=rdb.params;
    paramConditionTable=rdb.paramConditions;




    iscell_dbTablesResult=iscell(dbTables.Result);








    initialSize=length(dbTables.Result);
    results.no{initialSize}=[];
    corners.no{initialSize}=[];
    output.no{initialSize}=[];
    sValue.no{initialSize}=[];
    sCorners.no{initialSize}=[];
    sScalar.no{initialSize}=[];




    wResultsCornersOutputLastUsedIndex=0;
    sValueCornersScalarLastUsedIndex=0;

    maxDpoint=max(dbTables.DataPoint);
    dPoint=1;
    k=1;
    for i=1:maxDpoint
        cadence.AdeInfoManager.loadResult('dataPoint',dPoint);

        simDBS=struct(cadence.AdeInfoManager.getInstance());
        if i==1

            simDBC.no{maxDpoint}=[];
        end
        simDBC.no{i}=struct(cadence.AdeInfoManager.getInstance('dataPoint',dPoint));
        sizeTable=size(dbTables);
        rowTable=sizeTable(1);
        count=1;

        for i1=1:rowTable
            if iscell_dbTablesResult
                if(((isa(dbTables.Result{i1},'logical')==1)||(dbTables.Result{i1}==false))...
                    &&(dbTables.DataPoint(i1)==dPoint)&&strcmpi(dbTables.Test{i1},s1)...
                    &&startsWith(dbTables.Output{i1},'/'))
                    count=count+1;
                    wResultsCornersOutputLastUsedIndex=k;
                    results.no{k}=dbTables.Result{i1};
                    corners.no{k}=dbTables.Corner{i1};
                    output.no{k}=dbTables.Output{i1};

                    switch simulationType
                    case 'all'
                        kBegin=k;
                        for wfType=1:10
                            switch wfType
                            case 1
                                waveform=getWaveform('VT',dbTables,i1);
                            case 2
                                waveform=getWaveform('VS',dbTables,i1);
                            case 3
                                waveform=getWaveform('VDC',dbTables,i1);
                            case 4
                                waveform=getWaveform('VF',dbTables,i1);
                            case 5
                                waveform=getWaveform('IF',dbTables,i1);
                            case 6
                                waveform=getWaveform('IS',dbTables,i1);
                            case 7
                                waveform=getWaveform('IDC',dbTables,i1);
                            case 8
                                waveform=getWaveform('IT',dbTables,i1);
                            case 9
                                waveform=getWaveform('VN',dbTables,i1);
                            case 10
                                waveform=getWaveform('NG',dbTables,i1);
                            end
                            if~isempty(waveform)&&...
                                (k==1||k==kBegin||~isequal(waveformData.no(k-1),waveform))
                                waveformData.no(k)=waveform;
                                k=k+1;
                            end
                        end
                    case 'tran'
                        kBegin=k;
                        for wfType=1:2
                            switch wfType
                            case 1
                                waveform=getWaveform('VT',dbTables,i1);
                            case 2
                                waveform=getWaveform('IT',dbTables,i1);
                            end
                            if~isempty(waveform)&&...
                                (k==1||k==kBegin||~isequal(waveformData.no(k-1),waveform))
                                waveformData.no(k)=waveform;
                                k=k+1;
                            end
                        end
                    case 'ac'
                        kBegin=k;
                        try
                            for wfType=1:2
                                switch wfType
                                case 1
                                    waveform=getWaveform('VF',dbTables,i1);
                                case 2
                                    waveform=getWaveform('IF',dbTables,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(k-1),waveform))
                                    waveformData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        catch
                        end
                    case 'dc'
                        kBegin=k;
                        try
                            for wfType=1:4
                                switch wfType
                                case 1
                                    waveform=getWaveform('VDC',dbTables,i1);
                                case 2
                                    waveform=getWaveform('VS',dbTables,i1);
                                case 3
                                    waveform=getWaveform('IDC',dbTables,i1);
                                case 4
                                    waveform=getWaveform('IS',dbTables,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(k-1),waveform))
                                    waveformData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        catch
                        end
                    case 'noise'
                        kBegin=k;
                        try
                            for wfType=1:2

                                switch wfType
                                case 1
                                    waveform=getWaveform('VN',dbTables,i1);
                                case 2
                                    waveform=getWaveform('NG',dbTables,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(k-1),waveform))
                                    waveformData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        catch
                        end
                    end

                else
                    sValueCornersScalarLastUsedIndex=k;
                    sValue.no{k}=dbTables.Result{i1};
                    sCorners.no{k}=dbTables.Corner{i1};
                    sScalar.no{k}=dbTables.Output{i1};
                end

            else
                if(((dbTables.Result(i1)==0)||(dbTables.Result{i1}==false))...
                    &&(dbTables.DataPoint(i1)==dPoint)&&strcmpi(dbTables.Test{i1},s1)...
                    &&startsWith(dbTables.Output{i1},'/'))
                    count=count+1;
                    wResultsCornersOutputLastUsedIndex=k;
                    results.no{k}=dbTables.Result(i1);
                    corners.no{k}=dbTables.Corner(i1);
                    output.no{k}=dbTables.Output(i1);
                    switch simulationType
                    case 'all'
                        kBegin=k;
                        for wfType=1:10
                            switch wfType
                            case 1
                                waveform=getWaveform('VT',dbTables,i1);
                            case 2
                                waveform=getWaveform('VS',dbTables,i1);
                            case 3
                                waveform=getWaveform('VDC',dbTables,i1);
                            case 4
                                waveform=getWaveform('VF',dbTables,i1);
                            case 5
                                waveform=getWaveform('IF',dbTables,i1);
                            case 6
                                waveform=getWaveform('IS',dbTables,i1);
                            case 7
                                waveform=getWaveform('IDC',dbTables,i1);
                            case 8
                                waveform=getWaveform('IT',dbTables,i1);
                            case 9
                                waveform=getWaveform('VN',dbTables,i1);
                            case 10
                                waveform=getWaveform('NG',dbTables,i1);
                            end
                            if~isempty(waveform)&&...
                                (k==1||k==kBegin||~isequal(waveformData.no(k-1),waveform))
                                waveformData.no(k)=waveform;
                                k=k+1;
                            end
                        end
                    case 'tran'
                        kBegin=k;
                        for wfType=1:2
                            switch wfType
                            case 1
                                waveform=getWaveform('VT',dbTables,i1);
                            case 2
                                waveform=getWaveform('IT',dbTables,i1);
                            end
                            if~isempty(waveform)&&...
                                (k==1||k==kBegin||~isequal(waveformData.no(k-1),waveform))
                                waveformData.no(k)=waveform;
                                k=k+1;
                            end
                        end
                    case 'ac'
                        kBegin=k;
                        try
                            for wfType=1:2
                                switch wfType
                                case 1
                                    waveform=getWaveform('VF',dbTables,i1);
                                case 2
                                    waveform=getWaveform('IF',dbTables,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(k-1),waveform))
                                    waveformData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        catch
                        end
                    case 'dc'
                        kBegin=k;
                        try
                            for wfType=1:4
                                switch wfType
                                case 1
                                    waveform=getWaveform('VDC',dbTables,i1);
                                case 2
                                    waveform=getWaveform('VS',dbTables,i1);
                                case 3
                                    waveform=getWaveform('IDC',dbTables,i1);
                                case 4
                                    waveform=getWaveform('IS',dbTables,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(k-1),waveform))
                                    waveformData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        catch
                        end
                    case 'noise'
                        kBegin=k;
                        try
                            for wfType=1:2
                                switch wfType
                                case 1
                                    waveform=getWaveform('VN',dbTables,i1);
                                case 2
                                    waveform=getWaveform('NG',dbTables,i1);
                                end
                                if~isempty(waveform)&&...
                                    (k==1||k==kBegin||~isequal(waveformData.no(k-1),waveform))
                                    waveformData.no(k)=waveform;
                                    k=k+1;
                                end
                            end
                        catch
                        end
                    end

                else
                    sValueCornersScalarLastUsedIndex=k;
                    sValue.no{k}=dbTables.Result(i1);
                    sCorners.no{k}=dbTables.Corner{i1};
                    sScalar.no{k}=dbTables.Output{i1};
                end
            end
        end
        dPoint=dPoint+1;
    end
    if initialSize>wResultsCornersOutputLastUsedIndex

        for excess=initialSize:-1:wResultsCornersOutputLastUsedIndex+1
            results.no(excess)=[];
            corners.no(excess)=[];
            output.no(excess)=[];
        end
    end
    if initialSize>sValueCornersScalarLastUsedIndex

        for excess=initialSize:-1:sValueCornersScalarLastUsedIndex+1
            sValue.no(excess)=[];
            sCorners.no(excess)=[];
            sScalar.no(excess)=[];
        end
    end



    if exist('results','var')
        wfResults=results.no;
    else
        wfResults=[];
    end
    if exist('corners','var')
        wfCorners=corners.no;
    else
        wfCorners=[];
    end
    if exist('output','var')
        wfOutput=output.no;
    else
        wfOutput=[];
    end
    if exist('waveformData','var')
        waveformDB=waveformData.no;
    else
        waveformDB=[];
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



    save('adeInfoCurrent.mat',...
    'dbTables','totalCorners','wfResults','wfCorners','wfOutput',...
    'scScalarInfo','scScalarOut','scCorners',...
    'waveformDB','simDBS','simDBC','paramTable','paramConditionTable',...
    'signalTables','exprTables');
end

function waveform=getWaveform(waveformType,dbTables,i1)

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
            [~,waveform]=evalc('struct(VT(dbTables.Output{i1}));');
        case 'VS'
            [~,waveform]=evalc('struct(VS(dbTables.Output{i1}));');
        case 'VDC'
            [~,waveform]=evalc('struct(VDC(dbTables.Output{i1}));');
        case 'VF'
            [~,waveform]=evalc('struct(VF(dbTables.Output{i1}));');
        case 'IF'
            [~,waveform]=evalc('struct(IF(dbTables.Output{i1}));');
        case 'IS'
            [~,waveform]=evalc('struct(IS(dbTables.Output{i1}));');
        case 'IDC'
            [~,waveform]=evalc('struct(IDC(dbTables.Output{i1}));');
        case 'IT'
            [~,waveform]=evalc('struct(IT(dbTables.Output{i1}));');
        case 'VN'
            [~,waveform]=evalc('struct(VN());');
        case 'NG'
            [~,waveform]=evalc('struct(NG(dbTables.Output{i1}));');
        otherwise
            waveform=[];
        end
    catch
        waveform=[];
    end
end
