classdef Inspector<handle
    properties(SetObservable=true)
App
mdomApp
MainTable
DataModel
DataProvider
listener
channel
    end

    methods

        function obj=Inspector(diagramApp)
            obj.App=diagramApp;

            obj.channel=strcat('/inspector/',obj.App.editor.uuid,'/messagechannel');
            obj.listener=message.subscribe(obj.channel,@(msg)obj.processClientRequest(msg));

            obj.DataProvider=classdiagram.app.core.inspector.InspectorProvider;
            obj.DataModel=mdom.DataModel(obj.DataProvider);


            obj.mdomApp=mdom.App;
            obj.mdomApp.beginTransaction();
            obj.MainTable=obj.mdomApp.createWidget('mdom.TreeTable',struct('tag','Inspector','dataModel',obj.DataModel.getID,'selectionMode',mdom.SelectionMode.Single));
            obj.mdomApp.endTransaction();

            obj.mdomApp.start();

            obj.DataModel.columnChanged(2,{});


            obj.updateSource(obj.App.getClassDiagramFactory().getPropertySchema(''));
        end

        function updateSource(obj,schema)

            obj.DataProvider.updateSource(schema);

            if~isempty(schema)&&isa(schema,"classdiagram.app.core.inspector.PropertySchemaInterface")

                subProps=schema.subProperties(obj.DataProvider.RootID);
                obj.DataModel.rowChanged('',length(subProps),{});


                expandRootNodes=schema.defaultExpandGroups();
                if~isempty(expandRootNodes)
                    indexes=contains(subProps,expandRootNodes);
                    for i=1:length(indexes)
                        if indexes(i)
                            p=subProps(i);
                            props=schema.subProperties(p);
                            obj.DataModel.updateRowID(mdom.RowIndex(obj.DataProvider.RootID,i-1),p);
                            obj.DataModel.rowChanged(p,length(props),{});
                        end
                    end
                end
            end
        end

        function refreshInspector(obj)
            selected=obj.App.editor.getSelection().getPrimary();
            if selected.isValid
                objectID=selected.getAttribute('ObjectID').value;
            else
                objectID='';
            end

            factory=obj.App.getClassDiagramFactory();
            schema=factory.getPropertySchema(objectID);
            obj.updateSource(schema);

            if~isempty(schema)
                message.publish(obj.channel,struct('action','showInspector'));
            else
                notifObj=[];
                element=factory.getObject(objectID);
                if isa(element,'classdiagram.app.core.domain.BaseObject')
                    switch element.ConstantType
                    case{'Event','Method','Property'}
                        notifObj=classdiagram.app.core.notifications.notifications.PIError(...
                        'classdiagram_editor:messages:PI_CanNotShowClassEntity',...
                        lower(string(element.ConstantType)),string(element.getName));
                    case{'Enum','Class'}
                        name=string(element.getName);
                        nameParts=name.split('.');
                        notifObj=classdiagram.app.core.notifications.notifications.PIError(...
                        'classdiagram_editor:messages:PI_ClassNotFound',...
                        string(element.ConstantType),nameParts(end));
                    case 'EnumLiteral'
                        enum=element.getOwningEnum;
                        name=string(enum.getName);
                        nameParts=name.split('.');
                        notifObj=classdiagram.app.core.notifications.notifications.PIError(...
                        'classdiagram_editor:messages:PI_ClassNotFound',...
                        string(enum.ConstantType),nameParts(end));
                    end
                end

                if~isempty(notifObj)

                    message.publish(obj.channel,struct('action','showMessage',...
                    'message',notifObj.DisplayMessage));



                end
            end
        end

        function processClientRequest(obj,actionInfo)
            switch actionInfo.action
            case 'InspectorReady'
                message.publish(obj.channel,struct('action','initMDOM','mdom_id',obj.mdomApp.getID));
            case 'SelectionChanged'
                obj.refreshInspector();
            otherwise
                disp('unknown action');
            end
        end

        function schema=getSchema(obj)
            schema=obj.DataProvider.PropertySchema;
        end

        function delete(obj)
            message.unsubscribe(obj.listener);
        end
    end

    methods(Hidden=true)
        function expanded=nodeExpanded(obj,nodeName)
            expanded=obj.DataModel.isRowExpanded(nodeName);
        end
    end
end

