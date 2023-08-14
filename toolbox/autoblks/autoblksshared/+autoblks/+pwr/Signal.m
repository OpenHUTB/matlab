classdef Signal<matlab.mixin.Copyable&matlab.mixin.Heterogeneous




    properties

        Name char

        Description char


Parent

        Children autoblks.pwr.Signal


        PwrUnits char='kW';

        EnrgyUnits char='MJ';
    end


    properties(Dependent=true)

Pwr

Enrgy

FinalEnrgy

MaxAbsEnrgy


ParentBlk
    end


    properties(SetAccess=protected)

        FullSignalName char
    end


    properties(SetAccess=protected,Hidden=true)

        PwrData timeseries
        EnrgyData timeseries
        FinalEnrgyData double
    end

    properties(Dependent=true,Hidden=true)

PwrPositive
PwrNegative


DescriptionWithPwrUnits
DescriptionWithEnrgyUnits
    end


    methods


        function Pwr=get.Pwr(obj)
            Pwr=obj.getEnrgySum('Pwr');
            Pwr.Name=obj.Description;
        end


        function Enrgy=get.Enrgy(obj)
            Enrgy=obj.getEnrgySum('Enrgy');
            Enrgy.Name=obj.Description;
        end


        function Desc=get.DescriptionWithPwrUnits(obj)
            Desc=[obj.Description,' (',obj.PwrUnits,')'];
        end


        function Desc=get.DescriptionWithEnrgyUnits(obj)
            Desc=[obj.Description,' (',obj.EnrgyUnits,')'];
        end


        function BlkObj=get.ParentBlk(obj)
            BlkObj=obj.Parent;
            while isa(BlkObj,'autoblks.pwr.Signal')
                BlkObj=BlkObj.Parent;
            end
        end


        function FinalEnrgy=get.FinalEnrgy(obj)
            FinalEnrgy=obj.getEnrgySum('FinalEnrgy');
        end


        function MaxAbsEnrgy=get.MaxAbsEnrgy(obj)
            CurrEnrgy=obj.Enrgy;
            if isa(CurrEnrgy,'timeseries')
                MaxAbsEnrgy=max(abs(CurrEnrgy.Data));
            else
                MaxAbsEnrgy=[];
            end
        end


        function Signal=get.PwrPositive(obj)
            Signal=obj.getSignalFromDir('Positive');
        end


        function Signal=get.PwrNegative(obj)
            Signal=obj.getSignalFromDir('Negative');
        end


        function set.Name(obj,NewName)
            if isa(obj.Parent,'autoblks.pwr.Signal')
                OtherNames=setxor(obj.Name,{obj.Parent.Children.Name});
                idx=1;
                OrigNewName=NewName;
                while idx<length(obj.Parent.Children)
                    if ismember(NewName,OtherNames)
                        NewName=[OrigNewName,num2str(idx)];
                        idx=idx+1;
                    else
                        break;
                    end
                end
                obj.Name=NewName;
            else
                obj.Name=NewName;
            end

            UpdateFullSignalName=obj.FullSignalName;
        end


        function set.Children(obj,Value)
            obj.Children=Value;
            for i=1:length(obj.Children)
                obj.Children(i).Parent=obj;
                obj.Children(i).PwrUnits=obj.PwrUnits;
                obj.Children(i).EnrgyUnits=obj.EnrgyUnits;
            end
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


        function FullSignalName=get.FullSignalName(obj)
            if isempty(obj.Parent)
                obj.FullSignalName=obj.Name;
            elseif~isa(obj.Parent,'autoblks.pwr.Signal')
                obj.FullSignalName=obj.Name;
            else
                obj.FullSignalName=[obj.Parent.FullSignalName,'.',obj.Name];
            end
            FullSignalName=obj.FullSignalName;
        end
    end


    methods(Hidden=true)

        function DataSum=getEnrgySum(obj,Type)
            if isempty(obj.Children)
                switch Type
                case 'Pwr'
                    DataSum=obj.PwrData;
                    DataSum.Data=autoblksunitconv(DataSum.Data,'W',obj.PwrUnits);
                    DataSum.DataInfo.Units=Simulink.SimulationData.Unit(obj.PwrUnits);
                case 'Enrgy'
                    DataSum=obj.EnrgyData;
                    DataSum.Data=autoblksunitconv(DataSum.Data,'J',obj.EnrgyUnits);
                    DataSum.DataInfo.Units=Simulink.SimulationData.Unit(obj.EnrgyUnits);
                case 'FinalEnrgy'
                    DataSum=obj.FinalEnrgyData;
                    DataSum=autoblksunitconv(DataSum,'J',obj.EnrgyUnits);
                end

            else
                SumObj=sum(obj.Children);
                SumObj.PwrUnits=obj.PwrUnits;
                SumObj.EnrgyUnits=obj.EnrgyUnits;
                DataSum=SumObj.getEnrgySum(Type);

            end
        end


        function ChildList=getChildSignalList(obj)
            if~isempty(obj.Children)
                ChildList=obj.Children(1).getChildSignalList;
                for i=2:length(obj.Children)
                    ChildList=[ChildList,obj.Children(i).getChildSignalList];
                end
            else
                ChildList=obj;
            end

        end


        function SignalSummary=getSignalSummary(obj)
            if isempty(obj)
                SignalSummary=struct('FullName',{},'Name',{},'Description',{});
            else
                SignalSummary.FullName=obj.FullSignalName;
                SignalSummary.Name=obj.Name;
                SignalSummary.Description=obj.Description;

                for i=1:length(obj.Children)
                    SignalSummary=[SignalSummary;obj.Children(i).getSignalSummary];
                end
            end
        end


        function AddPwrSignalData(obj,PwrSignalData)
            if isstruct(PwrSignalData)
                ChildNames=fieldnames(PwrSignalData);
                for i=1:length(obj.Children)
                    [~,IA]=intersect(ChildNames,obj.Children(i).Name);
                    if~isempty(IA)
                        obj.Children(i).AddPwrSignalData(PwrSignalData.(ChildNames{IA(1)}));
                    end
                end
            elseif~isempty(PwrSignalData)
                if all(size(PwrSignalData.Data)>1)
                    ParentObj=obj.Parent;
                    for i=1:length(ParentObj.Children)
                        if isequal(obj,ParentObj.Children)
                            CurrData=PwrSignalData;
                            CurrData.Data=CurrData.Data(:,1);
                            obj.AddPwrSignalData(CurrData);
                            BaseName=obj.Name;
                            obj.Name=[BaseName,num2str(1)];
                            for j=2:size(PwrSignalData.Data,2)
                                CurrData=PwrSignalData;
                                CurrData.Data=CurrData.Data(:,j);
                                NewSignal=obj.copy;
                                idx=i+j-2;
                                ParentObj.Children=[ParentObj.Children(1:idx);NewSignal;ParentObj.Children((idx+1):end)];
                                NewSignal.AddPwrSignalData(CurrData);
                                NewSignal.Name=[BaseName,num2str(j)];
                            end

                            break;
                        end
                    end
                else
                    obj.PwrData=PwrSignalData;
                    obj.PwrData.Data=squeeze(obj.PwrData.Data);
                    [obj.EnrgyData,obj.FinalEnrgyData]=autoblksIntegrateTimeseries(obj.PwrData);
                end
            end
        end


        function SummaryTbl=tableSummary(obj)
            Signal={obj.Description};
            Total=obj.FinalEnrgy;
            Positive=obj.PwrPositive.FinalEnrgy;
            Negative=obj.PwrNegative.FinalEnrgy;
            for i=1:length(obj.Children)
                ChildTbl=obj.Children(i).tableSummary;
                ChildSignal=cellstr(ChildTbl.Signal);
                for j=1:size(ChildTbl,1)
                    Signal=[Signal;['  ',ChildSignal{j}]];
                end
                Total=[Total;ChildTbl.Total];
                Positive=[Positive;ChildTbl.Positive];
                Negative=[Negative;ChildTbl.Negative];
            end

            SummaryTbl=table(Signal,Total,Positive,Negative);
        end


        function PwrDataset=getPwrDataset(obj,BlkPath)

            if nargin<2
                BlkPath=[];
            end


            if isempty(obj.Children)
                PwrTimeseries=obj.Pwr;
                if all(PwrTimeseries.Data==0)
                    PwrDataset=[];
                else
                    PwrDataset=Simulink.SimulationData.Signal;
                    if~isempty(BlkPath)
                        PwrDataset.BlockPath=BlkPath;
                    end
                    PwrDataset.PortType='outport';
                    PwrDataset.Name=obj.DescriptionWithPwrUnits;
                    PwrTimeseries.Name=PwrDataset.Name;
                    PwrDataset.Values=PwrTimeseries;
                end
            else
                PwrDataset=Simulink.SimulationData.Dataset;
                PwrDataset.Name=obj.Description;
                for i=1:length(obj.Children)
                    ChildPwrDataset=obj.Children(i).getPwrDataset(BlkPath);
                    if~isempty(ChildPwrDataset)
                        PwrDataset=PwrDataset.addElement(ChildPwrDataset);
                    end
                end
            end
        end


        function EnrgyDataset=getEnrgyDataset(obj,BlkPath)

            if nargin<2
                BlkPath=[];
            end


            if isempty(obj.Children)
                EnrgyTimeseries=obj.Enrgy;
                if all(EnrgyTimeseries.Data==0)
                    EnrgyDataset=[];
                else
                    EnrgyDataset=Simulink.SimulationData.Signal;
                    if~isempty(BlkPath)
                        EnrgyDataset.BlockPath=BlkPath;
                    end
                    EnrgyDataset.PortType='outport';
                    EnrgyDataset.Name=obj.DescriptionWithEnrgyUnits;
                    EnrgyTimeseries.Name=EnrgyDataset.Name;
                    EnrgyDataset.Values=EnrgyTimeseries;
                end
            else
                EnrgyDataset=Simulink.SimulationData.Dataset;
                EnrgyDataset.Name=obj.Description;
                for i=1:length(obj.Children)
                    ChildEnrgyDataset=obj.Children(i).getEnrgyDataset(BlkPath);
                    if~isempty(ChildEnrgyDataset)
                        EnrgyDataset=EnrgyDataset.addElement(ChildEnrgyDataset);
                    end
                end
            end
        end
    end


    methods

        function Val=plus(obj,obj2)
            Val=addSubtractVal(obj,obj2,true);
        end


        function Val=minus(obj,obj2)
            Val=addSubtractVal(obj,obj2,false);
        end


        function Val=uminus(objs)
            Val=autoblks.pwr.Signal.empty;
            for i=1:length(objs)
                Val(i)=objs(i).copy;
                for j=1:length(Val(i).Children)
                    Val(i).Children(j)=-Val(i).Children(j);
                end
                if isempty(Val(i).Children)
                    Val(i).PwrData.Data=-Val(i).PwrData.Data;
                    Val(i).EnrgyData.Data=-Val(i).EnrgyData.Data;
                    Val(i).FinalEnrgyData=-Val(i).FinalEnrgyData;
                end
            end
        end


        function Val=sum(objs)
            if~isempty(objs)
                Val=autoblks.pwr.Signal;
                PwrTimeSeries=objs(1).Pwr;
                PwrTimeSeries.Data=autoblksunitconv(PwrTimeSeries.Data,objs(1).PwrUnits,'W');
                EnrgyTimeSeries=objs(1).Enrgy;
                EnrgyTimeSeries.Data=autoblksunitconv(EnrgyTimeSeries.Data,objs(1).EnrgyUnits,'J');
                Val.PwrData=PwrTimeSeries;
                Val.EnrgyData=EnrgyTimeSeries;
                Val.FinalEnrgyData=Val.EnrgyData.Data(end);
                Val.Name='signal';
                Val.PwrUnits=objs(1).PwrUnits;
                Val.EnrgyUnits=objs(1).EnrgyUnits;

                for i=2:length(objs)
                    Val=Val+objs(i);
                end
            else
                Val=autoblks.pwr.Signal.empty;
            end

        end
    end


    methods(Access=protected,Hidden=true)

        function SignalHierarchy=GetSignalHierarchy(obj,DestPortHdl)
            SignalHierarchy=get_param(DestPortHdl,'SignalHierarchy');
            if isempty(SignalHierarchy)
                return;
            end
            if isempty(SignalHierarchy.SignalName)
                TopSignalObj=obj;
                LineHdl=get_param(DestPortHdl,'Line');
                SrcPortHdl=get_param(LineHdl,'SrcPortHandle');
                ParentBlkName=get_param(DestPortHdl,'Parent');
                if strcmp(get_param(ParentBlkName,'BlockType'),'BusCreator')
                    AllPortHdls=get_param(ParentBlkName,'PortHandles');
                    ParentSignalHierarchy=get_param(AllPortHdls.Outport(1),'SignalHierarchy');
                    SignalHierarchy=ParentSignalHierarchy.Children(get_param(DestPortHdl,'PortNumber'));
                end
            end

        end


        function Signal=getSignalFromDir(obj,Dir)
            Signal=obj.copy;

            if isempty(Signal.Children)
                if strcmp(Dir,'Positive')
                    Signal.PwrData.Data=max(Signal.PwrData.Data,0);
                else
                    Signal.PwrData.Data=min(Signal.PwrData.Data,0);
                end
                [Signal.EnrgyData,Signal.FinalEnrgyData]=autoblksIntegrateTimeseries(Signal.PwrData);
            else
                OldChildSignals=Signal.Children;
                Signal.Children=autoblks.pwr.Signal.empty;
                idx=1;
                for i=1:length(OldChildSignals)
                    CheckChildSignal=OldChildSignals(i).getSignalFromDir(Dir);
                    if~isempty(CheckChildSignal)
                        Signal.Children(idx)=OldChildSignals(i).getSignalFromDir(Dir);
                        idx=idx+1;
                    end
                end
                if isempty(Signal.Children)
                    Signal=autoblks.pwr.Signal.empty;
                end
            end

        end


        function Val=addSubtractVal(obj,obj2,AddVal)
            Val=autoblks.pwr.Signal;
            Val.Name='signal';
            Val.Description='';

            PwrTimeSeries1=obj.Pwr;
            PwrTimeSeries1.Data=autoblksunitconv(PwrTimeSeries1.Data,obj.PwrUnits,'W');
            PwrTimeSeries2=obj2.Pwr;
            PwrTimeSeries2.Data=autoblksunitconv(PwrTimeSeries2.Data,obj2.PwrUnits,'W');

            EnrgyTimeSeries1=obj.Enrgy;
            EnrgyTimeSeries1.Data=autoblksunitconv(EnrgyTimeSeries1.Data,obj.EnrgyUnits,'J');
            EnrgyTimeSeries2=obj2.Enrgy;
            EnrgyTimeSeries2.Data=autoblksunitconv(EnrgyTimeSeries2.Data,obj2.EnrgyUnits,'J');


            [PwrTimeSeries1,PwrTimeSeries2]=autoblksMatchTimeseriesTime(PwrTimeSeries1,PwrTimeSeries2);
            [EnrgyTimeSeries1,EnrgyTimeSeries2]=autoblksMatchTimeseriesTime(EnrgyTimeSeries1,EnrgyTimeSeries2);


            if AddVal
                Val.PwrData=PwrTimeSeries1+PwrTimeSeries2;
                Val.EnrgyData=EnrgyTimeSeries1+EnrgyTimeSeries2;
            else
                Val.PwrData=PwrTimeSeries1-PwrTimeSeries2;
                Val.EnrgyData=EnrgyTimeSeries1-EnrgyTimeSeries2;
            end
            Val.PwrData.DataInfo.Units=Simulink.SimulationData.Unit('W');
            Val.EnrgyData.DataInfo.Units=Simulink.SimulationData.Unit('J');

            Val.FinalEnrgyData=Val.EnrgyData.Data(end);
            Val.PwrUnits=obj.PwrUnits;
            Val.EnrgyUnits=obj.EnrgyUnits;
        end


        function setChildUnits(obj,Unit,UnitParamName)
            for i=1:length(obj.Children)
                obj.Children(i).(UnitParamName)=Unit;
                obj.Children(i).setChildUnits(Unit,UnitParamName);
            end
        end
    end
end



