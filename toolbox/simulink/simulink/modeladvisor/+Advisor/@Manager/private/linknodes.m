function[topLevelWorkFlows,recordCellArray]=linknodes(recordCellArray,varargin)
    topLevelWorkFlows={};





    keySet=cell(1,length(recordCellArray));
    valueSet=(1:length(recordCellArray));
    for i=1:length(recordCellArray)
        keySet{i}=recordCellArray{i}.ID;
    end
    speedIDCell=containers.Map(keySet,valueSet);

    for i=1:length(recordCellArray)
        recordCellArray{i}.Index=i;




        if~recordCellArray{i}.Visible
            continue;
        end

        if isa(recordCellArray{i},'ModelAdvisor.Group')
            for j=1:length(recordCellArray{i}.Children)
                jchildren=recordCellArray{i}.Children{j};


                if speedIDCell.isKey(jchildren)
                    k=speedIDCell(jchildren);
                    if isempty(recordCellArray{k}.ParentObj)


                        if isa(recordCellArray{k},'ModelAdvisor.FactoryGroup')&&...
                            strcmp(recordCellArray{i}.ID,'_SYSTEM_BY_TASK')
                            DAStudio.error('Simulink:tools:MAFactoryGrpUnderGrp',recordCellArray{k}.DisplayName);
                        end

                        recordCellArray{i}.ChildrenObj{end+1}=recordCellArray{k};
                        if isa(recordCellArray{i},'ModelAdvisor.Group')&&...
                            isa(recordCellArray{k},'ModelAdvisor.Task')&&~isempty(recordCellArray{k}.MAC)
                            recordCellArray{i}.ChildrenMACIndex{end+1}=recordCellArray{k}.MACIndex;
                            if isa(recordCellArray{i},'ModelAdvisor.Procedure')
                                recordCellArray{k}.ShowCheckbox=false;
                                recordCellArray{k}.Selected=false;
                                if isa(recordCellArray{k},'ModelAdvisor.Task')


                                    recordCellArray{k}.Enable=false;
                                end
                                if recordCellArray{k}.ShowCheckboxInProcedure
                                    recordCellArray{k}.ShowCheckbox=true;
                                    recordCellArray{k}.Selected=true;
                                    recordCellArray{k}.Enable=true;
                                end
                            end
                        end






                        recordCellArray{i}.ChildrenIndex{end+1}=k;
                        recordCellArray{k}.ParentIndex=i;
                    else
                        DAStudio.error('Simulink:tools:MAMultipleParentFound',recordCellArray{k}.DisplayName);
                    end
                end
            end
        end
    end


    if nargin>2
        ConfigUIRoot=varargin{1};
        ValidTopLevelNodes=[];
        for i=1:length(ConfigUIRoot.ChildrenObj)
            ValidTopLevelNodes(end+1)=ConfigUIRoot.ChildrenObj{i}.Index;%#ok<AGROW>
        end
    end


    for i=1:length(recordCellArray)
        if isa(recordCellArray{i},'ModelAdvisor.Group')
            loc_getAllChindrenIndex(recordCellArray{i});
        end
        if recordCellArray{i}.Visible

            if isempty(recordCellArray{i}.ParentIndex)

                IsValidTopLevelNode=true;
                if nargin>2
                    if~any(i==ValidTopLevelNodes)
                        IsValidTopLevelNode=false;
                    end
                end
                if recordCellArray{i}.Published&&IsValidTopLevelNode



                    topLevelWorkFlows{end+1}=i;%#ok<AGROW>
                end

                loc_set1stTaskNodeUnderProcedure(recordCellArray{i},false,[],false);
            else
                if recordCellArray{i}.Published
                    DAStudio.error('Simulink:tools:MAMultipleParentFound',recordCellArray{i}.DisplayName);
                end
            end
        end
    end
end

function indexArray=loc_getAllChindrenIndex(this)
    indexArray={};
    if isa(this,'ModelAdvisor.Group')
        if isempty(this.AllChildrenIndex)
            for i=1:length(this.ChildrenObj)
                indexArray{end+1}=this.ChildrenObj{i}.Index;%#ok<AGROW>
                if isa(this.ChildrenObj{i},'ModelAdvisor.Group')&&~isempty(this.ChildrenObj{i}.Children)
                    indexArray=[indexArray,loc_getAllChindrenIndex(this.ChildrenObj{i})];%#ok<AGROW>
                end
            end
            this.AllChildrenIndex=indexArray;
        else
            indexArray=this.AllChildrenIndex;
        end
    end
end


function[found1stTaskNodeInThisScope,activeNode]=loc_set1stTaskNodeUnderProcedure(start_node,found1stTaskNodeInThisScope,activeNode,InsideProcedure)
    if isa(start_node,'ModelAdvisor.Procedure')
        InsideProcedure=true;
        loopthroughNodes=start_node.getChildren;
        for i=1:length(loopthroughNodes)
            if isa(loopthroughNodes(i),'ModelAdvisor.Task')
                if~found1stTaskNodeInThisScope
                    loopthroughNodes(i).Selected=true;
                    loopthroughNodes(i).Enable=true;
                    found1stTaskNodeInThisScope=true;
                    activeNode=loopthroughNodes(i);
                else
                    for j=1:length(activeNode)
                        activeNode(j).NextInProcedureCallGraph=[activeNode(j).NextInProcedureCallGraph,loopthroughNodes(i).Index];
                        loopthroughNodes(i).PreviousInProcedureCallGraph=[loopthroughNodes(i).PreviousInProcedureCallGraph,activeNode(j).Index];
                    end
                    activeNode=loopthroughNodes(i);
                end
            elseif isa(loopthroughNodes(i),'ModelAdvisor.Procedure')
                [found1stTaskNodeInThisScope,activeNode]=loc_set1stTaskNodeUnderProcedure(loopthroughNodes(i),found1stTaskNodeInThisScope,activeNode,InsideProcedure);
            elseif isa(loopthroughNodes(i),'ModelAdvisor.Group')
                [found1stTaskNodeInThisScope,activeNode]=loc_set1stTaskNodeUnderProcedure(loopthroughNodes(i),found1stTaskNodeInThisScope,activeNode,InsideProcedure);
            end
        end
    elseif isa(start_node,'ModelAdvisor.Group')
        loopthroughNodes=start_node.getChildren;
        if InsideProcedure
            start_node.ShowCheckbox=false;
        end
        newactiveNode=[];
        for i=1:length(loopthroughNodes)
            if isa(loopthroughNodes(i),'ModelAdvisor.Task')

                if~found1stTaskNodeInThisScope
                else
                    for j=1:length(activeNode)
                        activeNode(j).NextInProcedureCallGraph=[activeNode(j).NextInProcedureCallGraph,loopthroughNodes(i).Index];
                        loopthroughNodes(i).PreviousInProcedureCallGraph=[loopthroughNodes(i).PreviousInProcedureCallGraph,activeNode(j).Index];
                    end
                    newactiveNode=[newactiveNode,loopthroughNodes(i)];%#ok<AGROW>
                end
            elseif isa(loopthroughNodes(i),'ModelAdvisor.Procedure')
                [~,tempactiveNode]=loc_set1stTaskNodeUnderProcedure(loopthroughNodes(i),found1stTaskNodeInThisScope,activeNode,InsideProcedure);
                newactiveNode=[newactiveNode,tempactiveNode];%#ok<AGROW>
            elseif isa(loopthroughNodes(i),'ModelAdvisor.Group')
                [~,tempactiveNode]=loc_set1stTaskNodeUnderProcedure(loopthroughNodes(i),found1stTaskNodeInThisScope,activeNode,InsideProcedure);
                newactiveNode=[newactiveNode,tempactiveNode];%#ok<AGROW>
            end
        end
        activeNode=newactiveNode;
    end
end
