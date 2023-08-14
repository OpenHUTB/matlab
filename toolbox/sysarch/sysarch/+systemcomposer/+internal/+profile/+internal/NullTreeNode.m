classdef NullTreeNode<handle





    methods
        function id=getID(~)
            id=0;
        end

        function label=getDisplayLabel(~)
            label=DAStudio.message('SystemArchitecture:ProfileDesigner:NoProfilesLoaded');
        end

        function has=hasChildren(~)


            has=false;
        end
    end
end