classdef WebWindowCreator<handle




    methods
        function window=createWindow(obj,url,jobViewer)
            debugPort=matlab.internal.getDebugPort();
            window=matlab.internal.webwindow(url,'DebugPort',debugPort);

            graphObj=groot;
            window.Position=MultiSim.internal.WebWindowCreator.getDefaultPosition(graphObj.ScreenSize);
            window.setMinSize([400,200]);




            if~jobViewer.getConfig('DebugMode')
                window.CustomWindowClosingCallback=@(~,~)close(jobViewer);
            end
            window.MATLABClosingCallback=@(~,~)obj.onMATLABClose(jobViewer);
        end

        function show(~,window)
            window.show();
            window.bringToFront();
        end
    end

    methods(Static,Hidden=true)
        function position=getDefaultPosition(screenSize)


            screenWidth=screenSize(3);
            screenHeight=screenSize(4);
            winWidth=1000;
            winHeight=750;



            xOffset=max([(screenWidth-winWidth)/2,0]);




            yOffset=(screenHeight-winHeight)/2;
            if yOffset<0
                yOffset=2*yOffset;
            end

            position=[xOffset,yOffset,winWidth,winHeight];
        end

        function onMATLABClose(jobViewer)
            jobViewer.closeAndExit();
        end
    end
end
