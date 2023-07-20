

function[docName,subDoc]=getDocSubDoc(docId)

    docName=docId;
    subDoc='';



    bangPos=find(docId=='!');
    if~isempty(bangPos)

        docName=docId(1:bangPos(1)-1);
        subDoc=docId(bangPos(1)+1:end);
    end

end