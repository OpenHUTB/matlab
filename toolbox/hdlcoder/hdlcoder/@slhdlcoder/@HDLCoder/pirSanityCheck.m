




function checks=pirSanityCheck(this,mdlIdx)




    narginchk(2,2);
    checks=[];

    this.mdlIdx=mdlIdx;
    mdlName=this.AllModels(mdlIdx).modelName;
    p=pir(mdlName);
    vN=p.Networks;
    for ii=1:numel(vN)
        hN=vN(ii);

        for jj=1:numel(hN.PirInputPorts)
            sig=hN.PirInputSignals(jj);
            if(isempty(sig)||~isa(sig,'hdlcoder.signal'))
                msg=message('hdlcoder:engine:UnconnectedPorts','Input','subsystem');
                checks(end+1).level='Warning';%#ok<AGROW>
                checks(end).path=getfullname(hN.SimulinkHandle);
                checks(end).type='model';
                checks(end).message=msg.getString;
                checks(end).MessageID=msg.Identifier;
            end
        end
        for jj=1:numel(hN.PirOutputPorts)
            sig=hN.PirOutputSignals(jj);
            if(isempty(sig)||~isa(sig,'hdlcoder.signal'))
                msg=message('hdlcoder:engine:UnconnectedPorts','Output','subsystem');
                checks(end+1).level='Warning';%#ok<AGROW>
                checks(end).path=getfullname(hN.SimulinkHandle);
                checks(end).type='model';
                checks(end).message=msg.getString;
                checks(end).MessageID=msg.Identifier;
                error(message('hdlcoder:engine:PIRConnectivityFailure',mdlName));
            end
        end


        vComps=hN.Components;
        numComps=length(vComps);
        for jj=1:numComps
            hC=vComps(jj);


            if hC.Synthetic
                continue;
            end
            slbh=hC.SimulinkHandle;
            try
                obj=get_param(slbh,'Object');
            catch me %#ok<NASGU>


                continue;
            end


            if isa(obj,'Simulink.Annotation')
                continue;
            end

            if slhdlcoder.SimulinkFrontEnd.isSyntheticBlock(slbh)
                continue;
            end

            for kk=1:numel(hC.PirInputPorts)
                insig=hC.PirInputSignals(kk);
                if(isempty(insig)||~isa(insig,'hdlcoder.signal'))
                    msg=message('hdlcoder:engine:UnconnectedPorts','Input','block');
                    checks(end+1).level='Warning';%#ok<AGROW>
                    checks(end).path=getfullname(hC.SimulinkHandle);
                    checks(end).type='block';
                    checks(end).message=msg.getString;
                    checks(end).MessageID=msg.Identifier;
                end
            end

            for kk=1:numel(hC.PirOutputPorts)
                outsig=hC.PirOutputSignals(kk);
                if(isempty(outsig)||~isa(outsig,'hdlcoder.signal'))
                    msg=message('hdlcoder:engine:UnconnectedPorts','Output','block');
                    checks(end+1).level='Warning';%#ok<AGROW>
                    checks(end).path=getfullname(hC.SimulinkHandle);
                    checks(end).type='block';
                    checks(end).message=msg.getString;
                    checks(end).MessageID=msg.Identifier;
                end
            end




            if(hC.isCtxReference)
                refNtwk=hC.ReferenceNetwork;


                for kk=1:numel(hC.PirInputPorts)
                    compInSignal=hC.PirInputSignals(kk);
                    ph=compInSignal.SimulinkHandle;


                    if(compInSignal.Type.isRecordType)


                        refNtwkInSignal=getReferenceNetworkPortSignal(hC.PirInputPorts(kk).Name,refNtwk.PirInputPorts);






                        virtualBus=strcmp(get_param(ph,'CompiledBusType'),'VIRTUAL_BUS');
                        if(virtualBus&&~refNtwkInSignal.Type.isRecordType)
                            continue;
                        end




                        compBusPortElements=numel(compInSignal.Type.MemberNamesFlattened);
                        refNtwkBusPortElements=numel(refNtwkInSignal.Type.MemberNamesFlattened);
                        if(compBusPortElements~=refNtwkBusPortElements)
                            compInPortName=hC.PirInputPorts(kk).Name;
                            msg=message('hdlcoder:engine:BusInterfaceMismatch',compInPortName,hN.Name,...
                            compInPortName,refNtwk.Name);
                            checks(end+1).level='Error';%#ok<AGROW>
                            checks(end).path=getfullname(hC.SimulinkHandle);
                            checks(end).type='block';
                            checks(end).message=msg.getString;
                            checks(end).MessageID=msg.Identifier;
                        end
                    end
                end


                for kk=1:numel(hC.PirOutputPorts)
                    compOutSignal=hC.PirOutputSignals(kk);

                    if(compOutSignal.Type.isRecordType)


                        refNtwkOutSignal=getReferenceNetworkPortSignal(hC.PirOutputPorts(kk).Name,refNtwk.PirOutputPorts);



                        compBusPortElements=numel(compOutSignal.Type.MemberNamesFlattened);
                        refNtwkBusPortElements=numel(refNtwkOutSignal.Type.MemberNamesFlattened);
                        if(compBusPortElements~=refNtwkBusPortElements)


                            compOutPortName=hC.PirOutputPorts(kk).Name;
                            idx=strfind(compOutPortName,'_Outport');
                            busObjectName=extractBefore(compOutPortName,idx(end));
                            msg=message('hdlcoder:engine:BusInterfaceMismatch',busObjectName,hN.Name,...
                            busObjectName,refNtwk.Name);
                            checks(end+1).level='Error';%#ok<AGROW>
                            checks(end).path=getfullname(hC.SimulinkHandle);
                            checks(end).type='block';
                            checks(end).message=msg.getString;
                            checks(end).MessageID=msg.Identifier;
                        end
                    end
                end
            end
        end
    end
end

function refNtwkSignal=getReferenceNetworkPortSignal(compPortName,refNtwkPortsList)

    for ii=1:numel(refNtwkPortsList)
        if strcmp(refNtwkPortsList(ii).Name,compPortName)
            refNtwkSignal=refNtwkPortsList(ii).Signal;
            return;
        end
    end

    assert(false,strcat('Invalid Port Name ',compPortName));
end
