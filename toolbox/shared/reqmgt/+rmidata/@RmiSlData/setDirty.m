function setDirty(this,mdlName,state)
    try
        modelH=get_param(mdlName,'Handle');
        if isKey(this.statusMap,modelH)
            if islogical(state)
                this.statusMap(modelH)=state;
            else
                editorId=state;
                try
                    if strcmp(get_param(mdlName,'ReqHilite'),'on')
                        codeHasLinks=rmiml.hasLinks(editorId);
                        if rmisl.isHarnessIdString(editorId)

                            editorId=rmisl.harnessIdToEditorName(editorId);
                        end
                        blkH=Simulink.ID.getHandle(editorId);
                        blkOwnColor=get_param(blkH,'HiliteAncestors');
                        if strcmp(blkOwnColor,'reqHere')

                        else
                            if codeHasLinks&&~strcmp(blkOwnColor,'reqInside')
                                set_param(blkH,'HiliteAncestors','reqInside');
                            elseif~codeHasLinks&&~strcmp(blkOwnColor,'fade')
                                set_param(blkH,'HiliteAncestors','off');
                            end
                        end
                    end
                    this.statusMap(modelH)=true;

                catch Mex
                    if strcmp(Mex.identifier,'Simulink:utility:objectDestroyed')

                        return;
                    else
                        rethrow(Mex);
                    end
                end

            end
        end
    catch
        warning(message('Slvnv:rmigraph:UnmatchedModelName',mdlName));
    end
end
