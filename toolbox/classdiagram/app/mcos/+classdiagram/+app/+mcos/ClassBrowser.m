classdef ClassBrowser<handle
    properties(SetObservable=true)
        DataModel mdom.DataModel;
        DataProvider classdiagram.app.mcos.MCOSPackageProvider;
listener
channel
app
    end


    methods

        function obj=ClassBrowser(app,factory,packageNames)
            obj.app=app;
            if isa(app.notifier,'classdiagram.app.core.notifications.WDFNotifier')
                notificationFcn=@(notifObj)app.notifier.processNotification(notifObj);
            else
                notificationFcn=@(id,var)app.notifier.processNotification(id,var);
            end
            obj.DataProvider=classdiagram.app.mcos.MCOSPackageProvider(factory,notificationFcn);
            obj.DataModel=mdom.DataModel(obj.DataProvider);

            obj.DataModel.columnChanged(1,{});
            obj.channel=strcat('/classbrowser/',obj.DataModel.getID,'/messagechannel');
            obj.listener=message.subscribe(obj.channel,@(msg)obj.processClientRequest(msg));

            obj.addRootPackages(packageNames);
        end


        function id=getDataModelID(obj)
            id=obj.DataModel.getID();
        end


        function success=addRootClasses(obj,classes)
            success=obj.DataProvider.addRootClasses(classes);
        end


        function removeRootClasses(obj,classes)
            obj.DataProvider.removeRootClasses(classes);
        end


        function success=addRootEnums(obj,enums)
            success=obj.DataProvider.addRootEnums(enums);
        end


        function removeRootEnums(obj,enums)
            obj.DataProvider.removeRootEnums(enums);
        end


        function success=addRootPackages(obj,packages)
            success=obj.DataProvider.addRootPackages(packages);
        end


        function removeRootPackages(obj,packages)
            obj.DataProvider.removeRootPackages(packages);
        end


        function addRootFolders(obj,folders)
            obj.DataProvider.addRootFolders(folders);
        end


        function removeRootFolders(obj,folders)
            obj.DataProvider.removeRootFolders(folders);
        end


        function addRootProjects(obj,projects)
            obj.DataProvider.addRootProjects(projects);
        end


        function removeRootProjects(obj,projects)
            obj.DataProvider.removeRootProjects(projects);
        end


        function removeRoot(obj,root)
            switch root.ConstantType
            case "Package"
                obj.removeRootPackages(string(root.getName));
            case "Class"
                obj.removeRootClasses(string(root.getName));
            case "Enum"
                obj.removeRootEnums(string(root.getName));
            case "Folder"
                obj.removeRootFolders(string(root.getName));
            case "Project"
                obj.removeRootProjects(string(root.getName));
            otherwise
                if isa(obj.app.notifier,'classdiagram.app.core.notifications.WDFNotifier')

                    obj.app.notifier.processNotification(...
                    classdiagram.app.core.notifications.notifications.WDFNotification(...
                    'CBUnknownRootType',messageFills=root.ConstantType,...
                    Severity=classdiagram.app.core.notifications.Severity.Error));
                else
                    obj.app.notifier.processNotification('CBUnknownRootType',root.ConstantType);
                end
            end
        end


        function addRoot(obj,rootName,rootType)
            switch string(rootType)
            case "Package"
                obj.addRootPackages(string(rootName));
            case "Class"
                obj.addRootClasses(string(rootName));
            case "Enum"
                obj.addRootEnums(string(rootName));
            case "Folder"
                obj.addRootFolders(string(rootName));
            case "Project"
                obj.addRootProjects(string(rootName));
            otherwise
                if isa(obj.app.notifier,'classdiagram.app.core.notifications.WDFNotifier')

                    obj.app.notifier.processNotification(...
                    classdiagram.app.core.notifications.notifications.WDFNotification(...
                    'CBUnknownRootType',messageFills=rootType,...
                    Severity=classdiagram.app.core.notifications.Severity.Error));
                else
                    obj.app.notifier.processNotification('CBUnknownRootType',rootType);
                end
            end
        end


        function refreshHierarchy(obj,varargin)
            obj.DataProvider.refreshHierarchy;
            if~isempty(varargin)
                refreshData=varargin{1};
                id=refreshData.id;
                nodeInfo=obj.DataProvider.getNodeInfoByID(id);
                nodeInfo=[nodeInfo{:}];
                [~,idx]=unique([nodeInfo.ID]);
                message.publish(obj.channel,...
                struct('action','setSelect','nodes',nodeInfo(idx)));
            end
        end

        function refreshView(obj)
            obj.DataModel.refreshView;
        end


        function exists=rootNodeExists(obj,nodeId)
            rootNodes=obj.DataProvider.getRootNodes;
            exists=any(cellfun(@(o)strcmp(o.getObjectID,nodeId),rootNodes));
        end

        function processClientRequest(obj,actionInfo)
            success=true;
            switch actionInfo.action
            case 'Remove'
                obj.DataProvider.removeNodeByUUID(actionInfo.data.id);
            otherwise
                disp('unknown action');
            end

            message.publish(obj.channel,struct('action',actionInfo.action,'success',success));
        end

        function delete(obj)
            message.unsubscribe(obj.listener);
        end
    end

    methods(Hidden=true)


        function expandNode(obj,node)
            obj.DataProvider.expandNode(node);
        end

        function expandNodeByUUID(obj,uuid)
            obj.DataProvider.expandNodeByUUID(uuid);
        end


        function collapseNode(obj,node)
            obj.DataProvider.collapseNode(node);
        end

        function collapseNodeByUUID(obj,uuid)
            obj.DataProvider.collapseNodeByUUID(uuid);
        end




        function topnodes=getRootNodes(obj)
            topnodes=obj.DataProvider.getRootNodes();
        end


        function topnodes=getRootNodesUUID(obj)
            topnodes=obj.DataProvider.getRootNodesUUID();
        end




        function childnodes=getChildNodes(obj,parentNode)
            childnodes=obj.DataProvider.getChildNodes(parentNode);
        end

        function childnodes=getChildNodesUUID(obj,pUUID)
            childnodes=obj.DataProvider.getChildNodesUUID(pUUID);
        end


        function nodeInfo=getNodeInfo(obj,uuid)
            nodeInfo=obj.DataProvider.getNodeInfo(uuid);
        end
    end
end

