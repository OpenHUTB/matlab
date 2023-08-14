function[rndMode,ovMode,inputSigns,dspMode,nfpOptions,blockOptions,isPOE]=getBlockInfo(this,hC)



    isPOE=false;
    slbh=hC.SimulinkHandle;
    sat=get_param(slbh,'DoSatur');
    if strcmp(sat,'on')
        ovMode='Saturate';
    else
        ovMode='Wrap';
    end

    rndMode=get_param(slbh,'RndMeth');

    inputSigns=strtrim(get_param(slbh,'Inputs'));
    if strcmp(inputSigns,'2')
        inputSigns='**';
    elseif strcmp(inputSigns,'1')
        inputSigns='*';
    end

    if~contains(inputSigns,'/')&&~strcmp(inputSigns,'*')


        if targetmapping.mode(hC.SLOutputSignals(1))&&targetcodegen.targetCodeGenerationUtils.isNFPMode()

            inputSigns=repmat('*',1,hC.NumberOfPirInputPorts);
        else
            inputSigns='**';
        end
    end

    if strcmp(inputSigns,'/*')&&~targetmapping.mode(hC.SLOutputSignals(1))
        blockOptions.firstInputSignDivide=true;
        inputSigns='*/';
    else
        blockOptions.firstInputSignDivide=false;
    end

    dspModeStr=getImplParams(this,'DSPStyle');
    dspMode=int8(0);

    if isempty(dspModeStr)
        dspMode=int8(0);
    elseif strcmpi(dspModeStr,'on')
        dspMode=int8(1);
    elseif strcmpi(dspModeStr,'off')
        dspMode=int8(2);
    end

    nfpOptions=getNFPImplParamInfo(this,hC,inputSigns);
    v=this.validateDSPStyle(hC);
    if(numel(v)>1)
        dspMode=int8(0);
    end

    blockOptions.mulKind=get_param(hC.SimulinkHandle,'Multiplication');
    blockOptions.mulOver=get_param(hC.SimulinkHandle,'CollapseMode');
    blockOptions.dimension=get_param(hC.SimulinkHandle,'CollapseDim');

    if(hC.NumberOfPirInputPorts==1)&&strcmp(blockOptions.mulKind,'Element-wise(.*)')
        if(prod(hC.PirInputSignals(1).Type.getDimensions)~=prod(hC.PirOutputSignals(1).Type.getDimensions))
            isPOE=true;
        end
    end

end


