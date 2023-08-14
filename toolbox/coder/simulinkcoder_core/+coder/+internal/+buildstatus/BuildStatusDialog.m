classdef BuildStatusDialog<handle

    properties(Hidden)
modelName
URL
Dialog
studio
SubNeedToClean

    end

    methods

        function obj=BuildStatusDialog(modelName,studio,debug,subNeedToClean)


            obj.modelName=modelName;
            obj.SubNeedToClean=subNeedToClean;
            if isempty(studio)
                studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
                if isempty(studios)
                    obj.studio=[];
                else
                    obj.studio=studios(1);
                end
            else
                obj.studio=studio;
            end
            connector.ensureServiceOn;
            if debug
                html='buildstatus-debug.html';
            else
                html='buildstatus.html';
            end
            obj.URL=connector.getUrl(['/toolbox/coder/simulinkcoder_core/buildstatus/web/',html,'?model=',modelName]);
            if debug,disp(obj.URL);end
            obj.createDialog;
        end


        function addSubNeedToClean(obj,subscriptions)
            obj.SubNeedToClean=[obj.SubNeedToClean,subscriptions];
        end

        function subs=getSubNeedToClean(obj)
            subs=obj.SubNeedToClean;
        end

        function setSubNeedToClean(obj,subs)
            obj.SubNeedToClean=subs;
        end


        function geometry=getDialogGeometry(obj)
            windowSize=[840,700];
            screenSize=get(groot,'ScreenSize');
            screenSize=screenSize(3:4);
            geometry=[(screenSize-windowSize)/2,windowSize];
        end


        function show(obj)
            if isempty(obj.Dialog)||~obj.Dialog.isWindowValid
                obj.createDialog;
            end
            obj.Dialog.show;
            obj.Dialog.bringToFront;
        end


        function createDialog(obj)
            obj.Dialog=matlab.internal.webwindow(obj.URL);
            obj.Dialog.Title=DAStudio.message('RTW:buildStatus:BuildStatus');
            obj.Dialog.Position=obj.getDialogGeometry;
            obj.Dialog.CustomWindowClosingCallback=@obj.cleanup;
        end



        function cleanup(obj,~,~)

            for k=1:length(obj.SubNeedToClean)
                message.unsubscribe(obj.SubNeedToClean{k});
            end

            if~isempty(obj.Dialog)&&obj.Dialog.isWindowValid
                obj.Dialog.close;
                delete(obj.Dialog);
            end
        end
    end
end
