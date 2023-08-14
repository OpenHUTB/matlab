function[varargout]=autoblksfundflwcv(varargin)






    varargout{1}=0;

    Block=varargin{1};
    BlkHdl=get_param(Block,'Handle');
    context=varargin{2};

    switch context
    case 'FundFlwCvHeatPopupCallback'
        FundFlwCvTypePopupCallback(BlkHdl);
    case 'DrawCommands'
        varargout{1}=DrawCommands(BlkHdl);
    case 'Initialization'
        varargout{1}=Initialization(Block,BlkHdl);
    end
end

function ParamStruct=Initialization(Block,BlkHdl)

    fundflwblk_names={'autolibfundflwcommon/HeatTrnsfr Constant Input','HeatTrnsfr Constant Input'
    'autolibfundflwcommon/HeatTrnsfr External Input','HeatTrnsfr External Input'
    'autolibfundflwcommon/HeatTrnsfr External Wall Convection','HeatTrnsfr External Wall Convection'};

    switch get_param(BlkHdl,'HeatTransferModelPopup')
    case 'Constant'
        autoblksreplaceblock(BlkHdl,fundflwblk_names,1);
    case 'External input'
        autoblksreplaceblock(BlkHdl,fundflwblk_names,2);
    case 'External wall convection'
        autoblksreplaceblock(BlkHdl,fundflwblk_names,3);
    end


    NumInlet=str2double(get_param(Block,'NumInletPorts'));
    NumOutlet=str2double(get_param(Block,'NumOutletPorts'));
    SetupPorts(Block,'Inlet',NumInlet);
    SetupPorts(Block,'Outlet',NumOutlet);


    if NumInlet>0&&NumOutlet>0
        ActiveVariant='InletAndOutlet';
    elseif NumOutlet>0
        ActiveVariant='OutletOnly';
    else
        ActiveVariant='InletOnly';
    end
    set_param([Block,'/Sum Flow/Power Heat Flow Array'],'LabelModeActiveChoice',ActiveVariant)


    setupPwrTrnsfrdBus([Block,'/Control Volume Reformatted/PwrTrnsfrd Bus'],NumInlet,NumOutlet);


    MassFracBlkNames={'autolibfundflwcommon/Single Species','Single Species'
    'autolibfundflwcommon/Mass Fraction Integration','Mass Fraction Integration'};
    MassFracIntBlkName=[Block,'/Control Volume Reformatted/Control Volume/Mass Fractions'];
    MassFracInfo=autoblkssetupengflwmassfrac(BlkHdl);


    AvailMassFrac=autoblkssetupengflwmassfrac(BlkHdl,'GetAllMassFracs');
    ParamStruct.NumMassFrac=length(AvailMassFrac);
    ParamStruct.NumInletPorts=max(NumInlet,1);
    ParamStruct.NumOutletPorts=max(NumOutlet,1);


    if~isempty(MassFracInfo)
        ParamStruct.AirO2MassFrac=MassFracInfo.AirO2MassFrac;
        if length(MassFracInfo.MassFracs)==1
            ParamStruct.MassFracIdx=1;
            ParamStruct.MassFracInitCond=1;
            ParamStruct.MassFracNames=MassFracInfo.MassFracs;
            ParamStruct.MassFracInitCond=1;
            autoblksreplaceblock(MassFracIntBlkName,MassFracBlkNames,1);
        else
            ParamStruct.MassFracNames=MassFracInfo.MassFracs;
            ParamStruct.MassFracInitCond=MassFracInfo.MassFracInitCond;








            ParamStruct.MassFracInitCond=ParamStruct.MassFracInitCond;
            [~,~,IMassFrac]=intersect(ParamStruct.MassFracNames,AvailMassFrac,'stable');
            ParamStruct.MassFracIdx=IMassFrac;
            autoblksreplaceblock(MassFracIntBlkName,MassFracBlkNames,2);
        end
    end


    ParamList={...
    'Vch',[1,1],{'gt',0};...
    'Pinit',[1,1],{'gt',0;'lt',500000};...
    'Tinit',[1,1],{'gt',0;'lt',2000};...
    'R',[1,1],{'gt',200;'lt',400};...
    'cp',[1,1],{'gt',0;'lt',5000};...
    'm_wall',[1,1],{'gt',0};...
    'cp_wall',[1,1],{'gt',0};...
    'Dint_cond',[1,1],{'gt',0};...
    'Aint_cond',[1,1],{'gt',0};...
    'kint',[1,1],{'gt',0};...
    'Aint_conv',[1,1],{'gt',0};...
    'Dext_cond',[1,1],{'gt',0};...
    'Aext_cond',[1,1],{'gt',0};...
    'kext',[1,1],{'gt',0};...
    'Aext_conv',[1,1],{'gt',0};...
    'Tmass',[1,1],{'gt',0};...
    'q_he',[1,1],{};...
    };

    IntrnBp(1,1:2)={'int_bpts',{}};
    ExtrnBp(1,1:2)={'ext_bpts',{}};

    LookupTblList={...
    IntrnBp,'int_tbl',{'gt',0};...
    ExtrnBp,'ext_tbl',{'gt',0};...
    };

    autoblkscheckparams(Block,ParamList,LookupTblList);

end


function FundFlwCvTypePopupCallback(BlkHdl)
    popupParent='HeatTransferModelPopup';
    popupValue=get_param(BlkHdl,popupParent);
    switch popupValue
    case 'Constant'
        autoblksenableparameters(BlkHdl,[],[],{'ConstHeatTransferContainer','HeatTransferTab'},'ExternalConvectionContainer');
    case 'External input'
        autoblksenableparameters(BlkHdl,[],[],[],{'ConstHeatTransferContainer','ExternalConvectionContainer','HeatTransferTab'});
    case 'External wall convection'
        autoblksenableparameters(BlkHdl,[],[],{'ExternalConvectionContainer','HeatTransferTab'},'ConstHeatTransferContainer');
    end
end

function IconInfo=DrawCommands(BlkHdl)
    AliasNames={'Inlet1','C';'Outlet1','C';'Inlet2','C';'Outlet2',...
    'C';'Inlet3','C';'Outlet3','C';'Inlet4','C';'Outlet4','C'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);
    switch get_param(BlkHdl,'ImageTypePopup')
    case 'Cold'
        IconInfo.ImageName='control_volume_cold.png';
    case 'Hot'
        IconInfo.ImageName='control_volume_hot.png';
    end
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,5,40,'white');
end


function[popupValue]=getPopupValue(BlkHdl,popupParent)
    popupPref='blkPrm_';
    lpar=length(popupParent);
    lpre=length(popupPref);
    h1=get_param(BlkHdl,popupParent);
    h2=strfind(h1,':');
    if isempty(h2)
        popupValue=h1;
    else
        h3=h1(h2(2)+1:end);
        if strfind(h3,'blkPrm_')==1
            popupValue=h3(lpar+lpre+1:end);
        end
    end
end


function SetupPorts(Block,TypePort,NumPorts)

    PortSubName=[Block,'/',TypePort,' Ports'];
    PMIOPorts=find_system(PortSubName,'SearchDepth',1,'BlockType','PMIOPort');
    CurrentNumPorts=length(PMIOPorts);
    if CurrentNumPorts==NumPorts
        return
    end
    PortSubHdl=get_param(PortSubName,'Handle');
    MassMuxName=[PortSubName,'/Mass Flow Rate Mux'];
    HeatMuxName=[PortSubName,'/Heat Flow Rate Mux'];
    MassFracConcatName=[PortSubName,'/Mass Fraction Concatenate'];

    Port1Name=[PortSubName,'/',TypePort,' Port 1'];
    Port1Pos=get_param(Port1Name,'Position');
    BlkHieght=Port1Pos(4)-Port1Pos(2);


    OldConns=autoblksgetblockconn(PortSubHdl);


    for i=1:length(OldConns.Inports)
        delete_line(OldConns.Inports(i).LineHdl);
    end


    for i=1:length(OldConns.Outports)
        delete_line(OldConns.Outports(i).LineHdl);
    end


    for i=1:length(OldConns.LConns)
        delete_line(OldConns.LConns(i).LineHdl);
    end
    for i=1:length(OldConns.RConns)
        delete_line(OldConns.RConns(i).LineHdl);
    end


    if CurrentNumPorts==0
        delete_block(Port1Name);
        delete_line(find_system(PortSubName,'SearchDepth',1,'FindAll','on','Type','line','SrcPortHandle',-1))
        delete_line(find_system(PortSubName,'SearchDepth',1,'FindAll','on','Type','line','DstPortHandle',-1))
    end


    if CurrentNumPorts<NumPorts
        SetupPortMux(MassMuxName,NumPorts)
        SetupPortMux(HeatMuxName,NumPorts)
        SetupPortConcat(MassFracConcatName,NumPorts)

        for i=(CurrentNumPorts+1):NumPorts
            PortPos=Port1Pos;
            PortPos(2)=(i-1)*(BlkHieght+30)+Port1Pos(2);
            PortPos(4)=PortPos(2)+BlkHieght;
            NewPortName=[TypePort,' Port ',num2str(i)];
            add_block('autolibfundflwcommon/Volume Port',[PortSubName,'/',NewPortName],'Position',PortPos)
            add_line(PortSubName,[NewPortName,'/1'],['Mass Flow Rate Mux/',num2str(i)])
            add_line(PortSubName,[NewPortName,'/2'],['Heat Flow Rate Mux/',num2str(i)])
            add_line(PortSubName,[NewPortName,'/3'],['Mass Fraction Concatenate/',num2str(i)])
            add_line(PortSubName,'VolBus/1',[NewPortName,'/1'])
            AddPMIOPort([PortSubName,'/',NewPortName],TypePort,i)
        end
    elseif CurrentNumPorts>NumPorts

        for i=(NumPorts+1):CurrentNumPorts
            delete_block([PortSubName,'/',TypePort,' Port ',num2str(i)])
            delete_block([PortSubName,'/',TypePort,num2str(i)]);
        end
        SetupPortMux(MassMuxName,NumPorts)
        SetupPortMux(HeatMuxName,NumPorts)
        SetupPortConcat(MassFracConcatName,NumPorts)


        delete_line(find_system(PortSubName,'SearchDepth',1,'FindAll','on','Type','line','SrcPortHandle',-1))
        delete_line(find_system(PortSubName,'SearchDepth',1,'FindAll','on','Type','line','DstPortHandle',-1))
    end


    if NumPorts==0
        ClosedPortName=[TypePort,' Port 1'];
        add_block('autolibfundflwcommon/Closed Volume Port',Port1Name,'Position',Port1Pos);
        add_line(PortSubName,[ClosedPortName,'/1'],['Mass Flow Rate Mux/',num2str(1)])
        add_line(PortSubName,[ClosedPortName,'/2'],['Heat Flow Rate Mux/',num2str(1)])
        add_line(PortSubName,[ClosedPortName,'/3'],['Mass Fraction Concatenate/',num2str(i)])
        add_line(PortSubName,'VolBus/1',[ClosedPortName,'/1'])
    end


    autoblksreconnectblock(PortSubHdl,OldConns)

end


function setupPwrTrnsfrdBus(BusSetupBlk,NumInlet,NumOutlet)

    BusCreatorBlk=[BusSetupBlk,'/Bus Creator'];
    DemuxBlk=[BusSetupBlk,'/Demux'];
    NumTotal=max(NumInlet+NumOutlet,1);
    if NumInlet<1&&NumOutlet<1
        NumInlet=1;
    end
    CurrNumTotal=str2double(get_param(BusCreatorBlk,'Inputs'));

    if NumTotal~=CurrNumTotal

        DemuxPortHdl=get_param(DemuxBlk,'PortHandles');
        DemuxPortLines=get_param(DemuxPortHdl.Outport,'Line');
        if~iscell(DemuxPortLines)
            DemuxPortLines={DemuxPortLines};
        end
        for i=1:length(DemuxPortLines)
            if ishandle(DemuxPortLines{i})
                delete_line(DemuxPortLines{i})
            end
        end


        set_param(BusCreatorBlk,'Inputs',num2str(NumTotal));
        set_param(DemuxBlk,'Outputs',num2str(NumTotal));
    end


    DemuxPortHdl=get_param(DemuxBlk,'PortHandles');
    BusCreatorPortHdl=get_param(BusCreatorBlk,'PortHandles');
    DemuxOutport=DemuxPortHdl.Outport;
    BusInport=BusCreatorPortHdl.Inport;


    LineHdl=zeros(1,NumTotal);
    for i=1:NumTotal
        LineHdl(i)=get_param(DemuxOutport(i),'Line');
        if~ishandle(LineHdl(i))
            LineHdl(i)=add_line(BusSetupBlk,DemuxOutport(i),BusInport(i));
        end
    end


    InletIdx=1;
    OutletIdx=1;
    for PortIdx=1:NumTotal
        NewPortName=['PwrHeatFlw',num2str(PortIdx)];
        OldPortName=get_param(LineHdl(PortIdx),'Name');
        if~strcmp(NewPortName,OldPortName)
            set_param(LineHdl(PortIdx),'Name',NewPortName)
        end

        OldDesc=get_param(LineHdl(PortIdx),'Description');
        if PortIdx<=NumInlet
            NewDesc=['Port ',num2str(PortIdx),' heat flow',newline,'Inlet',num2str(InletIdx)];
            InletIdx=InletIdx+1;
        else
            NewDesc=['Port ',num2str(PortIdx),' heat flow',newline,'Outlet',num2str(OutletIdx)];
            OutletIdx=OutletIdx+1;
        end
        if~strcmp(OldDesc,NewDesc)
            set_param(LineHdl(PortIdx),'Description',NewDesc)
        end
    end
end

function SetupPortMux(MuxName,NumInputs)
    NumInputs=max(1,NumInputs);
    MuxPos=get_param(MuxName,'Position');
    MuxPos(4)=MuxPos(2)+10*NumInputs+30;
    set_param(MuxName,'Inputs',num2str(NumInputs))
    set_param(MuxName,'Position',MuxPos)
end

function SetupPortConcat(ConcatName,NumInputs)
    NumInputs=max(1,NumInputs);
    MuxPos=get_param(ConcatName,'Position');
    MuxPos(4)=MuxPos(2)+10*NumInputs+30;
    set_param(ConcatName,'NumInputs',num2str(NumInputs))
    set_param(ConcatName,'Position',MuxPos)
end

function AddPMIOPort(ConnBlkName,TypePort,PortNum)
    BlkH=14;
    BlkW=30;
    if strcmp(TypePort,'Inlet')
        PortSide='Left';
    elseif strcmp(TypePort,'Outlet')
        PortSide='Right';
    end
    PortHdls=get_param(ConnBlkName,'PortHandles');
    PortPos=get_param(PortHdls.LConn,'Position');
    BlkPosStart=[PortPos(1)-BlkW-30,PortPos(2)-BlkH/2];
    BlkPos=[BlkPosStart,BlkPosStart+[BlkW,BlkH]];

    Parent=get_param(ConnBlkName,'Parent');
    NewBlkName=[Parent,'/',TypePort,num2str(PortNum)];
    add_block('built-in/PMIOPort',NewBlkName,'Side',PortSide,'Position',BlkPos,'Port',num2str(PortNum))

    PMIOPortHdls=get_param(NewBlkName,'PortHandles');
    add_line(Parent,PortHdls.LConn(1),PMIOPortHdls.RConn(1))

end
