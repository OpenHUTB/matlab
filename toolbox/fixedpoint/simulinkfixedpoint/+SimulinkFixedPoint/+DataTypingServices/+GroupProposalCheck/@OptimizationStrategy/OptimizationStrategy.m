classdef OptimizationStrategy<handle





    properties(SetAccess=private)
        fxpStrategy=SimulinkFixedPoint.DataTypingServices.GroupProposalCheck.FixedPointStrategy();
        checksQueue={};
    end

    methods
        function this=OptimizationStrategy()
            this.checksQueue{1}=@(x)(this.checkLocked(x));
            this.checksQueue{2}=@(x)(this.checkStoredIntegers(x));

        end

        function isProposable=isGroupProposable(this,effectiveConstraint,groupSpecifiedDataType,groupRange,group)


            isProposable=this.fxpStrategy.isGroupProposable(effectiveConstraint,groupSpecifiedDataType,groupRange,group);

            if isProposable

                if any(isempty(groupRange))
                    isProposable=false;
                    return;
                end

                members=group.getGroupMembers();
                for mIndex=1:numel(members)
                    isProposable=this.checkAnyQueue(members{mIndex});
                    if~isProposable
                        return;
                    end
                end
            end
        end
    end

    methods(Hidden)

        function isProposable=checkAnyQueue(this,member)
            isProposable=false;

            for cIndex=1:numel(this.checksQueue)
                isProposable=this.checksQueue{cIndex}(member);
                if~isProposable
                    return
                end
            end

        end

        function isProposable=checkLocked(~,member)



            isProposable=~member.isLocked||(member.isLocked&&member.getSpecifiedDTContainerInfo.isInherited);
        end

        function isProposable=checkStoredIntegers(~,member)


            blkObj=member.UniqueIdentifier.getObject;
            isProposable=~(isprop(blkObj,'ConvertRealWorld')&&strcmpi(blkObj.ConvertRealWorld,'Stored Integer (SI)'));
        end
    end
end

