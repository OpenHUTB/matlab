function das=getDirtyRequirementSets()




    das=struct('Type',{},'Address',{},'ParentType',{},'ParentAddress',{});

    rss=slreq.find('type','ReqSet','Dirty',true);

    for N=1:numel(rss)
        das(end+1).Type='sl_req_file';%#ok<AGROW>
        das(end).Address=rss(N).Filename;
        das(end).ParentType='';
        das(end).ParentAddress='';
    end
end
