function docFixRef(sessionId,type,doc,item,issue,varargin)
















    storedSession=rmiref.docCheckCallback('session');
    if strcmp(sessionId,storedSession)



        rmiref.docCheckCallback('fix',item,issue,varargin);
    else



        fix(type,doc,item,issue,varargin);
    end
end

function fix(type,doc,item,issue,allArgs)
    switch type
    case 'word'
        rmiref.DocCheckWord.fix(doc,item,issue,allArgs);
    case 'excel'
        rmiref.DocCheckExcel.fix(doc,item,issue,allArgs);
    case 'doors'
        rmiref.DocCheckDoors.fix(doc,item,issue,allArgs);
    otherwise
        errordlg(getString(message('Slvnv:rmiref:docCheckCallback:docFixRef',type)));
    end
end

