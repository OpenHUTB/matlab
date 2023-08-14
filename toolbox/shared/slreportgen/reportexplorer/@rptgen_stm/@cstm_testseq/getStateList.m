function stateHierarchyList=getStateList(this,d,sect,states,blockPath)





    elem=createElement(d,'emphasis',...
    getString(message('RptgenSL:rstm_cstm_testseq:stepHierarchyTitle')));
    setAttribute(elem,'role','bold');
    para=createElement(d,'para',elem);
    appendChild(sect,para);

    nStates=numel(states);
    for i=1:nStates
        stateHierarchyList={};
        list=getList(this,d,states{i},stateHierarchyList,blockPath);
        if iscell(list)
            stateHierarchyList=list;
        else
            stateHierarchyList{1}=list;
        end


        if rptgen.use_java
            m=com.mathworks.toolbox.rptgencore.docbook.ListMaker(stateHierarchyList);
            m.setListType('itemizedlist');
            list=m.createList(java(d));
        else
            m=mlreportgen.re.internal.db.ListMaker(stateHierarchyList);
            setListType(m,'itemizedlist');
            list=createList(m,d.Document);
        end
        appendChild(sect,list);
    end
end


function listContent=getList(this,d,state,listContent,blockPath)
    noOfChildren=numel(state.children);
    if noOfChildren==0
        listContent=makeLinkNode(this,state,d,blockPath);
    else
        subList={};
        for i=1:noOfChildren
            childData=...
            getList(this,d,state.children{i},listContent,blockPath);
            if iscell(childData)
                subList{end+1}=childData{1};%#ok<AGROW>
                subList{end+1}=childData{2};%#ok<AGROW>
            else
                subList{end+1}=childData;%#ok<AGROW>
            end
        end
        listContent={makeLinkNode(this,state,d,blockPath),subList};
    end
end


function linkNode=makeLinkNode(this,state,d,blockPath)
    stateName=getStateName(this,state);


    assert(~isempty(stateName));

    id=getObjectID(this,state,blockPath);
    linkNode=createElement(d,'link',stateName);
    setAttribute(linkNode,'linkend',id);
end