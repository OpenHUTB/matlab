classdef SDPSetupTool<handle




    properties
studio
topModel
currentModel
app
dataProvider
dataModel
tt
dlg
        debug=false
    end

    methods
        function obj=SDPSetupTool(studio)
            obj.studio=studio;
            topH=studio.App.blockDiagramHandle;
            obj.topModel=get_param(topH,'Name');
            currentH=studio.App.getActiveEditor.blockDiagramHandle;
            obj.currentModel=get_param(currentH,'Name');
            obj.init();


            mdlObj=get_param(topH,'Object');
            addlistener(mdlObj,'CloseEvent',@(~,~)delete(obj));
        end

        init(obj)
        url=getUrl(obj)
        web=show(obj)

        dialogCallback(obj,widget,event)
        [success,errmsg]=apply(obj)
        result=preview(obj)
    end
end

