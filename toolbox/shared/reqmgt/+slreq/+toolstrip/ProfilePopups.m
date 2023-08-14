classdef ProfilePopups

    methods(Static)

        function boolValue=showBuiltins
            availableTemplates=slreq.templates.Manager.getListOfTemplates();
            nTemplates=numel(availableTemplates);
            boolValue=nTemplates>0;
        end

        function boolValue=doNotShowBuiltins
            boolValue=~slreq.toolstrip.ProfilePopups.showBuiltins;
        end

        function gw=importOptionsGenerator(cbinfo)
            gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);

            availableTemplates=slreq.templates.Manager.getListOfTemplates();
            nTemplates=numel(availableTemplates);


            actionName='ImportFromFolderAction';
            action=gw.createAction(actionName);
            action.text=message("Slvnv:reqmgt:toolstrip:ImportProfile");
            action.description=message("Slvnv:reqmgt:toolstrip:ImportProfileDesc");
            action.setCallbackFromArray(@(cbinfo)slreq.toolstrip.loadProfile(cbinfo),dig.model.FunctionType.Action);
            action.enabled=true;
            action.icon='applyProfile';

            itemName='ImportFromFolderItem';
            item=gw.Widget.addChild('ListItem',itemName);
            item.ActionId=[gw.Namespace,':',actionName];


            item=gw.Widget.addChild('PopupListHeader','TemplateHeaderItem');
            item.Label=message("Slvnv:reqmgt:toolstrip:TemplateSeparator");
            gw.Widget.addChild('PopupListSeparator','TemplateHeaderSeparator');

            function loadProfileCB(index,cbInfoStruct)
                cbInfoStruct.EventData=fullfile(availableTemplates{index}.file.folder,...
                availableTemplates{index}.file.name);
                slreq.toolstrip.loadProfile(cbInfoStruct);
            end


            for i=1:nTemplates
                actionName=['ImportTemplateProfileAction_',num2str(i)];
                action=gw.createAction(actionName);

                [~,templateName,~]=fileparts(availableTemplates{i}.file.name);
                action.text=templateName;
                action.description=availableTemplates{i}.description;

                action.setCallbackFromArray(@(cbinfo)loadProfileCB(i,cbinfo),dig.model.FunctionType.Action);
                action.enabled=true;
                action.icon='applyProfile';
                itemName=['ImportTemplateProfileOptions_',num2str(i)];
                item=gw.Widget.addChild('ListItem',itemName);
                item.ActionId=[gw.Namespace,':',actionName];
            end
        end
    end
end
