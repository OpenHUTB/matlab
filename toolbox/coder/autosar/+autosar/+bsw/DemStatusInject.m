classdef DemStatusInject




    methods(Static)
        function configureInjectBlockInternal(blkPath)

            function doSet(dc,bit)
                switch dc.Prompt
                case 'Set'
                    set_param(bitBlock,[bit,'_Enable'],'on');
                    set_param(bitBlock,[bit,'_Val'],'on');
                case 'Clear'
                    set_param(bitBlock,[bit,'_Enable'],'on');
                    set_param(bitBlock,[bit,'_Val'],'off');
                otherwise
                    set_param(bitBlock,[bit,'_Enable'],'off');
                end
            end

            maskObj=get_param(blkPath,'MaskObject');
            TF_Change=maskObj.getDialogControl('TF_Change');
            TFTOC_Change=maskObj.getDialogControl('TFTOC_Change');
            PDTC_Change=maskObj.getDialogControl('PDTC_Change');
            CDTC_Change=maskObj.getDialogControl('CDTC_Change');
            TNCSLC_Change=maskObj.getDialogControl('TNCSLC_Change');
            TFSLC_Change=maskObj.getDialogControl('TFSLC_Change');
            TNCTOC_Change=maskObj.getDialogControl('TNCTOC_Change');
            WIR_Change=maskObj.getDialogControl('WIR_Change');

            bitBlock=[blkPath,'/SetUdsBit'];
            doSet(TF_Change,'TF');
            doSet(TFTOC_Change,'TFTOC');
            doSet(PDTC_Change,'PDTC');
            doSet(CDTC_Change,'CDTC');
            doSet(TNCSLC_Change,'TNCSLC');
            doSet(TFSLC_Change,'TFSLC');
            doSet(TNCTOC_Change,'TNCTOC');
            doSet(WIR_Change,'WIR');

            maskType=get_param(blkPath,'MaskType');
            if strcmp(maskType,'DemStatusInject')
                autosar.bsw.DemStatusInject.updateTriggerMode(blkPath);
                autosar.bsw.DemStatusInject.updatePriority(blkPath);
            else
                assert(strcmp(maskType,'DemFaultInject'),'Expected Fault Analyzer fault block');
            end
        end

        function setConditions(blkPath)
            faultType=get_param(blkPath,'FaultType');

            maskObj=get_param(blkPath,'MaskObject');
            TF_Change=maskObj.getDialogControl('TF_Change');
            TFTOC_Change=maskObj.getDialogControl('TFTOC_Change');
            PDTC_Change=maskObj.getDialogControl('PDTC_Change');
            CDTC_Change=maskObj.getDialogControl('CDTC_Change');
            TNCSLC_Change=maskObj.getDialogControl('TNCSLC_Change');
            TFSLC_Change=maskObj.getDialogControl('TFSLC_Change');
            TNCTOC_Change=maskObj.getDialogControl('TNCTOC_Change');
            WIR_Change=maskObj.getDialogControl('WIR_Change');

            switch faultType
            case 'Event Fail'
                TF_Change.Prompt='Set';
                TFTOC_Change.Prompt='Set';
                PDTC_Change.Prompt='Set';
                CDTC_Change.Prompt='';
                TNCSLC_Change.Prompt='Clear';
                TFSLC_Change.Prompt='Set';
                TNCTOC_Change.Prompt='Clear';
                WIR_Change.Prompt='';
            case 'Event Pass'
                TF_Change.Prompt='Clear';
                TFTOC_Change.Prompt='';
                PDTC_Change.Prompt='';
                CDTC_Change.Prompt='';
                TNCSLC_Change.Prompt='Clear';
                TFSLC_Change.Prompt='';
                TNCTOC_Change.Prompt='Clear';
                WIR_Change.Prompt='';
            case 'Operation Cycle Start'
                TF_Change.Prompt='';
                TFTOC_Change.Prompt='Clear';
                PDTC_Change.Prompt='';
                CDTC_Change.Prompt='';
                TNCSLC_Change.Prompt='';
                TFSLC_Change.Prompt='';
                TNCTOC_Change.Prompt='Set';
                WIR_Change.Prompt='';
            case 'Operation Cycle End'
                TF_Change.Prompt='';
                TFTOC_Change.Prompt='Clear';
                PDTC_Change.Prompt='';
                CDTC_Change.Prompt='';
                TNCSLC_Change.Prompt='';
                TFSLC_Change.Prompt='';
                TNCTOC_Change.Prompt='';
                WIR_Change.Prompt='';
            case 'Fault Record Overwritten'
                TF_Change.Prompt='';
                TFTOC_Change.Prompt='';
                PDTC_Change.Prompt='Clear';
                CDTC_Change.Prompt='Clear';
                TNCSLC_Change.Prompt='';
                TFSLC_Change.Prompt='Clear';
                TNCTOC_Change.Prompt='';
                WIR_Change.Prompt='';
            case 'Fault Maturation'
                TF_Change.Prompt='';
                TFTOC_Change.Prompt='';
                PDTC_Change.Prompt='';
                CDTC_Change.Prompt='Set';
                TNCSLC_Change.Prompt='';
                TFSLC_Change.Prompt='';
                TNCTOC_Change.Prompt='';
                WIR_Change.Prompt='';
            case 'Clear Diagnostic'
                TF_Change.Prompt='Clear';
                TFTOC_Change.Prompt='Clear';
                PDTC_Change.Prompt='Clear';
                CDTC_Change.Prompt='Clear';
                TNCSLC_Change.Prompt='Set';
                TFSLC_Change.Prompt='Clear';
                TNCTOC_Change.Prompt='Set';
                WIR_Change.Prompt='Clear';
            case 'Aging'
                TF_Change.Prompt='';
                TFTOC_Change.Prompt='';
                PDTC_Change.Prompt='';
                CDTC_Change.Prompt='Clear';
                TNCSLC_Change.Prompt='';
                TFSLC_Change.Prompt='Clear';
                TNCTOC_Change.Prompt='';
                WIR_Change.Prompt='';
            case 'Healing'
                TF_Change.Prompt='';
                TFTOC_Change.Prompt='';
                PDTC_Change.Prompt='';
                CDTC_Change.Prompt='';
                TNCSLC_Change.Prompt='';
                TFSLC_Change.Prompt='';
                TNCTOC_Change.Prompt='';
                WIR_Change.Prompt='Clear';
            case 'Indicator Conditions Met'
                TF_Change.Prompt='';
                TFTOC_Change.Prompt='';
                PDTC_Change.Prompt='';
                CDTC_Change.Prompt='';
                TNCSLC_Change.Prompt='';
                TFSLC_Change.Prompt='';
                TNCTOC_Change.Prompt='';
                WIR_Change.Prompt='Set';
            otherwise
            end
        end

        function updateTriggerMode(blkPath)









            blockPath=getfullname(blkPath);
            triggerType=get_param(blockPath,'TriggerType');

            termBlk='Terminate';
            groundBlk='Ground';
            triggerBlk='Trigger';

            termPath=[blockPath,'/',termBlk];
            groundPath=[blockPath,'/',groundBlk];


            isGroundCommented=strcmp(get_param(groundPath,'Commented'),'on');

            lh=get_param(termPath,'LineHandles');
            switch triggerType
            case 'message'
                if~isGroundCommented
                    set_param(groundPath,'Commented','on');
                    delete_line(lh.Inport);
                    add_line(blkPath,[triggerBlk,'/1'],[termBlk,'/1']);
                end
            otherwise
                if isGroundCommented
                    set_param(groundPath,'Commented','off');
                    delete_line(lh.Inport);
                    add_line(blkPath,[groundBlk,'/1'],[termBlk,'/1']);
                end
            end
        end

        function updatePriority(blkPath)





            triggerType=get_param(blkPath,'TriggerType');
            priority=get_param(blkPath,'Priority');
            switch triggerType
            case{'function-call','message'}
                if strcmp(priority,'1')
                    set_param(blkPath,'Priority','');
                end
            otherwise
                if isempty(priority)
                    set_param(blkPath,'Priority','1');
                end
            end
        end
    end
end


