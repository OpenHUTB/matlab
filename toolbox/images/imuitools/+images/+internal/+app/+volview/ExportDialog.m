classdef ExportDialog<images.internal.app.utilities.ExportToWorkspaceDialog




    properties(Access=?uitest.factory.Tester)
        Tag='VolViewExportDlg'
    end

    methods

        function self=ExportDialog(loc,dlgTitle,varName,labelMsg)
            self@images.internal.app.utilities.ExportToWorkspaceDialog(loc,dlgTitle,varName,labelMsg);
        end

    end

    methods(Access=protected)

        function keyPress(self,evt)

            switch(evt.Key)
            case 'escape'
                cancelClicked(self);
            end

        end

    end

end
