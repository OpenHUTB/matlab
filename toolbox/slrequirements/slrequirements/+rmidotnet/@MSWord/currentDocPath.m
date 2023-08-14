function docPath=currentDocPath()

    docPath='';

    wordApp=rmidotnet.MSWord.application('current');

    if~isempty(wordApp)
        hDoc=wordApp.ActiveDocument;

        if~isempty(hDoc)
            docPath=hDoc.FullName.char;
        end



        [~,~,ext]=fileparts(docPath);
        if isempty(ext)
            docPath='';
        end
    end
end