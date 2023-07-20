function currentlyOpenDocuments=getOpenDocuments(counter)

    currentlyOpenDocuments=cell(0,2);
    wordApp=rmidotnet.MSWord.application('current');

    if~isempty(wordApp)
        wordDocs=wordApp.Documents;
        for i=1:wordDocs.Count
            if nargin==0||i==counter
                currentlyOpenDocuments(end+1,:)={wordDocs.Item(i).Name.char,wordDocs.Item(i).Path.char};%#ok<AGROW>
            end
        end
    end

end
