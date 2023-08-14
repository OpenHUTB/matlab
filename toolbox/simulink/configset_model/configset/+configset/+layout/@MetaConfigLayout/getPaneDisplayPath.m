function paneName=getPaneDisplayPath(obj,id,delimiter)









    if nargin<3
        delimiter='/';
    end
    paneId=id;
    paneName=obj.getPaneDisplay(id);

    while~isempty(obj.getParentGroupName(paneId))
        paneId=obj.getParentGroupName(paneId);
        parentName=obj.getPaneDisplay(paneId);
        paneName=[parentName,delimiter,paneName];%#ok<AGROW>
    end
end

