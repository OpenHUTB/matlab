function goto(argIn)




    ed=Simulink.typeeditor.app.Editor.getInstance;

    if isa(argIn,'dig.CallbackInfo')
        currentElem=ed.getListComp.getSelection{end};
        if isa(currentElem,'Simulink.typeeditor.app.Element')
            elemType=currentElem.Parent.SourceObject.Type(length('Bus: ')+1:end);
            pathToNav=[elemType,'.',currentElem.Name];
        else
            gotoTypeWithPrefix=split(currentElem.getPropValue('Type'),':');
            gotoType=strtrim(gotoTypeWithPrefix{end});
            resolvesToType=currentElem.doesVariableExistInWorkspace(gotoType);
            assert(resolvesToType);
            pathToNav=gotoType;
        end
    else
        pathToNav=argIn;
    end

    if~isempty(ed)
        tc=ed.getTreeComp;
        lc=ed.getListComp;
        curRoot=ed.getCurrentTreeNode{1}.getRoot;
        pathStrs=split(pathToNav,'.');
        forElement=length(pathStrs)>1;

        parentNode=Simulink.typeeditor.utils.getNodeFromPath(curRoot,pathStrs{1},1);
        if forElement
            childNode=Simulink.typeeditor.utils.getNodeFromPath(parentNode,pathStrs{2},1);
            assert(isa(childNode,'Simulink.typeeditor.app.Element'));
            nodeToSelect=childNode;
        else
            nodeToSelect=parentNode;
        end




        visibleChildren=cellfun(@(child)child.Name,lc.imSpreadSheetComponent.getChildrenItems(curRoot),'UniformOutput',false);
        if~any(strcmp(pathStrs{1},visibleChildren))
            lc.imSpreadSheetComponent.setFilterText('');
        end
        if forElement
            tc.expand(parentNode,true);
        end
        lc.view(nodeToSelect);
    end
