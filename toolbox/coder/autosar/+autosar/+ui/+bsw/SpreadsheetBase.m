classdef SpreadsheetBase<handle




    properties(Access=protected)
DlgSource
    end

    methods
        function this=SpreadsheetBase(dlgSource)
            this.DlgSource=dlgSource;
        end

        function rows=getMappingSpreadsheetRows(this)

            rows=this.DlgSource.UserData.m_MappingChildren;
        end

        function rows=getFiMSpreadsheetRows(this)

            rows=this.DlgSource.UserData.m_InhibitionMatrix;
        end

        function rows=getNvInitValueSpreadsheetRows(this)

            rows=this.DlgSource.UserData.m_InitValues;
        end

        function updateFiMSpreadhseet(this)
            aDlgs=DAStudio.ToolRoot.getOpenDialogs(this.DlgSource);
            for i=1:length(aDlgs)
                aDlg=aDlgs(i);
                fimSS=aDlg.getWidgetInterface('fimTagmatrixSpreadsheet');
                if~isempty(fimSS)
                    fimSS.update();
                end
            end
        end

        function updateNvInitValSpreadhseet(this)
            assert(slfeature('NVRAMInitialValue'),'NVRAM Initial Value feature should be enabled');
            aDlgs=DAStudio.ToolRoot.getOpenDialogs(this.DlgSource);
            for i=1:length(aDlgs)
                aDlg=aDlgs(i);
                nvmSS=aDlg.getWidgetInterface('nvmInitValTagmatrixSpreadsheet');
                if~isempty(nvmSS)
                    nvmSS.update();
                end
            end
        end
    end

    methods(Access=protected)
        function reportError(~,me)
            dp=DAStudio.DialogProvider;
            title=DAStudio.message('Simulink:utility:ErrorDialogSeverityError');
            dp.errordlg(me.message,title,true);
        end
    end

    methods(Sealed,Static,Access=protected)
        function enableWidget(dialog,widgetTag)
            dialog.setEnabled(widgetTag,true);
            dialog.setVisible(widgetTag,true);
        end

        function disableWidget(dialog,widgetTag)
            dialog.setEnabled(widgetTag,false);
            dialog.setVisible(widgetTag,false);
        end
    end
end


