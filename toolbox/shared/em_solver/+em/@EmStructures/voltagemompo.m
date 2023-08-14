function V=voltagemompo(obj,ElemNumber,omega,pwavesource)


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
        V=V(1:obj.SolverStruct.RWG.EdgesTotalMoM,:);
    elseif getNumFeedLocations(obj)==1
        V=voltage_radiation(obj,[]).';
    elseif getNumFeedLocations(obj)>1&&~isscalar(ElemNumber)

        dim=obj.SolverStruct.RWG.EdgesTotalMoM;
        ArrayDim=getNumFeedLocations(obj);
        V=zeros(dim,ArrayDim+1);
        V(:,1)=voltage_radiation(obj,[]).';
        for m=2:ArrayDim+1
            index=find(obj.SolverStruct.RWG.feededge(:,m-1));
            index1=obj.SolverStruct.RWG.feededge(index,m-1);%#ok<FNDSB>
            V(index1,m)=obj.SolverStruct.RWG.EdgeLength(index1);
        end
    elseif getNumFeedLocations(obj)>1&&isscalar(ElemNumber)

        dim=obj.SolverStruct.RWG.EdgesTotalMoM;
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