function connectSynthBlocks(syntheticblocks,hThisNetwork)





    for ii=1:length(syntheticblocks)
        sblk=syntheticblocks(ii);

        hC=hThisNetwork.findComponent('sl_handle',sblk);


        if~isempty(hC)
            hC.setSynthetic();
        end


        if~slhdlcoder.SimulinkFrontEnd.isHandledSyntheticBlock(sblk)
            continue;
        end

        vOp=hC.PirOutputPorts;
        phan=get_param(sblk,'PortHandles');
        for jj=1:length(phan.Outport)
            hP=vOp(jj);
            hS=hP.Signal;

            opobj=get_param(phan.Outport(jj),'Object');
            gdport=opobj.getGraphicalDst;
            for kk=1:length(gdport)
                gdportnum=get_param(gdport(kk),'PortNumber');
                gdblk=get_param(gdport(kk),'Parent');
                gdblkh=get_param(gdblk,'Handle');
                gdblktp=get_param(gdblkh,'BlockType');

                if strcmp(gdblktp,'Outport')
                    gdportnum=str2num(get(gdblkh,'Port'));%#ok
                    hS.addReceiver(hThisNetwork,gdportnum-1);
                else
                    hgdC=hThisNetwork.findComponent('sl_handle',gdblkh);





                    if~isempty(hgdC)
                        hP=hgdC.PirInputPort(gdportnum);
                        existingSig=hP.Signal;
                        if isempty(existingSig)
                            hS.addReceiver(hgdC,gdportnum-1);
                        end
                    end
                end
            end
        end
    end
