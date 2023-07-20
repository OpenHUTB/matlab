classdef(Hidden=true)ScheduleEditorInterface<handle

    properties
modelHandle
URL
Dialog
    end

    methods(Abstract)
        hide(obj)
        show(obj)
        isVisible(obj)
    end

    methods

        function obj=ScheduleEditorInterface(modelHandle)
            obj.modelHandle=modelHandle;
            obj.URL=sltp.internal.URLBuilder.buildURL(obj.modelHandle);
            connector.ensureServiceOn;
        end
    end

    methods(Static,Hidden=true)
        function position=getDefaultPosition(screenSize)


            screenWidth=screenSize(3);
            screenHeight=screenSize(4);
            winWidth=900;
            winHeight=800;



            xOffset=max([(screenWidth-winWidth)/2,0]);




            yOffset=(screenHeight-winHeight)/2;
            if yOffset<0
                yOffset=2*yOffset;
            end

            position=[xOffset,yOffset,winWidth,winHeight];
        end
    end
end



