classdef PlantInfo<matlab.mixin.Copyable&matlab.mixin.Heterogeneous










    properties(SetAccess=protected)

        SysName char


        FullSysPath cell


SysHyperlink


        Parent autoblks.pwr.PlantInfo=autoblks.pwr.PlantInfo.empty;


        Children autoblks.pwr.PlantInfo=autoblks.pwr.PlantInfo.empty;


        Trnsfrd autoblks.pwr.Signal


        NotTrnsfrd autoblks.pwr.Signal


        Stored autoblks.pwr.Signal
    end


    properties(Dependent=true)


        Inputs autoblks.pwr.Signal


        Outputs autoblks.pwr.Signal


        Losses autoblks.pwr.Signal


        Time double


        Eff timeseries


        AvgEff double

    end


    properties

        PwrUnits char='kW';


        EnrgyUnits char='MJ';


        EnrgyBalanceRelTol=0.01;


        EnrgyBalanceAbsTol=0.01;

    end




    properties(SetAccess=protected,Hidden=true)

        PwrBusObj autoblks.pwr.PwrInfoBus=autoblks.pwr.PwrInfoBus.empty


        PwrTrnsfrdPortConns autoblks.pwr.TrnsfrdConn


MdlRefName

        EnrgyBlkRef='autolibpowerinfoutils/Power Accounting Bus Creator';
        ConnPassThroughBlkTypes={'UnitConversion','RateTransition','SignalSpecification','Sum','TransferFcn'};
        CheckPortConnObj autoblks.pwr.autoblksCheckSysPortConn
    end


    properties(Dependent=true,Hidden=true)

Name


        PwrStoredInSignalData autoblks.pwr.Signal
        PwrStoredOutSignalData autoblks.pwr.Signal
    end


    methods

        function obj=PlantInfo(SysName,Parent)
            obj.checkoutLicense;


            if iscell(SysName)
                obj.FullSysPath=SysName;
            else
                obj.SysName=SysName;
                obj.FullSysPath=cellstr(SysName);
            end


            if nargin>=2
                obj.Parent=Parent;
                obj.CheckPortConnObj=obj.Parent.CheckPortConnObj;
            else
                obj.CheckPortConnObj=autoblks.pwr.autoblksCheckSysPortConn;
            end
            TopMdl=getBDRootName(obj.SysName);
            if~bdIsLoaded(TopMdl)
                load_system(TopMdl);
            end


            obj.SysHyperlink=autoblksMdlHyperlink(obj.SysName);


            obj.findChildren;


            obj.findConns;


            obj.PwrUnits='kW';
            obj.EnrgyUnits='MJ';
        end


        function run(obj)

            obj.loggingOn;
            TopMdl=bdroot(obj.SysName);
            SimOut=sim(obj.SysName,'ReturnWorkspaceOutputs','on');
            SignalLoggingName=get_param(TopMdl,'SignalLoggingName');
            obj.loggingOff;
            obj.addLoggedData(SimOut.(SignalLoggingName));
        end


        function loggingOn(obj)

            TopMdl=getBDRootName(obj.SysName);
            if~bdIsLoaded(TopMdl)
                load_system(TopMdl);
            end
            if isempty(obj.Parent)
                if strcmp(get_param(TopMdl,'SignalLogging'),'off')
                    try
                        set_param(TopMdl,'SignalLogging','on');
                    catch
                    end
                end
            end
            for i=1:length(obj.PwrBusObj)
                obj.PwrBusObj(i).loggingOn;
            end
            if~isempty(obj.Children)
                for i=1:length(obj.Children)
                    obj.Children(i).loggingOn;
                end
                if length(obj.FullSysPath)~=length(obj.Children(1).FullSysPath)
                    try
                        save_system(bdroot(obj.Children(1).SysName));
                    catch
                    end
                end
            end
            if isempty(obj.Parent)
                try
                    save_system(TopMdl);
                catch
                end
            end
        end


        function loggingOff(obj)

            TopMdl=getBDRootName(obj.SysName);
            if~bdIsLoaded(TopMdl)
                load_system(TopMdl);
            end
            for i=1:length(obj.PwrBusObj)
                obj.PwrBusObj(i).loggingOff;
            end
            if~isempty(obj.Children)
                for i=1:length(obj.Children)
                    obj.Children(i).loggingOff;
                end
                if length(obj.FullSysPath)~=length(obj.Children(1).FullSysPath)
                    try
                        save_system(bdroot(obj.Children(1).SysName));
                    catch
                    end
                end
            end
            if isempty(obj.Parent)
                try
                    save_system(TopMdl);
                catch
                end
            end
        end


        function addLoggedData(obj,LoggedData)



            if~isempty(LoggedData)

                RemoveIdx=[];
                for i=1:LoggedData.numElements
                    SignalObj=LoggedData{i};
                    Blk=SignalObj.BlockPath.getBlock(SignalObj.BlockPath.getLength);
                    isPwrAccountingBlk=strcmp(get_param(Blk,'ReferenceBlock'),obj.EnrgyBlkRef);

                    if isPwrAccountingBlk


                    else
                        RemoveIdx=[RemoveIdx,i];
                    end
                end


                if~isempty(RemoveIdx)
                    LoggedData=LoggedData.removeElement(RemoveIdx);
                end



                FinalTime=getFinalTime(LoggedData);
                LoggedData=matchFinalTime(LoggedData,FinalTime);

            end


            obj.addChildrenLoggedData(LoggedData);

        end


        function flag=isEnrgyBalanced(obj)
            flag=autoblksIsEnrgyBalanced([obj.Trnsfrd,obj.NotTrnsfrd],obj.Stored,obj.EnrgyBalanceRelTol,obj.EnrgyBalanceAbsTol);
        end


        function ChildSysObj=findChildSys(obj,ChildSys)



            ChildSysObj=autoblks.pwr.PlantInfo.empty;


            if ishandle(ChildSys)
                ChildSysName=[get_param(ChildSys,'Parent'),'/',get_param(ChildSys,'Name')];
            else
                ChildSysName=ChildSys;
            end


            if strcmp(ChildSysName,obj.SysName)
                ChildSysObj=obj;
            else
                for i=1:length(obj.Children)
                    ChildSysObj=obj.Children(i).findChildSys(ChildSysName);
                    if~isempty(ChildSysObj)
                        break;
                    end
                end
            end
        end


        function dispSysSummary(obj)


            if isempty(obj.Outputs.Pwr.Data)
                obj.run;
            end


            [Tbl,~,RowNamesNoLink]=obj.tableSysSummary(true);
            Str=table2str(Tbl,RowNamesNoLink,3);
            disp(Str);
        end


        function dispSignalSummary(obj)

            disp(' ')
            disp(obj.SysHyperlink)
            disp(getString(message('autoblks_shared:autoblkSharedMisc:avgEff',num2str(obj.AvgEff,'%.2f'))))
            disp(' ')
            [Tbl,SignalNames]=obj.tableSignalSummary;
            Str=table2str(Tbl,SignalNames,3);
            disp(Str);
        end


        function xlsSysSummary(obj,FileName,SheetName)




            if nargin<3
                SheetName=[];
            end
            Tbl=obj.tableSysSummary(false);
            Tbl.Properties.VariableNames=Tbl.Properties.VariableDescriptions;
            if isempty(SheetName)
                writetable(Tbl,FileName,'WriteVariableNames',true);
            else
                writetable(Tbl,FileName,'WriteVariableNames',true,'Sheet',SheetName);
            end
        end



        function sdiSummary(obj,varargin)

            obj.checkoutLicense;
            if nargin<2
                Dataset=obj.getBlkDataset;
            else
                Dataset=obj.getBlkDataset(varargin{1});
            end
            RunID=Simulink.sdi.createRun(obj.SysName,'vars',Dataset);
            Simulink.sdi.view;
        end


        function H=histogramEff(obj,NumBins)



            if nargin<2
                NumBins=[];
            end


            EffTimeSeries=obj.Eff;
            InputPwrTimeSeries=obj.Inputs.Pwr;
            TimeData=EffTimeSeries.Time;
            EffData=EffTimeSeries.Data;
            InputPwrData=InputPwrTimeSeries.Data;
            if length(EffData)>=2
                EffData(1)=EffData(2);
            end
            EffData(~isfinite(EffData))=0;


            TimeIncrement=mode(diff(TimeData));
            TimeHist=0:TimeIncrement:TimeData(end);
            EffHist=interp1(TimeData,EffData,TimeHist);
            InputPwrHist=interp1(TimeData,InputPwrData,TimeHist);
            EffHist(EffHist<0)=NaN;
            EffHist(EffHist>1)=NaN;


            if~isempty(NumBins)
                [HistCounts,EffEdges,InputPwrEdges]=histcounts2(EffHist,InputPwrHist,NumBins);
            else
                [HistCounts,EffEdges,InputPwrEdges]=histcounts2(EffHist,InputPwrHist);
            end
            HistCounts=HistCounts*TimeIncrement;
            H=histogram2('XBinEdges',EffEdges,'YBinEdges',InputPwrEdges,'BinCounts',HistCounts);
            xlabel(getString(message('autoblks_shared:autoblkSharedMisc:xLabelHist')))
            ylabel(getString(message('autoblks_shared:autoblkSharedMisc:yLabelHist',obj.Inputs.PwrUnits)))
            zlabel(getString(message('autoblks_shared:autoblkSharedMisc:zLabelHist')))
            title(getString(message('autoblks_shared:autoblkSharedMisc:titleHist',obj.Name)))
        end

    end


    methods(Hidden=true)









        function Dataset=getBlkDataset(obj,varargin)

            if nargin<2

                BlkPath=Simulink.SimulationData.BlockPath(obj.FullSysPath);


                PwrCell={obj.Trnsfrd,...
                obj.NotTrnsfrd,...
                obj.Stored,...
                obj.Losses,...
                obj.Inputs,...
                obj.Outputs};

                PwrData=Simulink.SimulationData.Dataset;
                EnrgyData=Simulink.SimulationData.Dataset;
                for i=1:length(PwrCell)
                    if~isempty(PwrCell{i})
                        NewPwrData=PwrCell{i}.getPwrDataset(BlkPath);
                        if~isempty(NewPwrData)
                            PwrData=PwrData.addElement(NewPwrData);
                            EnrgyData=EnrgyData.addElement(PwrCell{i}.getEnrgyDataset(BlkPath));
                        end
                    end
                end


                SignalDataset=Simulink.SimulationData.Dataset;
                SignalDataset.Name=obj.Name;

                EffData=obj.Eff;
                EffSignal=Simulink.SimulationData.Signal;
                EffSignal.BlockPath=BlkPath;
                EffSignal.PortType='outport';
                EffSignal.Name=EffData.Name;
                EffSignal.Values=EffData;
                SignalDataset=SignalDataset.addElement(EffSignal);

                PwrData.Name='Power';
                SignalDataset=SignalDataset.addElement(PwrData);

                EnrgyData.Name='Energy';
                SignalDataset=SignalDataset.addElement(EnrgyData);


                Dataset=Simulink.SimulationData.Dataset;
                Dataset=Dataset.addElement(SignalDataset);

            else


                InputStr=cellstr(varargin{1});
                if any(strcmpi(InputStr,'all'))
                    Dataset=obj.getBlkDataset;

                    for i=1:length(obj.Children)
                        ChildDatasets=obj.Children(i).getBlkDataset('all');
                        for j=1:ChildDatasets.numElements
                            Dataset=Dataset.addElement(ChildDatasets{j});
                        end
                    end
                else
                    Dataset=obj.getBlkDataset;
                    for i=1:length(InputStr)
                        ChildSys=obj.findChildSys(InputStr{i});
                        if~isempty(ChildSys)
                            ChildDataset=ChildSys.getBlkDataset;
                            Dataset=Dataset.addElement(ChildDataset{1});
                        end
                    end
                end
            end

        end


        function Val=getAllEnrgyBlkObjs(obj)
            if isempty(obj.PwrBusObj)
                Val=autoblks.pwr.PlantInfo.empty;
                for i=1:length(obj.Children)
                    Val=[Val,obj.Children(i).getAllEnrgyBlkObjs];
                end
            else
                Val=obj;
            end
        end
    end

    methods


        function Name=get.Name(obj)
            Idxdd=strfind(obj.SysName,'//');
            Idxd=strfind(obj.SysName,'/');
            for i=1:length(Idxdd)
                Idxd=setxor(Idxd,Idxdd(i)+[0,1]);
            end

            if~isempty(Idxd)
                Name=strrep(obj.SysName((Idxd(end)+1):end),'//','/');

            else
                Name=obj.SysName;
            end


        end

        function Time=get.Time(obj)
            Val=obj.Trnsfrd;
            if isempty(Val)
                Val=obj.NotTrnsfrd;
            end
            if isempty(Val)
                Val=obj.Stored;
            end
            if isempty(Val)
                Time=[];
            else
                Time=Val.Pwr.Time;
            end
        end
        function Val=get.Inputs(obj)

            if~isempty(obj.Trnsfrd)
                TrnsfrdData=obj.getSignalDataDir(obj.Trnsfrd,'PwrPositive');
            else
                TrnsfrdData=autoblks.pwr.Signal.empty;
            end


            if~isempty(obj.NotTrnsfrd)
                TempNotTrnsfrd=obj.getSignalDataDir(obj.NotTrnsfrd,'PwrPositive');
                if~isempty(obj.Children)
                    NotTrnsfrdData=TempNotTrnsfrd.Children(1).copy;
                    NotTrnsfrdData.Name=TempNotTrnsfrd.Name;
                    NotTrnsfrdData.Description=TempNotTrnsfrd.Description;
                else
                    NotTrnsfrdData=TempNotTrnsfrd;
                end
            else
                NotTrnsfrdData=autoblks.pwr.Signal.empty;
            end

            Val=autoblks.pwr.Signal;
            Val.Children=[TrnsfrdData,NotTrnsfrdData];
            if isempty(Val.Children)
                Val=obj.setZeroSignal(Val);
            end
            Val.Name='PwrInput';
            Val.Description='Inputs';
            Val.PwrUnits=obj.PwrUnits;
            Val.EnrgyUnits=obj.EnrgyUnits;
            Val.Parent=obj;
        end
        function Val=get.Outputs(obj)
            Val=obj.getSignalDataDir(obj.Trnsfrd,'PwrNegative','PwrOutput','Outputs');
            Val.Parent=obj;
        end
        function Val=get.Losses(obj)
            if isempty(obj.Children)
                Val=obj.getSignalDataDir(obj.NotTrnsfrd,'PwrNegative','PwrLoss','Losses');
            else
                Val=obj.NotTrnsfrd.Children(2);
            end
            Val.Parent=obj;
        end
        function Val=get.PwrStoredInSignalData(obj)
            Val=obj.getSignalDataDir(obj.Stored,'PwrPositive','PwrStoredIn','Stored Input');
            Val.Parent=obj;
        end
        function Val=get.PwrStoredOutSignalData(obj)
            Val=obj.getSignalDataDir(obj.Stored,'PwrNegative','PwrStoredOut','Stored Output');
            Val.Parent=obj;
        end


        function Eff=get.Eff(obj)
            PwrIn=(obj.Inputs.Pwr-obj.PwrStoredOutSignalData.Pwr);
            Eff=0-(obj.Outputs.Pwr-obj.PwrStoredInSignalData.Pwr)/PwrIn;
            Eff.Data=min(Eff.Data,1);
            Eff.Name='Efficiency';
        end
        function AvgEff=get.AvgEff(obj)
            AvgEff=-(obj.Outputs.FinalEnrgy-obj.PwrStoredInSignalData.FinalEnrgy)/(obj.Inputs.FinalEnrgy-obj.PwrStoredOutSignalData.FinalEnrgy);
        end


        function set.FullSysPath(obj,FullSysPath)
            obj.FullSysPath=cellstr(FullSysPath);
            obj.SysName=obj.FullSysPath{end};
        end


        function set.PwrUnits(obj,Unit)
            if~strcmp(obj.PwrUnits,Unit)
                autoblksunitconv(1,'W',Unit);
            end
            obj.PwrUnits=Unit;
            obj.setChildUnits(Unit,'PwrUnits')
        end


        function set.EnrgyUnits(obj,Unit)
            if~strcmp(obj.EnrgyUnits,Unit)
                autoblksunitconv(1,'J',Unit);
            end
            obj.EnrgyUnits=Unit;
            obj.setChildUnits(Unit,'EnrgyUnits')
        end


        function set.EnrgyBalanceRelTol(obj,Val)
            obj.EnrgyBalanceRelTol=Val;
            for i=1:length(obj.PwrTrnsfrdPortConns)
                obj.PwrTrnsfrdPortConns(i).EnrgyBalanceRelTol=Val;
            end
            obj.setChildTol(Val,'EnrgyBalanceRelTol')
        end


        function set.EnrgyBalanceAbsTol(obj,Val)
            obj.EnrgyBalanceAbsTol=Val;
            for i=1:length(obj.PwrTrnsfrdPortConns)
                obj.PwrTrnsfrdPortConns(i).EnrgyBalanceAbsTol=Val;
            end
            obj.setChildTol(Val,'EnrgyBalanceAbsTol')
        end
    end


    methods(Access=private)


        function addChildrenLoggedData(obj,LoggedData)


            obj.Trnsfrd=autoblks.pwr.Signal.empty;
            obj.NotTrnsfrd=autoblks.pwr.Signal.empty;
            obj.Stored=autoblks.pwr.Signal.empty;


            if~isempty(obj.PwrBusObj)
                obj.PwrBusObj.addLoggedData(LoggedData);
                if~isempty(obj.PwrBusObj.PwrTrnsfrdSignal)
                    obj.Trnsfrd=obj.PwrBusObj.PwrTrnsfrdSignal.getDataObj;

                    SignalList=obj.Trnsfrd.getChildSignalList;
                    SignalNames={SignalList.FullSignalName};

                    FoundIdx=[];
                    for i=1:length(obj.PwrTrnsfrdPortConns)
                        SearchIdx=setxor(1:length(SignalNames),FoundIdx);
                        for j=SearchIdx(:)'
                            if obj.PwrBusObj.AssctPortMap.isKey(SignalNames{j})
                                SignalPortNames=obj.PwrBusObj.AssctPortMap(SignalNames{j});
                                if~iscell(SignalPortNames)
                                    SignalPortNames={SignalPortNames};
                                end
                                if iscellstr(SignalPortNames)
                                    SignalPortNames={SignalPortNames};
                                end
                                for k=1:length(SignalPortNames)
                                    if isequal(sort(obj.PwrTrnsfrdPortConns(i).PortName),sort(SignalPortNames{k}))
                                        obj.PwrTrnsfrdPortConns(i).PwrTrnsfrdData=SignalList(j);
                                        FoundIdx=[FoundIdx,j];
                                        break;
                                    end
                                end
                            end
                        end
                    end

                end
                if~isempty(obj.PwrBusObj.PwrNotTrnsfrdSignal)
                    obj.NotTrnsfrd=obj.PwrBusObj.PwrNotTrnsfrdSignal.getDataObj;
                end
                if~isempty(obj.PwrBusObj.PwrStoredSignal)
                    obj.Stored=obj.PwrBusObj.PwrStoredSignal.getDataObj;
                end
            end


            if~isempty(obj.Children)

                for i=1:length(obj.Children)
                    obj.Children(i).addChildrenLoggedData(LoggedData);
                end


                SignalData=[obj.Children.NotTrnsfrd];
                PosSignalData=autoblks.pwr.Signal.empty;
                NegSignalData=autoblks.pwr.Signal.empty;
                for i=1:length(SignalData)
                    NegSignalData=[NegSignalData;SignalData(i).PwrNegative];
                    PosSignalData=[PosSignalData;SignalData(i).PwrPositive];
                end

                if~isempty(PosSignalData)
                    NotTrnsfrdInput=sum(PosSignalData);
                    NotTrnsfrdInput.Name='PwrInput';
                    NotTrnsfrdInput.Description='Input';
                else
                    NotTrnsfrdInput=autoblks.pwr.Signal.empty;
                end

                if~isempty(NegSignalData)
                    NotTrnsfrdLoss=sum(NegSignalData);
                    NotTrnsfrdLoss.Name='PwrLoss';
                    NotTrnsfrdLoss.Description='Losses';
                else
                    NotTrnsfrdLoss=autoblks.pwr.Signal.empty;
                end
                obj.NotTrnsfrd=autoblks.pwr.Signal;
                obj.NotTrnsfrd.Children=[NotTrnsfrdInput,NotTrnsfrdLoss];
                obj.NotTrnsfrd.Name=obj.Children(1).NotTrnsfrd.Name;
                obj.NotTrnsfrd.Description=obj.Children(1).NotTrnsfrd.Description;

                if isempty(obj.NotTrnsfrd.Children)
                    obj.NotTrnsfrd=autoblks.pwr.Signal.empty;
                end


                obj.Stored=sum([obj.Children.Stored]);
                obj.Stored.Name=obj.Children(1).Stored.Name;
                obj.Stored.Description=obj.Children(1).Stored.Description;


                obj.Trnsfrd=autoblks.pwr.Signal;
                for i=1:length(obj.Children)
                    if~isempty(obj.Children(i).Trnsfrd)
                        obj.Trnsfrd.Name=obj.Children(i).Trnsfrd.Name;
                        obj.Trnsfrd.Description=obj.Children(i).Trnsfrd.Description;
                        break;
                    end
                end
                if~isempty(obj.PwrTrnsfrdPortConns)
                    TrnsfrdIdx=1;
                    for i=1:length(obj.PwrTrnsfrdPortConns)
                        TrnsfrdData=[obj.PwrTrnsfrdPortConns(i).PwrChildSrc.PwrTrnsfrdData];
                        if~isempty(TrnsfrdData)
                            obj.Trnsfrd.Children(TrnsfrdIdx)=sum(TrnsfrdData);
                            obj.PwrTrnsfrdPortConns(i).PwrTrnsfrdData=obj.Trnsfrd.Children(i);
                            obj.Trnsfrd.Children(TrnsfrdIdx).Name=obj.PwrTrnsfrdPortConns(i).PwrChildSrc(1).PwrTrnsfrdData.Name;
                            obj.Trnsfrd.Children(TrnsfrdIdx).Description=[obj.PwrTrnsfrdPortConns(i).PwrChildSrc(1).PwrTrnsfrdData.ParentBlk.Name,...
                            ': ',obj.PwrTrnsfrdPortConns(i).OriginPwrTrnsfrdConn(1).PwrTrnsfrdData.Description];
                            TrnsfrdIdx=TrnsfrdIdx+1;
                        end

                    end

                    if TrnsfrdIdx==1
                        obj.Trnsfrd=autoblks.pwr.Signal.empty;
                    end
                else
                    obj.Trnsfrd=autoblks.pwr.Signal.empty;
                end


            end


            if~isempty(obj.Trnsfrd)
                obj.Trnsfrd.PwrUnits=obj.PwrUnits;
                obj.Trnsfrd.EnrgyUnits=obj.EnrgyUnits;
                obj.Trnsfrd.Parent=obj;
            end
            if~isempty(obj.NotTrnsfrd)
                obj.NotTrnsfrd.PwrUnits=obj.PwrUnits;
                obj.NotTrnsfrd.EnrgyUnits=obj.EnrgyUnits;
                obj.NotTrnsfrd.Parent=obj;
            end
            if~isempty(obj.Stored)
                obj.Stored.PwrUnits=obj.PwrUnits;
                obj.Stored.EnrgyUnits=obj.EnrgyUnits;
                obj.Stored.Parent=obj;
            end


            if~isempty(obj.PwrBusObj)

                if~obj.isEnrgyBalanced
                    warning(message('autoblks_shared:autoerrSysEnrgyInfo:enrgyNotBalanced',autoblksMdlHyperlink(obj.SysName),autoblksMdlHyperlink(obj.PwrBusObj.BlkName)));
                end
            else




                ChildBlkPorts=obj.getChildBlkPorts;
                for i=1:length(ChildBlkPorts)
                    if isempty(ChildBlkPorts(i).PwrPortConn)
                        if~ChildBlkPorts(i).isConnEnrgyBalanced
                            if isempty(ChildBlkPorts(i).PwrBlkConn)
                                for j=1:length(ChildBlkPorts(i).OriginPwrTrnsfrdConn)
                                    warning(message('autoblks_shared:autoerrSysEnrgyInfo:enrgyTrnsfrdNotConn',ChildBlkPorts(i).OriginPwrTrnsfrdConn(j).Parent.SysHyperlink,ChildBlkPorts(i).OriginPwrTrnsfrdConn(j).PwrTrnsfrdData.FullSignalName));
                                end
                            else
                                PortFinalConn=ChildBlkPorts(i).FinalDstPwrTrnsfrdConn;
                                AllSignalConns=[ChildBlkPorts(i).OriginPwrTrnsfrdConn,PortFinalConn];
                                AllSignalNames=cell(size(AllSignalConns));
                                for j=1:length(AllSignalNames)
                                    if~isempty(AllSignalConns(j).PwrTrnsfrdData)
                                        SignalName=AllSignalConns(j).PwrTrnsfrdData.FullSignalName;
                                    else
                                        SignalName='NA';
                                    end
                                    AllSignalNames{j}=[AllSignalConns(j).Parent.SysName,': ',SignalName,num2str(j)];

                                end
                                SortedNames=sort(AllSignalNames);
                                ConnSignals=[];
                                if strcmp(AllSignalNames{1},SortedNames{1})
                                    BlockName=cell(size(AllSignalConns));
                                    SignalName=BlockName;
                                    for j=1:length(AllSignalConns)

                                        BlockName{j}=AllSignalConns(j).Parent.SysHyperlink;
                                        if~isempty(AllSignalConns(j).PwrTrnsfrdData)
                                            SignalName{j}=AllSignalConns(j).PwrTrnsfrdData.FullSignalName;
                                        else
                                            SignalName{j}='NA';
                                        end
                                        if j>1
                                            ConnSignals=[ConnSignals,newline,'''',BlockName{j},...
                                            ''': ''',SignalName{j},''''];
                                        end
                                    end
                                    warning(message('autoblks_shared:autoerrSysEnrgyInfo:enrgyTrnsfrdConnNotBalanced',BlockName{1},SignalName{1},ConnSignals));
                                end
                            end
                        end
                    end
                end
            end
        end


        function Val=getSignalDataDir(obj,DataObj,MethodName,Name,Description)
            if isempty(DataObj)
                Val=autoblks.pwr.Signal.empty;
            else
                Val=DataObj.(MethodName);
            end
            Val=obj.setZeroSignal(Val);
            if~isempty(Val)
                if nargin>3
                    Val.Name=Name;
                end
                if nargin>4
                    Val.Description=Description;
                end
            end
        end


        function[BusBlkNames,MdlRefPaths]=findEnrgyBusBlks(obj,SysName,SysMdlRefPath)
            if nargin<3
                SysMdlRefPath={};
            else
                SysMdlRefPath=cellstr(SysMdlRefPath);
            end






            BusBlkNames=cellstr(find_system(SysName,'LookUnderMasks','all',...
            'FollowLinks','on','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'ReferenceBlock',obj.EnrgyBlkRef));
            MdlRefPaths=cell(size(BusBlkNames));
            for i=1:length(BusBlkNames)
                MdlRefPaths{i}=[SysMdlRefPath,BusBlkNames{i}];
            end


            [MdlRefNames,FindMdlRefPaths]=findMdlRefs(SysName,SysMdlRefPath);
            for i=1:length(MdlRefNames)
                load_system(MdlRefNames{i})
                [NewBusBlkNames,NewMdlRefPaths]=obj.findEnrgyBusBlks(MdlRefNames{i},FindMdlRefPaths{i});
                BusBlkNames=[BusBlkNames;NewBusBlkNames];
                MdlRefPaths=[MdlRefPaths;NewMdlRefPaths];
            end
        end


        function findChildren(obj)

            BlkSearchName=obj.SysName;
            if strcmp(get_param(obj.SysName,'Type'),'block')
                if strcmp(get_param(obj.SysName,'BlockType'),'SubSystem')
                    if strcmp(get_param(obj.SysName,'Variant'),'on')
                        BlkSearchName=get_param(obj.SysName,'ActiveVariantBlock');
                    end
                end
            end


            ChildMdlRefBlks=cellstr(find_system(BlkSearchName,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','ModelReference'));
            if all(strcmp(ChildMdlRefBlks,BlkSearchName))&&~isempty(ChildMdlRefBlks)
                MdlRefNameSearch=get_param(ChildMdlRefBlks{1},'ModelName');
                ChildSubSystemBlks=cellstr(find_system(MdlRefNameSearch,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','SubSystem'));
                ChildMdlRefBlks=cellstr(find_system(MdlRefNameSearch,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','ModelReference'));
                SysIsMdlRef=true;
            else
                ChildSubSystemBlks=cellstr(find_system(BlkSearchName,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','SubSystem'));
                [~,IA]=setxor(ChildSubSystemBlks,BlkSearchName);
                ChildSubSystemBlks=ChildSubSystemBlks(IA);
                SysIsMdlRef=false;
            end
            AllChildBlks=[ChildMdlRefBlks;ChildSubSystemBlks];
            obj.MdlRefName='';
            if~strcmp(get_param(BlkSearchName,'Type'),'block_diagram')
                if strcmp(get_param(BlkSearchName,'BlockType'),'ModelReference')
                    obj.MdlRefName=get_param(BlkSearchName,'ModelName');
                end
            end


            obj.Children=autoblks.pwr.PlantInfo.empty;
            SysIdx=1;
            HasAssctPwrBus=false;
            AddSysObj=false(size(AllChildBlks));
            for i=1:length(AllChildBlks)

                [BusBlkNames,MdlRefPaths]=obj.findEnrgyBusBlks(AllChildBlks{i},obj.FullSysPath(1:end-1));
                AssctBlkNames=cell(size(BusBlkNames));

                for j=1:length(AssctBlkNames)
                    PwrBusObjCheck=autoblks.pwr.PwrInfoBus(MdlRefPaths{j});
                    if strcmp(PwrBusObjCheck.getAssctBlkName,BlkSearchName)
                        obj.PwrBusObj=PwrBusObjCheck;
                        obj.PwrBusObj.GetInputSignals;
                        HasAssctPwrBus=true;
                        break;
                    end
                    AssctBlkNames{j}=PwrBusObjCheck.getAssctBlkName;
                end
                if HasAssctPwrBus
                    break;
                end
                AddSysObj(i)=length(BusBlkNames)>=1;
            end


            if~HasAssctPwrBus
                for i=1:length(AddSysObj)
                    if AddSysObj(i)
                        if SysIsMdlRef
                            BlkPathCell=[obj.FullSysPath(1:end-1),BlkSearchName,AllChildBlks(i)];
                        else
                            BlkPathCell=[obj.FullSysPath(1:end-1),AllChildBlks(i)];
                        end
                        obj.Children(SysIdx)=autoblks.pwr.PlantInfo(BlkPathCell,obj);
                        SysIdx=SysIdx+1;
                    end
                end
            end
        end


        function findConns(obj)


            SysHdl=get_param(obj.SysName,'Handle');
            PortInfo=autoblksgetportinfo(SysHdl);
            PortNames={PortInfo.Inports.Name,PortInfo.Outports.Name,PortInfo.LConns.Name,PortInfo.RConns.Name};
            obj.PwrTrnsfrdPortConns=autoblks.pwr.TrnsfrdConn.empty;


            if~isempty(obj.PwrBusObj)
                ConnIdx=1;
                KeySignals=obj.PwrBusObj.AssctPortMap.keys;
                for i=1:length(KeySignals)
                    AssctPortNames=obj.PwrBusObj.AssctPortMap(KeySignals{i});
                    if iscell(AssctPortNames)
                        if iscellstr(AssctPortNames)
                            AssctPortNames={AssctPortNames};
                        end
                    else
                        AssctPortNames={{AssctPortNames}};
                    end
                    for j=1:length(AssctPortNames)
                        if all(ismember(AssctPortNames{j},PortNames))
                            obj.PwrTrnsfrdPortConns(ConnIdx)=autoblks.pwr.TrnsfrdConn(obj,AssctPortNames{j});
                            ConnIdx=ConnIdx+1;
                            break;
                        end
                    end

                end
            end


            ChildBlkPorts=obj.getChildBlkPorts;
            if~isempty(ChildBlkPorts)

                PortNames=obj.getSysPortInfo;
                PortBlkHdls=-ones(size(PortNames));
                PortBlkPortHdls=-ones(size(PortNames));

                for i=1:length(PortNames)
                    if isempty(obj.MdlRefName)
                        PortBlkHdls(i)=get_param([obj.SysName,'/',PortNames{i}],'Handle');
                    else
                        PortBlkHdls(i)=get_param([obj.MdlRefName,'/',PortNames{i}],'Handle');
                    end
                    ph=get_param(PortBlkHdls(i),'PortHandles');
                    PortBlkPortHdls(i)=[ph.Inport,ph.Outport,ph.LConn,ph.RConn];
                end


                AllEnrgyBlkObjs=obj.getAllEnrgyBlkObjs;
                StopSearchBlkHdls=[PortBlkHdls,cell2mat(get_param({AllEnrgyBlkObjs.SysName},'Handle'))'];


                for i=1:length(ChildBlkPorts)


                    for j=(i+1):length(ChildBlkPorts)

                        isOriginMatch=false;
                        for k=1:length(ChildBlkPorts(i).OriginPwrTrnsfrdConn)
                            for m=1:length(ChildBlkPorts(j).OriginPwrTrnsfrdConn)
                                if isequal(ChildBlkPorts(i).OriginPwrTrnsfrdConn(k),ChildBlkPorts(j).OriginPwrTrnsfrdConn(m))
                                    isOriginMatch=true;
                                    break;
                                end
                            end
                            if isOriginMatch
                                break;
                            end
                        end


                        if~isOriginMatch
                            PortsConnI=false(size(ChildBlkPorts(i).OriginPwrTrnsfrdConn(1).PortHdl));
                            PortsConnJ=false(size(ChildBlkPorts(j).OriginPwrTrnsfrdConn(1).PortHdl));
                            for k=1:length(ChildBlkPorts(i).OriginPwrTrnsfrdConn(1).PortHdl)
                                for m=1:length(ChildBlkPorts(j).OriginPwrTrnsfrdConn(1).PortHdl)
                                    isConnected=obj.CheckPortConnObj.isPortConnected(ChildBlkPorts(i).OriginPwrTrnsfrdConn(1).PortHdl(k),ChildBlkPorts(j).OriginPwrTrnsfrdConn(1).PortHdl(m),...
                                    ChildBlkPorts(i).OriginPwrTrnsfrdConn(1).Parent.FullSysPath,ChildBlkPorts(j).OriginPwrTrnsfrdConn(1).Parent.FullSysPath,...
                                    obj.ConnPassThroughBlkTypes,StopSearchBlkHdls);
                                    if isConnected
                                        PortsConnI(k)=true;
                                        PortsConnJ(m)=true;
                                    end
                                end
                            end
                            if all(PortsConnI)&&all(PortsConnJ)
                                ChildBlkPorts(i).addPwrBlkConn(ChildBlkPorts(j));
                            end
                        end
                    end


                    isPortConn=false(size(ChildBlkPorts(i).OriginPwrTrnsfrdConn(1).PortHdl));
                    PortConnNames=cell(size(isPortConn));
                    for j=1:length(ChildBlkPorts(i).OriginPwrTrnsfrdConn(1).PortHdl)
                        for k=1:length(PortBlkPortHdls)
                            isPortConn(j)=obj.CheckPortConnObj.isPortConnected(ChildBlkPorts(i).OriginPortHdl(j),PortBlkPortHdls(k),...
                            ChildBlkPorts(i).OriginPwrTrnsfrdConn(1).Parent.FullSysPath,ChildBlkPorts(i).OriginPwrTrnsfrdConn(1).Parent.FullSysPath,...
                            obj.ConnPassThroughBlkTypes,StopSearchBlkHdls);
                            if isPortConn(j)
                                PortConnNames{j}=PortNames{k};
                                break;
                            end
                        end
                        if~isPortConn(j)
                            break;
                        end
                    end
                    if all(isPortConn)
                        obj.PwrTrnsfrdPortConns(end+1)=autoblks.pwr.TrnsfrdConn(obj,PortConnNames);
                        ChildBlkPorts(i).addPwrPortConn(obj.PwrTrnsfrdPortConns(end));
                    end

                end

            end


            if isempty(obj.Parent)
                obj.removeUnusedPortConns;
            end

        end


        function ChildBlkPorts=getChildBlkPorts(obj)
            ChildBlkPorts=autoblks.pwr.TrnsfrdConn.empty;
            for i=1:length(obj.Children)
                ChildBlkPorts=[ChildBlkPorts,obj.Children(i).PwrTrnsfrdPortConns];
            end
        end


        function removeUnusedPortConns(obj)
            if~isempty(obj.Children)&&~isempty(obj.Parent)
                RemoveIdx=[];
                for i=1:length(obj.PwrTrnsfrdPortConns)
                    if isempty(obj.PwrTrnsfrdPortConns(i).PwrBlkConn)&&isempty(obj.PwrTrnsfrdPortConns(i).PwrPortConn)
                        RemoveIdx=[RemoveIdx,i];
                    end
                end
                for i=RemoveIdx
                    obj.PwrTrnsfrdPortConns(i).removeAllConns;
                end
                obj.PwrTrnsfrdPortConns=obj.PwrTrnsfrdPortConns(setxor(1:length(obj.PwrTrnsfrdPortConns),RemoveIdx));
            end
            for i=1:length(obj.Children)
                obj.Children(i).removeUnusedPortConns;
            end
        end


        function[PortNames,SysPortInfo]=getSysPortInfo(obj)
            SysPortInfo=autoblksgetportinfo(get_param(obj.SysName,'Handle'));
            PortNames={SysPortInfo.Inports.Name,SysPortInfo.Outports.Name,SysPortInfo.LConns.Name,SysPortInfo.RConns.Name};
        end


        function Val=setZeroSignal(obj,Val)
            if isempty(Val)
                Val=autoblks.pwr.Signal;
                Val.AddPwrSignalData(timeseries(obj.Time*0,obj.Time));
                Val.PwrUnits=obj.PwrUnits;
                Val.EnrgyUnits=obj.EnrgyUnits;
            end

        end


        function setChildUnits(obj,Unit,UnitParamName)


            if~isempty(obj.Trnsfrd)
                obj.Trnsfrd.(UnitParamName)=Unit;
            end
            if~isempty(obj.NotTrnsfrd)
                obj.NotTrnsfrd.(UnitParamName)=Unit;
            end
            if~isempty(obj.Stored)
                obj.Stored.(UnitParamName)=Unit;
            end


            if~isempty(obj.PwrBusObj)
                obj.PwrBusObj.(UnitParamName)=Unit;
            end


            for i=1:length(obj.Children)
                obj.Children(i).(UnitParamName)=Unit;
                obj.Children(i).setChildUnits(Unit,UnitParamName);
            end
        end


        function setChildTol(obj,Val,TolName)
            for i=1:length(obj.Children)
                obj.Children(i).(TolName)=Val;
            end
        end


        function[SummaryTbl,FullNameNoLink,RowNamesNoLink]=tableSysSummary(obj,IncludeHyperlinks)

            obj.checkoutLicense;


            if nargin<2
                IncludeHyperlinks=true;
            end


            RowNamesNoLink={obj.Name};
            FullNameNoLink={obj.SysName};
            Efficiency=obj.AvgEff;
            EnergyLoss=obj.Losses.FinalEnrgy;
            EnergyInput=obj.Inputs.FinalEnrgy;
            EnergyOutput=obj.Outputs.FinalEnrgy;
            DeltaEnrgyStored=obj.Stored.FinalEnrgy;


            for i=1:length(obj.Children)
                [ChildTbl,ChildFullNameNoLink]=obj.Children(i).tableSysSummary(false);
                for j=1:size(ChildTbl,1)
                    RowNamesNoLink=[RowNamesNoLink;['  ',ChildTbl.SystemName{j}]];
                    FullNameNoLink=[FullNameNoLink;ChildFullNameNoLink{j}];
                end
                Efficiency=[Efficiency;ChildTbl.Efficiency];
                EnergyLoss=[EnergyLoss;ChildTbl.EnergyLoss];
                EnergyInput=[EnergyInput;ChildTbl.EnergyInput];
                EnergyOutput=[EnergyOutput;ChildTbl.EnergyOutput];
                DeltaEnrgyStored=[DeltaEnrgyStored;ChildTbl.DeltaEnrgyStored];
            end


            for i=1:length(FullNameNoLink)
                if isempty(strrep(FullNameNoLink{i},' ',''))
                    FullNameNoLink{i}=' ';
                end
            end


            if IncludeHyperlinks
                SystemName=cell(size(RowNamesNoLink));
                for i=1:length(RowNamesNoLink)
                    if~isempty(strrep(FullNameNoLink{i},' ',''))
                        SystemName{i}=autoblksMdlHyperlink(FullNameNoLink{i},[],RowNamesNoLink{i});
                    else
                        SystemName{i}=strrep(RowNamesNoLink{i},newline,' ');
                    end
                end
            else
                SystemName=cell(size(RowNamesNoLink));
                for i=1:length(RowNamesNoLink)
                    SystemName{i}=strrep(RowNamesNoLink{i},newline,' ');
                end
            end


            SummaryTbl=table(SystemName,Efficiency,EnergyLoss,EnergyInput,EnergyOutput,DeltaEnrgyStored);
            SummaryTbl.Properties.VariableDescriptions={'Name',...
            'Efficiency',...
            ['Energy Loss (',obj.EnrgyUnits,')'],...
            ['Energy Input (',obj.EnrgyUnits,')'],...
            ['Energy Output (',obj.EnrgyUnits,')'],...
            ['Energy Stored (',obj.EnrgyUnits,')']};
            SummaryTbl.Properties.VariableUnits=[{'',''},repmat({obj.EnrgyUnits},1,4)];
            SummaryTbl.Properties.Description=['''',obj.Name,''' Energy Summary'];
            SummaryTbl.Properties.VariableDescriptions{1}='System Name';
        end


        function[SummaryTbl,Signal]=tableSignalSummary(obj)

            SignalTbl=[obj.Inputs.tableSummary;...
            obj.Outputs.tableSummary;...
            obj.Losses.tableSummary;...
            obj.Stored.tableSummary];
            Signal=SignalTbl.Signal(:);
            Energy=SignalTbl.Total(:);

            SummaryTbl=table(Signal,Energy);
            SummaryTbl.Properties.VariableDescriptions={'Signal',...
            ['Energy (',obj.EnrgyUnits,')']};
            SummaryTbl.Properties.VariableUnits={'',obj.EnrgyUnits};
            SummaryTbl.Properties.Description=['''',obj.Name,''' Energy Summary'];
        end


        function checkoutLicense(obj)
            [CheckoutWorked,ErrMsg]=builtin('license','checkout','Powertrain_Blockset');
            if~CheckoutWorked
                CheckoutWorked=builtin('license','checkout','Vehicle_Dynamics_Blockset');
            end
            if~CheckoutWorked
                error(ErrMsg)
            end

        end
    end
end


function[MdlRefNames,MdlRefPaths]=findMdlRefs(ParentMdlName,ParentMdlRefPath)
    if nargin<2
        ParentMdlRefPath={};
    else
        ParentMdlRefPath=cellstr(ParentMdlRefPath);
    end
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        [MdlNames,MdlRefPaths]=find_mdlrefs(ParentMdlName,'AllLevels',false,...
        'MatchFilter',@Simulink.match.activeVariants);
    else
        [MdlNames,MdlRefPaths]=find_mdlrefs(ParentMdlName,'AllLevels',false,...
        'Variants','ActiveVariants');
    end
    MdlRefPaths=cellstr(MdlRefPaths);
    if isempty(MdlRefPaths)
        MdlRefNames={};
    else
        MdlRefNames=MdlNames(1:end-1);
    end
    for i=1:length(MdlRefNames)
        MdlRefPaths{i}=[ParentMdlRefPath,MdlRefPaths{i}];
    end

end


function[Pwr,FinalEnrgy]=zeroEmptySignal(Val)
    if isempty(Val)
        Pwr=0;
        FinalEnrgy=0;
    else
        Pwr=Val.Pwr;
        FinalEnrgy=Val.FinalEnrgy;
    end

end


function bdrootName=getBDRootName(SysName)
    s=strfind(SysName,'/');
    if isempty(s)
        bdrootName=SysName;
    else
        bdrootName=SysName(1:(s(1)-1));
    end
end


function Str=table2str(Tbl,RowNamesNoLink,NumDec)

    if length(NumDec)==1
        NumDec=repmat(NumDec,1,length(Tbl.Properties.VariableNames));
    end


    DataCell=cell(size(Tbl));
    for j=1:size(Tbl,2)
        if~iscell(Tbl{1,j})
            MaxVal=max(abs(Tbl{:,j}));
            MinVal=MaxVal/10^NumDec(j);
        else
            MinVal=nan;
        end
        for i=1:size(Tbl,1)
            NextVal=Tbl{i,j};
            if iscell(NextVal)
                NextVal=NextVal{:};
            end
            if ischar(NextVal)||isstring(NextVal)
                DataCell{i,j}=NextVal;
            else
                if isfinite(NextVal)
                    if abs(NextVal)<=MinVal
                        NextVal=0;
                    end
                    DataCell{i,j}=num2str(NextVal,NumDec(j));
                else
                    DataCell{i,j}='-';
                end
            end
        end
    end


    ColNames=Tbl.Properties.VariableDescriptions;
    MaxColLength=zeros(size(ColNames));
    MaxColLength(1)=length(ColNames{1})+2;
    for j=1:size(DataCell,1)
        MaxColLength(1)=max(MaxColLength(1),length(RowNamesNoLink{j})+2);
    end
    for i=2:length(MaxColLength)
        MaxColLength(i)=length(ColNames{i})+4;
        for j=1:size(DataCell,1)
            MaxColLength(i)=max(MaxColLength(i),length(DataCell{j,i})+2);
        end
    end


    Str='';
    for i=1:length(MaxColLength)

        SpaceNum=ceil((MaxColLength(i)-length(ColNames{i}))/2);
        MaxColLength(i)=SpaceNum*2+length(ColNames{i});
        Str=[Str,repmat(' ',1,SpaceNum),ColNames{i},repmat(' ',1,SpaceNum)];
    end


    Str=[Str,newline,repmat('-',1,sum(MaxColLength))];


    for j=1:size(DataCell,1)
        Str=[Str,newline];
        Str=[Str,DataCell{j,1},repmat(' ',1,MaxColLength(1)-length(RowNamesNoLink{j}))];
        for i=2:length(MaxColLength)
            Str=[Str,repmat(' ',1,MaxColLength(i)-length(DataCell{j,i})-2),DataCell{j,i},'  '];
        end
    end

end


function FinalTime=getFinalTime(LoggedData)


    FinalTime=0;

    InputType=class(LoggedData);
    switch InputType

    case 'Simulink.SimulationData.Dataset'
        for i=1:LoggedData.numElements
            FinalTime=max(FinalTime,getFinalTime(LoggedData{i}.Values));
        end

    case 'struct'
        for i=1:length(LoggedData)
            StructFields=fieldnames(LoggedData(i));
            for j=1:length(StructFields)
                FinalTime=max(FinalTime,getFinalTime(LoggedData(i).(StructFields{j})));
            end
        end

    case 'timeseries'
        for i=1:length(LoggedData)
            FinalTime=max([FinalTime;LoggedData(i).Time(:)]);
        end

    end


end


function LoggedData=matchFinalTime(LoggedData,FinalTime)



    InputType=class(LoggedData);
    switch InputType

    case 'Simulink.SimulationData.Dataset'
        for i=1:LoggedData.numElements
            LoggedData{i}.Values=matchFinalTime(LoggedData{i}.Values,FinalTime);
        end

    case 'struct'
        for i=1:length(LoggedData)
            StructFields=fieldnames(LoggedData(i));
            for j=1:length(StructFields)
                LoggedData(i).(StructFields{j})=matchFinalTime(LoggedData(i).(StructFields{j}),FinalTime);
            end
        end

    case 'timeseries'
        for i=1:length(LoggedData)

            if isempty(LoggedData(i).Data)
                if isempty(LoggedData(i).Time)
                    LoggedData(i)=timeseries([0;0],[0;FinalTime]);
                else
                    LoggedData(i).Data=LoggedData(i).Time*0;
                end

            end


            if LoggedData(i).Time(end)<FinalTime
                LoggedData(i)=LoggedData(i).addsample('Data',LoggedData(i).Data(end),'Time',FinalTime);
            end
        end

    end


end
