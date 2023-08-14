



classdef ExplicitPartitionsConstraint<slci.compatibility.Constraint

    methods

        function obj=ExplicitPartitionsConstraint()
            obj=obj@slci.compatibility.Constraint();
            obj.setEnum('ExplicitPartitions');
            obj.setCompileNeeded(1);
            obj.setFatal(true);
        end

        function out=getDescription(aObj)%#ok
            out='SLCI does not support model which contains explicit partitions';
        end

        function out=check(aObj)
            out=[];





            hasExplicitPartitions=false;




            mrfblks=find_system(aObj.ParentModel().getName(),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ModelReference');
            for i=1:numel(mrfblks)
                blk=mrfblks{i};
                hasExplicitPartitions=...
                strcmpi(get_param(blk,'ScheduleRates'),'on')...
                &&strcmpi(get_param(blk,'ScheduleRatesWith'),'Schedule Editor');
                if hasExplicitPartitions
                    break;
                end
            end

            if~hasExplicitPartitions



                sysblks=find_system(aObj.ParentModel().getName(),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem');
                for i=1:numel(sysblks)
                    blk=sysblks{i};
                    hasExplicitPartitions=...
                    strcmpi(get_param(blk,'TreatAsAtomicUnit'),'on')...
                    &&~strcmpi(get_param(blk,'ScheduleAs'),'Sample Time');
                    if hasExplicitPartitions
                        break;
                    end
                end
            end

            if hasExplicitPartitions
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end
        end
    end
end
