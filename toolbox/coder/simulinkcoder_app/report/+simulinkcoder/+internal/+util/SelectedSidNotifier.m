classdef SelectedSidNotifier<handle



    events
SelectedSidsChanged
    end

    properties
Studio
Timer
SelectionData
Listener
        Interval=100
    end

    methods
        function obj=SelectedSidNotifier(studio)
            obj.Studio=studio;
            obj.Timer=DAStudio.Timer;
            obj.Timer.setCallback(@()obj.notifyOfChange);
            selectionSystem=simulinkcoder.internal.util.SelectionSystem.instance();
            obj.Listener=selectionSystem.listener('SelectedSidsChangedFromAnyStudio',...
            @(~,data)obj.onSelectionChanged(data));
        end

        function onSelectionChanged(obj,selectionData)
            studio=obj.Studio;
            if isvalid(studio)
                editor=studio.App.getActiveEditor;
                if~isempty(editor)
                    if editor.getDocument==selectionData.Document
                        obj.SelectionData=selectionData;
                        obj.Timer.startSingle(obj.Interval);
                    end
                end
            end
        end
    end

    methods(Access=private)
        function notifyOfChange(obj)
            studio=obj.Studio;
            if isvalid(studio)
                editor=studio.App.getActiveEditor;
                if~isempty(editor)
                    if editor.getDocument==obj.SelectionData.Document
                        obj.notify('SelectedSidsChanged',obj.SelectionData);
                    end
                end
            end
        end
    end
end

