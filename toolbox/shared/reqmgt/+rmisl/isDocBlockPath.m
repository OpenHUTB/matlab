function out=isDocBlockPath(doc)





    out=false;

    doc=convertStringsToChars(doc);


    [~,~,dExt]=fileparts(doc);
    if strcmp(dExt,'.rtf')




        driveLetterRemoved=regexprep(doc,'^\w\:(/|\\)','\\');


        if~isempty(strfind(driveLetterRemoved,':'))
            out=true;
        end
    end
end