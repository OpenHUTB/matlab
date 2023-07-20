function V=voltage_radiation(obj,ElemNumber)








    obj.SolverStruct.HasSourceChanged=0;

    if isfield(obj.MesherStruct.Mesh,'T')&&~isempty(obj.MesherStruct.Mesh.T)
        V=zeros(1,obj.SolverStruct.RWG.EdgesTotal+...
        obj.SolverStruct.strdiel.EdgesTotal);
    elseif isprop(obj,'SolverType')&&strcmpi(obj.SolverType,'MoM-PO')
        V=zeros(1,obj.SolverStruct.RWG.EdgesTotalMoM);
    else
        V=zeros(1,obj.SolverStruct.RWG.EdgesTotal);
    end

    if~isempty(ElemNumber)
        [a,b]=pol2cart(obj.SolverStruct.Source.phaseshift(ElemNumber),...
        obj.SolverStruct.Source.voltage(ElemNumber));
        index=find(obj.SolverStruct.RWG.feededge(:,ElemNumber));
        V(obj.SolverStruct.RWG.feededge(index,ElemNumber))=complex(a,b)*...
        obj.SolverStruct.RWG.EdgeLength(obj.SolverStruct.RWG.feededge(index,ElemNumber));
    elseif isfield(obj.SolverStruct.Source,'phaseshift')
        [phaseshift,voltage]=em.internal.calculatePhaseShiftAndVoltage(obj,obj.SolverStruct);
        for m=1:size(obj.SolverStruct.RWG.feededge,2)
            [a,b]=pol2cart(phaseshift(m),voltage(m));
            index=find(obj.SolverStruct.RWG.feededge(:,m));
            V(obj.SolverStruct.RWG.feededge(index,m))=complex(a,b)*...
            obj.SolverStruct.RWG.EdgeLength(obj.SolverStruct.RWG.feededge(index,m));
        end
    elseif(isa(obj,'em.BackingStructure')||isa(obj,'em.ParabolicAntenna'))&&...
        em.internal.checkLRCArray(obj.Exciter)&&isfield(obj.Exciter.SolverStruct.Source,'phaseshift')
        [phaseshift,voltage]=em.internal.calculatePhaseShiftAndVoltage(obj.Exciter,obj.Exciter.SolverStruct);
        for m=1:size(obj.SolverStruct.RWG.feededge,2)
            [a,b]=pol2cart(phaseshift(m),voltage(m));
            index=find(obj.SolverStruct.RWG.feededge(:,m));
            V(obj.SolverStruct.RWG.feededge(index,m))=complex(a,b)*...
            obj.SolverStruct.RWG.EdgeLength(obj.SolverStruct.RWG.feededge(index,m));
        end
    else
        obj.SolverStruct.Source.voltage=1;
        for m=1:size(obj.SolverStruct.RWG.feededge,2)
            index=find(obj.SolverStruct.RWG.feededge(:,m));
            V(obj.SolverStruct.RWG.feededge(index,m))=obj.SolverStruct.Source.voltage*...
            obj.SolverStruct.RWG.EdgeLength(obj.SolverStruct.RWG.feededge(index,m));
        end

    end
    obj.SolverStruct.Solution.V=V;

end

