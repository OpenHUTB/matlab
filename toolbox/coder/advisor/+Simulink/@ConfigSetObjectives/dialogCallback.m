function dialogCallback(hObj,hDlg,tag)




    numOfObjectives=hObj.numOfObjs;
    objName=hObj.objsName;

    objectiveName=cell(1,numOfObjectives);
    for i=1:numOfObjectives
        objectiveName{i}.name=objName{i}.name;
        objectiveName{i}.order=objName{i}.order;
    end

    if hObj.justSwitched
        hObj.justSwitched=false;

        prioritiesOld=hObj.priorities;
        hObj.prioritiesOld=prioritiesOld;

        unselectedOld=hObj.unSelected;
        hObj.unSelectedOld=unselectedOld;
    end


    switch tag
    case 'Tag_Objective_downbutton'
        idxArray=hDlg.getWidgetValue('Tag_Objective_My_Objectives');
        sizes=size(idxArray);
        arraySize=sizes(2);

        priorities=hObj.priorities;

        if isempty(idxArray)||idxArray(end)+1==length(priorities)
            return;
        end

        for arrayIdx=arraySize:-1:1
            idx=idxArray(arrayIdx)+1;

            if(idx>=1&&idx<numOfObjectives)
                thisIdx=idx;
                nextIdx=idx+1;

                temp=priorities{thisIdx};
                priorities{thisIdx}=priorities{nextIdx};
                priorities{nextIdx}=temp;
            end
        end

        hObj.priorities=priorities;
        hObj.listbox2selected=idxArray(1)+1;
        loc_SetObjectivePrioritiesCopy(hObj,priorities);
        if~isempty(hObj.base)
            hObj.base.Objectives=hObj.opCopy;
            hObj.base.refreshCheckList;
        end

    case 'Tag_Objective_upbutton'
        idxArray=hDlg.getWidgetValue('Tag_Objective_My_Objectives');
        sizes=size(idxArray);
        arraySize=sizes(2);

        priorities=hObj.priorities;

        if isempty(idxArray)||idxArray(1)==0
            return;
        end

        for arrayIdx=1:arraySize
            idx=idxArray(arrayIdx)+1;

            if(idx>1&&idx<=numOfObjectives)
                thisIdx=idx;
                previousIdx=idx-1;
                temp=priorities{thisIdx};
                priorities{thisIdx}=priorities{previousIdx};
                priorities{previousIdx}=temp;
            end
        end

        hObj.priorities=priorities;
        hObj.listbox2selected=idxArray(1)-1;
        loc_SetObjectivePrioritiesCopy(hObj,priorities);
        if~isempty(hObj.base)
            hObj.base.Objectives=hObj.opCopy;
            hObj.base.refreshCheckList;
        end

    case{'Tag_Objective_rightbutton','Tag_Objective_Factory_Objectives'}
        objsLeft=hObj.objsLeft;

        idxArray=hDlg.getWidgetValue('Tag_Objective_Factory_Objectives');
        temp=size(idxArray);
        arraySize=temp(2);
        if arraySize==0
            return;
        end

        priorities=hObj.priorities;

        len=0;
        if~isempty(priorities)
            len=length(priorities);
        end

        unselected=hObj.unSelected;
        objsName=hObj.objsName;
        for arrayIdx=1:arraySize
            idx=idxArray(arrayIdx)+1;
            realIdx=unselected(idx);
            unselected(idx)=100;

            objsLeft(realIdx)=0;

            len=len+1;
            priorities{len}.name=objsName{realIdx}.name;
            priorities{len}.id=realIdx;
        end

        hObj.objsLeft=objsLeft;

        unselected=sort(unselected);

        for i=length(unselected):-1:1
            if unselected(i)==100
                unselected(i)=[];
            end
        end

        hObj.unSelected=unselected;
        hObj.priorities=priorities;
        loc_SetObjectivePrioritiesCopy(hObj,priorities);
        if~isempty(hObj.base)
            hObj.base.Objectives=hObj.opCopy;
            hObj.base.refreshCheckList;
        end

    case{'Tag_Objective_leftbutton','Tag_Objective_My_Objectives'}
        priorities=hObj.priorities;

        len=0;
        if~isempty(priorities)
            len=length(priorities);
        end

        objsLeft=hObj.objsLeft;

        idxArray=hDlg.getWidgetValue('Tag_Objective_My_Objectives');
        temp=size(idxArray);
        arraySize=temp(2);
        if arraySize==0
            return;
        end

        unselected=hObj.unSelected;
        lenus=length(unselected);
        for arrayIdx=1:arraySize
            idx=idxArray(arrayIdx)+1;
            realIdx=priorities{idx}.id;

            objsLeft(realIdx)=1;

            priorities{idx}=[];
            lenus=lenus+1;
            unselected(lenus)=realIdx;
        end

        unselected=sort(unselected);

        hObj.objsLeft=objsLeft;
        hObj.unSelected=unselected;

        new_priorities=cell(len-arraySize,1);

        for i=1:len-arraySize
            for j=1:len
                if~isempty(priorities{j})
                    new_priorities{i}=priorities{j};
                    priorities{j}=[];
                    break;
                end
            end
        end

        hObj.priorities=new_priorities;
        loc_SetObjectivePrioritiesCopy(hObj,new_priorities);
        if~isempty(hObj.base)
            hObj.base.Objectives=hObj.opCopy;
            hObj.base.refreshCheckList;
        end

    case 'Tag_Objective_OKButton'
        new_priorities=hObj.priorities;
        loc_SetObjectivePriorities(hObj.ParentSrc,new_priorities);

        dlg=hObj.ParentSrc.getDialogHandle;
        if~isempty(dlg)
            cs=hObj.ParentSrc.getConfigSetSource;
            old_priorities=get_param(cs,'ObjectivePriorities');
            new_priorities_names=get_param(hObj.ParentSrc,'ObjectivePriorities');

            if~isequal(old_priorities,new_priorities_names)
                enableApplyButton(dlg.getDialogSource,true);
            end



            if~isempty(new_priorities_names)&&slfeature('ConfigsetDDUX')==1
                if(isa(dlg,'DAStudio.Dialog'))
                    htmlView=dlg.getDialogSource;
                    data=struct;
                    data.paramName='ObjectivePriorities';

                    data.paramValue=strjoin(string(new_priorities_names),',');
                    data.widgetType='ddg';
                    htmlView.publish('sendToDDUX',data);
                end
            end
        end

        hObj.justSwitched=true;
        hObj.listbox2selected=-1;
        delete(hDlg);

    case 'Tag_Objective_CancelButton'
        hObj.dirty=0;

        prioritiesOld=hObj.prioritiesOld;
        hObj.priorities=prioritiesOld;

        unselectedOld=hObj.unSelectedOld;
        hObj.unSelected=unselectedOld;

        loc_SetObjectivePriorities(hObj.ParentSrc,prioritiesOld);
        op=get_param(hObj.ParentSrc,'ObjectivePriorities');

        objsLeft=[];
        if isempty(op)
            objsLeft=ones(1,numOfObjectives);
            unSelected=ones(1,numOfObjectives);

            hObj.objsLeft=objsLeft;
            hObj.unSelected=unSelected;
            hObj.priorities=[];
        else
            usIdx=1;
            opHash=coder.advisor.internal.HashMap();
            for i=1:length(op)
                opHash.put(op{i},1);
            end

            unSelected=[];

            for i=1:numOfObjectives

                if exist('rtw.codegenObjectives.ObjectiveCustomizer','class')>0
                    objectiveNameEng=rtw.codegenObjectives.ObjectiveCustomizer.getObjectiveEnglishName(objectiveName{i});
                end

                if isempty(opHash.get(objectiveNameEng))
                    unSelected(usIdx)=i;%#ok<AGROW>
                    if i~=numOfObjectives
                        usIdx=usIdx+1;
                    end
                    objsLeft(i)=1;%#ok<AGROW>
                end
            end

            if~isempty(unSelected)
                unSelected=sort(unSelected);
            end

            hObj.objsLeft=objsLeft;
            unSelected=sort(unSelected);
            hObj.unSelected=unSelected;
        end

        hObj.listbox2selected=-1;
        delete(hDlg);

    case 'Tag_Objective_Help'
        HelpArgs={[docroot,'/toolbox/ecoder/helptargets.map'],tag};
        helpview(HelpArgs{1},HelpArgs{2});
    end
end


function loc_SetObjectivePriorities(hSrc,priorities)
    val='';
    index=0;

    if isempty(priorities)
        set_param(hSrc,'ObjectivePriorities',val);
        return;
    end

    for i=1:length(priorities)
        if~isempty(priorities{i})
            index=index+1;

            id=priorities{i}.id;
            switch id
            case{1}
                name='Execution efficiency';
            case{2}
                name='ROM efficiency';
            case{3}
                name='RAM efficiency';
            case{4}
                name='Traceability';
            case{5}
                name='Safety precaution';
            case{6}
                name='Debugging';
            case{7}
                name='MISRA C:2012 guidelines';
            otherwise
                name=priorities{i}.name;
            end
            cm=DAStudio.CustomizationManager;

            if exist('rtw.codegenObjectives.ObjectiveCustomizer','class')>0
                val{index}=cm.ObjectiveCustomizer.nameToIDHash.get(name);
            else
                val{index}=name;
            end
        end
    end

    set_param(hSrc,'ObjectivePriorities',val);
end


function loc_SetObjectivePrioritiesCopy(hObj,priorities)
    val='';
    index=0;

    if isempty(priorities)
        hObj.opCopy=val;
        return;
    end

    for i=1:length(priorities)
        if~isempty(priorities{i})
            index=index+1;

            id=priorities{i}.id;
            switch id
            case{1}
                name='Execution efficiency';
            case{2}
                name='ROM efficiency';
            case{3}
                name='RAM efficiency';
            case{4}
                name='Traceability';
            case{5}
                name='Safety precaution';
            case{6}
                name='Debugging';
            case{7}
                name='MISRA C:2012 guidelines';
            otherwise
                name=priorities{i}.name;
            end
            cm=DAStudio.CustomizationManager;
            if exist('rtw.codegenObjectives.ObjectiveCustomizer','class')>0
                val{index}=cm.ObjectiveCustomizer.nameToIDHash.get(name);
            else
                val{index}=name;
            end
        end
    end

    hObj.opCopy=val;
end




