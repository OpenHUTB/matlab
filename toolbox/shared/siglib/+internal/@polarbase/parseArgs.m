function post_pv=parseArgs(p,args)


























































    p.pData_Raw=[];
    p.pData=[];
    p.pCurrentDataSetIndex=[];
    p.DataCacheDirty=true;
    post_pv={};

    if isempty(args)
        return
    end












    [args,pre_pv,post_pv]=parsePVPairArgs(p,args);
    parseData(p,args);




    for i=1:2:numel(pre_pv)
        p.(pre_pv{i})=pre_pv{i+1};
    end
