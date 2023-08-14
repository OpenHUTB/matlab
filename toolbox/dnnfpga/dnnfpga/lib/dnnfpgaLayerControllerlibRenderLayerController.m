function dnnfpgaLayerControllerlibRenderLayerController(gcb,lc,kernelDataType)




    if(isempty(lc))
        return;
    end

    if(isempty(kernelDataType))
        return;
    end

    lcName='LayerController';
    lcPath=[gcb,'/',lcName];
    try
        lh=get_param(lcPath,'LineHandles');
        delete_block(lcPath);
        delete_line(lh.Inport);
        delete_line(lh.Outport);

        outPortName='layerConfig';
        createLCSubsytem(gcb,lc,kernelDataType);
    catch me
    end

    add_line(gcb,'D/1',[lcName,'/1'],'autorouting','on');
    add_line(gcb,'load/1',[lcName,'/2'],'autorouting','on');
    add_line(gcb,'stage/1',[lcName,'/3'],'autorouting','on');
    add_line(gcb,[lcName,'/1'],[outPortName,'/1'],'autorouting','on');

end

function createLCSubsytem(gcb,lc,kernelDataType)
    newGcb=[gcb,'/LayerController'];
    add_block('built-in/SubSystem',newGcb,'TreatAsAtomicUnit','off');

    add_block('built-in/InPort',[newGcb,'/D'],'Position',[-10,800,10,810]);
    add_block('built-in/InPort',[newGcb,'/load'],'Position',[-10,2000,10,2010]);
    add_block('built-in/InPort',[newGcb,'/stage'],'Position',[-10,3000,10,3010]);
    add_block('built-in/OutPort',[newGcb,'/layerConfig'],'Position',[1500,1500,1550,1520]);
    add_block('built-in/BusCreator',[newGcb,'/bus1'],'Position',[1330,100,1335,3050],'Inputs',num2str(length(lc)));

    depth=0;
    for i=1:length(lc)
        depth=depth+lc{i}.vectorType;
    end
    ssrName='SSR';
    drawSSRBlock(newGcb,depth);

    add_line(newGcb,'D/1',[ssrName,'/1'],'autorouting','on');
    add_line(newGcb,'load/1',[ssrName,'/2'],'autorouting','on');
    add_line(newGcb,'stage/1',[ssrName,'/3'],'autorouting','on');
    add_line(newGcb,'bus1/1','layerConfig/1','autorouting','on');




    prevParamSize=150;

    j=1;
    for i=1:length(lc)
        convertName=['convert',num2str(i)];
        muxPosition=[730,prevParamSize+50,735,prevParamSize+50+lc{i}.vectorType*15];
        prevParamSize=prevParamSize+50+lc{i}.vectorType*15;


        muxName=['mux',num2str(j)];
        add_block('built-in/mux',[newGcb,'/',muxName],'Position',muxPosition,...
        'DisplayOption','bar','Inputs',num2str(lc{i}.vectorType));


        switch lc{i}.dataType
        case 'single'

            add_block('hdlsllib/HDL Floating Point Operations/Float Typecast',[newGcb,'/',convertName],'Position',[1000,(i*70)+50,1100,(i*70)+85]);
        otherwise

            if(strcmp(lc{i}.name,'reLUValue')||strcmp(lc{i}.name,'avgpoolMultiplier')||strcmp(lc{i}.name,'gapMultiplier')||strcmp(lc{i}.name,'fcBias')||strcmp(lc{i}.name,'reLUScaleExp')||strcmp(lc{i}.name,'int32ToInt8Exp'))
                if(strcmp(kernelDataType,'single'))
                    add_block('hdlsllib/HDL Floating Point Operations/Float Typecast',[newGcb,'/',convertName],'Position',[1000,(i*70)+50,1100,(i*70)+85]);
                else
                    add_block('hdlsllib/HDL Floating Point Operations/Data Type Conversion',[newGcb,'/',convertName],...
                    'Position',[1000,(i*70)+50,1100,(i*70)+85],'ConvertRealWorld','Stored Integer (SI)','OutDataTypeStr',lc{i}.dataType);
                end
            else
                add_block('hdlsllib/HDL Floating Point Operations/Data Type Conversion',[newGcb,'/',convertName],...
                'Position',[1000,(i*70)+50,1100,(i*70)+85],'ConvertRealWorld','Stored Integer (SI)','OutDataTypeStr',lc{i}.dataType);
            end
        end


        if((i==8)&&(length(lc)>30))
            add_block('simulink/Signal Routing/Selector',[newGcb,'/Sel1'],'Position',[850,530,900,550],...
            'InputPortWidth',num2str(lc{i}.vectorType),'Indices','[1:ControlLogicOutputFeatureAddrIdx]');

            add_line(newGcb,[muxName,'/1'],'Sel1/1','autorouting','on');
            add_line(newGcb,'Sel1/1',[convertName,'/1'],'autorouting','on');
        else
            add_line(newGcb,[muxName,'/1'],[convertName,'/1'],'autorouting','on');
        end
        for k=1:lc{i}.vectorType
            add_line(newGcb,['SSR/',num2str(j)],[muxName,'/',num2str(k)],'autorouting','on');
            j=j+1;
        end
        add_line(newGcb,['convert',num2str(i),'/1'],['bus1/',num2str(i)],'autorouting','on');


        PortHandles=get_param([newGcb,'/',convertName],'PortHandles');
        set_param(PortHandles.Outport,'Name',lc{i}.name);

    end

end


function drawSSRBlock(curGcb,depth)
    createSubsystem([curGcb,'/SSR'],depth);
end

function curGcb=createSubsystem(curGcbOrig,depth)
    root=fileparts(curGcbOrig);


    h=add_block('built-in/SubSystem',curGcbOrig,'MakeNameUnique','on','TreatAsAtomicUnit','off','Position',[50,50,250,3800]);
    subBlockName=get_param(h,'name');
    curGcb=[root,'/',subBlockName];
    dPortPos=[20,163,50,177];
    loadPortPos=[20,133,50,147];
    stagePortPos=[20,23,50,37];

    VectorDelayPos=[295,55,335,115];
    demuxPos=[395,155,435,215];
    EnbTapDelayPos=[110,55,150,115];


    add_block('built-in/InPort',[curGcb,'/D'],'Position',dPortPos);
    add_block('built-in/InPort',[curGcb,'/load'],'Position',loadPortPos);
    add_block('built-in/InPort',[curGcb,'/stage'],'Position',stagePortPos);




    EnbTapDelaySubSysName='EnbTapDelaySubSys';
    EnbTapDelaySubSysPath=[curGcb,'/',EnbTapDelaySubSysName];


    hEnbSubsys=add_block('simulink/Ports & Subsystems/Enabled Subsystem',EnbTapDelaySubSysPath,'MakeNameUnique','on','TreatAsAtomicUnit','off','Position',EnbTapDelayPos);
    subBlockEnbSysName=get_param(hEnbSubsys,'name');
    curGcbEnbSub=[curGcb,'/',subBlockEnbSysName];


    statControl='StateControl';
    stateControlPath=[curGcbEnbSub,'/',statControl];
    add_block('hdlsllib/HDL Subsystems/State Control',stateControlPath);


    tapDelayName='tapDelay';
    tapDelayPath=[curGcbEnbSub,'/',tapDelayName];
    hTapDelay=add_block('simulink/Discrete/Tapped Delay',tapDelayPath);


    set_param(hTapDelay,'NumDelays',num2str(depth));
    set_param(hTapDelay,'DelayOrder','Newest');

    pEnbSubsys=get_param(hEnbSubsys,'PortHandles');

    hLoad=get_param([curGcb,'/load'],'Handle');
    pLoad=get_param(hLoad,'PortHandles');


    pTapDelay=get_param(hTapDelay,'PortHandles');

    hInPort=get_param([curGcbEnbSub,'/In1'],'Handle');
    pInPort=get_param(hInPort,'PortHandles');

    hOutPort=get_param([curGcbEnbSub,'/Out1'],'Handle');
    pOutPort=get_param(hOutPort,'PortHandles');


    delete_line(curGcbEnbSub,pInPort.Outport,pOutPort.Inport)


    add_line(curGcbEnbSub,pInPort.Outport,pTapDelay.Inport,'autorouting','on');
    add_line(curGcbEnbSub,pTapDelay.Outport,pOutPort.Inport,'autorouting','on');


    VectorDelayName='VectorDelay';
    VectorDelayPath=[curGcb,'/',VectorDelayName];
    add_block('dnnfpgaSharedGenericlib/EnabledDelay',VectorDelayPath,'Position',VectorDelayPos);


    demuxName='Demux';
    demuxPath=[curGcb,'/',demuxName];
    hDemux=add_block('simulink/Signal Routing/Demux',demuxPath,'Position',demuxPos);
    set_param(hDemux,'Outputs',num2str(depth));

    pDemux=get_param(hDemux,'PortHandles');

    for i=1:depth
        outPortName=['out',num2str(i)];
        outPortPath=[curGcb,'/',outPortName];
        outPortPos=[495,10+(i*5),535,40+(i*5)];
        hOut=add_block('built-in/OutPort',outPortPath,'Position',outPortPos);
        pOut=get_param(hOut,'PortHandles');
        add_line(curGcb,pDemux.Outport(i),pOut.Inport,'autorouting','on');
    end

    add_line(curGcb,[EnbTapDelaySubSysName,'/1'],[VectorDelayName,'/1'],'autorouting','on');
    add_line(curGcb,[VectorDelayName,'/1'],[demuxName,'/1'],'autorouting','on');
    add_line(curGcb,'D/1',[EnbTapDelaySubSysName,'/1'],'autorouting','on');


    add_line(curGcb,pLoad.Outport,pEnbSubsys.Enable,'autorouting','on');
    add_line(curGcb,'stage/1',[VectorDelayName,'/2'],'autorouting','on');
end
