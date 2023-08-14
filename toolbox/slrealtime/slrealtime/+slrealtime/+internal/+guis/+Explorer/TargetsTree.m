classdef TargetsTree<handle




    properties
App
        Tree matlab.ui.container.Tree
        TargetComputersNode matlab.ui.container.TreeNode
        GridLayout matlab.ui.container.GridLayout
        UpperButtonGridLayout matlab.ui.container.GridLayout
        LowerButtonGridLayout matlab.ui.container.GridLayout
        AddButton matlab.ui.control.Button
        RemoveButton matlab.ui.control.Button
        UpButton matlab.ui.control.Button
        DownButton matlab.ui.control.Button
    end


    methods
        function this=TargetsTree(hApp)
            this.App=hApp;


            this.GridLayout=uigridlayout(this.App.TargetsTreePanel.Figure);
            this.GridLayout.ColumnWidth={35,'1x'};
            this.GridLayout.RowHeight={'1x'};
            this.GridLayout.Padding=[2,2,2,2];
            this.GridLayout.ColumnSpacing=2;
            this.GridLayout.RowSpacing=2;


            this.UpperButtonGridLayout=uigridlayout(this.GridLayout);
            this.UpperButtonGridLayout.ColumnWidth={'1x'};
            this.UpperButtonGridLayout.RowHeight={10,25,25,'1x'};
            this.UpperButtonGridLayout.ColumnSpacing=1;
            this.UpperButtonGridLayout.RowSpacing=5;
            this.UpperButtonGridLayout.Padding=[1,1,1,1];
            this.UpperButtonGridLayout.Layout.Row=1;
            this.UpperButtonGridLayout.Layout.Column=1;


            this.LowerButtonGridLayout=uigridlayout(this.UpperButtonGridLayout);
            this.LowerButtonGridLayout.ColumnWidth={'1x',20};
            this.LowerButtonGridLayout.RowHeight={50,20,20,'1x'};
            this.LowerButtonGridLayout.ColumnSpacing=1;
            this.LowerButtonGridLayout.RowSpacing=3;
            this.LowerButtonGridLayout.Padding=[1,1,1,1];
            this.LowerButtonGridLayout.Layout.Row=4;
            this.LowerButtonGridLayout.Layout.Column=1;


            this.Tree=uitree(this.GridLayout);
            this.Tree.Layout.Row=1;
            this.Tree.Layout.Column=2;
            this.Tree.SelectionChangedFcn=@this.TreeSelectionChanged;



            this.AddButton=uibutton(this.UpperButtonGridLayout,'push');
            this.AddButton.Layout.Row=2;
            this.AddButton.Layout.Column=1;
            this.AddButton.Text='';
            this.AddButton.Icon=this.App.Icons.addTargetIcon;
            this.AddButton.ButtonPushedFcn=@this.AddButtonPushed;


            this.RemoveButton=uibutton(this.UpperButtonGridLayout,'push');
            this.RemoveButton.Layout.Row=3;
            this.RemoveButton.Layout.Column=1;
            this.RemoveButton.Text='';
            this.RemoveButton.Icon=this.App.Icons.deleteTargetIcon;
            this.RemoveButton.ButtonPushedFcn=@this.RemoveButtonPushed;


            this.UpButton=uibutton(this.LowerButtonGridLayout,'push');
            this.UpButton.Layout.Row=2;
            this.UpButton.Layout.Column=2;
            this.UpButton.Text='';
            this.UpButton.Icon=this.App.Icons.moveTargetUpIcon;
            this.UpButton.ButtonPushedFcn=@this.UpButtonPushed;


            this.DownButton=uibutton(this.LowerButtonGridLayout,'push');
            this.DownButton.Layout.Row=3;
            this.DownButton.Layout.Column=2;
            this.DownButton.Text='';
            this.DownButton.Icon=this.App.Icons.moveTargetDownIcon;
            this.DownButton.ButtonPushedFcn=@this.DownButtonPushed;

            this.TargetComputersNode=uitreenode(this.Tree);
            this.TargetComputersNode.Text=getString(message(this.App.Messages.targetComputersMsgId));

        end

        function disable(this)
            if~isempty(this.Tree.Children)
                this.Tree.Children(1).Parent=[];
            end
            this.Tree.Enable='off';

        end

    end




    methods(Access=public,Hidden)
        function treeNodeText=getTreeNodeTextForApplication(this,appName,targetName)



            treeNodeText=appName;
            target=this.App.TargetManager.updateStartupAppInMap(targetName);
            if strcmp(appName,target.startupApp.appName)
                msg=message(this.App.Messages.startupMsgId);
                treeNodeText=[appName,' (',msg.getString(),')'];
            end
        end

        function targetNames=getTreeTargetNames(this)

            targetNodes=this.TargetComputersNode.Children;
            targetNames=cell(size(targetNodes));
            for i=1:length(targetNodes)
                targetNames{i}=targetNodes(i).NodeData.targetName;
            end

        end

        function selectedTargetName=getTreeSelectedTargetName(this)




            selectedTargetName=[];
            treeNode=this.Tree.SelectedNodes;
            if~isempty(treeNode)&&~isempty(treeNode.NodeData)&&treeNode.NodeData.isTarget()
                selectedTargetName=treeNode.NodeData.targetName;
            end
        end

        function selectTargetNameInTree(this,selectedTargetName)
            targetNamesInTree=getTreeTargetNames(this);
            index=find(strcmp(targetNamesInTree,selectedTargetName));
            assert(~isempty(index),'The selected target is not in the Target Computers Tree.');
            selectedTargetNode=this.TargetComputersNode.Children(index);
            this.Tree.SelectedNodes=selectedTargetNode;
            expand(this.TargetComputersNode)
        end

        function[selectedAppName,targetName]=getTreeSelectedAppName(this)




            selectedAppName=[];
            targetName=[];
            treeNode=this.Tree.SelectedNodes;
            if~isempty(treeNode)&&~isempty(treeNode.NodeData)&&treeNode.NodeData.isApp()
                selectedAppName=treeNode.NodeData.appName;
                targetName=treeNode.NodeData.targetName;
            end
        end

        function removeAllAppNodes(this,selectedTargetName)
            target=this.App.TargetManager.getTargetFromMap(selectedTargetName);
            target.node.Children.delete;
        end
    end




    methods(Access=public,Hidden)
        function TreeSelectionChanged(this,Tree,event)



            previousSelectedNodes=event.PreviousSelectedNodes;
            if isempty(previousSelectedNodes)
                previousTargetName=[];
            else
                previousTargetName=previousSelectedNodes.NodeData.targetName;
            end

            selectedNodes=event.SelectedNodes;
            if selectedNodes.NodeData.isTarget()
                selectedTargetName=selectedNodes.NodeData.targetName;
                if~strcmp(previousTargetName,selectedTargetName)
                    this.App.UpdateApp.ForSelectedTarget(selectedTargetName);












                end


            elseif selectedNodes.NodeData.isApp()
                selectedTargetName=selectedNodes.NodeData.targetName;
                if~strcmp(previousTargetName,selectedTargetName)
                    this.App.UpdateApp.ForSelectedTarget(selectedTargetName);
                end
















            end
        end
    end

    methods(Access=private)


        function UpButtonPushed(this,Button,event)
            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            nodes=this.TargetComputersNode.Children;
            idx=find(strcmp(arrayfun(@(x)x.NodeData.targetName,nodes,'UniformOutput',false),selectedTargetName));
            if idx==1

                return;
            end
            tempNode=nodes(idx-1);
            nodes(idx-1)=nodes(idx);
            nodes(idx)=tempNode;
            this.TargetComputersNode.Children=nodes;
            this.Tree.SelectedNodes=nodes(idx-1);
            this.App.UpdateApp.ForMoveTargetControls(selectedTargetName);
        end


        function DownButtonPushed(this,Button,event)
            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            nodes=this.TargetComputersNode.Children;
            idx=find(strcmp(arrayfun(@(x)x.NodeData.targetName,nodes,'UniformOutput',false),selectedTargetName));
            if idx==length(nodes)

                return;
            end
            tempNode=nodes(idx+1);
            nodes(idx+1)=nodes(idx);
            nodes(idx)=tempNode;
            this.TargetComputersNode.Children=nodes;
            this.Tree.SelectedNodes=nodes(idx+1);
            this.App.UpdateApp.ForMoveTargetControls(selectedTargetName);
        end


        function AddButtonPushed(this,button,event)
            try

                targets=slrealtime.Targets;
                target=targets.addTarget();
                targetName=target.TargetSettings.name;
            catch ME
                msg=message(this.App.Messages.errorMsgId);
                uialert(this.App.UpdateApp.getShowingUIFigure(),ME.message,msg.getString());
                return;
            end



            addedTarget=this.App.TargetManager.getTargetFromMap(targetName);
            this.Tree.SelectedNodes=addedTarget.node;
            this.App.UpdateApp.ForSelectedTarget(targetName);

            this.App.TargetConfigurationDocument.Showing=true;
        end


        function RemoveButtonPushed(this,button,event)
            selectedTargetName=this.App.TargetManager.getSelectedTargetName();

            this.App.TargetConfiguration.UIFigure.Visible='on';
            msg1=message(this.App.Messages.deleteTargetPromptMsgId,selectedTargetName);
            msg2=message(this.App.Messages.deleteTargetConfirmMsgId);
            uiconfirm(this.App.TargetConfiguration.UIFigure,msg1.getString(),msg2.getString(),...
            'CloseFcn',@(o,e)this.deleteTargetButtonPushedCloseFcn(o,e,selectedTargetName));
        end

        function deleteTargetButtonPushedCloseFcn(this,~,event,targetName)





            if strcmp(event.SelectedOption,'OK')
                try

                    targets=slrealtime.Targets;
                    targets.removeTarget(targetName);
                catch ME
                    msg=message(this.App.Messages.errorMsgId);
                    uialert(this.App.UpdateApp.getShowingUIFigure(),ME.message,msg.getString());
                end
            end
        end

    end

end
