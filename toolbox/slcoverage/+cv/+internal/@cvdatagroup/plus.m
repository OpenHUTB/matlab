function res=plus(lhs,rhs)




    lhs.load();
    rhs.load();
    if isa(rhs,lhs.getCvDataClassName())
        trhs=feval(lhs.getCvDataGroupClassName());
        init(trhs);
        trhs.add(rhs);
        rhs=trhs;
    end




    if~isa(lhs,lhs.getCvDataGroupClassName())||~isa(rhs,lhs.getCvDataGroupClassName())
        error(message('Slvnv:simcoverage:plus:InvalidArgument'));
    end
    lan=lhs.allNames(SlCov.CovMode.Mixed);
    ran=rhs.allNames(SlCov.CovMode.Mixed);
    ian=intersect(lan,ran);
    res=feval(lhs.getCvDataGroupClassName());
    init(res);
    for idx=1:length(ian)
        res.add(lhs.get(ian{idx})+rhs.get(ian{idx}));
    end
    [~,ilan,iran]=setxor(lan,ran);
    for idx=1:numel(ilan)
        res.add(lhs.get(lan{ilan(idx)}));
    end
    for idx=1:numel(iran)
        res.add(rhs.get(ran{iran(idx)}));
    end

    feval([lhs.getCvDataClassName(),'.aggregateDescription'],res,lhs,rhs)


