

function[editor,editorDomain]=getEditor(mdl)


    editorDomain=[];
    editor=[];
    try
        editors=GLUE2.Util.findAllEditors(mdl);
        numEditors=length(editors);
        for idx=1:numEditors
            if editors(idx).isVisible
                domain=editors(idx).getStudio.getActiveDomain();
                if ismethod(domain,'createParamChangesCommand')
                    editor=editors(idx);
                    editorDomain=domain;
                    break;
                end
            end
        end
    catch me %#ok<NASGU>
        editor=[];
        editorDomain=[];
    end
end

