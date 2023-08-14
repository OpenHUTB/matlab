function output=stackoperation(method)




    persistent stack;
    persistent op;
    persistent ep;
    persistent redo_counter;
    persistent stack_size;


    if isempty(op)
        op=1;
        ep=1;
        redo_counter=0;
        stack_size=2;
        stack=cell(1,stack_size);
    end

    switch method
    case 'push'
        op=loc_plus(op,stack_size);
        if op==ep
            ep=loc_plus(ep,stack_size);
        end
        stack=loc_save_to_stack(stack,op);
        redo_counter=0;
        modeladvisorprivate('modeladvisorutil2','UpdateUndoRedoMenuToolbar');
    case{'pop','undo'}
        if ModelAdvisor.ConfigUI.stackoperation('undo_times')>0
            temp=save_current_state;
            loc_load_from_stack(stack,op);
            stack{op}=temp;
            op=loc_minus(op,stack_size);
            redo_counter=redo_counter+1;
            modeladvisorprivate('modeladvisorutil2','UpdateUndoRedoMenuToolbar');
        end
    case 'redo'
        if redo_counter>0
            temp=save_current_state;
            redo_counter=redo_counter-1;
            op=loc_plus(op,stack_size);
            loc_load_from_stack(stack,op);
            stack{op}=temp;
            modeladvisorprivate('modeladvisorutil2','UpdateUndoRedoMenuToolbar');
        end
    case 'init'
        op=1;
        ep=1;
        redo_counter=0;
        stack_size=2;
        for i=1:length(stack)
            for j=1:length(stack{i})
                stack{i,j}.MAObj=[];
            end
        end
        stack=cell(1,stack_size);
        modeladvisorprivate('modeladvisorutil2','UpdateUndoRedoMenuToolbar');
    case 'undo_times'
        if op>=ep
            output=op-ep;
        else
            output=stack_size-(ep-op);
        end
    case 'redo_times'
        output=redo_counter;
    case 'debug'
        disp(['op ',num2str(op)]);
        disp(['ep ',num2str(ep)]);
        disp(['undo_times ',num2str(ModelAdvisor.ConfigUI.stackoperation('undo_times'))]);
        disp(['redo_counter ',num2str(redo_counter)]);
    end

    function output=loc_plus(input,stack_size)
        if input>=stack_size
            output=1;
        else
            output=input+1;
        end

        function output=loc_minus(input,stack_size)
            if input==1
                output=stack_size;
            else
                output=input-1;
            end

            function tempStruct=save_current_state
                mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
                temp=cell(1,length(mdladvObj.ConfigUICellArray)+1);
                temp{1}=loc_fastcopy(mdladvObj.ConfigUIRoot,temp{1});
                temp2=mdladvObj.ConfigUICellArray;
                for i=1:length(temp2)
                    temp2{i}.Index=i;
                end
                temp{1}.Index=0;
                for j=1:length(mdladvObj.ConfigUIRoot.ChildrenObj)
                    temp{1}.ChildrenObj{j}=mdladvObj.ConfigUIRoot.ChildrenObj{j}.Index;
                end
                for i=1:length(temp2)
                    temp{i+1}=loc_fastcopy(temp2{i},temp{i+1});
                    if~isempty(temp2{i}.ParentObj)
                        temp{i+1}.ParentObj=temp2{i}.ParentObj.Index;
                    end
                    for j=1:length(temp2{i}.ChildrenObj)
                        temp{i+1}.ChildrenObj{j}=temp2{i}.ChildrenObj{j}.Index;
                    end
                end
                tempStruct.data=temp;
                tempStruct.dirty=mdladvObj.ConfigUIDirty;

                me=mdladvObj.ConfigUIWindow;
                if isa(me,'DAStudio.Explorer')
                    imme=DAStudio.imExplorer(me);
                    selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
                    if isa(selectedNode,'ModelAdvisor.ConfigUI')
                        tempStruct.selectedNodeID=selectedNode.ID;
                    else
                        tempStruct.selectedNodeID='';
                    end
                else
                    tempStruct.selectedNodeID='';
                end


                function stack=loc_save_to_stack(stack,position)
                    stack{position}=save_current_state;

                    function loc_load_from_stack(stack,position)
                        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
                        cuicellarrary=stack{position}.data;
                        cuiobjs=cell(1,length(cuicellarrary));
                        for i=1:length(cuicellarrary)
                            cuiobjs{i}=ModelAdvisor.ConfigUI;
                            loc_fastcopy(cuicellarrary{i},cuiobjs{i});
                        end
                        for i=1:length(cuicellarrary)

                            if isfield(cuicellarrary{i},'ParentObj')&&isnumeric(cuicellarrary{i}.ParentObj)

                                cuiobjs{i}.ParentObj=cuiobjs{cuicellarrary{i}.ParentObj+1};

                                cuiobjs{i}.ParentObj.addChildren(cuiobjs{i});
                                for k=1:length(cuicellarrary{cuicellarrary{i}.ParentObj+1}.ChildrenObj)
                                    if isnumeric(cuicellarrary{cuicellarrary{i}.ParentObj+1}.ChildrenObj{k})
                                        cuiobjs{i}.ParentObj.ChildrenObj{k}=cuiobjs{cuicellarrary{cuicellarrary{i}.ParentObj+1}.ChildrenObj{k}+1};
                                    end
                                end
                            end
                        end
                        mdladvObj.ConfigUIRoot=cuiobjs{1};
                        if length(cuicellarrary)>1
                            mdladvObj.ConfigUICellArray=cuiobjs(2:end);
                        else
                            mdladvObj.ConfigUICellArray={};
                        end
                        Simulink.ModelAdvisor.openConfigUI;

                        mdladvObj.ConfigUIDirty=stack{position}.dirty;


                        mdladvObj.setConfigUIDirty(stack{position}.dirty);

                        me=mdladvObj.ConfigUIWindow;
                        if isa(me,'DAStudio.Explorer')&&~isempty(stack{position}.selectedNodeID)
                            imme=DAStudio.imExplorer(me);
                            selectedNode=[];
                            for i=1:length(cuiobjs)
                                if strcmp(cuiobjs{i}.ID,stack{position}.selectedNodeID)
                                    selectedNode=cuiobjs{i};
                                    break
                                end
                            end
                            if isa(selectedNode,'ModelAdvisor.ConfigUI')
                                imme.selectTreeViewNode(selectedNode(1));
                            end
                        end


                        function newobj=loc_fastcopy(obj,newobj)
                            newobj.ID=obj.ID;
                            newobj.OriginalNodeID=obj.OriginalNodeID;
                            newobj.DisplayName=obj.DisplayName;
                            newobj.Description=obj.Description;
                            newobj.HelpMethod=obj.HelpMethod;
                            newobj.HelpArgs=obj.HelpArgs;
                            newobj.Selected=obj.Selected;
                            newobj.InTriState=obj.InTriState;
                            newobj.NeedToggleForTriState=obj.NeedToggleForTriState;
                            newobj.Type=obj.Type;
                            newobj.Visible=obj.Visible;
                            newobj.Enable=obj.Enable;
                            newobj.Value=obj.Value;
                            newobj.Published=obj.Published;
                            newobj.ShowCheckbox=obj.ShowCheckbox;
                            newobj.LicenseName=obj.LicenseName;
                            newobj.CSHParameters=obj.CSHParameters;
                            newobj.InLibrary=obj.InLibrary;
                            newobj.ByTaskMode=obj.ByTaskMode;
                            newobj.Index=obj.Index;
                            newobj.MAC=obj.MAC;
                            newobj.MAObj=obj.MAObj;
                            newobj.MACIndex=obj.MACIndex;

                            newobj.InputParameters=loc_copy_inputparam(obj.InputParameters);
                            newobj.Protected=obj.Protected;
                            newobj.DisplayLabelPrefix=obj.DisplayLabelPrefix;

                            function output=loc_copy_inputparam(input)


                                if isempty(input)
                                    output={};
                                else
                                    for k=1:length(input)
                                        if isa(input{k},'ModelAdvisor.InputParameter')
                                            output{k}=copy(input{k});%#ok<AGROW>
                                        else
                                            output{k}=input{k};%#ok<AGROW>
                                        end
                                    end
                                end
