



classdef InactiveTriggerMdlRef<Transform.InactiveTrigger

    methods
        function obj=InactiveTriggerMdlRef()
            obj=obj@Transform.InactiveTrigger();
            obj.pivotBlockType='ModelReference';
        end

        function yesno=applicable(~,bh,~)
            yesno=strcmp(get(bh,'BlockType'),'ModelReference');
            if yesno
                ph=get(bh,'PortHandles');
                yesno=~isempty(ph.Trigger)&&isempty(ph.Enable);
            end
        end
    end

    methods(Access=protected)
        function[detail,isMdl,covOwner]=getCovDetailForSys(~,cvd,bh)
            isMdl=true;
            covOwner=get_param(get_param(bh,'NormalModeModelName'),'handle');
            [~,detail]=cvd.getDecisionInfo(covOwner);
        end

        function actionBlk=getTriggerBlock(~,sysH,~)
            sysH=get_param(get_param(sysH,'NormalModeModelName'),'handle');
            findOpts=Simulink.FindOptions('SearchDepth',1);
            actionBlk=Simulink.findBlocksOfType(sysH,'TriggerPort',findOpts);
        end

        function h=getDisabledMdlBlkSynth(~,~,~)

            h=[];
        end
    end
end
