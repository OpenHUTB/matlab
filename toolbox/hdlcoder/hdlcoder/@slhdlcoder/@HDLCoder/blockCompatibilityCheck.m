function checks=blockCompatibilityCheck(this,pirFrontEnd)

    checks=[];

    dtoChecks=checkDTO(this,pirFrontEnd);
    checks=cat(2,checks,dtoChecks);


    inout_checks=checkInOutPorts(this,pirFrontEnd);
    checks=cat(2,checks,inout_checks);




    bbw_checks=this.forAllComponents(pirFrontEnd.hPir,@largeBitWidthChecks);
    checks=cat(2,checks,bbw_checks);

    numErrs=this.statusCount(checks);
    haveErrors=(numErrs~=0);

    if~haveErrors

        enumOrder_checks=checkEnumOrder(this);
        checks=cat(2,checks,enumOrder_checks);
    end


    if~haveErrors


        blockChecks=pirFrontEnd.validatePIR(pirFrontEnd.hPir);
        checks=cat(2,checks,blockChecks);
    end

end


function checks=checkDTO(this,pirFrontEnd)
    checks=[];


    mdlName=pirFrontEnd.SimulinkConnection.ModelName;
    dto=get_param(mdlName,'DataTypeOverride');
    nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();
    if~isempty(strfind(dto,'Double'))||(~isempty(strfind(dto,'Single'))&&~nfpMode)
        msg=message('hdlcoder:validate:DTOonModel',this.ModelName);
        checks(end+1).path=this.ModelName;
        checks(end).type='model';
        checks(end).message=msg.getString;
        checks(end).level='Error';
        checks(end).MessageID=msg.Identifier;
    end
end



function checks=checkInOutPorts(this,pirFrontEnd)%#ok<INUSL>
    checks=[];
    hPir=pirFrontEnd.hPir;
    vNetworks=hPir.Networks;
    numNetworks=length(vNetworks);


    if targetcodegen.targetCodeGenerationUtils.isNFPMode()
        return
    end

    for i=1:numNetworks
        hN=vNetworks(i);
        vComps=hN.Components;
        numComps=length(vComps);

        if hN.hasBidirectionalPorts
            blkPath='';
            if hN.SimulinkHandle>0
                blkPath=getfullname(hN.SimulinkHandle);
            end

            msg=message('hdlcoder:validate:inoutnetwork');
            checks(end+1).path=blkPath;%#ok<AGROW>
            checks(end).type='block';
            checks(end).message=msg.getString;
            checks(end).level='Error';
            checks(end).MessageID=msg.Identifier;
            break;
        end

        for j=1:numComps
            hC=vComps(j);
            if isa(hC,'hdlcoder.ntwk_instance_comp')
                continue;
            end

            compSignals=[hC.PirInputSignals;hC.PirOutputSignals];
            compPorts=[hC.PirInputPorts;hC.PirOutputPorts];

            for ii=1:length(compSignals)
                if compPorts(ii).getBidirectional&&hdlsignalisdouble(compSignals(ii))
                    blkPath='';
                    if hC.SimulinkHandle>0
                        blkPath=getfullname(hC.SimulinkHandle);
                    end

                    msg=message('hdlcoder:validate:inoutdouble');
                    checks(end+1).path=blkPath;%#ok<AGROW>
                    checks(end).type='block';
                    checks(end).message=msg.getString;
                    checks(end).level='Error';
                    checks(end).MessageID=msg.Identifier;
                    break;
                end
            end
        end
    end
end




function checks=checkEnumOrder(this)
    checks=[];

    slName=this.getStartNodeName;

    hSS=get_param(slName,'Handle');
    compiledBlockList=getCompiledBlockList(get_param(hSS,'ObjectAPI_FP'));


    hassSFBlock=hasSFBlockPresent(compiledBlockList);
    for k=1:length(compiledBlockList)
        slbh=compiledBlockList(k);
        han=get_param(getfullname(slbh),'Handle');
        phan=get_param(han,'PortHandles');
        if~isempty(phan.State)
            portList=[phan.Outport,phan.State];
        else
            portList=phan.Outport;
        end

        numOutPorts=length(portList);
        for portIdx=1:numOutPorts
            oportHandle=portList(portIdx);
            slSignalType=get_param(oportHandle,'CompiledPortDataType');
            if isSLEnumType(slSignalType)
                [enumValues,enumStrings]=enumeration(slSignalType);
                enumValues=int32(enumValues.double);


                numVals=numel(enumValues);
                curVal=enumValues(1);
                for ii=2:numVals
                    if curVal>=enumValues(ii)&&~hassSFBlock
                        errMsg=message('hdlcoder:makehdl:EnumValueOrder',...
                        slSignalType,enumStrings{ii},enumValues(ii),...
                        enumStrings{ii-1},enumValues(ii-1));
                        checks(end+1).path=this.ModelName;%#ok<AGROW>
                        checks(end).type='block';
                        checks(end).message=errMsg.getString;
                        checks(end).level='Error';
                        checks(end).MessageID=errMsg.Identifier;


                    elseif curVal==enumValues(ii)&&hassSFBlock
                        errMsg=message('hdlcoder:makehdl:SameValueEncodingNotPossible',...
                        slSignalType,enumStrings{ii},enumValues(ii),...
                        enumStrings{ii-1},enumValues(ii-1));
                        checks(end+1).path=this.ModelName;%#ok<AGROW>
                        checks(end).type='block';
                        checks(end).message=errMsg.getString;
                        checks(end).level='Error';
                        checks(end).MessageID=errMsg.Identifier;

                    end
                    curVal=enumValues(ii);
                end
            end
        end
    end
end


function isa=hasSFBlockPresent(compiledBlockList)
    isa=false;
    for k=1:length(compiledBlockList)
        slbh=compiledBlockList(k);


        if isprop(get_param(slbh,'Object'),'BlockType')&&...
            strcmpi(get_param(slbh,'BlockType'),'SubSystem')&&...
            ~strcmpi(get_param(slbh,'SFBlockType'),'NONE')
            isa=true;
            break;
        end
    end
end

