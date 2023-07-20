classdef WindowsSection<matlab.internal.cmlink.preferences.sections.PreferencesSection


    properties
        Grid;
        PathToGit;
        PathToGitBrowse;
        PathToShell;
        PathToShellBrowse;
    end

    methods
        function obj=WindowsSection(panelGrid)
            obj=obj@matlab.internal.cmlink.preferences.sections.PreferencesSection(...
            panelGrid,i_getMessage("WindowsHeading"),1);

            obj.Grid=uigridlayout(obj.SectionGrid);
            obj.Grid.Padding=[0,0,0,0];
            obj.Grid.RowHeight=repmat("fit",1,2);
            obj.Grid.ColumnWidth=["fit","1x","fit"];

            uilabel(obj.Grid,"Text",i_getMessage("WindowsPathToGit"));
            obj.PathToGit=uieditfield(obj.Grid,...
            "Value",i_getGitSetting().PathToGitWindows.ActiveValue,...
            "Editable","on");
            obj.PathToGitBrowse=uibutton(obj.Grid,...
            "Text","...",...
            "ButtonPushedFcn",@(~,~)obj.folderBrowseButtonCallback(obj.PathToGit));

            uilabel(obj.Grid,"Text",i_getMessage("WindowsPathToShell"));
            obj.PathToShell=uieditfield(obj.Grid,...
            "Value",i_getGitSetting().PathToShellWindows.ActiveValue,...
            "Editable","on");
            obj.PathToShellBrowse=uibutton(obj.Grid,...
            "Text","...",...
            "ButtonPushedFcn",@(~,~)obj.folderBrowseButtonCallback(obj.PathToShell));
        end

        function commit(obj)
            gs=i_getGitSetting();
            gs.PathToGitWindows.PersonalValue=obj.PathToGit.Value;
            gs.PathToShellWindows.PersonalValue=obj.PathToShell.Value;
        end
    end

    methods(Access=private)
        function folderBrowseButtonCallback(~,fieldToUpdate)
            [filename,pathname]=uigetfile('*',i_getMessage("Select"));
            if~isequal(filename,0)&&~isequal(pathname,0)
                fieldToUpdate.Value=fullfile(pathname,filename);
            end
        end
    end
end

function value=i_getMessage(resource)
    value=string(message("shared_cmlink:preferences_git:"+resource));
end

function s=i_getGitSetting()
    s=settings().matlab.sourcecontrol.git;
end
