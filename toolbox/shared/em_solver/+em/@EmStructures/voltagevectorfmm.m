function V=voltagevectorfmm(obj,ElemNumber,omega,pwavesource)


    if isempty(obj.SolverStruct.Source)
        obj.SolverStruct.Source.type='voltage';
        obj.SolverStruct.Source.voltage=1;
    end

    if strcmp(obj.SolverStruct.Source.type,'planewave')
        if isempty(pwavesource)
            dir=obj.Direction./norm(obj.Direction);
            Pol=obj.Polarization;
        else
            dir=pwavesource.Direction;
            Pol=pwavesource.Polarization;
        end
        V=voltage_scattered(obj,omega,dir,Pol).';
    elseif isempty(ElemNumber)
        V=voltage_radiation(obj,[]).';
    elseif getNumFeedLocations(obj)>1&&~isempty(ElemNumber)
        dim=obj.SolverStruct.RWG.EdgesTotal;
        ArrayDim=getNumFeedLocations(obj);
        V=zeros(dim,ArrayDim);
        for m=1:ArrayDim
            index=find(obj.SolverStruct.RWG.feededge(:,m));
            index1=obj.SolverStruct.RWG.feededge(index,m);%#ok<FNDSB>
            V(index1,m)=obj.SolverStruct.RWG.EdgeLength(index1);
        end
    end
    obj.SolverStruct.HasSourceChanged=0;
































end