function togglePerspective(this,cStudioOrModelH,~)













    if isa(cStudioOrModelH,'DAS.Studio')
        cStudio=cStudioOrModelH;
    else
        editor=rmisl.modelEditors(cStudioOrModelH,true,true);
        if isempty(editor)
            error(message('Slvnv:slreq:ErrorEnterPerspectiveDueToUnopenedModel',getfullname(cStudioOrModelH)))
        end
        cStudio=editor.getStudio;
    end
    if~isempty(this.perspectiveManager)
        this.perspectiveManager.togglePerspective(cStudio);
    end
end
