function hNewC=elaborate(this,hN,hC)




    hCInSignals=hC.SLInputSignals;
    hCOutSignals=hC.SLOutputSignals;
    slbh=hC.SimulinkHandle;
    select_comp=get_param(slbh,'opMode');


    if strcmp(select_comp,'Vector')
        [rndMode,ovMode,initVal,elabMode]=getBlockInfo(this,slbh,hC);
        hNewC=pirelab.getVectorMACComp(hN,hCInSignals,hCOutSignals,rndMode,ovMode,hC.Name,'',slbh,initVal,elabMode);
    else



        InHandles=find_system(slbh,'LookUnderMasks','on','FollowLinks','on','SearchDepth',1,'BlockType','Inport');
        InportNames=cellstr(get_param(InHandles,'Name'));
        PortInString=strjoin(InportNames,';');

        OutHandles=find_system(slbh,'LookUnderMasks','on','FollowLinks','on','SearchDepth',1,'BlockType','Outport');
        OutportNames=cellstr(get_param(OutHandles,'Name'));
        PortOutString=strjoin(OutportNames,';');


        [rndMode,InitValueSetting,initValue,numberOfSamples,opMode,Cbox_ValidOut,Cbox_EndInAndOut,Cbox_StartOut,Cbox_CountOut]=getBlockInfo_StreamingComp(this,slbh,hC);
        hNewC=pirelab.getStreamingMACComp(hN,hCInSignals,hCOutSignals,rndMode,hC.Name,InitValueSetting,initValue,numberOfSamples,opMode,Cbox_ValidOut,Cbox_EndInAndOut,Cbox_StartOut,Cbox_CountOut,...
        PortInString,PortOutString);


        extra_in_ports=hNewC.NumberOfPirInputPorts-length(InportNames);
        if extra_in_ports>0
            hNewC.delInputPort(length(InportNames),extra_in_ports);
        end

        extra_out_ports=hNewC.NumberOfPirOutputPorts-length(OutportNames);
        if extra_out_ports>0
            hNewC.delOutputPort(length(OutportNames),extra_out_ports);
        end
    end
end

function[rndMode,ovMode,initVal,elabMode]=getBlockInfo(this,slbh,hC)

    sat=get_param(slbh,'DoSatur');
    if strcmp(sat,'on')
        ovMode='Saturate';
    else
        ovMode='Wrap';
    end

    rndMode=get_param(slbh,'RndMeth');
    initValSource=get_param(slbh,'initValueSetting');

    initVal='0';
    if(strcmp(initValSource,'Dialog'))
        cval=getBlockDialogValue(this,get_param([get(slbh,'Path'),'/',get(slbh,'Name'),'/vectorMAC/Constant'],'Handle'));
        initVal=pirelab.getValueWithType(cval,hC.PirOutputSignals(1).Type);
    end


    elabMode=this.getElabMode;
end

function cval=getBlockDialogValue(this,slbh)


    if strcmpi(get_param(slbh,'BlockType'),'Constant')
        rto=get_param(slbh,'RuntimeObject');
        constprm=0;
        for n=1:rto.NumRuntimePrms
            if strcmp(rto.RuntimePrm(n).Name,'Value')
                constprm=n;
                break;
            end
        end
        if constprm==0
            error(message('hdlcoder:validate:constantvaluenotfound'));
        end
        cval=rto.RuntimePrm(constprm).Data;
        if isempty(cval)
            cval=hdlslResolve('Value',slbh);
        end

    elseif strcmpi(get_param(slbh,'BlockType'),'Ground')
        cval=0;
    else
        valstruct=get_param(slbh,'MaskWSVariables');
        if isempty(valstruct)
            valstruct=get_param(get(get_param(slbh,'Object'),'Parent'),'MaskWSVariables');
        end
        if isempty(valstruct)
            cval=this.hdlslResolve('value',slbh);
        else
            val_loc=strcmp('Value',{valstruct.Name});
            if any(val_loc)==true
                cval=valstruct(val_loc).Value;
            else
                val_loc=strcmp('enumConstDispStr',{valstruct.Name});
                if any(val_loc)==true
                    cval=valstruct(val_loc).Value;
                else
                    error(message('hdlcoder:validate:valuenotfound'));
                end
            end
        end
        if ischar(cval)

            cval=slResolve(cval,slbh);
        end
    end
end

function[rndMode,InitValueSetting,initValue,numberOfSamples,opMode,Cbox_ValidOut,Cbox_EndInAndOut,Cbox_StartOut,Cbox_CountOut]=getBlockInfo_StreamingComp(this,slbh,hC)
    opMode=get_param(slbh,'opMode');
    switch opMode
    case 'Streaming - using Start and End ports'
        rndMode=get_param(slbh,'RndMeth2');
        initValSource2=get_param(slbh,'initValueSetting2');
        initValue='0';
        if(strcmp(initValSource2,'Dialog'))
            cval=getBlockDialogValue(this,get_param([get(slbh,'Path'),'/',get(slbh,'Name'),'/streamingMAC_without_counter/const_initValue'],'Handle'));
            initValue=pirelab.getValueWithType(cval,hC.PirOutputSignals(1).Type);
        end
        InitValueSetting=get_param(slbh,'initValueSetting2');
        numberOfSamples=-1;
        Cbox_ValidOut=get_param(slbh,'validOut');
        Cbox_EndInAndOut=get_param(slbh,'endInandOut');
        Cbox_StartOut=get_param(slbh,'startOut');
        Cbox_CountOut='off';

    case 'Streaming - using Number of Samples'
        rndMode=get_param(slbh,'RndMeth3');
        initValSource3=get_param(slbh,'initValueSetting3');
        initValue='0';
        if(strcmp(initValSource3,'Dialog'))
            cval=getBlockDialogValue(this,get_param([get(slbh,'Path'),'/',get(slbh,'Name'),'/streamingMAC_with_counter/const_initValue'],'Handle'));
            initValue=pirelab.getValueWithType(cval,hC.PirOutputSignals(1).Type);
        end
        InitValueSetting=get_param(slbh,'initValueSetting3');
        numberOfSamples=num2str(hdlslResolve('num_samples',slbh));
        Cbox_ValidOut=get_param(slbh,'validOut');
        Cbox_EndInAndOut='off';
        Cbox_StartOut='off';
        Cbox_CountOut=get_param(slbh,'countOut');

    otherwise
        error('Streaming MAC block: Mode not determined correctly');
    end
end
