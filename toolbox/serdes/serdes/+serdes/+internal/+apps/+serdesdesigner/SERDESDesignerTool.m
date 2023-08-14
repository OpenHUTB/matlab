classdef SERDESDesignerTool<handle



    properties
Model
View
Controller
    end

    properties(SetAccess=protected,Hidden)
        appContainer;
        StatusWidget;
    end

    methods
        function obj=SERDESDesignerTool(varargin)


            matlab.internal.lang.capability.Capability.require(matlab.internal.lang.capability.Capability.LocalClient);





            obj.Model=serdes.internal.apps.serdesdesigner.Model();
            obj.View=serdes.internal.apps.serdesdesigner.View();
            obj.Controller=serdes.internal.apps.serdesdesigner.Controller(obj.Model,obj.View);

            obj.Model.View=obj.View;
            obj.Model.SerdesDesignerTool=obj;
            obj.View.SerdesDesignerTool=obj;
            obj.appContainer=obj.View.Toolstrip.appContainer;

            if nargin==1
                openedExistingDesign=initialModel(obj.Model,varargin{1});
            else
                openedExistingDesign=false;
            end
            newView(obj.View,obj.Model.Name,obj.Model.SerdesDesign);


            set(obj.appContainer,'CanCloseFcn',@(h,e)appCloseRequestFcn(obj));


            if~openedExistingDesign
                obj.Model.newPopupActions('Blank canvas');
            end
        end

        function result=appCloseRequestFcn(obj)






            if~isvalid(obj)||~isvalid(obj.Model)



                result=true;
                return;
            end
            if~isempty(obj.Model)&&obj.Model.IsChanged

                if obj.Model.processSerdesDesignSaving()
                    result=false;
                    return;
                end
            end


            s=settings;
            if~isempty(s)&&...
                isprop(s,'serdes')&&...
                isprop(s.serdes,'SerDesDesigner')&&...
                isprop(s.serdes.SerDesDesigner,'X')&&...
                isprop(s.serdes.SerDesDesigner,'Y')&&...
                isprop(s.serdes.SerDesDesigner,'Width')&&...
                isprop(s.serdes.SerDesDesigner,'Height')
                windowBounds=obj.appContainer.WindowBounds;
                s.serdes.SerDesDesigner.X.PersonalValue=windowBounds(1);
                s.serdes.SerDesDesigner.Y.PersonalValue=windowBounds(2);
                s.serdes.SerDesDesigner.Width.PersonalValue=windowBounds(3);
                s.serdes.SerDesDesigner.Height.PersonalValue=windowBounds(4);
            end
            canvas=obj.View.CanvasFig;
            if~isempty(canvas)&&isvalid(canvas)

                canvas.WindowButtonUpFcn=[];
                canvas.WindowButtonMotionFcn=[];
                canvas.SizeChangedFcn=[];
            end
            obj.appContainer.Visible=false;
            obj.View.ClosingAppContainer=true;
            result=true;
        end

        function setStatus(obj,statusText)
            if~isempty(obj.StatusWidget)
                delete(obj.StatusWidget);
            end
            if~isempty(statusText)
                obj.StatusWidget=uiprogressdlg(obj.View.CanvasFig,'Message',statusText,'Title','Please Wait','Indeterminate','on');
            end









        end
    end
end
