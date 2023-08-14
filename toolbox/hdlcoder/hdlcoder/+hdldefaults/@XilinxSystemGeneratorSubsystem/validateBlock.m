function v=validateBlock(~,hC)


    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;
    v=validateXSGSubsystem(bfp,v);
end


function validateStruct=validateXSGSubsystem(xsgSubsys,validateStruct)


    xsgBlks=targetcodegen.xilinxisesysgendriver.findXSGBlks(xsgSubsys);
    if(length(xsgBlks)~=1)
        xsgSubsysPath=[get_param(xsgSubsys,'Parent'),'/',get_param(xsgSubsys,'Name')];
        assert(~isempty(xsgBlks),sprintf('''%s'' contains no System Generator block.',xsgSubsysPath));
        validateStruct(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:xsgblkcount',xsgSubsysPath));
        return;
    end
    xsgBlk=xsgBlks(1);
    xsgBlkPath=[get_param(xsgBlk,'Parent'),'/',get_param(xsgBlk,'Name')];


    hh_xlr=findobj(allchild(0),'Tag','Sysbldr');
    blkhdl_xlr=get(hh_xlr,'UserData');
    if(length(blkhdl_xlr)>1)
        blkhdl_xlr=[blkhdl_xlr{:}];
    end

    if(~isempty(find(blkhdl_xlr==xsgBlk,1)))
        validateStruct(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:xsgopenxsgdialog',xsgBlkPath));
        return;
    end


    xsgSubPath=get(xsgSubsys,'Path');
    modelName=bdroot(xsgSubPath);
    hDriver=hdlmodeldriver(modelName);
    hDI=hDriver.DownstreamIntegrationDriver;
    if~isempty(hDI)&&hDI.isIPCoreGen
        validateStruct(end+1)=hdlvalidatestruct(1,...
        message('hdlcommon:hdlturnkey:XSGIPCoreIncompatible',xsgBlkPath));
    end


    xsgParams=xlgetparams(xsgBlk);





















    familyDevicePackageSpeed=hdlgetdeviceinfo;
    if(~isempty(familyDevicePackageSpeed{1})||...
        ~isempty(familyDevicePackageSpeed{2})||...
        ~isempty(familyDevicePackageSpeed{3})||...
        ~isempty(familyDevicePackageSpeed{4}))
        xsgFamilyDevicePackageSpeed={xsgParams.xilinxfamily,...
        xsgParams.part,...
        xsgParams.package,...
        xsgParams.speed};
        if(~isequal(lower(regexprep(familyDevicePackageSpeed{1},'-|\s','')),lower(regexprep(xsgFamilyDevicePackageSpeed{1},'-|\s',''))))
            validateStruct(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:xsgblkconflictdevice',xsgBlkPath,...
            familyDevicePackageSpeed{1},familyDevicePackageSpeed{2},familyDevicePackageSpeed{4},familyDevicePackageSpeed{3}));
        end
    end


    validateStruct=validateIO(xsgSubsys,'Inport',validateStruct);
    validateStruct=validateIO(xsgSubsys,'Outport',validateStruct);

end

function validateStruct=validateIO(xsgSubsys,blockType,validateStruct)

    if(strcmpi(blockType,'Inport'))
        xsgPortType='gatewayin';
        direction='forward';
    elseif(strcmpi(blockType,'Outport'))
        xsgPortType='gatewayout';
        direction='backward';
    else
        assert(false,'blockType is invalid.');
    end

    ports=find_system(xsgSubsys,'SearchDepth',1,'blocktype',blockType);
    for i=1:length(ports)
        port=ports(i);
        portBlkPath=[get_param(port,'Parent'),'/',get_param(port,'Name')];
        nextBlks=walk(ports(i),direction);
        if(hdlgetparameter('GatewayoutWithDTC')...
            &&length(nextBlks)==1...
            &&strcmp(blockType,'Outport')...
            &&strcmpi(get_param(nextBlks(1),'BlockType'),'DataTypeConversion')...
            )
            gatewayout=walk(nextBlks(1),direction);
            validateStruct=validateGatewayDatatype(gatewayout,xsgPortType,nextBlks(1),validateStruct,portBlkPath);
        else
            for j=1:length(nextBlks)
                nextBlk=nextBlks(j);
                try
                    block_type=get_param(nextBlk,'block_type');
                catch me %#ok<NASGU>
                    block_type='';
                end
                if(~strcmpi(block_type,xsgPortType))
                    validateStruct(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:validate:xsgsubsysport',portBlkPath,xsgPortType));%#ok<*AGROW>
                else


                    switch lower(xsgPortType)
                    case 'gatewayin'
                        validateStruct=validateGatewayDatatype(nextBlk,xsgPortType,port,validateStruct,portBlkPath);
                    case 'gatewayout'
                        try
                            if(~strcmpi(get_param(nextBlk,'inherit_from_input'),'on'))
                                nextBlkPath=[get_param(nextBlk,'Parent'),'/',get_param(nextBlk,'Name')];
                                validateStruct(end+1)=hdlvalidatestruct(1,...
                                message('hdlcoder:validate:xsgsubsysportdatatype',nextBlkPath));
                            end
                        catch me
                            if(isequal(me.identifier,'Simulink:Commands:ParamUnknown'))
                                validateStruct(end+1)=hdlvalidatestruct(1,...
                                message('hdlcoder:validate:xsgsubsysport',portBlkPath,xsgPortType));
                            else
                                rethrow(me);
                            end
                        end
                    end
                end
            end
        end
    end
end

function[validateStruct,slType,xsgType]=getGatewayXSGType(gatewayBlk,xsgPortType,validateStruct)
    slType='';
    ph=get_param(gatewayBlk,'PortHandles');
    switch lower(xsgPortType)
    case 'gatewayin'
        xsgType=get(ph.Outport,'CompiledPortDataType');
    case 'gatewayout'
        xsgType=get(ph.Inport,'CompiledPortDataType');
    end

    if(strcmpi(xsgType,'Bool'))
        signed=false;
        wl=1;
        fl=0;
    else
        pos=strfind(xsgType,'_');
        type=xsgType(1:pos(1)-1);
        switch type
        case 'fix'
            signed=true;
        case 'ufix'
            signed=false;
        otherwise
            validateStruct(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:xsgnonfixedpoint'));
            return;
        end

        wl=str2double(xsgType(pos(1)+1:pos(2)-1));
        fl=str2double(xsgType(pos(2)+1:end));
        assert(fl>=0,'System generator shall not have negative fraction.');
    end

    slType=tostringInternalSlName(numerictype(signed,wl,fl));
end

function[slType,slOrigType]=getOutputSLType(blk)
    ph=get_param(blk,'PortHandles');
    slOrigType=get(ph.Outport,'CompiledPortDataType');
    switch lower(slOrigType)
    case 'boolean'
        slType='ufix1';
    case 'int8'
        slType='sfix8';
    case 'uint8'
        slType='ufix8';
    case 'int16'
        slType='sfix16';
    case 'uint16'
        slType='ufix16';
    case 'int32'
        slType='sfix32';
    case 'uint32'
        slType='ufix32';
    case 'int64'
        slType='ufix64';
    case 'uint64'
        slType='sfix64';
    otherwise
        slType=slOrigType;
    end
end

function validateStruct=validateGatewayDatatype(gatewayBlk,xsgPortType,slBlk,validateStruct,portBlkPath)
    if(~strcmpi(get_param(gatewayBlk,'block_type'),xsgPortType))
        validateStruct(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:xsgsubsysport',portBlkPath,xsgPortType));%#ok<*AGROW>
    else
        [validateStruct,slExpType,xsgExpType]=getGatewayXSGType(gatewayBlk,xsgPortType,validateStruct);
        [slActType,slOrigType]=getOutputSLType(slBlk);
        if(strcmpi(slActType,'double')||strcmpi(slActType,'single'))
            validateStruct(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:xsgnonfixedpoint'));
            return;
        end

        if(~isequal(slExpType,slActType))
            validateStruct(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:xsgnontrivialdtc',[get_param(gatewayBlk,'Parent'),'/',get_param(gatewayBlk,'Name')],xsgExpType,slOrigType));
        end
    end
end

function nextBlock=walk(startingBlk,direction)
    nextBlock=[];
    isForward=strcmpi(direction,'forward');

    startingH=get_param(startingBlk,'Handle');
    pc=get_param(startingH,'PortConnectivity');
    for i=1:length(pc)
        if(isForward)
            h=pc(i).DstBlock;
        else
            h=pc(i).SrcBlock;
        end
        nextBlock=[nextBlock,setdiff(h,nextBlock)];%#ok<*AGROW>
    end
end







