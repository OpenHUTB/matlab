function success=customEdittimeFix(checkID,hash)




    editEngine=edittimecheck.EditTimeEngine.getInstance();
    success=editEngine.fix(bdroot(gcs),checkID,hash,false);
end