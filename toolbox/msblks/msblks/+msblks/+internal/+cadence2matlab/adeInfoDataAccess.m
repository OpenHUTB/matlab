classdef adeInfoDataAccess





    properties
viewName
cellName
library
outputTable
aliasTable
testNames
resultsTable
nCorners
exprWaveformDB

    end

    properties(Access=protected)
adeInfoTemp


adeHistoryName

resultsFolder
isViewOpen
    end

    methods
        function obj=adeInfoDataAccess(varargin)


            import cadence.utils.*




            adeInfoArg=varargin{:};
            obj.adeInfoTemp=adeInfoArg.loadResult();
            obj.adeHistoryName=obj.adeInfoTemp.adeHistory;
            obj.viewName=skill('t','axlGetSessionViewName','t',obj.adeInfoTemp.adeSession);
            obj.cellName=skill('t','axlGetSessionCellName','t',obj.adeInfoTemp.adeSession);
            obj.library=skill('t','axlGetSessionLibName','t',obj.adeInfoTemp.adeSession);
            obj.testNames=obj.adeInfoTemp.adeRDB.tests.Test;







        end
    end

    methods(Access=public)

        function[dbTables,...
            signalTables,...
            exprTables,...
            totalCorners,...
            wfResults,...
            wfCorners,...
            wfOutput,...
            History,...
            scScalarInfo,...
            scScalarOut,...
            scCorners,...
            waveformDB,...
            simDBS,...
            simDBC,...
            paramTable,...
paramConditionTable...
            ]=extractAllAdeInfoHistory(obj,symRunsAndTestsRequest,isMetricsOnly)


            import cadence.srrdata.*
            import cadence.Query.*
            import cadence.utils.*
            import cadence.simdata.*
            import cadence.srrsata.*
            import cadence.streamCalculator.*
            import cadence.utils.cdsPlot.*





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
            history.no={};
            sScalar.no={};
            sValue.no={};
            sCorners.no={};


            [~,adeInfoMgr]=evalc('cadence.AdeInfoManager.loadResult();');


            simCnt=1;


            for test=1:length(symRunsAndTestsRequest)


                testRequest=symRunsAndTestsRequest{test}{2};
                runType=symRunsAndTestsRequest{test}{1};
                history.no{simCnt}=runType;





                adeInfoMgr.loadResult('test',testRequest,'history',runType,'DataPoint',-1);




                isFirstInNextTestRequest=true;
                for type=1:2
                    switch type
                    case 1
                        runType='Interactive';
                    case 2
                        runType='Ocean';
                    end

                    try



                        [~,adeInfo.no{simCnt}]=evalc("cadence.AdeInfoManager.loadResult('history',runType);");
                        [~,rdb.no{simCnt}]=evalc("cadence.AdeInfoManager.loadResult('history',runType).adeRDB;");
                        [~,dbTables.no{simCnt}]=evalc('rdb.no{simCnt}.query();');
                        dbTables.no{simCnt}=dbTables.no{simCnt}(strcmp(dbTables.no{simCnt}.Test,testRequest),:);

                        [~,signalTables.no{simCnt}]=evalc('rdb.no{simCnt}.where(Type == TypeValue.Signal).query();');


                        [~,exprTables.no{simCnt}]=evalc('rdb.no{simCnt}.where(Type == TypeValue.Expr).query();');


                    catch ex
                        if strcmpi(ex.identifier,'MATLAB:undefinedVarOrClass')
                            rethrow(ex);
                        end
                        continue;
                    end

                    if(~isempty(signalTables.no{simCnt}))
                        signalTables.no{simCnt}=signalTables.no{simCnt}(strcmp(signalTables.no{simCnt}.Test,testRequest),:);
                    end

                    if(~isempty(exprTables.no{simCnt}))
                        exprTables.no{simCnt}=exprTables.no{simCnt}(strcmp(exprTables.no{simCnt}.Test,testRequest),:);
                    end
                    signalTables.no{simCnt}=dbTables.no{simCnt};
                    if(~isempty(exprTables.no{simCnt}))
                        exprList=unique(exprTables.no{simCnt}.Output);

                        for i=1:length(exprList)
                            idxExpr=find(strcmp(signalTables.no{simCnt}.Output,exprList(i)));
                            signalTables.no{simCnt}(idxExpr,:)=[];
                        end
                    end


                    if(~isempty(exprTables.no{simCnt}))
                        waveTable=exprTables.no{simCnt}(strcmp(exprTables.no{simCnt}.Result,{'wave'}),:);
                        if(~isempty(waveTable))

                            signalTables.no{simCnt}=[signalTables.no{simCnt};waveTable];
                        end
                    end

                    if simCnt>1&&strcmp(rdb.no{simCnt}.history,rdb.no{simCnt-1}.history)||...
                        ~strcmp(runType,'Interactive')

                        if isFirstInNextTestRequest&&strcmp(runType,'Interactive')
                            isFirstInNextTestRequest=false;
                        else

                            adeInfo.no(simCnt)=[];
                            rdb.no(simCnt)=[];
                            dbTables.no(simCnt)=[];
                            signalTables.no(simCnt)=[];
                            exprTables.no(simCnt)=[];
                            break;
                        end
                    end

                    symRun=rdb.no{simCnt}.history;
                    if isempty(dbTables.no{simCnt})


                        adeInfo.no(simCnt)=[];
                        rdb.no(simCnt)=[];
                        dbTables.no(simCnt)=[];
                        signalTables.no(simCnt)=[];
                        exprTables.no(simCnt)=[];
                        continue;
                    end


                    dbTables.no{simCnt}(~strcmpi(dbTables.no{simCnt}.Test,testRequest),:)=[];
                    isFirstInNextTestRequest=false;

                    totalCorners.no{simCnt}=rdb.no{simCnt}.corners;
                    paramTable.no{simCnt}=rdb.no{simCnt}.params;
                    paramConditionTable.no{simCnt}=rdb.no{simCnt}.paramConditions;




                    iscell_dbTablesResult=iscell(dbTables.no{simCnt}.Result);
                    iscell_dbTablesCorner=iscell(dbTables.no{simCnt}.Corner);
                    iscell_dbTablesOutput=iscell(dbTables.no{simCnt}.Output);








                    initialSize=length(dbTables.no{simCnt}.Result);
                    wResults.no(simCnt).results.no{initialSize}=[];
                    wCorners.no(simCnt).corners.no{initialSize}=[];
                    wOutput.no(simCnt).output.no{initialSize}=[];
                    sValue.no{simCnt}.value.no{initialSize}=[];
                    sCorners.no(simCnt).corners.no{initialSize}=[];
                    sScalar.no{simCnt}.scalar.no{initialSize}=[];




                    wResultsCornersOutputLastUsedIndex=0;
                    sValueCornersScalarLastUsedIndex=0;

                    maxDpoint=max(dbTables.no{simCnt}.DataPoint);
                    dPoint=1;



                    [~,~]=evalc("cadence.AdeInfoManager.loadResult('dataPoint',-1);");
                    try
                        warning('off','MATLAB:structOnObject');
                        simDBS.no{simCnt}=struct(adeInfo.no{simCnt});
                        simDBS.no{simCnt}.adeRDB=[];
                        warning('on','MATLAB:structOnObject');





                    catch
                    end
                    if(~isMetricsOnly)
                        signalAlias=msblks.internal.cadence2matlab.findSignalAlias;
                        uniqueOutputs=unique(dbTables.no{simCnt}.Output);



                        waveformDataTemp=[];
                        NodeWithissue=[];
                        flag=0;
                        for i=1:length(uniqueOutputs)
                            if(ismember(uniqueOutputs{i},signalAlias.Name))
                                [~,idx]=ismember(uniqueOutputs{i},signalAlias.Name);
                                try
                                    signalName=signalAlias.Output{idx};
                                catch
                                    signalName=uniqueOutputs{i};
                                end
                            else
                                signalName=uniqueOutputs{i};
                            end
                            if(~isempty(exprTables.no{simCnt}))
                                if(~ismember(uniqueOutputs{i},exprTables.no{simCnt}.Output))
                                    for wfType=1:10
                                        switch wfType
                                        case 1
                                            waveform=obj.getWaveform('VT',signalName);
                                            if(~isempty(waveform))
                                                if(flag==0)
                                                    flag=1;
                                                end
                                            end
                                        case 2
                                            waveform=obj.getWaveform('VS',signalName);
                                            if(~isempty(waveform))
                                                if(flag==0)
                                                    flag=1;
                                                end
                                            end
                                        case 3
                                            waveform=obj.getWaveform('VDC',signalName);
                                            if(~isempty(waveform))
                                                if(flag==0)
                                                    flag=1;
                                                end
                                            end
                                        case 4
                                            waveform=obj.getWaveform('VF',signalName);
                                            if(~isempty(waveform))
                                                if(flag==0)
                                                    flag=1;
                                                end
                                            end
                                        case 5
                                            waveform=obj.getWaveform('IF',signalName);
                                            if(~isempty(waveform))
                                                if(flag==0)
                                                    flag=1;
                                                end
                                            end
                                        case 6
                                            waveform=obj.getWaveform('IS',signalName);
                                            if(~isempty(waveform))
                                                if(flag==0)
                                                    flag=1;
                                                end
                                            end
                                        case 7
                                            waveform=obj.getWaveform('IDC',signalName);
                                            if(~isempty(waveform))
                                                if(flag==0)
                                                    flag=1;
                                                end
                                            end
                                        case 8
                                            waveform=obj.getWaveform('IT',signalName);
                                            if(~isempty(waveform))
                                                if(flag==0)
                                                    flag=1;
                                                end
                                            end
                                        case 9
                                            waveform=obj.getWaveform('VN',signalName);
                                            if(~isempty(waveform))
                                                if(flag==0)
                                                    flag=1;
                                                end
                                            end
                                        case 10
                                            waveform=obj.getWaveform('NG',signalName);
                                            if(~isempty(waveform))
                                                if(flag==0)
                                                    flag=1;
                                                end
                                            end
                                        otherwise
                                            waveform=[];
                                        end
                                        if~isempty(waveform)
                                            if(istable(waveform))
                                                if(isempty(waveformDataTemp))
                                                    waveformDataTemp=waveform;
                                                else
                                                    waveformDataTemp=[waveformDataTemp;waveform];
                                                end
                                            else
                                                flag=0;
                                            end
                                        end

                                    end
                                    if(flag==0)
                                        if(isempty(NodeWithissue))
                                            NodeWithissue={uniqueOutputs{i}};
                                        else
                                            NodeWithissue(end+1)={uniqueOutputs{i}};
                                        end
                                    else
                                        flag=0;
                                    end
                                end
                            else
                                for wfType=1:10
                                    switch wfType
                                    case 1
                                        waveform=obj.getWaveform('VT',signalName);
                                        if(~isempty(waveform))
                                            if(flag==0)
                                                flag=1;
                                            end
                                        end
                                    case 2
                                        waveform=obj.getWaveform('VS',signalName);
                                        if(~isempty(waveform))
                                            if(flag==0)
                                                flag=1;
                                            end
                                        end
                                    case 3
                                        waveform=obj.getWaveform('VDC',signalName);
                                        if(~isempty(waveform))
                                            if(flag==0)
                                                flag=1;
                                            end
                                        end
                                    case 4
                                        waveform=obj.getWaveform('VF',signalName);
                                        if(~isempty(waveform))
                                            if(flag==0)
                                                flag=1;
                                            end
                                        end
                                    case 5
                                        waveform=obj.getWaveform('IF',signalName);
                                        if(~isempty(waveform))
                                            if(flag==0)
                                                flag=1;
                                            end
                                        end
                                    case 6
                                        waveform=obj.getWaveform('IS',signalName);
                                        if(~isempty(waveform))
                                            if(flag==0)
                                                flag=1;
                                            end
                                        end
                                    case 7
                                        waveform=obj.getWaveform('IDC',signalName);
                                        if(~isempty(waveform))
                                            if(flag==0)
                                                flag=1;
                                            end
                                        end
                                    case 8
                                        waveform=obj.getWaveform('IT',signalName);
                                        if(~isempty(waveform))
                                            if(flag==0)
                                                flag=1;
                                            end
                                        end
                                    case 9
                                        waveform=obj.getWaveform('VN',signalName);
                                        if(~isempty(waveform))
                                            if(flag==0)
                                                flag=1;
                                            end
                                        end
                                    case 10
                                        waveform=obj.getWaveform('NG',signalName);
                                        if(~isempty(waveform))
                                            if(flag==0)
                                                flag=1;
                                            end
                                        end
                                    otherwise
                                        waveform=[];
                                    end



                                    if~isempty(waveform)
                                        if(istable(waveform))
                                            if(isempty(waveformDataTemp))
                                                waveformDataTemp=waveform;
                                            else
                                                waveformDataTemp=[waveformDataTemp;waveform];
                                            end
                                        else
                                            flag=0;
                                        end
                                    end

                                end
                                if(flag==0)
                                    if(isempty(NodeWithissue))
                                        NodeWithissue={uniqueOutputs{i}};
                                    else
                                        NodeWithissue(end+1)={uniqueOutputs{i}};
                                    end
                                else
                                    flag=0;
                                end
                            end
                        end

                        nodesIssue=unique(NodeWithissue);
                        if(~isempty(nodesIssue))
                            disp(['There were issues accessing waveforms for following nodes:',newline()]);
                            disp(nodesIssue');
                        end

                        warning('off','MATLAB:structOnObject');
                        if(~isempty(waveformDataTemp))
                            waveformDataTemp=table2struct(waveformDataTemp);
                            fields=fieldnames(waveformDataTemp);

                            for i=1:length(waveformDataTemp)
                                waveformDataStruct=struct(waveformDataTemp(i).wave);
                                for j=1:length(fields)
                                    if(~strcmp(fields{j},'wave'))
                                        waveformDataStruct.(fields{j})=waveformDataTemp(i).(fields{j});
                                    end
                                end

                                waveformData.no(simCnt).waveData.no(i)=waveformDataStruct;

                            end
                        else
                            waveformData.no(simCnt).waveData=[];
                        end


                        a=[];
                        b=dbTables.no{simCnt}.Result;
                        if(max(strcmp(b,{'wave'}))==true)

                            [~,a]=evalc("msblks.internal.cadence2matlab.plotCadenceExpressions");
                            testsList=strings(length(a),1);
                            for i=1:length(a)
                                testsList(i)=a(i).TestName;
                            end


                            if(~isempty(a))
                                if(length(unique(testsList))==1)
                                    b=rmfield(a,'TestName');
                                    if(isempty(waveformData.no(simCnt).waveData))
                                        waveformData.no(simCnt).waveData.no=b;
                                    else
                                        w=[waveformData.no(simCnt).waveData.no';b];
                                        waveformData.no(simCnt).waveData.no=w;
                                    end
                                else
                                    idx=strcmp(testsList,testRequest);
                                    id=find(idx==false);
                                    a(id)=[];
                                    b=rmfield(a,'TestName');
                                    if(isempty(waveformData.no(simCnt).waveData))
                                        waveformData.no(simCnt).waveData.no=b;
                                    else
                                        w=[waveformData.no(simCnt).waveData.no';b];
                                        waveformData.no(simCnt).waveData.no=w;
                                    end
                                end
                            end
                        end


                        warning('on','MATLAB:structOnObject');



                        if(~isempty(nodesIssue))
                            for i=1:length(nodesIssue)
                                dbTables.no{simCnt}(ismember(dbTables.no{simCnt}.Output,nodesIssue{i}),:)=[];
                                signalTables.no{simCnt}(ismember(signalTables.no{simCnt}.Output,nodesIssue{i}),:)=[];
                            end
                        end







                        maxDpoint=max(dbTables.no{simCnt}.DataPoint);

                        dPoint=1;

                        k=1;
                        for i=1:maxDpoint
                            sizeTable=size(dbTables.no{simCnt});
                            rowTable=sizeTable(1);
                            count=1;

                            for i1=1:rowTable
                                if iscell_dbTablesResult
                                    if(strcmp(dbTables.no{simCnt}.Result{i1},'wave'))
                                        if((dbTables.no{simCnt}.DataPoint(i1)==dPoint))
                                            count=count+1;
                                            wResultsCornersOutputLastUsedIndex=k;
                                            wResults.no(simCnt).no{k}=dbTables.no{simCnt}.Result{i1};
                                            if iscell_dbTablesCorner
                                                wCorners.no(simCnt).corners.no{k}=dbTables.no{simCnt}.Corner{i1};
                                            else
                                                wCorners.no(simCnt).corners.no{k}=dbTables.no{simCnt}.Corner(i1);
                                            end
                                            if iscell_dbTablesOutput
                                                wOutput.no(simCnt).output.no{k}=dbTables.no{simCnt}.Output{i1};
                                            else
                                                wOutput.no(simCnt).output.no{k}=dbTables.no{simCnt}.Output(i1);
                                            end
                                            k=k+1;
                                        end
                                    else
                                        if(~strcmp(dbTables.no{simCnt}.Result{i1},'Error'))
                                            if(((isa(dbTables.no{simCnt}.Result{i1},'logical')==1)||(dbTables.no{simCnt}.Result{i1}==false))...
                                                &&(dbTables.no{simCnt}.DataPoint(i1)==dPoint))
                                                count=count+1;
                                                wResultsCornersOutputLastUsedIndex=k;
                                                wResults.no(simCnt).no{k}=dbTables.no{simCnt}.Result{i1};
                                                if iscell_dbTablesCorner
                                                    wCorners.no(simCnt).corners.no{k}=dbTables.no{simCnt}.Corner{i1};
                                                else
                                                    wCorners.no(simCnt).corners.no{k}=dbTables.no{simCnt}.Corner(i1);
                                                end
                                                if iscell_dbTablesOutput
                                                    wOutput.no(simCnt).output.no{k}=dbTables.no{simCnt}.Output{i1};
                                                else
                                                    wOutput.no(simCnt).output.no{k}=dbTables.no{simCnt}.Output(i1);
                                                end
                                                k=k+1;
                                            end
                                        end
                                    end

                                else
                                    if(strcmp(dbTables.no{simCnt}.Result(i1),'wave'))
                                        if((dbTables.no{simCnt}.DataPoint(i1)==dPoint))
                                            count=count+1;
                                            wResultsCornersOutputLastUsedIndex=k;
                                            wResults.no(simCnt).no{k}=dbTables.no{simCnt}.Result(i1);
                                            if iscell_dbTablesCorner
                                                wCorners.no(simCnt).corners.no{k}=dbTables.no{simCnt}.Corner{i1};
                                            else
                                                wCorners.no(simCnt).corners.no{k}=dbTables.no{simCnt}.Corner(i1);
                                            end
                                            if iscell_dbTablesOutput
                                                wOutput.no(simCnt).output.no{k}=dbTables.no{simCnt}.Output{i1};
                                            else
                                                wOutput.no(simCnt).output.no{k}=dbTables.no{simCnt}.Output(i1);
                                            end
                                            k=k+1;
                                        end
                                    else
                                        if(~strcmp(dbTables.no{simCnt}.Result(i1),'Error'))
                                            if(((dbTables.no{simCnt}.Result(i1)==0)||(dbTables.no{simCnt}.Result(i1)==false))...
                                                &&(dbTables.no{simCnt}.DataPoint(i1)==dPoint))
                                                count=count+1;
                                                wResultsCornersOutputLastUsedIndex=k;
                                                wResults.no(simCnt).no{k}=dbTables.no{simCnt}.Result(i1);
                                                if iscell_dbTablesCorner
                                                    wCorners.no(simCnt).corners.no{k}=dbTables.no{simCnt}.Corner{i1};
                                                else
                                                    wCorners.no(simCnt).corners.no{k}=dbTables.no{simCnt}.Corner(i1);
                                                end
                                                if iscell_dbTablesOutput
                                                    wOutput.no(simCnt).output.no{k}=dbTables.no{simCnt}.Output{i1};
                                                else
                                                    wOutput.no(simCnt).output.no{k}=dbTables.no{simCnt}.Output(i1);
                                                end
                                                k=k+1;
                                            end
                                        end
                                    end
                                end

                            end
                            dPoint=dPoint+1;
                        end
                        if initialSize>wResultsCornersOutputLastUsedIndex

                            for excess=initialSize:-1:wResultsCornersOutputLastUsedIndex+1
                                wResults.no(simCnt).results.no(excess)=[];
                                wCorners.no(simCnt).corners.no(excess)=[];
                                wOutput.no(simCnt).output.no(excess)=[];
                            end
                        end
                        if initialSize>sValueCornersScalarLastUsedIndex

                            for excess=initialSize:-1:sValueCornersScalarLastUsedIndex+1
                                sValue.no{simCnt}.value.no(excess)=[];
                                sCorners.no(simCnt).corners.no(excess)=[];
                                sScalar.no{simCnt}.scalar.no(excess)=[];
                            end
                        end
                    end

                    simCnt=simCnt+1;

                end
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
                if simCnt>2

                    if isempty(waveformData.no)
                        waveformDB=[];
                    else
                        waveformDB=waveformData.no;
                    end

                else
                    if isempty(waveformData.no)||isempty(waveformData.no.waveData)
                        waveformDB=[];
                    else
                        waveformDB=waveformData.no;
                    end
                end
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





        end
        function waveform=getWaveform(obj,waveformType,netName)

            import cadence.srrdata.*
            import cadence.Query.*
            import cadence.utils.*
            import cadence.simdata.*
            import cadence.srrsata.*
            import cadence.streamCalculator.*
            import cadence.utils.cdsPlot.*






            try
                switch upper(waveformType)
                case 'VT'
                    [~,waveform]=evalc('VT(netName);');
                    waveform.WaveType(:)={'VT'};
                    waveform.Output(:)={netName};
                case 'VS'
                    [~,waveform]=evalc('VS(netName);');
                    waveform.WaveType(:)={'VS'};
                    waveform.Output(:)={netName};
                case 'VDC'
                    waveform=[];



                case 'VF'
                    [~,waveform]=evalc('VF(netName);');
                    waveform.WaveType(:)={'VF'};
                    waveform.Output(:)={netName};
                case 'IF'
                    [~,waveform]=evalc('IF(netName);');
                    waveform.WaveType(:)={'IF'};
                    waveform.Output(:)={netName};
                case 'IS'
                    [~,waveform]=evalc('IS(netName);');
                    waveform.WaveType(:)={'IS'};
                    waveform.Output(:)={netName};
                case 'IDC'
                    waveform=[];



                case 'IT'
                    [~,waveform]=evalc('IT(netName);');
                    waveform.WaveType(:)={'IT'};
                    waveform.Output(:)={netName};
                case 'VN'
                    [~,waveform]=evalc('VN(netName);');
                    waveform.WaveType(:)={'VN'};
                    waveform.Output(:)={netName};
                case 'NG'
                    [~,waveform]=evalc('NG(netName);');
                    waveform.WaveType(:)={'NG'};
                    waveform.Output(:)={netName};
                otherwise
                    waveform=[];
                end
            catch
                waveform=[];

            end

        end
    end
end






































