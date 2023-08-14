classdef VariableBrowserComponent<matlab.ui.componentcontainer.ComponentContainer






    properties(Access={?matlab.uitest.TestCase,?matlab.unittest.TestCase})
        Grid matlab.ui.container.GridLayout
TableTree
        Map containers.Map
        SelectedVariables_I=struct;
Data
ContextMenuWithDelete
ContextMenuWithoutDelete
    end

    properties
VariableSelectionChangedFcn
UserInteractionCallFcn
        EnableColumnSelectionAcrossVariables(1,1)logical=false;
    end

    properties(Dependent)
SelectedVariables
Interactive
    end

    methods(Access=public)
        function tableName=getTableName(this)
            tableName=this.TableTree.Children.NodeData;
        end
    end

    methods(Access=protected)
        function setup(obj)
            obj.Grid=uigridlayout(obj,[1,1],'ColumnWidth',{'1x'},'RowHeight',{'1x'});
            obj.Grid.Padding=[0,0,0,0];
            obj.VariableSelectionChangedFcn=@(e,d)obj.updateSelectedVars(d);
            obj.TableTree=uitree(obj.Grid,'checkbox');
            obj.TableTree.Editable='on';
            obj.TableTree.Layout.Row=1;
            obj.TableTree.Layout.Column=1;
            obj.TableTree.CheckedNodesChangedFcn=@(e,d)obj.selectionChanged(d);


            obj.TableTree.NodeTextChangedFcn=@(e,d)obj.nodeTextChanged(d);
        end

        function update(~)
        end

        function selectionChanged(this,eventData)
            if~isempty(this.VariableSelectionChangedFcn)&&~isempty(eventData)
                selectedData.Columns=string.empty;
                selectedData.Variable=string.empty;

                for i=1:length(eventData.CheckedNodes)
                    if~isequal(eventData.CheckedNodes(i).Parent,this.TableTree)
                        if isequal(width(this.Data.(eventData.CheckedNodes(i).NodeData)),1)
                            selectedData.Columns=[selectedData.Columns,{eventData.CheckedNodes(i).NodeData}];
                        end
                    else
                        selectedData.Variable=eventData.CheckedNodes(i).NodeData;
                    end
                end

                if isempty(selectedData.Variable)
                    selectedData.Variable=string(this.getTableName());
                end

                try
                    this.SelectedVariables_I=selectedData;
                    this.VariableSelectionChangedFcn(this,selectedData);
                catch e
                    disp(e);
                end
            end
        end


        function updateSelectedVars(this,eventData)
            this.SelectedVariables=eventData;
        end


        function updateMap(this)

            this.Map=containers.Map();
            for i=1:length(this.TableTree.Children)
                data=this.TableTree.Children(i);
                dataChildren=data.Children;
                nodeData=data.NodeData;
                for j=1:length(data.Children)
                    key=nodeData+"."+dataChildren(j).NodeData;
                    this.Map(key)=dataChildren(j);
                end

            end
        end
    end

    methods

        function set.SelectedVariables(this,SelectedVariables)
            this.TableTree.CheckedNodes=[];
            this.SelectedVariables_I=struct;


            for j=1:length(SelectedVariables)
                this.SelectedVariables_I(j).Columns=string.empty;
                this.SelectedVariables_I(j).Variable=SelectedVariables(j).Variable;
                for i=1:length(SelectedVariables(j).Columns)
                    selKey=SelectedVariables(j).Variable+"."+SelectedVariables(j).Columns(i);
                    if isKey(this.Map,selKey)
                        val=this.Map(selKey);

                        this.SelectedVariables_I(j).Columns(i)=SelectedVariables(j).Columns(i);
                        if isempty(this.TableTree.CheckedNodes)
                            this.TableTree.CheckedNodes=val;
                        else
                            this.TableTree.CheckedNodes(end+1)=val;
                        end
                    end
                end
            end
        end

        function initializeContextMenus(this)
            fig=ancestor(this,"figure");

            deleteMenuItem=[];

            if isempty(this.ContextMenuWithDelete)
                this.ContextMenuWithDelete=uicontextmenu(fig,"Tag","ContextMenuWithDeleteTag");
                deleteMenuItem=uimenu(this.ContextMenuWithDelete,'Text',getString(message('MATLAB:datatools:preprocessing:variableBrowser:variableBrowser:CONTEXT_MENU_DELETE')));
            end

            if isempty(this.ContextMenuWithoutDelete)
                this.ContextMenuWithoutDelete=uicontextmenu(fig,"Tag","ContextMenuWithoutDeleteTag");
            end

            if~isempty(deleteMenuItem)
                deleteMenuItem.MenuSelectedFcn=@(e,d)this.deleteTableColumns(e,d);
            end
        end

        function value=get.SelectedVariables(this)
            value=this.SelectedVariables_I;
        end

        function value=get.Interactive(this)
            value=this.TableTree.Enable;
        end

        function set.Interactive(this,value)
            this.TableTree.Enable=value;
        end

        function addData(this,data,varName)
            this.Data=data;



            variableNode=uitreenode(this.TableTree);
            variableNode.Text=varName;
            variableNode.NodeData=varName;

            varNames=data.Properties.VariableNames;

            isTimeTable=false;
            if istimetable(data)
                varNames=[data.Properties.DimensionNames{1},varNames];
                isTimeTable=true;
            end

            this.initializeContextMenus();
            treeComp=this.TableTree;
            timeNode=[];
            for i=1:length(varNames)

                columnNode=uitreenode(variableNode);
                columnNode.Text=varNames{i};
                columnNode.NodeData=varNames{i};
                if(isTimeTable&&i==1)
                    columnNode.ContextMenu=this.ContextMenuWithoutDelete;
                    timeNode=columnNode;
                else
                    columnNode.ContextMenu=this.ContextMenuWithDelete;
                end
            end
            expand(this.TableTree);


            this.updateMap();



            SelectedVarsStruct={};
            SelectedVarsStruct.Variable=this.getTableName();
            SelectedVarsStruct.Columns=[];
            this.SelectedVariables=SelectedVarsStruct;

            if~isempty(timeNode)
                addStyle(treeComp,uistyle('FontWeight','bold'),'node',timeNode);
            end
        end

        function deleteTableColumns(this,eventSrc,eventData)
            actioInfo=struct();
            actioInfo.error=false;
            actioInfo.type='Delete';
            if isequal(length(this.SelectedVariables.Columns),...
                length(this.Data.Properties.VariableNames))
                actioInfo.error=true;
            else
                actioInfo.codeObj=matlab.internal.preprocessingApp.variableBrowser.deleteTableColumnAction...
                (this.SelectedVariables.Variable,string(this.TableTree.SelectedNodes.Text));
            end
            this.UserInteractionCallFcn(actioInfo);
        end

        function nodeTextChanged(this,e)
            if isempty(e.Text)
                e.Node.Text=e.PreviousText;
                return;
            end

            if isequal(e.Node.Parent,this.TableTree)
                e.Node.Text=e.PreviousText;
                return;
            end


            textArr=split(e.Node.Text,"(");
            newNodeData=string(textArr(1));
            oldNodeData=e.Node.NodeData;
            e.Node.NodeData=newNodeData;
            this.updateMap();
            actionInfo=struct();
            actionInfo.type='Rename';
            actionInfo.error=false;
            if isequal(e.Node.Parent,this.TableTree)
                isVarNode=true;
                codeObj=matlab.internal.preprocessingApp.variableBrowser.renameTableColumnAction(this.Data,oldNodeData,oldNodeData,newNodeData,isVarNode);
                this.SelectedVariables.Variable=this.getTableName();
            else
                codeObj=matlab.internal.preprocessingApp.variableBrowser.renameTableColumnAction(this.Data,e.Node.Parent.NodeData,oldNodeData,newNodeData);
            end
            actionInfo.codeObj=codeObj;
            s=matlab.internal.preprocessingApp.selection.Selection.getInstance();
            selectedVars=s.SelectedTableVariables;
            index=find(contains(selectedVars,oldNodeData));
            if~isequal(index,-1)
                selectedVars(index)=newNodeData;
            end
            selection=struct('SelectedVariable',s.SelectedVariable,...
            'SelectedTableVariables',selectedVars,...
            'LastChangedSrc',s.LastChangedSrc);
            s.setSelection(selection,false);
            this.UserInteractionCallFcn(actionInfo);
        end

        function removeData(this,varName)

            for i=1:length(this.TableTree.Children)
                if strcmp(this.TableTree.Children(i).NodeData,varName)
                    data=this.TableTree.Children(i);
                    dataChildren=data.Children;
                    nodeData=data.NodeData;
                    if strcmp(nodeData,varName)

                        for j=1:length(dataChildren)
                            remove(this.Map,varName+"."+dataChildren(j).NodeData);
                        end

                        removeStyle(this.TableTree);
                        delete(this.TableTree.Children(i));
                        break;
                    end
                end
            end
        end
    end
end
