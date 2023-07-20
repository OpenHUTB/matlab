function[docTxt,bookMarkId]=getAnchorInfo(myRef)
    try
        [docTxt,bookMarkId]=rmiref.DoorsUtil.getAnchorInfo(myRef.docname,myRef.itemname,myRef.isLink);
    catch Mex
        warning('rmiref:DockCheckDoors:findBookmark',Mex.message);
        docTxt=getString(message('Slvnv:rmiref:DocCheckDoors:ReferenceTo',myRef.label));
        bookMarkId='-1';
    end
end
