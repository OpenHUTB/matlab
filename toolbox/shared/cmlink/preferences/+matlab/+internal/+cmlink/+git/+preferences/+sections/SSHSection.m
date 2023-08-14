classdef SSHSection<matlab.internal.cmlink.preferences.sections.PreferencesSection




    properties
        AllowSSH;
        UseSSHAgent;
        PublicKeyFileLabel;
        PublicKeyFile;
        PublicKeyFileBrowse;
        PrivateKeyFileLabel;
        PrivateKeyFile;
        PrivateKeyFileBrowse;
        KeyHasPassphrase;
        Grid;
    end

    methods
        function obj=SSHSection(panelGrid)
            obj=obj@matlab.internal.cmlink.preferences.sections.PreferencesSection(...
            panelGrid,i_getMessage("SSHHeading"),3);

            obj.Grid=uigridlayout(obj.SectionGrid);
            obj.Grid.Padding=[0,0,0,0];
            obj.Grid.RowHeight=repmat("fit",1,4);
            obj.Grid.ColumnWidth=["fit","1x","fit"];

            obj.AllowSSH=uicheckbox(obj.Grid);
            obj.AllowSSH.Layout.Column=[1,3];
            obj.AllowSSH.Text=i_getMessage("AllowSSH");
            obj.AllowSSH.Value=i_getGitSetting().AllowSSH.ActiveValue;
            obj.AllowSSH.ValueChangedFcn=@(~,event)obj.setEnableFlags(event.Value);

            obj.PublicKeyFileLabel=uilabel(obj.Grid,"Text",i_getMessage("SSHPublicKeyFile"));
            obj.PublicKeyFile=uieditfield(obj.Grid,...
            "Value",i_getGitSetting().PublicKeyFile.ActiveValue,...
            "Editable","on");
            obj.PublicKeyFileBrowse=uibutton(obj.Grid,...
            "Text","...",...
            "ButtonPushedFcn",@(~,~)obj.folderBrowseButtonCallback(obj.PublicKeyFile));

            obj.PrivateKeyFileLabel=uilabel(obj.Grid,"Text",i_getMessage("SSHPrivateKeyFile"));
            obj.PrivateKeyFile=uieditfield(obj.Grid,...
            "Value",i_getGitSetting().PrivateKeyFile.ActiveValue,...
            "Editable","on");
            obj.PrivateKeyFileBrowse=uibutton(obj.Grid,...
            "Text","...",...
            "ButtonPushedFcn",@(~,~)obj.folderBrowseButtonCallback(obj.PrivateKeyFile));

            obj.KeyHasPassphrase=uicheckbox(obj.Grid);
            obj.KeyHasPassphrase.Layout.Column=[1,3];
            obj.KeyHasPassphrase.Text=i_getMessage("SSHKeyIsPassphraseProtected");
            obj.KeyHasPassphrase.Value=i_getGitSetting().KeyHasPassphrase.ActiveValue;

            obj.UseSSHAgent=uicheckbox(obj.Grid);
            obj.UseSSHAgent.Layout.Column=[1,3];
            if ispc
                obj.UseSSHAgent.Text=i_getMessage("SSHUsePageant");
            else
                obj.UseSSHAgent.Text=i_getMessage("SSHUseSSHAgent");
            end
            obj.UseSSHAgent.Value=i_getGitSetting().UseSSHAgent.ActiveValue;

            obj.setEnableFlags(obj.AllowSSH.Value);
        end

        function commit(obj)
            gs=i_getGitSetting();
            gs.AllowSSH.PersonalValue=obj.AllowSSH.Value;
            gs.UseSSHAgent.PersonalValue=obj.UseSSHAgent.Value;
            gs.PublicKeyFile.PersonalValue=obj.PublicKeyFile.Value;
            gs.PrivateKeyFile.PersonalValue=obj.PrivateKeyFile.Value;
            gs.KeyHasPassphrase.PersonalValue=obj.KeyHasPassphrase.Value;
        end
    end

    methods(Access=private)
        function folderBrowseButtonCallback(~,fieldToUpdate)
            defaultFolder=matlab.internal.cmlink.git.credentials.getDefaultSSHFolder();
            [filename,pathname]=uigetfile('*',i_getMessage("SSHSelectKeyFile"),defaultFolder);
            if~isequal(filename,0)&&~isequal(pathname,0)
                fieldToUpdate.Value=fullfile(pathname,filename);
            end
        end

        function setEnableFlags(obj,value)
            obj.UseSSHAgent.Enable=value;
            obj.PublicKeyFileLabel.Enable=value;
            obj.PublicKeyFile.Enable=value;
            obj.PublicKeyFileBrowse.Enable=value;
            obj.PrivateKeyFileLabel.Enable=value;
            obj.PrivateKeyFile.Enable=value;
            obj.PrivateKeyFileBrowse.Enable=value;
            obj.KeyHasPassphrase.Enable=value;
        end
    end
end

function s=i_getGitSetting()
    s=settings().matlab.sourcecontrol.git;
end

function value=i_getMessage(resource)
    value=string(message("shared_cmlink:preferences_git:"+resource));
end
