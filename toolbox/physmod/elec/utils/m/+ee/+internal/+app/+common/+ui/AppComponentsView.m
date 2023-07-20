classdef AppComponentsView
    methods
        function app=AppComponentsView()
        end
    end

    methods(Static)
        function progressDialogHandle=showProgressDialog(this,messageTitle,messageText)



            progressDialogHandle=uiprogressdlg(this,...
            "Title",messageTitle,...
            "Message",messageText,...
            "Indeterminate","on");
        end
    end
end