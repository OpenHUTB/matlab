function connectBusExpansionSubsystem(this,blocklist,hN)





    hN.setBusExpansionSubsystem(true);
    storeAsBusExpandedBlock(this,hN);




    origBlkh=get_param(hN.FullPath,'Handle');
    if~isempty(origBlkh)&&...
        strcmp(get_param(origBlkh,'BlockType'),'ToFile')
        hN.dontTouch(true);
    end




    for ii=1:numel(blocklist)
        slbh=blocklist(ii);
        typ=get_param(slbh,'BlockType');
        phan=get_param(slbh,'PortHandles');

        for jj=1:numel(phan.Outport)
            oportH=phan.Outport(jj);
            opobj=get_param(oportH,'Object');
            dstPorts=opobj.getGraphicalDst;
            hsig=this.pirGetSignal(hN,slbh,oportH);
            if strcmp(typ,'Inport')

                hsig.addDriver(hN,str2double(get_param(slbh,'Port'))-1);
            else
                driverComp=hN.findComponent('sl_handle',slbh);
                if~isempty(driverComp)
                    hsig.addDriver(hN.findComponent('sl_handle',slbh),jj-1);
                end
            end

            for dstcnt=1:size(dstPorts,1)
                dstBlkH=get_param(dstPorts(dstcnt,1),'Parenthandle');
                obj=get_param(dstBlkH,'object');

                dstPort=dstPorts(dstcnt);


                if obj.isSynthesized&&strcmp(obj.getSyntReason,'SL_SYNT_BLK_REASON_BS_VIRTUALIZATION')
                    ph=get_param(dstBlkH,'PortHandles');
                    if(numel(ph.Inport)==1)&&(numel(ph.Outport)==1)
                        oportH=ph.Outport;
                        opobj=get_param(oportH,'Object');

                        dstPort=opobj.getGraphicalDst;

                        dstBlkH=get_param(dstPort,'ParentHandle');
                    end
                end
                if strcmp(get_param(dstBlkH,'Blocktype'),'Outport')

                    hsig.addReceiver(hN,str2double(get_param(dstBlkH,'Port'))-1);
                else
                    dstComp=hN.findComponent('sl_handle',dstBlkH);
                    if~isempty(dstComp)
                        hsig.addReceiver(dstComp,get_param(dstPort,'PortNumber')-1);
                    end
                end
            end
        end
    end
end





function storeAsBusExpandedBlock(this,hN)
    if isempty(this.BusExpandedBlocks)
        this.BusExpandedBlocks=hN;
    else
        this.BusExpandedBlocks(end+1)=hN;
    end
end


