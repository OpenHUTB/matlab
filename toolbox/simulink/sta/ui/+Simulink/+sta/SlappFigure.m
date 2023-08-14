classdef SlappFigure<handle





    properties(Abstract)


Tag


FullUrl


CEFWindow


IS_DEBUG
LaunchDebugTools


MacIcon
PcIcon
LinuxIcon

MinSize
    end


    methods(Abstract,Hidden)


getDebugHTML


getReleaseHTML


generateAppId


onMATLABExit


onDialogClose


getPosition


initCEFTitle

onClose
    end


    methods


        function show(aSlappFig)
            if isvalid(aSlappFig)&&isempty(aSlappFig.CEFWindow)



                aSlappFig.CEFWindow=matlab.internal.webwindow(...
                aSlappFig.FullUrl,aSlappFig.debuggingPort);


                figPosition=getPosition(aSlappFig);

                aSlappFig.CEFWindow.Position=[figPosition(1),...
                figPosition(2),...
                figPosition(3),...
                figPosition(4)];

                aSlappFig.CEFWindow.setMinSize(aSlappFig.MinSize);

                iconFileName=aSlappFig.PcIcon;
                if ismac()
                    iconFileName=aSlappFig.MacIcon;
                elseif~ispc()&&~ismac()
                    iconFileName=aSlappFig.LinuxIcon;
                end

                aSlappFig.CEFWindow.Icon=iconFileName;

                aSlappFig.CEFWindow.Title=initCEFTitle(aSlappFig);



                aSlappFig.CEFWindow.CustomWindowClosingCallback=@(evt,src)onDialogClose(aSlappFig);


                aSlappFig.CEFWindow.MATLABClosingCallback=@(evt,src)onMATLABClose(aSlappFig);


                aSlappFig.CEFWindow.show();
                aSlappFig.bringToFront();


                if aSlappFig.LaunchDebugTools
                    aSlappFig.CEFWindow.executeJS('cefclient.sendMessage("openDevTools");');
                end
            end

        end


        function bringToFront(aSlappFig)




            if~isempty(aSlappFig.CEFWindow)
                aSlappFig.CEFWindow.bringToFront();
            end

        end


        function close(aSlappFig)
            if isvalid(aSlappFig)
                onClose(aSlappFig);
            end
        end
    end
end
