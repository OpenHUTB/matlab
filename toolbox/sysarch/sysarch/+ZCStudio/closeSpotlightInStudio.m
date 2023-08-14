function closeSpotlightInStudio(varargin)




    if(nargin>0)
        studioTag=varargin{1};
        studios=DAS.Studio.getStudio(studioTag);
    else
        studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    end

    if~isempty(studios)
        activeStudio=studios(1,1);
        activeStudio.App.removeSpotlightView();


        resetPropertyInspector(activeStudio);

        resetRequirement(activeStudio);


        ZCStudio.StudioIntegManager.closeInvalidNotifInStudio(activeStudio)

    end

end


function resetPropertyInspector(studio)
    editor=studio.App.getActiveEditor();

    selectList=editor.getSelection();
    size=selectList.size();
    if size>0
        primarySelection=selectList.at(size);
        objH=primarySelection.handle;
    else
        editorName=editor.getName();
        objH=get_param(editorName,'Handle');
    end


    studio=editor.getStudio();
    propInspector=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');


    if~isempty(propInspector)
        objType=get_param(objH,'Type');
        obj=get_param(objH,'Object');
        propInspector.updateSource(objType,obj);
    end
end


function resetRequirement(studio)
    editor=studio.App.getActiveEditor();

    selectList=editor.getSelection();
    size=selectList.size();
    selections=cell(1,size);
    for i=1:size
        selectObj=selectList.at(i);
        selections{i}=get_param(selectObj.handle,'Object');
    end

    sysarch.highlightRequirement(selections);
end