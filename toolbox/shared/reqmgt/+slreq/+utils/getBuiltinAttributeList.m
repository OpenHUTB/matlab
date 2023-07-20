function out=getBuiltinAttributeList(type)



    switch type
    case 'link'
        out={'Source','Type','Destination','Keywords',...
        'SID','CreatedOn','CreatedBy','ModifiedOn','ModifiedBy','Revision','Description','Rationale'};
    case 'req'
        out={'Index','ID','Summary','Type','Keywords','SID',...
        'CreatedOn','CreatedBy','ModifiedOn','SynchronizedOn','ModifiedBy','Revision',...
        'Verified','Implemented','Description','Rationale'};
    end


end
