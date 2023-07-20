classdef UserInfoSection<matlab.internal.cmlink.preferences.sections.PreferencesSection




    properties
        Grid;
        UserName;
        Email;
    end

    methods
        function obj=UserInfoSection(panelGrid)
            obj=obj@matlab.internal.cmlink.preferences.sections.PreferencesSection(...
            panelGrid,i_getMessage("UserInfoHeading"),1);

            obj.Grid=uigridlayout(obj.SectionGrid);
            obj.Grid.Padding=[0,0,0,0];
            obj.Grid.RowHeight=repmat("fit",1,3);
            obj.Grid.ColumnWidth=["fit","1x"];

            globalGitConfig=matlab.internal.cmlink.git.Config();

            descriptionLabel=uilabel(obj.Grid,"Text",i_getMessage("UserInfoDescription"));
            descriptionLabel.Layout.Column=[1,2];
            descriptionLabel.Layout.Row=1;

            nameLabel=uilabel(obj.Grid,"Text",i_getMessage("UserInfoName"));
            nameLabel.Layout.Column=1;
            nameLabel.Layout.Row=2;
            obj.UserName=uieditfield(obj.Grid,"Value",globalGitConfig.getValueOr("user.name",""),"Editable","on");
            obj.UserName.Layout.Column=2;
            obj.UserName.Layout.Row=2;

            emailLabel=uilabel(obj.Grid,"Text",i_getMessage("UserInfoEmail"));
            emailLabel.Layout.Column=1;
            emailLabel.Layout.Row=3;
            obj.Email=uieditfield(obj.Grid,"Value",globalGitConfig.getValueOr("user.email",""),"Editable","on");
            obj.Email.Layout.Column=2;
            obj.Email.Layout.Row=3;
        end

        function commit(obj)
            globalGitConfig=matlab.internal.cmlink.git.Config();
            globalGitConfig.setValue("user.name",obj.UserName.Value);
            globalGitConfig.setValue("user.email",obj.Email.Value);
        end
    end
end

function value=i_getMessage(resource)
    value=string(message("shared_cmlink:preferences_git:"+resource));
end
