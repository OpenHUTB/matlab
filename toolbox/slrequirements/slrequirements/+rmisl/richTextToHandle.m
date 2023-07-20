function[obj,isRichText]=richTextToHandle(obj)


    richTextStart=strfind(obj,'<!DOCTYPE HTML ');
    if isempty(richTextStart)
        isRichText=false;
    else
        isRichText=true;
        tokens=regexp(obj,'<body [^>]+>(.*)<//body>','tokens');
        if isempty(tokens)
            obj=[];
            return;
        else
            contents=regexprep(strtrim(tokens{1}{1}),'<[^>]+>','');
        end






        parent=obj(1:richTextStart(1)-2);
        parentObj=get_param(parent,'Object');
        annotations=find(parentObj,'-isa','Simulink.Annotation');
        for i=1:length(annotations)
            if strcmp(annotations(i).PlainText,contents)
                obj=annotations(i).Handle;
                return;
            end
        end
        obj=[];
    end
end
