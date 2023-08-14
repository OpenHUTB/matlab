function match=findAllSubsysBlks(hndl)




    match=get_param(hndl,"Type")=="block"&&...
    get_param(hndl,"BlockType")=="SubSystem"&&...
    get_param(hndl,"ReferenceBlock")==""&&...
    get_param(hndl,"SFBlockType")=="NONE";
end
