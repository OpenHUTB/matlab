function MagE=directivity(obj,freq,theta1,phi1,pol,Normalize,coord,...
    R,calc_emb_pattern,type,sparam)









    if isfield(obj.SolverStruct.Solution,'Dirfreq')&&...
        ~isempty(obj.SolverStruct.Solution.Dirfreq)&&...
        ~isscalar(phi1)&&~isscalar(theta1)
        if(numel(obj.SolverStruct.Solution.theta)==numel(theta1))&&...
            (numel(obj.SolverStruct.Solution.phi)==numel(phi1))&&...
            all(obj.SolverStruct.Solution.theta==theta1)&&...
            all(obj.SolverStruct.Solution.phi==phi1)&&...
            (~calc_emb_pattern)&&...
            strcmpi(obj.SolverStruct.Solution.pol,pol)
            idx=find(obj.SolverStruct.Solution.Dirfreq==freq,1);
            if isempty(obj.SolverStruct.Solution.Type)
                if~isempty(idx)
                    MagE=obj.SolverStruct.Solution.Directivity;
                    return;
                end
            else
                itype=obj.SolverStruct.Solution.Type;
                if~isempty(idx)&&isequal(type,itype)
                    MagE=obj.SolverStruct.Solution.Directivity;
                    return;
                end
            end
        end
    end


    if isfield(obj.SolverStruct.Solution,'Radfreq')
        idx=find(obj.SolverStruct.Solution.Radfreq==freq,1);
    else
        obj.SolverStruct.Solution.Radfreq=[];
        obj.SolverStruct.Solution.RadiatedPower=[];
        idx=[];
    end
    if isempty(idx)
        sphereChoice='low';
        if getTotalArrayElems(obj)>100
            sphereChoice='high';
        end
        [Points,n_s,Area_s]=em.FieldAnalysisWithFeed.generateRadiationSphere(R,obj.Tilt,obj.TiltAxis,sphereChoice);
        [E,H]=calcEHfields(obj,freq,Points,calc_emb_pattern);
        Poynting=0.5*real(cross(E,conj(H)));
        RadiatedPower=R^2*sum(abs(dot(n_s,Poynting)).*Area_s);
        clear Area_s Center_s n_s p_s t_s
        obj.SolverStruct.Solution.Radfreq=[...
        obj.SolverStruct.Solution.Radfreq,freq];
        obj.SolverStruct.Solution.RadiatedPower=[...
        obj.SolverStruct.Solution.RadiatedPower,RadiatedPower];
    else
        RadiatedPower=obj.SolverStruct.Solution.RadiatedPower(idx);
    end

    [absE,~]=calcefield(obj,freq,theta1,phi1,pol,[],coord,...
    R,calc_emb_pattern);





    if strcmpi(type,'RealizedGain')
        phaseshift=obj.FeedPhase;
        voltage=obj.FeedVoltage;
        [x,y]=pol2cart(phaseshift,voltage);
        Vport=complex(x,y);
        Vport=Vport.';

        Portin=(Vport')*Vport;

        sdim=getNumFeedLocations(obj);
        sdiff=eye(sdim)-(sparam')*sparam;


        Portout=(Vport')*(sdiff)*Vport;
        PortEfficiency=Portout/Portin;
        RadiatedPower=RadiatedPower/PortEfficiency;
    end
    MagE=em.FieldAnalysisWithFeed.calculateDirectivity(absE,R,RadiatedPower,Normalize);

    if isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP
        MagE=MagE+10*log10(2);
    end

    if~isscalar(theta1)&&~isscalar(phi1)
        obj.SolverStruct.Solution.Directivity=MagE;
        obj.SolverStruct.Solution.Dirfreq=freq;
        obj.SolverStruct.Solution.theta=theta1;
        obj.SolverStruct.Solution.phi=phi1;
        obj.SolverStruct.Solution.cep=calc_emb_pattern;
        obj.SolverStruct.Solution.pol=pol;
        obj.SolverStruct.Solution.Type=type;
    end

end