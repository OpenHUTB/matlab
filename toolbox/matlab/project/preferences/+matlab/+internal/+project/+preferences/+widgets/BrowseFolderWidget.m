classdef BrowseFolderWidget<matlab.internal.project.preferences.widgets.PreferenceWidget




    properties(SetAccess=immutable,GetAccess=private)
FolderEditField
    end

    methods
        function obj=BrowseFolderWidget(container,prompt,setting)
            obj=obj@matlab.internal.project.preferences.widgets.PreferenceWidget(setting);
            rowLayout=matlab.internal.project.preferences.utils.makeFitGridLayout(container,1,3);
            rowLayout.Padding=0;

            uilabel(rowLayout,"Text",prompt);

            obj.FolderEditField=uieditfield(rowLayout,...
            "Value",setting.ActiveValue,...
            "Editable","off");

            uibutton(rowLayout,...
            "Icon",i_getOpenIcon(),...
            "Text","",...
            "ButtonPushedFcn",@obj.folderBrowseButtonCallback);

            rowLayout.ColumnWidth=["fit","1x","fit"];
        end

        function commit(obj)
            obj.Value=obj.FolderEditField.Value;
        end
    end

    methods(Access=private)
        function folderBrowseButtonCallback(obj,~,~)
            chosenFolder=uigetdir;
            if chosenFolder~=0
                obj.FolderEditField.Value=chosenFolder;
            end
        end
    end
end

function location=i_getOpenIcon()
    location=fullfile(matlabroot,"toolbox","matlab","project",...
    "preferences","images","open_16.png");
end
