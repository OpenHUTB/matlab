classdef PortDesigner<matlab.apps.AppBase


    properties(Access=public)
        SelectportsUIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        ActorhierarchyLabel matlab.ui.control.Label
        ListPorts matlab.ui.control.ListBox
        GridLayout3 matlab.ui.container.GridLayout
        CancelButton matlab.ui.control.Button
        OKButton matlab.ui.control.Button
        GridLayout2 matlab.ui.container.GridLayout
        ButtonDel matlab.ui.control.Button
        ButtonAdd matlab.ui.control.Button
        FindactorLabel matlab.ui.control.Label
        PortsLabel matlab.ui.control.Label
        PropertyLabel matlab.ui.control.Label
        ListProperties matlab.ui.control.ListBox
        EditObject matlab.ui.control.EditField
        Tree matlab.ui.container.Tree
    end


    properties(Access=private)
        ClassInfo;
Actor
Component
BlockHandle
    end



    methods(Access=private)


        function startupFcn(app,Actor,Ports,Component,BlockHandle)
            movegui(app.SelectportsUIFigure,'center');
            if nargin==5
                app.ClassInfo=?sim3d.Actor;
                inputPropertyList={'Translation','Rotation','Scale',...
                'Color','Transparency','Shininess','Metallic','Tessellation',...
                'Mass','CenterOfMass','Collisions'};
                outputPropertyList={'Translation','Rotation','Scale',...
                'Color','Transparency','Shininess','Metallic','Tessellation',...
                'Mass','CenterOfMass','Collisions'};
                eventList={'OnHit','Activate','BeginOverlap','EndOverlap','IsOverlapped','Control','Menu'};
                if strcmp(Component,'EventsText')
                    app.PortsLabel.Text='Event ports';
                    app.ListProperties.Items=eventList;
                elseif strcmp(Component,'InputsText')
                    app.PortsLabel.Text='Input ports';
                    app.ListProperties.Items=inputPropertyList;
                else
                    app.PortsLabel.Text='Output ports';
                    app.ListProperties.Items=outputPropertyList;
                end
                app.ListProperties.Value=app.ListProperties.Items{1};

                app.ListPorts.Items=Ports(~cellfun('isempty',Ports));
                app.Actor=Actor;
                app.Component=Component;
                app.BlockHandle=BlockHandle;
                AddNode(app.Tree,Actor);
                app.Tree.SelectedNodes=app.Tree.Children;
            end

            function AddNode(ANode,AActor)
                newNode=uitreenode(ANode,'Text',AActor.getTag());
                newNode.UserData=[newNode.Text,'.'];

                if~isempty(AActor.getChildList())
                    children=struct2cell(AActor.Children);
                    for k=1:numel(children)
                        AddNode(newNode,children{k});
                    end
                end
                ANode.expand;
            end
        end


        function TreeSelectionChanged(app,event)

        end


        function ButtonAddPushed(app,event)
            RefName=app.Tree.SelectedNodes.UserData;
            NewItem=[RefName,app.ListProperties.Value];
            existingList=app.ListPorts.Items;
            if~any(ismember(existingList,{NewItem}))
                app.ListPorts.Items=horzcat(app.ListPorts.Items,{NewItem});
            end
        end


        function ButtonDelPushed(app,event)
            if~isempty(app.ListPorts.Value)
                id=strcmp(app.ListPorts.Items,app.ListPorts.Value);
                app.ListPorts.Items(id)=[];
            end
        end


        function CancelButtonPushed(app,event)
            app.delete;
        end


        function OKButtonPushed(app,event)
            set_param(app.BlockHandle,app.Component,char(app.ListPorts.Items));
            app.delete;
        end


        function EditObjectValueChanged(app,event)
            FindNode(app.Tree.Children(1),app.EditObject.Value);

            function FindNode(Node,Text)
                if contains(Node.Text,Text,'IgnoreCase',true)
                    app.Tree.SelectedNodes=Node;
                else
                    n=numel(Node.Children);
                    for i=0:n-1
                        FindNode(Node.Children(n-i),Text);
                    end
                end
            end
        end
    end


    methods(Access=private)


        function createComponents(app)


            pathToMLAPP=fileparts(mfilename('fullpath'));


            app.SelectportsUIFigure=uifigure('Visible','off');
            app.SelectportsUIFigure.Position=[400,300,640,480];
            app.SelectportsUIFigure.Name='Select ports';
            app.SelectportsUIFigure.WindowStyle='modal';


            app.GridLayout=uigridlayout(app.SelectportsUIFigure);
            app.GridLayout.ColumnWidth={'5x','3x','1x','4x'};
            app.GridLayout.RowHeight={'1x','15x','1x','1x'};


            app.Tree=uitree(app.GridLayout);
            app.Tree.SelectionChangedFcn=createCallbackFcn(app,@TreeSelectionChanged,true);
            app.Tree.Layout.Row=2;
            app.Tree.Layout.Column=1;


            app.EditObject=uieditfield(app.GridLayout,'text');
            app.EditObject.ValueChangedFcn=createCallbackFcn(app,@EditObjectValueChanged,true);
            app.EditObject.Tooltip={'you can use your own name if it is not in the tree'};
            app.EditObject.Layout.Row=4;
            app.EditObject.Layout.Column=1;


            app.ListProperties=uilistbox(app.GridLayout);
            app.ListProperties.Items={};
            app.ListProperties.Layout.Row=2;
            app.ListProperties.Layout.Column=2;
            app.ListProperties.Value={};


            app.PropertyLabel=uilabel(app.GridLayout);
            app.PropertyLabel.FontWeight='bold';
            app.PropertyLabel.Layout.Row=1;
            app.PropertyLabel.Layout.Column=2;
            app.PropertyLabel.Text='Property';


            app.PortsLabel=uilabel(app.GridLayout);
            app.PortsLabel.FontWeight='bold';
            app.PortsLabel.Layout.Row=1;
            app.PortsLabel.Layout.Column=4;
            app.PortsLabel.Text='Ports';


            app.FindactorLabel=uilabel(app.GridLayout);
            app.FindactorLabel.Layout.Row=3;
            app.FindactorLabel.Layout.Column=1;
            app.FindactorLabel.Text='Find actor';


            app.GridLayout2=uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth={'1x'};
            app.GridLayout2.RowHeight={'1x','1x','1x','1x','1x'};
            app.GridLayout2.Padding=[0,0,0,0];
            app.GridLayout2.Layout.Row=2;
            app.GridLayout2.Layout.Column=3;


            app.ButtonAdd=uibutton(app.GridLayout2,'push');
            app.ButtonAdd.ButtonPushedFcn=createCallbackFcn(app,@ButtonAddPushed,true);
            app.ButtonAdd.Icon=fullfile(pathToMLAPP,'ui','arrowRightBlack.svg');
            app.ButtonAdd.Layout.Row=2;
            app.ButtonAdd.Layout.Column=1;
            app.ButtonAdd.Text='';


            app.ButtonDel=uibutton(app.GridLayout2,'push');
            app.ButtonDel.ButtonPushedFcn=createCallbackFcn(app,@ButtonDelPushed,true);
            app.ButtonDel.Icon=fullfile(pathToMLAPP,'ui','arrowleftBlack.svg');
            app.ButtonDel.Layout.Row=4;
            app.ButtonDel.Layout.Column=1;
            app.ButtonDel.Text='';


            app.GridLayout3=uigridlayout(app.GridLayout);
            app.GridLayout3.RowHeight={'1x'};
            app.GridLayout3.Padding=[0,0,0,0];
            app.GridLayout3.Layout.Row=4;
            app.GridLayout3.Layout.Column=4;


            app.OKButton=uibutton(app.GridLayout3,'push');
            app.OKButton.ButtonPushedFcn=createCallbackFcn(app,@OKButtonPushed,true);
            app.OKButton.Layout.Row=1;
            app.OKButton.Layout.Column=1;
            app.OKButton.Text='OK';


            app.CancelButton=uibutton(app.GridLayout3,'push');
            app.CancelButton.ButtonPushedFcn=createCallbackFcn(app,@CancelButtonPushed,true);
            app.CancelButton.Layout.Row=1;
            app.CancelButton.Layout.Column=2;
            app.CancelButton.Text='Cancel';


            app.ListPorts=uilistbox(app.GridLayout);
            app.ListPorts.Items={};
            app.ListPorts.Layout.Row=2;
            app.ListPorts.Layout.Column=4;
            app.ListPorts.Value={};


            app.ActorhierarchyLabel=uilabel(app.GridLayout);
            app.ActorhierarchyLabel.FontWeight='bold';
            app.ActorhierarchyLabel.Layout.Row=1;
            app.ActorhierarchyLabel.Layout.Column=1;
            app.ActorhierarchyLabel.Text='Actor hierarchy';


            app.SelectportsUIFigure.Visible='on';
        end
    end


    methods(Access=public)


        function app=PortDesigner(varargin)

            runningApp=getRunningApp(app);


            if isempty(runningApp)


                createComponents(app)


                registerApp(app,app.SelectportsUIFigure)


                runStartupFcn(app,@(app)startupFcn(app,varargin{:}))
            else


                figure(runningApp.SelectportsUIFigure)

                app=runningApp;
            end

            if nargout==0
                clear app
            end
        end


        function delete(app)


            delete(app.SelectportsUIFigure)
        end
    end
end