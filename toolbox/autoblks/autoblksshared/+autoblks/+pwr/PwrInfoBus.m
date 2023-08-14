classdef(Hidden)PwrInfoBus<handle





    properties
        PwrUnits char='kW';
        EnrgyUnits char='MJ';
    end


    properties(SetAccess=protected)
BlkName
FullBlkPath


        PwrTrnsfrdSignal autoblks.pwr.PwrInfoBusSignal
        PwrNotTrnsfrdSignal autoblks.pwr.PwrInfoBusSignal
        PwrStoredSignal autoblks.pwr.PwrInfoBusSignal


        AssctPortMap containers.Map

    end

    properties(SetAccess=protected,Hidden=true)

    end


    methods

        function obj=PwrInfoBus(BlkName)

            if iscell(BlkName)
                obj.FullBlkPath=BlkName;
            else
                obj.BlkName=BlkName;
                obj.FullBlkPath=cellstr(BlkName);
            end
        end


        function ShowDialog(obj)
            FigOpen=findOpenDialog(obj);

            if isempty(FigOpen)
                autoblks.pwr.PwrBusUtilUi(obj.BlkName,obj);
            else
                FigOpen.Visible='off';
                FigOpen.Visible='on';
            end
        end


        function CloseDialog(obj)
            FigOpen=findOpenDialog(obj);
            if~isempty(FigOpen)
                delete(FigOpen)
            end
        end


        function[AssctBlkName,FullPathName]=getAssctBlkName(obj)
            AssctBlkName='';
            FullPathName='';

            switch get_param(obj.BlkName,'AssctBlkSelPopup')
            case 'Parent'
                AssctBlkName=get_param(obj.BlkName,'Parent');
            case 'Parent reference block'
                SysNotFound=true;
                SysCannotBeFound=false;
                CurrBlk=obj.BlkName;
                RefBlkName=GetWsVar(obj.BlkName,'RefBlkName');
                while SysNotFound&&~SysCannotBeFound
                    CurrBlk=get_param(CurrBlk,'Parent');
                    if~strcmp(get_param(CurrBlk,'Type'),'block_diagram')
                        if strcmp(get_param(CurrBlk,'ReferenceBlock'),RefBlkName)||isempty(CurrBlk)||strcmp(get_param(CurrBlk,'ReferenceBlock'),'vehdynlibeom/Vehicle Body 3DOF Three Axles')||strcmp(get_param(CurrBlk,'ReferenceBlock'),'vehdynlibeom/Trailer Body 3DOF')
                            SysNotFound=false;
                            AssctBlkName=CurrBlk;
                        end
                    else
                        SysCannotBeFound=true;
                        SysNotFound=false;
                    end

                end

                if SysCannotBeFound
                    error(message('autoblks_shared:autoerrPwrInfoBus:assctBlkNotFound',autoblksMdlHyperlink(obj.BlkName)));
                end
            end

            if~isempty(AssctBlkName)
                if length(obj.FullBlkPath)>1
                    FullPathName=[obj.FullBlkPath(1:end-1),AssctBlkName];
                else
                    FullPathName=cellstr(AssctBlkName);
                end
            end
        end


        function loggingOn(obj)
            ph=get_param(obj.BlkName,'PortHandles');
            set_param(ph.Outport(1),'DataLogging','on')
        end


        function loggingOff(obj)
            ph=get_param(obj.BlkName,'PortHandles');
            set_param(ph.Outport(1),'DataLogging','off')
        end





        function addLoggedData(obj,LoggedData)

            FoundIdx=0;
            for i=1:LoggedData.numElements
                if strcmp(strrep(LoggedData{i}.BlockPath.getBlock(LoggedData{i}.BlockPath.getLength),newline,' '),strrep(obj.FullBlkPath{end},newline,' '))
                    FoundIdx=i;
                    break;
                end
            end

            if FoundIdx>0
                if LoggedData.numElements>=1
                    LoggedData=LoggedData{FoundIdx}.Values;
                    LoggedData=expandScalarTimeseries(LoggedData);
                    if isfield(LoggedData,'PwrTrnsfrd')
                        obj.PwrTrnsfrdSignal.AddPwrSignalData(LoggedData.('PwrTrnsfrd'))
                    end
                    if isfield(LoggedData,'PwrNotTrnsfrd')
                        obj.PwrNotTrnsfrdSignal.AddPwrSignalData(LoggedData.('PwrNotTrnsfrd'))
                    end
                    if isfield(LoggedData,'PwrStored')
                        obj.PwrStoredSignal.AddPwrSignalData(LoggedData.('PwrStored'))
                    end
                end
            else
                AssctBlkName=obj.getAssctBlkName;
                error(message('autoblks_shared:autoerrPwrInfoBus:noDataLogged',autoblksMdlHyperlink(AssctBlkName)));
            end
        end


        function GetInputSignals(obj)
            PortHdls=get_param([obj.BlkName,'/Bus Creator'],'PortHandles');
            PortHdls=PortHdls.Inport;
            InportNames=get_param(PortHdls,'Name');
            [~,TrnsfrdIdx]=intersect(InportNames,'PwrTrnsfrd');
            [~,NotTrnsfrdIdx]=intersect(InportNames,'PwrNotTrnsfrd');
            [~,StoredIdx]=intersect(InportNames,'PwrStored');
            obj.PwrTrnsfrdSignal=autoblks.pwr.PwrInfoBusSignal.empty;
            obj.PwrNotTrnsfrdSignal=autoblks.pwr.PwrInfoBusSignal.empty;
            obj.PwrStoredSignal=autoblks.pwr.PwrInfoBusSignal.empty;
            if~isempty(TrnsfrdIdx)
                obj.PwrTrnsfrdSignal=autoblks.pwr.PwrInfoBusSignal(PortHdls(TrnsfrdIdx),obj);
                obj.PwrTrnsfrdSignal.Name='PwrTrnsfrd';
                obj.PwrTrnsfrdSignal.Description=getString(message('autoblks_shared:autoblkPwrInfoBus:descTrans'));
            end
            if~isempty(NotTrnsfrdIdx)
                obj.PwrNotTrnsfrdSignal=autoblks.pwr.PwrInfoBusSignal(PortHdls(NotTrnsfrdIdx),obj);
                obj.PwrNotTrnsfrdSignal.Name='PwrNotTrnsfrd';
                obj.PwrNotTrnsfrdSignal.Description=getString(message('autoblks_shared:autoblkPwrInfoBus:descNotTrans'));
            end
            if~isempty(StoredIdx)
                obj.PwrStoredSignal=autoblks.pwr.PwrInfoBusSignal(PortHdls(StoredIdx),obj);
                obj.PwrStoredSignal.Name='PwrStored';
                obj.PwrStoredSignal.Description=getString(message('autoblks_shared:autoblkPwrInfoBus:descStored'));
            end


            TransfrdPwrChildSignals=obj.PwrTrnsfrdSignal.getChildSignalList;
            obj.AssctPortMap=containers.Map;

            for i=1:length(TransfrdPwrChildSignals)
                LineHdl=TransfrdPwrChildSignals(i).NameLineHdl;
                if ishandle(LineHdl)
                    TaggedPortNames=TransfrdPwrChildSignals(i).getDescLine(2);
                    if isempty(TaggedPortNames)
                        TaggedPortNames={};
                    else
                        try
                            TaggedPortNames=eval(TaggedPortNames);
                        catch
                        end
                    end
                    if~isempty(TaggedPortNames)
                        obj.AssctPortMap(TransfrdPwrChildSignals(i).FullSignalName)=TaggedPortNames;
                    end
                end
            end

        end


        function SignalSummary=getTrnsfrdSignalSummary(obj)
            SignalSummary=obj.PwrTrnsfrdSignal.getSignalSummary;
            SignalSummary=obj.addAssctPortToSummary(SignalSummary);
        end


        function set.FullBlkPath(obj,FullBlkPath)
            obj.FullBlkPath=cellstr(FullBlkPath);
            obj.BlkName=obj.FullBlkPath{end};
        end


        function set.PwrUnits(obj,Unit)
            autoblksunitconv(1,'W',Unit);
            obj.PwrUnits=Unit;
            if~isempty(obj.PwrTrnsfrdSignal)
                obj.PwrTrnsfrdSignal.PwrUnits=obj.PwrUnits;
            end
            if~isempty(obj.PwrNotTrnsfrdSignal)
                obj.PwrNotTrnsfrdSignal.PwrUnits=obj.PwrUnits;
            end
            if~isempty(obj.PwrStoredSignal)
                obj.PwrStoredSignal.PwrUnits=obj.PwrUnits;
            end
        end


        function set.EnrgyUnits(obj,Unit)
            autoblksunitconv(1,'J',Unit);
            obj.EnrgyUnits=Unit;

            if~isempty(obj.PwrTrnsfrdSignal)
                obj.PwrTrnsfrdSignal.EnrgyUnits=obj.EnrgyUnits;
            end
            if~isempty(obj.PwrNotTrnsfrdSignal)
                obj.PwrNotTrnsfrdSignal.EnrgyUnits=obj.EnrgyUnits;
            end
            if~isempty(obj.PwrStoredSignal)
                obj.PwrStoredSignal.EnrgyUnits=obj.EnrgyUnits;
            end
        end

    end


    methods(Access=private)

        function FigOpen=findOpenDialog(obj)
            FoundFigs=findall(0,'HandleVisibility','off');
            FigOpen=[];
            for i=1:length(FoundFigs)
                if isa(FoundFigs(i).UserData,'autoblks.pwr.PwrBusUtilUi')
                    if strcmp(FoundFigs(i).UserData.Blk,obj.BlkName)
                        FigOpen=FoundFigs(i);
                    end
                end
            end

        end


        function PortNames=getAllPortNames(obj)
            AssctBlkName=obj.getAssctBlkName;
            PortNames={};

            if~isempty(AssctBlkName)
                BlkHdl=get_param(AssctBlkName,'Handle');
                if~strcmp(get_param(BlkHdl,'Type'),'block_diagram')
                    PortInfo=autoblksgetportinfo(BlkHdl);
                    PortNames={PortInfo.Inports.Name,PortInfo.Outports.Name,PortInfo.LConns.Name,PortInfo.RConns.Name};
                end
            end
        end


        function SignalSummary=addAssctPortToSummary(obj,SignalSummary)


            AssctPortSignalNames=obj.AssctPortMap.keys;
            TransfrdPwrChildSignals=obj.PwrTrnsfrdSignal.getChildSignalList;
            ChildFullSignalNames={TransfrdPwrChildSignals.FullSignalName};


            for i=1:length(SignalSummary)
                [~,AssctPortI]=intersect(AssctPortSignalNames,SignalSummary(i).FullName);
                [~,ChildSignalI]=intersect(ChildFullSignalNames,SignalSummary(i).FullName);
                if~isempty(AssctPortI)
                    SignalSummary(i).AssctPort=TransfrdPwrChildSignals(ChildSignalI).getDescLine(2);
                elseif~isempty(ChildSignalI)
                    SignalSummary(i).AssctPort='';
                else
                    SignalSummary(i).AssctPort='<NA>';
                end
            end
        end
    end
end


function Value=GetWsVar(BlkName,ParamName)
    MaskObj=get_param(BlkName,'MaskObject');
    WsVars=MaskObj.getWorkspaceVariables;
    Value=WsVars(strcmp(ParamName,{WsVars.Name})).Value;
end


function Data=expandScalarTimeseries(Data,TimeArray)
    if nargin<2
        TimeArray=getLoggedDataTimeArray(Data);
    end
    if isstruct(Data)
        FieldNames=fieldnames(Data);
        for i=1:length(FieldNames)
            Data.(FieldNames{i})=expandScalarTimeseries(Data.(FieldNames{i}),TimeArray);
        end
    else
        if length(Data.Time)<=1
            NewData=repmat(Data.Data,1,length(TimeArray));
            set(Data,'Time',TimeArray,'Data',NewData);
        end
    end

end


function TimeArray=getLoggedDataTimeArray(Data)
    if isstruct(Data)
        FieldNames=fieldnames(Data);
        for i=1:length(FieldNames)
            TimeArray=getLoggedDataTimeArray(Data.(FieldNames{i}));
            if TimeArray(1)>-1
                break
            end
        end
    else
        if length(Data.Time)>1
            TimeArray=Data.Time;
        else
            TimeArray=-1;
        end
    end

end