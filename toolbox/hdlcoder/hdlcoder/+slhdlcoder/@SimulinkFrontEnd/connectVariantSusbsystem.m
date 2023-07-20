function connectVariantSusbsystem(this,blocklist,hThisNetwork)










    for ii=1:numel(blocklist)
        slbh=blocklist(ii);
        typ=get_param(slbh,'BlockType');
        phan=get_param(slbh,'PortHandles');
        blkObj=get_param(slbh,'Object');
        isSynthetic=slhdlcoder.SimulinkFrontEnd.isSyntheticBlock(slbh);

        for jj=1:numel(phan.Outport)
            oportH=phan.Outport(jj);
            opobj=get_param(oportH,'Object');
            dstPorts=opobj.getGraphicalDst;
            hsig=this.pirGetSignal(hThisNetwork,slbh,oportH);


            if strcmp(typ,'Inport')
                hsig.addDriver(hThisNetwork,str2double(blkObj.Port)-1);
            else
                hsig.addDriver(hThisNetwork.findComponent('sl_handle',slbh),jj-1);
            end




            if isempty(dstPorts)
                continue;
            end

            if isSynthetic
                continue;
            end


            for dstcnt=1:size(dstPorts,1)
                dstBlkParent=get_param(dstPorts(dstcnt,1),'Parent');
                dstBlkH=get_param(dstBlkParent,'Handle');
                if strcmp(get_param(dstBlkH,'Blocktype'),'Outport')
                    destPortStr=get_param(dstBlkParent,'Port');
                    hsig.addReceiver(hThisNetwork,str2double(destPortStr)-1);
                else
                    dstComp=hThisNetwork.findComponent('sl_handle',dstBlkH);
                    if~isempty(dstComp)
                        hsig.addReceiver(dstComp,get_param(dstPorts(dstcnt),'PortNumber')-1);
                    end
                end
            end

        end
    end
