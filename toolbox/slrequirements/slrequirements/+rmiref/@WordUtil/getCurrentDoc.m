function[currentDocName,hWord,hDoc]=getCurrentDoc()




    hWord=rmiref.WordUtil.getApplication(true);
    hDoc=hWord.ActiveDocument;
    if~isempty(hDoc)
        currentDocName=hDoc.FullName;
    else
        error(message('Slvnv:rmiref:WordUtil:getCurrent'));

    end
end
