function generateToolstripLiveCode(hObj,action,isUndoable)




    if nargin<3
        isUndoable=true;
    end

    hFig=ancestor(hObj,'figure');
    if isprop(hFig,'CodeGenerationProxy')
        hFig.CodeGenerationProxy.toolstripInteractionOccured(hObj,action,isUndoable);
    end
end