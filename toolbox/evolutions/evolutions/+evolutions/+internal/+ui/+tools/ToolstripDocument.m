classdef(Abstract)ToolstripDocument<matlab.ui.internal.FigureDocument







    properties(Abstract,Constant)
        Name char;
    end

    properties
        BackgroundColor(1,3)double{mustBeNonnegative,...
        mustBeLessThanOrEqual(BackgroundColor,1)}=get(0,'factoryUipanelBackgroundColor');
        ForegroundColor(1,3)double{mustBeNonnegative,...
        mustBeLessThanOrEqual(ForegroundColor,1)}=get(0,'factoryUipanelForegroundColor');
    end

    methods(Abstract)
        createDocumentComponents(this);
        layoutDocument(this);
    end

    methods
        function this=ToolstripDocument(configuration)
            this@matlab.ui.internal.FigureDocument(configuration);


            configureDocument(this);
        end
    end

    methods(Access=protected)
        function configureDocument(this)
            this.Title=this.Name;
            this.Tag=this.TagName;
        end
    end
end
