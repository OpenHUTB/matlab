function v=validateBlock(this,hC)


    v=hdlvalidatestruct;


    ports=this.getAllPirInputPorts(hC);
    isFPMode=targetcodegen.targetCodeGenerationUtils.isFloatingPointMode;
    if isFPMode

        ports=ports(2:end);
    else

        ports=[ports,this.getAllPirOutputPorts(hC)];
    end
    [noports,any_float]=this.checkForDoublePorts(ports);

    if~noports&&any_float
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:RAMSystem:validateBlock:SingleDoubleData'));
    end


    if~strcmpi(hdlsignalsltype(hC.PirInputSignals(3)),'boolean')

        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:RAMSystem:validateBlock:WriteEnableNotBoolean'));
    end

    [RAMType,~,IV,~,~]=this.getBlockInfo(hC);



    isDPRAM=strcmpi(RAMType,'Dual port');
    if isDPRAM&&length(hC.PirOutputSignals)==1
        v(end+1)=hdlvalidatestruct(2,...
        message('hdlcoder:RAMSystem:validateBlock:DualPortRAMHasOneOutputPort'));
    end

    if hC.Owner.hasResettableInstances
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:ramcannotbereset'));
    end




    if ischar(IV)
        IV=slResolve(IV,hC.SimulinkHandle);
    end

    if~isempty(IV)
        dataSig=hC.PirInputPorts(1).Signal;

        dataT=dataSig.Type;
        if~isreal(IV)&&~(dataT.isComplexType||dataT.BaseType.isComplexType)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:RAMSystem:validateBlock:IVComplexMismatch'));
        end

        numIV=numel(IV);
        if numIV>1
            addrTp=hC.PirInputSignals(2).Type;
            addrBits=addrTp.getLeafType.WordLength;
            ramSize=2^addrBits;
            if numIV~=ramSize
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:RAMSystem:validateBlock:IVWrongLength',numIV,ramSize));
            end
        end

        dataT=dataSig.Type.getLeafType;
        if~dataT.isFloatType&&(any(isnan(IV))||any(isinf(IV)))
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:RAMSystem:validateBlock:FixptInvalidValue'));

        end
    end

end


