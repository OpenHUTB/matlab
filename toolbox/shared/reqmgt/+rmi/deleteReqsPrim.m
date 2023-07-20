function result=deleteReqsPrim(reqs,indices)




    if~isempty(indices)&&(max(indices)>length(reqs))
        error(message('Slvnv:rmi:deleteReqsPrim:BadIndices'));
    end


    if~isempty(indices)
        reqs(indices)=[];
    end;

    result=reqs;
