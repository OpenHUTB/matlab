classdef EditorEvents






    methods(Static=true,Access='public')
        function openInNewWindow(bdName)
            editTimeController=sledittimecheck.EditTimeController.getInstance();
            editTimeController.handleNewWindowOpen(bdroot(bdName));
        end
    end
end

