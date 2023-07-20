function uuid=getUUIDFromID(id)
    idPref=rmifa.itemIDPref();
    uuid=id(strfind(id,idPref)+length(idPref):end);
end