classdef DemStatusOverride




    properties(Constant)
        UDSBits={'TF','TFTOC','PDTC','CDTC','TNCSLC','TFSLC','TNCTOC','WIR'};
    end

    methods(Static)
        function configureOverrideBlockInternal(blkH)


            portCount=1;
            for ii=1:numel(autosar.bsw.DemStatusOverride.UDSBits)
                udsBit=autosar.bsw.DemStatusOverride.UDSBits{ii};
                bitSource=get_param(blkH,[udsBit,'_Source']);
                bitValue=get_param(blkH,[udsBit,'_Value']);

                sourceBlk=find_system(blkH,'LookUnderMasks','all','FollowLinks','on','Name',udsBit);
                sourceBlk=sourceBlk{1};

                if strcmp(bitSource,'Dialog')

                    if strcmp(get_param(sourceBlk,'BlockType'),'Inport')

                        lh=get_param(sourceBlk,'LineHandles');
                        dstPortH=get(lh.Outport,'DstPortHandle');
                        delete_line(lh.Outport);
                        delete_block(sourceBlk);
                        sourceBlk=add_block('simulink/Sources/Constant',[blkH,'/',udsBit]);
                        ph=get_param(sourceBlk,'PortHandles');
                        add_line(blkH,ph.Outport,dstPortH);
                        autosar.mm.mm2sl.MRLayoutManager.homeBlk(sourceBlk);
                    end
                    if strcmp(bitValue,'on')
                        value='true';
                    else
                        value='false';
                    end
                    set_param(sourceBlk,'Value',value);
                else

                    if strcmp(get_param(sourceBlk,'BlockType'),'Constant')

                        lh=get_param(sourceBlk,'LineHandles');
                        dstPortH=get(lh.Outport,'DstPortHandle');
                        delete_line(lh.Outport);
                        delete_block(sourceBlk);
                        newBlk=add_block('simulink/Sources/In1',[blkH,'/',udsBit]);
                        ph=get_param(newBlk,'PortHandles');
                        add_line(blkH,ph.Outport,dstPortH);
                        autosar.mm.mm2sl.MRLayoutManager.homeBlk(sourceBlk);
                    end

                    set_param(sourceBlk,'Port',num2str(portCount));
                    portCount=portCount+1;
                end
            end
        end

        function updateOverrideBlockMask(blkH)
            maskObj=get_param(blkH,'MaskObject');
            uxButtonsDC=maskObj.getDialogControl('Shortcuts');
            if slfeature('FaultOverrideUxButtons')&&strcmp(uxButtonsDC.Visible,'off')
                uxButtonsDC.Visible='on';
                uxButtonsDC.Enabled='on';
            elseif~slfeature('FaultOverrideUxButtons')&&strcmp(uxButtonsDC.Visible,'on')
                uxButtonsDC.Visible='off';
                uxButtonsDC.Enabled='off';
            end
        end
    end
end


