classdef Dialogs<handle



    properties(Access=private,Constant)
        DialogMap=containers.Map();
    end


    methods(Access=private)

        function obj=Dialogs()
        end

    end


    methods(Access=public,Static)

        function put(reportID,dialog)
            import slxmlcomp.internal.filter.ui.Dialogs;
            if~Dialogs.DialogMap.isKey(reportID)
                map=Dialogs.DialogMap;
                map(reportID)=dialog;%#ok<NASGU>
            end
        end

        function remove(reportID)
            import slxmlcomp.internal.filter.ui.Dialogs;
            if~Dialogs.DialogMap.isKey(reportID)
                return
            end
            map=Dialogs.DialogMap;
            dialog=map(reportID);
            dialog.close();
            map.remove(reportID);
        end

    end

end

