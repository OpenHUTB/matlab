classdef CredentialsSection<matlab.internal.cmlink.preferences.sections.PreferencesSection




    properties
        Grid;
        LookupCredentials;
        ClearInMemCredentials;
        AllowSingleSignOn;
    end

    methods
        function obj=CredentialsSection(panelGrid)
            obj=obj@matlab.internal.cmlink.preferences.sections.PreferencesSection(...
            panelGrid,i_getMessage("CredentialsHeading"),1);

            obj.Grid=uigridlayout(obj.SectionGrid);
            obj.Grid.Padding=[0,0,0,0];
            obj.Grid.RowHeight=repmat("fit",1,4);
            obj.Grid.ColumnWidth=["fit","1x"];

            obj.LookupCredentials=uidropdown(obj.Grid);
            obj.LookupCredentials.Items=[...
            i_getMessage("CredentialsEnableGitCredentialManager"),...
            i_getMessage("CredentialsEnableInMemory"),...
            i_getMessage("CredentialsDisabled")];
            obj.LookupCredentials.ItemsData=["CredentialManager","InMemory","None"];
            obj.LookupCredentials.Value=i_getGitSetting().LookupCredentialMethod.ActiveValue;
            obj.LookupCredentials.Layout.Row=1;
            obj.LookupCredentials.Layout.Column=1;
            obj.LookupCredentials.ValueChangedFcn=@obj.lookupCredentialsChanged;


            obj.ClearInMemCredentials=uibutton(obj.Grid);
            obj.ClearInMemCredentials.Text=i_getMessage("ClearInMemoryCredentials");
            obj.ClearInMemCredentials.Layout.Row=1;
            obj.ClearInMemCredentials.Layout.Column=2;
            obj.ClearInMemCredentials.Visible=i_getGitSetting().LookupCredentialMethod.ActiveValue=="InMemory";
            obj.ClearInMemCredentials.ButtonPushedFcn=@obj.clearCredentialsCallback;

            obj.AllowSingleSignOn=uicheckbox(obj.Grid);
            obj.AllowSingleSignOn.Layout.Row=3;
            obj.AllowSingleSignOn.Layout.Column=1;
            obj.AllowSingleSignOn.Text=i_getMessage("AllowSingleSignOn");
            obj.AllowSingleSignOn.Value=i_getGitSetting().AllowSingleSignOn.ActiveValue;
        end

        function commit(obj)
            gs=settings().matlab.sourcecontrol.git;
            gs.LookupCredentialMethod.PersonalValue=obj.LookupCredentials.Value;
            gs.AllowSingleSignOn.PersonalValue=obj.AllowSingleSignOn.Value;
        end

        function lookupCredentialsChanged(obj,~,event)
            obj.ClearInMemCredentials.Visible=event.Value=="InMemory";
        end

        function clearCredentialsCallback(~,~,~)
            matlab.internal.cmlink.git.credentials.clearInMemoryCredentials();
        end
    end
end

function s=i_getGitSetting()
    s=settings().matlab.sourcecontrol.git;
end

function value=i_getMessage(resource)
    value=string(message("shared_cmlink:preferences_git:"+resource));
end
