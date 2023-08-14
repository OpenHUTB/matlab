function output=connectTree(input,UseDefaultCustomizationData,varargin)
    am=Advisor.Manager.getInstance;
    customizationData=am.slCustomizationDataStructure;
    if UseDefaultCustomizationData
        TaskAdvisorCellArray=customizationData.DefaultCustomizationData.TaskAdvisorCellArray;
    else
        TaskAdvisorCellArray=customizationData.TaskAdvisorCellArray;
    end
    if~isempty(varargin)
        fullTree=varargin{1};
    else
        fullTree=input;
    end
    for i=1:length(input)
        if~isempty(input{i}.ParentIndex)
            input{i}.ParentObj=fullTree{input{i}.ParentIndex};
        end
        if isa(input{i},'ModelAdvisor.Task')
            NextInProcedureCallGraphObjs=[];
            for j=1:length(input{i}.NextInProcedureCallGraph)
                NextInProcedureCallGraphObjs=[NextInProcedureCallGraphObjs,find_new_procedure_links(input,TaskAdvisorCellArray{input{i}.NextInProcedureCallGraph(j)}.ID)];%#ok<AGROW>
            end
            input{i}.NextInProcedureCallGraph=NextInProcedureCallGraphObjs;

            PreviousInProcedureCallGraphObjs=[];
            for j=1:length(input{i}.PreviousInProcedureCallGraph)
                PreviousInProcedureCallGraphObjs=[PreviousInProcedureCallGraphObjs,find_new_procedure_links(input,TaskAdvisorCellArray{input{i}.PreviousInProcedureCallGraph(j)}.ID)];%#ok<AGROW>
            end
            input{i}.PreviousInProcedureCallGraph=PreviousInProcedureCallGraphObjs;
        end
        if isa(input{i},'ModelAdvisor.Group')&&~isempty(input{i}.ChildrenIndex)

            input{i}.ChildrenObj=cell(1,length(input{i}.ChildrenIndex));
            for j=1:length(input{i}.ChildrenIndex)
                input{i}.ChildrenObj{j}=fullTree{input{i}.ChildrenIndex{j}};
                input{i}.addChildren(fullTree{input{i}.ChildrenIndex{j}},'connect_only');
            end
        end
    end
    output=input;
end


function newlinkObj=find_new_procedure_links(input,linkObjID)
    newlinkObj=[];
    for i=1:numel(input)
        if strcmp(input{i}.ID,linkObjID)
            newlinkObj=input{i};
            return
        end
    end
end
