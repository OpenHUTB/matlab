function id=setReqs(obj,reqs)




    if ischar(obj)&&contains(obj,'|UUID_')
        [fPath,rest]=strtok(obj,'|');
        id=rest(2:end);
    else
        [id,fPath]=rmide.getGuid(obj);
    end


    src=struct('artifact',fPath,'id',id,'domain','linktype_rmi_data');



    reqs=slreq.uri.correctDestinationUriAndId(reqs);


    slreq.internal.setLinks(src,reqs);








end


