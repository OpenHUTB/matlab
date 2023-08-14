


function onCodeViewEvent(obj,codeLanguage,eventData)

    if strcmpi(eventData.action,'FileChange')
        obj.onFileChange(codeLanguage,eventData.file);
    elseif strcmpi(eventData.action,'Annotation')
        userData=eventData.userData;
        anno=[];
        if strcmpi(userData.action,'add')

            anno=userData.last;
        elseif strcmpi(userData.action,'select')

            anno=userData.anno;
        end

        if~isempty(anno)

            obj.onFileChange(codeLanguage,anno.file);

            obj.addAnnotation(anno);
        end
    end
end