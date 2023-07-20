function checkReferencedModelPorts(this,slbh,blockInfo)





    scalarizePorts=this.HDLCoder.getParameter('ScalarizePorts');
    singleLib=this.HDLCoder.getParameter('use_single_library');
    isVhdl=this.HDLCoder.getParameter('isVhdl');


    isProtectingTopModel=this.HDLCoder.getParameter('BuildToProtectModel')&&...
    strcmp(get_param(slbh,'Name'),this.HDLCoder.ModelName);

    if isVhdl&&~singleLib&&...
        isa(get_param(slbh,'Object'),'Simulink.BlockDiagram')&&...
        (~strcmp(get_param(slbh,'Name'),this.HDLCoder.ModelName)||...
        isProtectingTopModel)
        for ii=1:numel(blockInfo.Inports)
            ph=blockInfo.Inports(ii);
            if scalarizePorts~=1&&...
                isaVectorPort(slbh,ph,'Outport')
                blkName=get_param(slbh,'Name');
                msg=message('hdlcoder:validate:MdlRefVector',...
                get_param(ph,'Name'),blkName);
                this.updateChecks(blkName,'model',msg,'Error');
            end

            cdt=get_param(ph,'CompiledPortDataTypes');
            dt=cdt.Outport{:};
            if isSLEnumType(dt)
                blkName=get_param(slbh,'Name');
                msg=message('hdlcoder:validate:MdlRefEnum',...
                get_param(ph,'Name'),blkName);
                this.updateChecks(blkName,'model',msg,'Error');
            end
        end
        for ii=1:numel(blockInfo.Outports)
            ph=blockInfo.Outports(ii);
            if scalarizePorts~=1&&...
                isaVectorPort(slbh,ph,'Inport')
                blkName=get_param(slbh,'Name');
                msg=message('hdlcoder:validate:MdlRefVector',...
                get_param(ph,'Name'),blkName);
                this.updateChecks(blkName,'model',msg,'Error');
            end

            cdt=get_param(ph,'CompiledPortDataTypes');
            dt=cdt.Inport{:};
            if isSLEnumType(dt)
                blkName=get_param(slbh,'Name');
                msg=message('hdlcoder:validate:MdlRefEnum',...
                get_param(ph,'Name'),blkName);
                this.updateChecks(blkName,'model',msg,'Error');
            end
        end
    end
end


function isVector=isaVectorPort(slbh,ph,queryPort)
    isVector=false;
    portInH=get_param(ph,'PortHandles');
    busStruct=get_param(portInH.(queryPort),'CompiledBusStruct');
    if isempty(busStruct)
        portDims=get_param(ph,'CompiledPortDimensions');
        portDims=portDims.(queryPort);
        if~slhdlcoder.SimulinkFrontEnd.isascalartype(portDims)
            isVector=true;
        end
    else

        busSigHier=get_param(portInH.(queryPort),'SignalHierarchy');
        if slhdlcoder.SimulinkFrontEnd.isArrayInsideBus(busSigHier,slbh)
            isVector=true;
        end
    end
end