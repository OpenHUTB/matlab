classdef BusSystemBlockBase<hdlimplbase.EmlImplBase




























    methods
        function this=BusSystemBlockBase(~)


        end
    end

    methods(Static)

        function nw=expandBusSignalsForSystemBlock(hC)






            nw=hC.Owner;
            slbh=hC.SimulinkHandle;
            if slbh~=-1&&isprop(slbh,'BlockType')&&...
                strcmpi(get_param(slbh,'BlockType'),'MATLABSystem')

                systemName=get_param(slbh,'System');

                implName=lowersysobj.getImplementationName(systemName);
                if~isempty(implName)

                    hC.createGenericPartition;
                    nw=hC.Owner;
                    nw.flattenAfterModelgen;
                    nic=nw.instances;
                    nic.SimulinkHandle=hC.SimulinkHandle;

                    hasRecordType=false;
                    inSignals=hC.PirInputSignals;
                    inIdx=1;
                    for sidx=1:numel(inSignals)
                        if inSignals(sidx).Type.isRecordType
                            hasRecordType=true;
                            busSignals=getBusSignalOuts(nw,inSignals(sidx));
                            N=numel(busSignals);
                            newInSignals(inIdx:inIdx+N-1)=busSignals;
                            inIdx=inIdx+N;
                        else
                            newInSignals(inIdx)=inSignals(sidx);%#ok<*AGROW>
                            inIdx=inIdx+1;
                        end
                    end
                    outIdx=1;
                    outSignals=hC.PirOutputSignals;
                    for sidx=1:numel(outSignals)
                        if outSignals(sidx).Type.isRecordType
                            hasRecordType=true;
                            busSignals=getBusSignalIns(nw,outSignals(sidx));
                            N=numel(busSignals);
                            newOutSignals(outIdx:outIdx+N-1)=busSignals;
                            outIdx=outIdx+N;
                        else
                            newOutSignals(outIdx)=outSignals(sidx);
                            outIdx=outIdx+1;
                        end
                    end
                    if hasRecordType
                        for sidx=1:numel(inSignals)
                            hC.removeInputPort(0);
                        end
                        for sidx=1:numel(outSignals)
                            hC.removeOutputPort(0);
                        end
                        hC.addInputPorts(numel(newInSignals));
                        hC.addOutputPorts(numel(newOutSignals));
                        for sidx=1:numel(newInSignals)
                            newInSignals(sidx).addReceiver(hC,sidx-1);
                        end
                        for sidx=1:numel(newOutSignals)
                            newOutSignals(sidx).addDriver(hC,sidx-1);
                        end
                    end
                end
            end
        end
    end
end

function out=getBusSignalOuts(hN,s)


    busType=s.Type;
    memberNames=busType.MemberNames;
    memberTypes=busType.MemberTypes;
    for ii=1:numel(memberNames)
        out(ii)=hN.addSignal(memberTypes(ii),memberNames{ii});
    end
    indexArray=sprintf('%s,',memberNames{:});
    indexArray=indexArray(1:end-1);
    pirelab.getBusSelectorComp(hN,s,out,indexArray);
end

function in=getBusSignalIns(hN,s)


    busType=s.Type;
    memberNames=busType.MemberNames;
    memberTypes=busType.MemberTypes;
    for ii=1:numel(memberNames)
        in(ii)=hN.addSignal(memberTypes(ii),memberNames{ii});
        in(ii).SimulinkRate=s.SimulinkRate;
    end
    name=['Bus:',s.Name];
    pirelab.getBusCreatorComp(hN,in,s,name,'on');
end
