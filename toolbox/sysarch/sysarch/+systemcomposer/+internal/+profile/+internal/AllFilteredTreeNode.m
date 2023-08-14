classdef AllFilteredTreeNode<handle





    methods
        function id=getID(~)
            id=0;
        end

        function label=getDisplayLabel(~)
            label=DAStudio.message('SystemArchitecture:ProfileDesigner:AllProfilesFiltered');
        end

        function has=hasChildren(~)


            has=false;
        end
    end
end