function[docTxt,anchorId]=getAnchorInfo(doc,id,isLink)

    if nargin<3
        isLink=false;
    end
    if isLink
        anchorId=id;
    else
        anchorId=rmidoors.getObjAttribute(doc,id,'parentid');
    end
    docTxt=rmidoors.getObjAttribute(doc,str2num(anchorId),'Object Heading');%#ok<ST2NM>
    if isempty(docTxt)
        docTxt=rmidoors.getObjAttribute(doc,str2num(anchorId),'Object Text');%#ok<ST2NM>
    end

end
