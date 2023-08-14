classdef SoftwareModelingSpreadSheetContext<dig.CustomContext




    properties(SetObservable=true)
        IsSpreadSheetVisible;
    end

    properties(Constant)
        AppName='softwareModelingSpreadSheetApp';
    end

    methods
        function this=SoftwareModelingSpreadSheetContext(isVisible)
            app=struct;
            app.name=swarch.internal.toolstrip.SoftwareModelingSpreadSheetContext.AppName;
            app.defaultContextType='softwareModelingSpreadSheetContext';
            app.defaultTabName='';
            app.priority=0;

            this@dig.CustomContext(app);
            this.TypeChain={app.defaultContextType};
            this.IsSpreadSheetVisible=isVisible;
        end

        function setVisible(this,isVisible)
            this.IsSpreadSheetVisible=isVisible;
        end
    end
end
