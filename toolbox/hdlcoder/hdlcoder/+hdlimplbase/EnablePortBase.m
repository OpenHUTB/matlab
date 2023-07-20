classdef EnablePortBase<hdlimplbase.PortBase




    methods
        function this=EnablePortBase(~)
        end
    end

    methods(Hidden)
        function v=baseValidateEnablePort(this,hC)
            v=baseValidateCtlPort(this,hC);
            blockInfo=this.getBlockInfo(hC.SimulinkHandle);
            result=this.checkStatesWhenEnabling(blockInfo);
            if~isempty(result)
                v(end+1)=result;
            end

            result=this.checkForNestedModelRefs(hC);
            if~isempty(result)
                for i=1:length(result)
                    v(end+1)=result(i);%#ok<AGROW>
                end
            end
        end


        function result=checkStatesWhenEnabling(~,blockInfo)
            result=[];
            if strcmp(blockInfo.StatesWhenEnabling,'reset')
                result=hdlvalidatestruct(1,...
                message('hdlcoder:validate:statesReset'));
            end
        end


        function result=checkForNestedModelRefs(~,hC)
            result=hdlvalidatestruct;



            mrBlocks=find_system(hC.Owner.SimulinkHandle,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks','on','BlockType','ModelReference');
            for ii=1:numel(mrBlocks)
                mrBlock=mrBlocks(ii);
                mrBlkObj=get_param(mrBlock,'Object');
                mrFullName=mrBlkObj.getFullName;
                hdlArch=hdlget_param(mrFullName,'Architecture');
                if strcmp(hdlArch,'ModelReference')
                    result(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:NestedModelRef',mrFullName));%#ok<AGROW>
                end
            end

            if length(result)==1&&result(1).Status==0
                result=[];
            end
        end
    end
end
