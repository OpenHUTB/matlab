classdef SubsystemRef




    methods(Static)

        function referencedSubsys=checkReferencedSubsystem(resultI)
            referencedSubsys='';
            for j=1:length(resultI)
                fname=resultI{j};
                if strcmp(get_param(fname,'type'),'block')&&strcmp(get_param(fname,"BlockType"),'SubSystem')...
                    &&~isempty(get_param(fname,'ReferencedSubsystem'))
                    referencedSubsys=get_param(fname,'ReferencedSubsystem');
                end
            end
        end

    end
end
