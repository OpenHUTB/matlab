function dlgstruct=getObjectiveDialogSchema(hObj)






    tag='Tag_Objective_';
    numOfObjectives=hObj.numOfObjs;
    objName=hObj.objsName;

    persistent objectiveName;

    for i=1:numOfObjectives
        objectiveName{i}=objName{i};
    end

    op=hObj.opCopy;

    cm=DAStudio.CustomizationManager;

    objWODef=cell(length(op),1);
    objWODefIdx=0;
    nameHash=cm.ObjectiveCustomizer.IDToNameHash;
    if~isempty(nameHash)
        for i=1:length(op)
            if~isempty(op{i})&&exist('rtw.codegenObjectives.ObjectiveCustomizer','class')>0
                translated=nameHash.get(op{i});
                if isempty(translated)
                    objWODefIdx=objWODefIdx+1;
                    objWODef{objWODefIdx}=op{i};
                else
                    op{i}=translated;
                end
            end
        end
    end

    if objWODefIdx>0
        objs=[];
        for j=1:objWODefIdx
            if j==1
                objs=['''',objWODef{j},''''];
            else
                objs=[objs,',','''',objWODef{j},''''];%#ok
            end
        end
        msgtext=DAStudio.message('RTW:configSet:customizedObjWithoutDefWarning',objs);

        msgbox(msgtext,DAStudio.message('RTW:configSet:objectiveWarningTitle'));
    end

    if isempty(op)
        objsLeft=1;
        unSelected=1;

        for i=2:numOfObjectives
            objsLeft=[objsLeft,1];%#ok
            unSelected=[unSelected,i];%#ok
        end

        hObj.objsLeft=objsLeft;
        hObj.unSelected=unSelected;
        hObj.priorities=[];
    end

    if~hObj.dirty
        hObj.dirty=false;

        pIdx=0;
        priorities=cell(length(op),1);

        usIdx=1;
        opHash=coder.advisor.internal.HashMap();

        objsLeft=hObj.objsLeft;
        objsName=hObj.objsName;

        for i=1:length(op)
            objNameLoc=translate(op{i});

            idx=findObjectiveIndex(hObj,objNameLoc,numOfObjectives);

            if idx>0
                name=objsName{idx}.name;
                pIdx=pIdx+1;
                priorities{pIdx}.id=idx;
                priorities{pIdx}.name=name;

                objsLeft(idx)=0;
                opHash.put(op{i},1);
            end
        end

        hObj.objsLeft=objsLeft;

        unSelected=[];
        for i=1:numOfObjectives

            if exist('rtw.codegenObjectives.ObjectiveCustomizer','class')>0
                objectiveNameEng=rtw.codegenObjectives.ObjectiveCustomizer.getObjectiveEnglishName(objectiveName{i});
            end

            if isempty(opHash.get(objectiveNameEng))||...
                (isempty(which('pslinkprivate'))&&strcmpi(objectiveNameEng,'Polyspace'))
                unSelected(usIdx)=i;%#ok
                if i~=numOfObjectives
                    usIdx=usIdx+1;
                end
            end
        end

        if~isempty(unSelected)
            unSelected=sort(unSelected);
        end

        hObj.unSelected=unSelected;
        hObj.priorities=priorities;
    end

    objsLeft=hObj.objsLeft;
    objs=hObj.objsName;
    for i=1:length(objs)
        factoryObjectiveName{i}=objs{i}.name;%#ok
    end

    iconpath=fullfile(matlabroot,'toolbox','shared','dastudio','resources');



    objs=cell(numOfObjectives,1);
    for k=1:numOfObjectives
        objs{k}=factoryObjectiveName{k};
        if(objsLeft(k)==0)
            objs{k}='';
        else
            if(objsLeft(k)<0)
                objs{k}='';
            end
        end
    end


    listbox1Entries={};
    for i=1:length(objs)
        if~isempty(objs{i})
            listbox1Entries{end+1}=objs{i};%#ok
        end
    end

    listbox1.Name=DAStudio.message('RTW:configSet:objectiveListboxName1');
    listbox1.Type='listbox';
    listbox1.Tag=[tag,'Factory_Objectives'];
    listbox1.Entries=listbox1Entries;
    listbox1.Mode=1;
    listbox1.Graphical=true;
    listbox1.DialogRefresh=false;
    listbox1.ListDoubleClickCallback=@doubleClick;
    listbox1.ToolTip=DAStudio.message('RTW:configSet:configSetObjectivesListBoxLeftToolTip');
    listbox1.Source=hObj;
    listbox1.ColSpan=[1,1];
    listbox1.RowSpan=[1,6];



    listbox2selected=hObj.listbox2selected;
    listbox2.Name=DAStudio.message('RTW:configSet:objectiveListboxName2');
    listbox2.Type='listbox';

    objs2=cell(numOfObjectives,1);
    for k=1:numOfObjectives
        objs2{k}='';
    end

    priorities=hObj.priorities;

    listbox2Entries=cell(numOfObjectives,1);
    if~isempty(priorities)
        for k=1:length(priorities)
            if~isempty(priorities{k})
                objs2{k}=priorities{k}.name;
            end
            listbox2Entries{k}=objs2{k};
        end
    end

    listbox2.Tag=[tag,'My_Objectives'];
    listbox2.Entries=listbox2Entries;
    listbox2.Mode=1;
    listbox2.Graphical=true;
    listbox2.DialogRefresh=false;
    listbox2.ListDoubleClickCallback=@doubleClick;
    if listbox2selected>=0
        listbox2.Value=listbox2selected;
    end
    listbox2.ListKeyPressCallback=@singleClick;
    listbox2.ObjectMethod='dialogCallback';
    listbox2.MethodArgs={'%dialog',[listbox2.Tag,'2']};
    listbox2.ArgDataTypes={'handle','string'};
    listbox2.ToolTip=DAStudio.message('RTW:configSet:configSetObjectivesListBoxRightToolTip');
    listbox2.Source=hObj;
    listbox2.ColSpan=[3,3];
    listbox2.RowSpan=[1,6];


    rightArrow=[];
    rightArrow.FilePath=fullfile(iconpath,'move_right.gif');
    rightArrow.Type='pushbutton';
    rightArrow.Tag=[tag,'rightbutton'];
    rightArrow.ObjectMethod='dialogCallback';
    rightArrow.MethodArgs={'%dialog',rightArrow.Tag};
    rightArrow.ArgDataTypes={'handle','string'};
    rightArrow.Mode=1;
    rightArrow.DialogRefresh=1;
    rightArrow.ToolTip=DAStudio.message('RTW:configSet:configSetObjectivesRightButtonToolTip');
    rightArrow.Source=hObj;
    rightArrow.MaximumSize=[60,30];
    rightArrow.MinimumSize=[60,30];
    rightArrow.ColSpan=[2,2];
    rightArrow.RowSpan=[3,3];
    rightArrow.Enabled=true;


    leftArrow.FilePath=fullfile(iconpath,'move_left.gif');
    leftArrow.Type='pushbutton';
    leftArrow.Tag=[tag,'leftbutton'];
    leftArrow.ObjectMethod='dialogCallback';
    leftArrow.MethodArgs={'%dialog',leftArrow.Tag};
    leftArrow.ArgDataTypes={'handle','string'};
    leftArrow.Mode=1;
    leftArrow.DialogRefresh=1;
    leftArrow.ToolTip=DAStudio.message('RTW:configSet:configSetObjectivesLeftButtonToolTip');
    leftArrow.Source=hObj;
    leftArrow.MaximumSize=[60,30];
    leftArrow.MinimumSize=[60,30];
    leftArrow.ColSpan=[2,2];
    leftArrow.RowSpan=[4,4];


    upArrow.FilePath=fullfile(iconpath,'move_up.gif');
    upArrow.Type='pushbutton';
    upArrow.Tag=[tag,'upbutton'];
    upArrow.ObjectMethod='dialogCallback';
    upArrow.MethodArgs={'%dialog',upArrow.Tag};
    upArrow.ArgDataTypes={'handle','string'};
    upArrow.DialogRefresh=1;
    upArrow.ToolTip=DAStudio.message('RTW:configSet:configSetObjectivesUpButtonToolTip');
    upArrow.Source=hObj;
    upArrow.MaximumSize=[20,20];
    upArrow.ColSpan=[4,4];
    upArrow.RowSpan=[3,3];


    downArrow.FilePath=fullfile(iconpath,'move_down.gif');
    downArrow.Type='pushbutton';
    downArrow.Tag=[tag,'downbutton'];
    downArrow.ObjectMethod='dialogCallback';
    downArrow.MethodArgs={'%dialog',downArrow.Tag};
    downArrow.ArgDataTypes={'handle','string'};
    downArrow.DialogRefresh=1;
    downArrow.ToolTip=DAStudio.message('RTW:configSet:configSetObjectivesDownButtonToolTip');
    downArrow.Source=hObj;
    downArrow.MaximumSize=[20,20];
    downArrow.ColSpan=[4,4];
    downArrow.RowSpan=[4,4];

    dlgstruct.LayoutGrid=[7,5];
    dlgstruct.Items={listbox1,listbox2,rightArrow,leftArrow,downArrow,upArrow};
    dlgstruct.DialogRefresh=1;
    dlgstruct.Source=hObj;

    function doubleClick(hDlg,tag,listItemIdx)%#ok
        dialogCallback(hObj,hDlg,tag);
        hDlg.refresh();
    end

    function singleClick(hDlg,tag,listItemIdx)%#ok
        dialogCallback(hObj,hDlg,[tag,'2']);
        hDlg.refresh();
    end
end


function idx=findObjectiveIndex(hObj,objName,numOfObjectives)
    objsName=hObj.objsName;
    for i=1:numOfObjectives
        name=objsName{i}.name;
        if strcmp(objName,name)
            idx=i;
            return;
        end
    end
    idx=-1;
end


function transName=translate(objName)
    if isempty(objName)
        transName='';
        return;
    end

    switch objName
    case{'Traceability'}
        transName=DAStudio.message('RTW:configSet:sanityCheckTraceability');
    case{'Safety precaution'}
        transName=DAStudio.message('RTW:configSet:sanityCheckSafetyprecaution');
    case{'Debugging'}
        transName=DAStudio.message('RTW:configSet:sanityCheckDebugging');
    case{'Execution efficiency'}
        transName=DAStudio.message('RTW:configSet:sanityCheckEfficiencyspeed');
    case{'ROM efficiency'}
        transName=DAStudio.message('RTW:configSet:sanityCheckEfficiencyROM');
    case{'RAM efficiency'}
        transName=DAStudio.message('RTW:configSet:sanityCheckEfficiencyRAM');
    case{'MISRA C:2012 guidelines'}
        transName=DAStudio.message('RTW:configSet:sanityCheckMisrac');
    case 'Polyspace'
        transName=DAStudio.message('RTW:configSet:sanityCheckPolyspace');
    otherwise
        transName=objName;
    end
end





