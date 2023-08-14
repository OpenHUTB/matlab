function[Pmloss]=conductionloss(obj,freq,metalthickness,conductivity)




    omega=2*pi*freq;
    [~,idx]=intersect(obj.SolverStruct.Solution.Frequency,freq);
    I=obj.SolverStruct.Solution.I(:,idx);
    EdgeLength=obj.SolverStruct.RWG.EdgeLength.';
    Pmloss=zeros(1,numel(freq));
    for q=1:numel(freq)
        if isinf(conductivity)
            Pmloss(q)=0;
        else
            Iq=I(:,q);
            I1=EdgeLength.*EdgeLength.*Iq;
            PL=Iq'*I1;
            Zs=em.EmStructures.Zsurf_calc(omega(q),metalthickness,conductivity);
            Pmloss(q)=0.5*real(Zs.*PL);
        end
    end
end

