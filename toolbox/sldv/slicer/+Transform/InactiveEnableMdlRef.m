



classdef InactiveEnableMdlRef<Transform.InactiveEnable
    methods

        function obj=InactiveEnableMdlRef()
            obj=obj@Transform.InactiveEnable();
            obj.pivotBlockType='ModelReference';
        end

        function yesno=applicable(~,bh,~)
            yesno=strcmp(get(bh,'BlockType'),'ModelReference');
            if yesno

                ph=get(bh,'PortHandles');
                yesno=~isempty(ph.Enable)&&isempty(ph.Trigger);
            end
        end
    end

    methods(Access=protected)
        function[detail,isMdl,covOwner]=getCovDetailForSys(~,cvd,bh)
            isMdl=true;
            covOwner=get_param(get_param(bh,'NormalModeModelName'),'handle');
            [~,detail]=cvd.getDecisionInfo(covOwner);
        end

        function actionBlk=getEnableBlock(~,sysH,~)
            sysH=get_param(get_param(sysH,'NormalModeModelName'),'handle');
            findOpts=Simulink.FindOptions('SearchDepth',1);
            actionBlk=Simulink.findBlocksOfType(sysH,'EnablePort',findOpts);
        end

        function h=getDisabledMdlBlkSynth(~,~,~)

            h=[];
        end
    end
end