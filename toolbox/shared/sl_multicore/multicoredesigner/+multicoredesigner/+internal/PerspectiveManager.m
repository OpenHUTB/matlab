classdef PerspectiveManager<handle







    events
MulticorePerspectiveChange
    end

    properties(GetAccess=private,SetAccess=private)
InPerspective
ShowPerspectiveControl
    end

    properties(Constant)
        iconPathOn=fullfile(matlabroot,'toolbox','shared','sl_multicore','multicoredesigner','+multicoredesigner','icons','multicoredesigner.png');
        iconPathOff=fullfile(matlabroot,'toolbox','shared','sl_multicore','multicoredesigner','+multicoredesigner','icons','multicoredesigner_off.png');
    end

    methods

        function obj=PerspectiveManager()
            obj.InPerspective=containers.Map('KeyType','double','ValueType','logical');

            if slfeature('SLMulticore')>0


                obj.ShowPerspectiveControl=true;
                GLUE2.addDomainTransformativeGroupCreatorCallback('Simulink','Multicore',...
                @obj.createPerspectiveGroupCallback);
            end
        end


        function delete(obj)
            if obj.ShowPerspectiveControl
                GLUE2.removeDomainTransformativeGroupCreatorCallback('Simulink','Multicore');
            end
        end

        function ret=isInPerspective(obj,modelH)
            ret=isKey(obj.InPerspective,modelH)&&...
            strcmp(get_param(modelH,'MulticorePerspectiveActive'),'on');
        end

        function togglePerspective(obj,modelH)


            if~isKey(obj.InPerspective,modelH)

                obj.InPerspective(modelH)=false;
            end

            obj.InPerspective(modelH)=~obj.InPerspective(modelH);


            if obj.InPerspective(modelH)
                set_param(modelH,'MulticorePerspectiveActive','on');
            else
                set_param(modelH,'MulticorePerspectiveActive','off');
            end


            obj.notify('MulticorePerspectiveChange',...
            multicoredesigner.internal.PerspectiveChangeEvent(obj.InPerspective(modelH),modelH));

        end

        function yesno=getStatus(obj,modelH)
            if~isKey(obj.InPerspective,modelH)

                yesno=false;
            else
                yesno=obj.InPerspective(modelH);
            end
        end

        function removeFromPerspectiveMap(obj,modelH)
            if isKey(obj.InPerspective,modelH)
                remove(obj.InPerspective,modelH);
            end
        end

    end

    methods(Access=private)
        function createPerspectiveGroupCallback(obj,callbackInfo)
            info=callbackInfo.EventData;
            if info.getBlockHandle()==0
                client=info.getPerspectivesClient;
                obj.displayPerspectiveControls(client);
            end
        end


        function displayPerspectiveControls(obj,client)
            studioHelper=slreq.utils.DAStudioHelper.createHelper(client.getEditor);
            modelH=studioHelper.TopModelHandle;

            location=GLUE2.getPerspectivesGroupLocation('Multicore');
            group=client.newTransformativeGroup(getString(message('dataflow:Spreadsheet:PerspectiveName')),location,false);
            if obj.getStatus(modelH)
                iconPath=obj.iconPathOff;
                tooltip=getString(message('dataflow:Spreadsheet:PerspectiveExitTooltip'));
                bubbleStr=getString(message('dataflow:Spreadsheet:PerspectiveExitBubbleString'));
            else
                iconPath=obj.iconPathOn;

                tooltip=getString(message('dataflow:Spreadsheet:PerspectiveEnterTooltip'));
                bubbleStr=getString(message('dataflow:Spreadsheet:PerspectiveEnterBubbleString'));
            end
            option=group.newOption('multicoreoption',iconPath,bubbleStr,tooltip);
            option.setSelectionCallback(@obj.onClickHandler);
        end

        function onClickHandler(obj,callbackInfo)
            info=callbackInfo.EventData;
            client=info.getPerspectivesClient;
            editor=client.getEditor;
            studio=editor.getStudio;
            modelH=studio.App.blockDiagramHandle;

            obj.togglePerspective(modelH);

            client.closePerspectives;
        end
    end
end

