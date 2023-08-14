classdef Model_1<handle




    properties(Access=protected)
        MatchingNetworkManager rf.internal.apps.matchnet.MatchingNetworkHistoryManager



        MatchingNetworkGenerator rf.internal.apps.matchnet.MatchingNetwork_GUIWrapper


        MatchingNetworkAnalyzer rf.internal.apps.matchnet.MatchingNetwork_GUIWrapper
    end

    properties(Access=protected)


        namecounter(1,1)double{mustBeNonnegative}=0
    end

    properties(Access=private)

        MatFilePath(1,:)char=''
    end

    properties(Constant,Access=private)
        DefaultName='Network'
    end

    properties(Hidden)
        IsChanged(1,1)logical=false

        Name char='Network'
    end

    properties(Access=protected,Constant)


        CIRC_PERF_IDX=8



        STATIC_TABLE_HEADERS={'abs(Parameter)','Condition','Goal',...
        sprintf('Min Frequency\n(GHz)'),...
        sprintf('Max Frequency\n(GHz)'),'Weight','Active'}
        DEFAULT_EVALPARAM_LINE={'S21','>',-3,1,1.125,1,false}



        FREQUENCY_SCALAR=1e9
    end

    events
NewNetworksGenerated

NetworkDataAvailable
NetworkEvaluationChanged

EvalparamsUpdated

NetworkDrawingDataAvailable
SBarUpdate
ConfigUpdate

InvalidParameters
InvalidParameters_2

AppBusy

EnablePlotButtons
NewName
    end

    methods(Access=public)

        function this=Model_1()

            this.MatchingNetworkManager=rf.internal.apps.matchnet.MatchingNetworkHistoryManager;


            this.MatchingNetworkGenerator=rf.internal.apps.matchnet.MatchingNetwork_GUIWrapper;
            this.MatchingNetworkGenerator.pauseAutoupdate();


            this.MatchingNetworkAnalyzer=rf.internal.apps.matchnet.MatchingNetwork_GUIWrapper;
            this.MatchingNetworkAnalyzer.disableAutomaticNetworks();
            [~,~,n]=this.MatchingNetworkAnalyzer.getAllCircuitNames();
            this.MatchingNetworkAnalyzer.deleteNetwork(n);

        end

        function resetModel(this)

            this.MatchingNetworkManager=rf.internal.apps.matchnet.MatchingNetworkHistoryManager;


            this.MatchingNetworkGenerator=rf.internal.apps.matchnet.MatchingNetwork_GUIWrapper;
            this.MatchingNetworkGenerator.pauseAutoupdate();


            this.MatchingNetworkAnalyzer=rf.internal.apps.matchnet.MatchingNetwork_GUIWrapper;
            this.MatchingNetworkAnalyzer.disableAutomaticNetworks();
            [~,~,n]=this.MatchingNetworkAnalyzer.getAllCircuitNames();
            this.MatchingNetworkAnalyzer.deleteNetwork(n);


            this.namecounter=0;
            this.MatFilePath='';

            this.IsChanged=false;
        end



        function newSession(this)
            if(~isempty(this.MatchingNetworkManager))
                delete(this.MatchingNetworkManager);
            end

            if(~isempty(this.MatchingNetworkGenerator))
                delete(this.MatchingNetworkGenerator);
            end
        end

        function newTerminations(this,evtdata)

            try
                this.MatchingNetworkGenerator.pauseAutoupdate();
                this.MatchingNetworkGenerator.CenterFrequency=evtdata.data.CenterFrequency;
                this.MatchingNetworkGenerator.LoadedQ=evtdata.data.Q;
                this.MatchingNetworkGenerator.SourceImpedance=evtdata.data.SourceZ;
                this.MatchingNetworkGenerator.LoadImpedance=evtdata.data.LoadZ;

                this.MatchingNetworkAnalyzer.CenterFrequency=evtdata.data.CenterFrequency;
                this.MatchingNetworkAnalyzer.LoadedQ=evtdata.data.Q;
                this.MatchingNetworkAnalyzer.SourceImpedance=evtdata.data.SourceZ;
                this.MatchingNetworkAnalyzer.LoadImpedance=evtdata.data.LoadZ;
            catch err
                evtdataOut=rf.internal.apps.matchnet.ArbitraryEventData(err.message);
                this.notify('InvalidParameters',evtdataOut);
            end
        end

        function generateNetworks(this,evtdata)
            try
                this.MatchingNetworkGenerator.pauseAutoupdate()

                this.MatchingNetworkGenerator.Components=evtdata.data.Topology;
                this.MatchingNetworkGenerator.CenterFrequency=evtdata.data.CenterFrequency;
                this.MatchingNetworkGenerator.LoadedQ=evtdata.data.Q;

                this.MatchingNetworkAnalyzer.Components=evtdata.data.Topology;
                this.MatchingNetworkAnalyzer.CenterFrequency=evtdata.data.CenterFrequency;
                this.MatchingNetworkAnalyzer.LoadedQ=evtdata.data.Q;


                this.MatchingNetworkGenerator.resumeAutoupdate();

                for editedRowIndex=1:size(evtdata.data.EvalparamTable.Data,1)
                    if(evtdata.data.EvalparamTable.Data{editedRowIndex,6}~=0)&&(evtdata.data.EvalparamTable.Data{editedRowIndex,7}==true)
                        freqband={evtdata.data.FREQUENCY_SCALAR*[evtdata.data.EvalparamTable.Data{editedRowIndex,4:5}]};
                        evpm=[evtdata.data.EvalparamTable.Data(editedRowIndex,1:3),freqband,evtdata.data.EvalparamTable.Data(editedRowIndex,6:7)];
                        dataCT.EvalparamIndex=editedRowIndex;
                        dataCT.NewEvalparam=evpm;
                        updateEvalparam(this,rf.internal.apps.matchnet.ArbitraryEventData(dataCT))
                    end
                end

                this.MatchingNetworkGenerator.pauseAutoupdate();


                networkSParameters=this.MatchingNetworkGenerator.calculateLoadedSParameters();


                [~,~,tempcktnames]=this.MatchingNetworkGenerator.getAllCircuitNames();
                failedTests=this.MatchingNetworkGenerator.getPerformanceTestsFailed(tempcktnames);
                finalcktnames=this.nameAutoCkts(length(tempcktnames));

                srcZ=this.MatchingNetworkGenerator.interpretZ('Source');
                loadZ=this.MatchingNetworkGenerator.interpretZ('Load');

                netcontainer=rf.internal.apps.matchnet.AutoMNContainer(finalcktnames,...
                this.MatchingNetworkGenerator.Circuit,...
                networkSParameters(:,2),...
                failedTests,...
                this.MatchingNetworkGenerator.CenterFrequency,...
                this.MatchingNetworkGenerator.LoadedQ,...
                this.MatchingNetworkGenerator.Components,...
                srcZ,...
                loadZ,...
                this.MatchingNetworkGenerator);

                if isempty(this.MatchingNetworkManager.AutoNetworkHistory)&&...
                    ~isempty(evtdata.data.EvalparamTable.Data)
                    updateEval=true;
                else
                    updateEval=false;
                end

                this.MatchingNetworkManager.addMNContainer(netcontainer);
                if updateEval
                    this.communicateReevaluatedPerformance();
                end


                data.CircuitGroupName=netcontainer.Name;







                data.CircuitNames=netcontainer.CircuitNames;

                data.Performance=netcontainer.PerformanceTestsFailed;
                data.Tracker={netcontainer.CenterFrequency/1e9...
                ,netcontainer.Q,netcontainer.Topology};

                evtdataOut=rf.internal.apps.matchnet.ArbitraryEventData(data);
                this.notify('NewNetworksGenerated',evtdataOut);
                this.IsChanged=true;
            catch err
                var=err.stack(1).name;
                if contains(var,'CenterFrequency')||contains(var,'LoadedQ')
                    err=[var(regexp(var,'\w*.$'):end),': ',err.message];
                else
                    err=err.message;
                end
                data.message=err;
                data.title='Error';
                evtdataOut=rf.internal.apps.matchnet.ArbitraryEventData(data);
                this.notify('InvalidParameters_2',evtdataOut);
            end
        end

        function openAction(this)
            inputDataFiles='Matching Network File';
            allFiles='All Files';
            selectFileTitle='Select File';

            [matfile,pathname]=uigetfile(...
            {'*.mat',[inputDataFiles,' (*.mat)'];...
            '*.*',[allFiles,' (*.*)']},...
            selectFileTitle,this.MatFilePath);

            wasCanceled=isequal(matfile,0)||isequal(pathname,0);
            if wasCanceled
                return;
            end

            loadModel(this,[pathname,matfile]);
            this.notify('NewName',...
            rf.internal.apps.matchnet.ArbitraryEventData(this.Name))
        end

        function importAction(this)
            inputDataFiles='Circuit File';
            allFiles='All Files';
            selectFileTitle='Select File';

            [matfile,pathname]=uigetfile(...
            {'*.mat',[inputDataFiles,' (*.mat)'];...
            '*.*',[allFiles,' (*.*)']},...
            selectFileTitle,this.MatFilePath);

            wasCanceled=isequal(matfile,0)||isequal(pathname,0);
            if wasCanceled
                return;
            end

            loadCircuit(this,[pathname,matfile]);
        end

        function loadCircuit(this,matfilepath)
            try

                temp=load(matfilepath,'-mat');
                [isValid,temp]=this.isValidCircuitFile(temp);
                if isValid
                    this.MatchingNetworkGenerator.resumeAutoupdate();
                    this.suppressWarning('off')
                    isUnique=this.MatchingNetworkManager.retrieveCircuits({temp.cktobj.Name});
                    if~isempty(isUnique)
                        temp.cktobj.Name=[temp.cktobj.Name,'_import'];
                    end
                    this.MatchingNetworkGenerator.addNetwork(temp.cktobj,temp.cktobj.Name);
                    this.suppressWarning('on')
                    networkSParameters=this.MatchingNetworkGenerator.calculateLoadedSParameters();
                    this.MatchingNetworkGenerator.pauseAutoupdate();

                    index=strcmp(networkSParameters(:,1),temp.cktobj.Name);

                    this.MatchingNetworkManager.UserNetworkHistory.SourceImpedance=this.MatchingNetworkGenerator.interpretZ('Source');
                    this.MatchingNetworkManager.UserNetworkHistory.LoadImpedance=this.MatchingNetworkGenerator.interpretZ('Load');
                    this.MatchingNetworkManager.UserNetworkHistory.CenterFrequency=this.MatchingNetworkGenerator.CenterFrequency;
                    this.MatchingNetworkManager.UserNetworkHistory.Q=this.MatchingNetworkGenerator.LoadedQ;

                    this.MatchingNetworkManager.UserNetworkHistory.CircuitNames={temp.cktobj.Name};
                    this.MatchingNetworkManager.UserNetworkHistory.Circuits=temp.cktobj;


                    this.MatchingNetworkManager.UserNetworkHistory.CircuitSParameters=networkSParameters(index,2);
                    this.MatchingNetworkManager.UserNetworkHistory.PerformanceTestsFailed=this.MatchingNetworkGenerator.getPerformanceTestsFailed({temp.cktobj.Name});

                    data.CircuitGroupName=this.MatchingNetworkManager.UserNetworkHistory.Name;
                    data.CircuitNames={temp.cktobj.Name};
                    data.Performance=this.MatchingNetworkGenerator.getPerformanceTestsFailed({temp.cktobj.Name});
                    evtdataOut=rf.internal.apps.matchnet.ArbitraryEventData(data);
                    this.notify('NewNetworksGenerated',evtdataOut);
                else
                    msg=message('rf:matchingnetworkgenerator:BadCKTFile',matfilepath);
                    error(msg)
                end
            catch err
                data.message=err.message;
                data.title='Error';
                evtdataOut=rf.internal.apps.matchnet.ArbitraryEventData(data);
                this.notify('InvalidParameters_2',evtdataOut);
            end
        end

        function loadModel(this,matfilepath)
            data1.Busy=true;
            this.notify('AppBusy',rf.internal.apps.matchnet.ArbitraryEventData(data1));
            try
                [~,this.Name]=fileparts(matfilepath);


                temp=load(matfilepath,'-mat');
                [isValid,temp]=this.isValidMNetworkFile(temp);
                if isValid

                    matchingnet=temp.mnobj;
                    loadObject(this,matchingnet)










                    this.MatFilePath=matfilepath;
                else
                    msg=message('rf:matchingnetworkgenerator:BadMNFile',matfilepath);
                    error(msg)
                end
            catch err
                data1.Busy=false;
                this.notify('AppBusy',rf.internal.apps.matchnet.ArbitraryEventData(data1));
                ttl=message('rf:matchingnetworkgenerator:LoadFailed');
                data.message=err.message;
                data.title=getString(ttl);
                evtdataOut=rf.internal.apps.matchnet.ArbitraryEventData(data);
                this.notify('InvalidParameters_2',evtdataOut);

            end
            data1.Busy=false;
            this.notify('AppBusy',rf.internal.apps.matchnet.ArbitraryEventData(data1));
        end

        function loadObject(this,mnet)
            size1=numel(mnet);
            mnet=unique(mnet,'stable');
            size2=numel(mnet);
            if size1~=size2
                warning(message('rf:matchingnetworkgenerator:ImportHasDups'))
            end

            if~(all(arrayfun(@(x)isequal(mnet(1).SourceImpedance,x.SourceImpedance),mnet))...
                &&all(arrayfun(@(x)isequal(mnet(1).LoadImpedance,x.LoadImpedance),mnet))...
                &&all(arrayfun(@(x)isequal(mnet(1).getEvaluationParameters,x.getEvaluationParameters),mnet)))
                error(message('rf:matchingnetworkgenerator:ImportArray'))
            end

            matchingnet=mnet(1);
            data.SourceZ=matchingnet.SourceImpedance;
            data.LoadZ=matchingnet.LoadImpedance;
            data.Q=matchingnet.LoadedQ;
            data.CenterFrequency=matchingnet.CenterFrequency;
            evtdata=rf.internal.apps.matchnet.ArbitraryEventData(data);
            newTerminations(this,evtdata);

            data.Topology=matchingnet.Components;
            data.CenterFrequency=matchingnet.CenterFrequency;
            data.Q=matchingnet.LoadedQ;
            EvalparamTable=matchingnet.getEvaluationParameters();
            for k=1:size(EvalparamTable,1)
                if strcmp(EvalparamTable.Parameter{k},'Gt')
                    EvalparamTable.Parameter{k}='S21';
                elseif strcmp(EvalparamTable.Parameter{k},'gammain')
                    EvalparamTable.Parameter{k}='S11';
                end
            end
            EvalparamTable=EvalparamTable.Variables;
            if~size(EvalparamTable,1)
                data.EvalparamTable.Data=[];
            else
                for k=1:size(EvalparamTable,1)
                    data.EvalparamTable.Data(k,:)=[EvalparamTable(k,1:3),num2cell(EvalparamTable{k,4}/1e9,1),EvalparamTable(k,5),{true}];
                end
            end
            this.notify('SBarUpdate',rf.internal.apps.matchnet.ArbitraryEventData(data));

            data.FREQUENCY_SCALAR=1e9;
            evtdata=rf.internal.apps.matchnet.ArbitraryEventData(data);
            generateNetworks(this,evtdata)

            communicateReevaluatedPerformance(this)

            this.notify('ConfigUpdate',rf.internal.apps.matchnet.ArbitraryEventData(data));

            this.notify('EnablePlotButtons')

            for k=2:numel(mnet)
                data.Topology=mnet(k).Components;
                data.CenterFrequency=mnet(k).CenterFrequency;
                data.Q=mnet(k).LoadedQ;

                data.EvalparamTable.Data=[];
                evtdata=rf.internal.apps.matchnet.ArbitraryEventData(data);
                generateNetworks(this,evtdata)
            end
        end

        function initialModel(this,arg)
            this.Name=this.DefaultName;
            if ischar(arg)

                [~,~,ext]=fileparts(arg);
                if isempty(ext)
                    filename=[arg,'.mat'];
                else
                    filename=arg;
                end


                loadModel(this,filename);
            else
                loadObject(this,arg)
            end
        end

        function saveAction(this,matfilepath)
            if nargin<2

                if isempty(this.MatFilePath)
                    matfilepath=getMatFilePath(this);
                    if isequal(matfilepath,0)
                        return;
                    end
                else
                    matfilepath=this.MatFilePath;
                end
            end

            try



                mnobj=arrayfun(@(x)x.MatchingNetworkObject,...
                this.MatchingNetworkManager.AutoNetworkHistory);

                save(matfilepath,'mnobj')
                this.IsChanged=false;


                this.MatFilePath=matfilepath;
                [~,name]=fileparts(this.MatFilePath);
                if~strcmp(this.Name,name)
                    this.notify('NewName',...
                    rf.internal.apps.matchnet.ArbitraryEventData(name))
                end
            catch err
                data.message=err.message;
                data.title='Error';
                evtdataOut=rf.internal.apps.matchnet.ArbitraryEventData(data);
                this.notify('InvalidParameters_2',evtdataOut);
            end
        end

        function savePopupActions(this,str)
            switch str
            case getString(message('rf:matchingnetworkgenerator:FileListItem_Save'))
                saveAction(this)
            case getString(message('rf:matchingnetworkgenerator:FileListItem_SaveAs'))
                matfilepath=getMatFilePath(this);
                if isequal(matfilepath,0)
                    return;
                end
                saveAction(this,matfilepath);
            end
        end

        function matfilepath=getMatFilePath(this)


            if isempty(this.MatFilePath)
                [matfile,pathname]=...
                uiputfile('*.mat','Save matching network as',...
                [this.DefaultName,'.mat']);
            else
                [matfile,pathname]=...
                uiputfile('*.mat','Save matching network as',this.MatFilePath);
            end
            isCanceled=isequal(matfile,0)||isequal(pathname,0);
            if isCanceled
                matfilepath=0;
            else
                matfilepath=[pathname,matfile];
            end
        end


        function supplyCircuitData(this,evtdata)

            circuitNames=evtdata.data.RequestedCircuits;



            [data.CircuitNames,data.CircuitSParams,data.CircuitCircuits,...
            data.CircuitFailedPerformanceTests,data.CircuitCenterFreq,...
            data.CircuitLoadedQ,sourceZ,loadZ]=this.MatchingNetworkManager.retrieveCircuits(circuitNames);

            if~isempty(data.CircuitNames)

                this.suppressWarning('off')
                this.MatchingNetworkAnalyzer.addNetwork(data.CircuitCircuits{1},data.CircuitNames{1});
                this.suppressWarning('on')
                [net,values]=this.MatchingNetworkAnalyzer.getCircuitDetails(data.CircuitNames);
                this.MatchingNetworkAnalyzer.deleteNetwork(data.CircuitNames{1});


                data.CircuitNets={net};
                data.CircuitValues={values};
                data.CircuitName=data.CircuitNames{1};

                data.CircuitSrcZ={sourceZ(1)};
                data.CircuitLoadZ={loadZ(1)};
            end
            this.notify('NetworkDataAvailable',rf.internal.apps.matchnet.ArbitraryEventData(data));
        end


        function supplyCircuitDrawingData(this,evtdata)



            circuitName=evtdata.data.RequestedCircuits;
            [~,~,ckt,~]=this.MatchingNetworkManager.retrieveCircuits(circuitName);


            this.suppressWarning('off')
            this.MatchingNetworkAnalyzer.addNetwork(ckt{1},circuitName{1});
            this.suppressWarning('on')
            [net,values]=this.MatchingNetworkAnalyzer.getCircuitDetails(circuitName);
            this.MatchingNetworkAnalyzer.deleteNetwork(circuitName{1});


            data.CircuitObj=clone(ckt{1});
            data.CircuitNets=net;
            data.CircuitValues=values;
            data.CircuitName=circuitName{1};
            this.notify('NetworkDrawingDataAvailable',rf.internal.apps.matchnet.ArbitraryEventData(data));
        end

        function exportCircuitCBK(this,evtdata)
            circuitName=evtdata.data.CircuitNames;
            switch evtdata.data.Option
            case 'circuit'

                [~,~,ckt]=this.MatchingNetworkManager.retrieveCircuits(circuitName);
                mnckt=cellfun(@(x)clone(x),ckt);
                for k=1:numel(mnckt)
                    mnckt(k).Name=[circuitName{k},'_export'];
                end
                assignin('base','mnckt',mnckt)
                disp('Selected Matching Networks exported to workspace variable <a href="matlab:disp(mnckt)">mnckt</a>.')
            case 'sparameters'
                [~,sparams]=this.MatchingNetworkManager.retrieveCircuits(circuitName);
                assignin('base','cktsparams',sparams)
                disp('Selected Scaterring matrix exported to workspace variable <a href="matlab:disp(cktsparams)">cktsparams</a>.')
            end
        end

        function updateEvalparam(this,evtdata)
            data.Busy=true;
            this.notify('AppBusy',rf.internal.apps.matchnet.ArbitraryEventData(data));






            if(strcmp(evtdata.data.NewEvalparam{1},'S11')||strcmp(evtdata.data.NewEvalparam{1},'S22'))
                evtdata.data.NewEvalparam{1}='gammain';
            elseif(strcmp(evtdata.data.NewEvalparam{1},'S21')||strcmp(evtdata.data.NewEvalparam{1},'S12'))
                evtdata.data.NewEvalparam{1}='Gt';
            end


            temptable=this.MatchingNetworkGenerator.getEvaluationParameters();
            if(length(temptable.Parameter)>=evtdata.data.EvalparamIndex)
                this.MatchingNetworkGenerator.clearEvaluationParameter(evtdata.data.EvalparamIndex);
                this.MatchingNetworkAnalyzer.clearEvaluationParameter(evtdata.data.EvalparamIndex);
            end

            if(evtdata.data.NewEvalparam{6}==false)
                evtdata.data.NewEvalparam{5}=0;
            end


            this.MatchingNetworkGenerator.addEvaluationParameter(evtdata.data.NewEvalparam{1:5},evtdata.data.EvalparamIndex);
            this.MatchingNetworkAnalyzer.addEvaluationParameter(evtdata.data.NewEvalparam{1:5},evtdata.data.EvalparamIndex);

            this.reevaluateAllPerformance();


            this.communicateReevaluatedPerformance();

            data.Busy=false;
            this.notify('AppBusy',rf.internal.apps.matchnet.ArbitraryEventData(data));
        end

        function deleteEvalparam(this,evtdata)
            data.Busy=true;
            this.notify('AppBusy',rf.internal.apps.matchnet.ArbitraryEventData(data));

            indices=evtdata.data.EvalparamIndex;
            temptable=this.MatchingNetworkGenerator.getEvaluationParameters();
            indices(indices>length(temptable.Parameter))=[];

            if(~isempty(indices))
                this.MatchingNetworkGenerator.clearEvaluationParameter(indices);
                this.MatchingNetworkAnalyzer.clearEvaluationParameter(indices);
            else
                data.Busy=false;
                this.notify('AppBusy',rf.internal.apps.matchnet.ArbitraryEventData(data));
                return;
            end
            this.reevaluateAllPerformance();
            this.communicateReevaluatedPerformance();

            data.Busy=false;
            this.notify('AppBusy',rf.internal.apps.matchnet.ArbitraryEventData(data));
        end
    end

    methods(Access=protected)

        function reevaluateAllPerformance(this)
            for j=0:length(this.MatchingNetworkManager.AutoNetworkHistory)
                currentContainer=this.MatchingNetworkManager.getMNContainer(j);
                if(isempty(currentContainer.Circuits))
                    continue;
                end
                this.suppressWarning('off')
                this.MatchingNetworkAnalyzer.addNetwork(...
                currentContainer.Circuits,currentContainer.CircuitNames);
                this.suppressWarning('on')
                this.MatchingNetworkAnalyzer.forceSort();

                networkSParameters=this.MatchingNetworkAnalyzer.calculateLoadedSParameters();

                [~,~,cktnames]=this.MatchingNetworkAnalyzer.getAllCircuitNames();

                failedTests=this.MatchingNetworkAnalyzer.getPerformanceTestsFailed(cktnames);
                if(j==0)
                    netcontainer=rf.internal.apps.matchnet.AutoMNContainer(cktnames,...
                    this.MatchingNetworkAnalyzer.Circuit,...
                    networkSParameters(:,2),...
                    failedTests);
                else
                    netcontainer=rf.internal.apps.matchnet.AutoMNContainer(cktnames,...
                    this.MatchingNetworkAnalyzer.Circuit,...
                    networkSParameters(:,2),...
                    failedTests,...
                    currentContainer.CenterFrequency,...
                    currentContainer.Q,...
                    currentContainer.Topology,...
                    currentContainer.SourceImpedance,...
                    currentContainer.LoadImpedance,...
                    this.MatchingNetworkGenerator);
                end
                this.MatchingNetworkManager.replaceMNContainer(j,netcontainer);



                this.MatchingNetworkAnalyzer.deleteNetwork(cktnames);

            end
        end

        function communicateReevaluatedPerformance(this)

            for j=0:length(this.MatchingNetworkManager.AutoNetworkHistory)
                netcontainer=this.MatchingNetworkManager.getMNContainer(j);
                if isempty(netcontainer.Circuits)
                    continue
                end
                data.CircuitGroupName=netcontainer.Name;
                data.CircuitNames=netcontainer.CircuitNames;
                data.Performance=netcontainer.PerformanceTestsFailed;
                data.Tracker={netcontainer.CenterFrequency/1e9...
                ,netcontainer.Q,netcontainer.Topology};

                this.notify('NewNetworksGenerated',rf.internal.apps.matchnet.ArbitraryEventData(data));

                data.ParametersTable=this.MatchingNetworkAnalyzer.getEvaluationParameters();
                this.notify('EvalparamsUpdated',rf.internal.apps.matchnet.ArbitraryEventData(data));
            end
        end
    end

    methods(Access=protected)

        function names=nameAutoCkts(this,cktscount)
            names=cell(cktscount,1);
            for j=1:cktscount
                names{j}=['auto_',num2str(j+this.namecounter)];
            end
            this.namecounter=this.namecounter+cktscount;
        end
    end

    methods(Static)
        function[isValid,newStruct]=isValidMNetworkFile(mnStruct)

            if numel(mnStruct)==1
                f=fields(mnStruct);
                fName=f{1};
                isValid=isa(mnStruct.(fName),'matchingnetwork');
                newStruct.mnobj=mnStruct.(fName);
            else
                isValid=false;
            end
        end

        function[isValid,newStruct]=isValidCircuitFile(cktStruct)

            if numel(cktStruct)==1
                f=fields(cktStruct);
                fName=f{1};
                isValid=isa(cktStruct.(fName),'circuit');
                newStruct.cktobj=cktStruct.(fName);
            else
                isValid=false;
            end
        end

        function suppressWarning(state)
            strwarn=["2Ports","ShortPort","NoGndNode"...
            ,"UnsupportedComponent","ShortedComponent"...
            ,"TooManySeriesConnections","BrokenChain"];
            arrayfun(@(x)warning(state,'rf:matchingnetwork:CircuitParser_'+x),strwarn)
        end
    end
end
