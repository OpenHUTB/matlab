function str=reqsToCsvStr(reqs)





    str='';

    for i=1:length(reqs)
        rq=reqs(i);
        id=rq.id;
        doc=rq.doc;


        id=strtok(id,' ');
        doc=strtok(doc,' ');


        if isempty(doc)
            error(message('Slvnv:rmi:sync_with_doors:SyncErrorModuleId',i));
        end
        if isempty(id)
            error(message('Slvnv:rmi:sync_with_doors:SyncErrorObjectId',i));
        end


        if id(1)=='#'
            id=id(2:end);
        end


        str=[str,doc,',',id,','];%#ok<AGROW>
    end

    if~isempty(str)>0
        str(end)=[];
    end
end
