



classdef SeparateOutputAndUpdateConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='All of the action subsystems connected to a given If or SwitchCase block should consistently combine or separate their output and update functions';
        end

        function obj=SeparateOutputAndUpdateConstraint()
            obj.setEnum('SeparateOutputAndUpdate');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            incompatibleBlks=containers.Map('KeyType','double',...
            'ValueType','any');

            mdlHdl=get_param(aObj.ParentModel().getHandle(),'Handle');




            ifBlks=find_system(mdlHdl,'LookUnderMasks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks','on',...
            'LookUnderReadProtectedSubsystems','on',...
            'BlockType','If');
            [incompatibleIf,incompatibleBlks]=...
            aObj.isIncompatible(ifBlks,incompatibleBlks);





            switchCaseBlks=find_system(mdlHdl,'LookUnderMasks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks','on',...
            'LookUnderReadProtectedSubsystems','on',...
            'BlockType','SwitchCase');
            [incompatibleSwitchCase,incompatibleBlks]=...
            aObj.isIncompatible(switchCaseBlks,incompatibleBlks);


            if incompatibleIf||incompatibleSwitchCase
                out=slci.compatibility.Incompatibility(aObj,...
                'SeparateOutputAndUpdate');
                incompatibleDests=cell(numel(values(incompatibleBlks)),1);


                srcBlks=keys(incompatibleBlks);
                numsrcs=numel(srcBlks);
                idx=1;
                for k=1:numsrcs
                    src=srcBlks{k};
                    dests=incompatibleBlks(src);
                    numdests=numel(dests);
                    for p=1:numdests
                        incompatibleDests{idx}=[dests(p),src];
                        idx=idx+1;
                    end
                end
                out.setObjectsInvolved(incompatibleDests);
            end
        end

    end

    methods(Access=private)



        function[isIncompatible,incompatibleBlks]=isIncompatible(aObj,...
            blks,incompatibleBlks)

            isIncompatible=false;
            numBlks=numel(blks);
            for k=1:numBlks
                blk=blks(k);


                destBlks=aObj.getDestinations(blk);

                sepOutputBlocks=[];
                for m=1:numel(destBlks)
                    destBlk=destBlks(m);
                    if strcmp(get_param(destBlk,'OutputUpdateCombined'),'off')
                        sepOutputBlocks(end+1)=destBlk;%#ok
                    end
                end



                if~isempty(sepOutputBlocks)&&...
                    numel(sepOutputBlocks)<numel(destBlks)
                    isIncompatible=true;
                    incompatibleBlks(blk)=sepOutputBlocks;
                end
            end
        end

        function dstBlks=getDestinations(~,srcBlkH)
            ports=get_param(srcBlkH,'Porthandles');
            outports=ports.Outport;
            numOut=numel(outports);
            dstBlks=[];
            for k=0:numOut-1
                dst=slci.internal.getActualDst(srcBlkH,k);
                if~isempty(dst)
                    dstBlks(end+1)=dst(1);%#ok<AGROW>
                end
            end
        end
    end


end
