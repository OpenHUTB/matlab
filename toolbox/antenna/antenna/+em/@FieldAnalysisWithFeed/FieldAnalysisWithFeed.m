classdef(Abstract)FieldAnalysisWithFeed<handle

    methods

        AR=axialRatio(obj,frequency,azimuth,elevation);
        [BW,Angles]=beamwidth(obj,frequency,azimuth,elevation,dBdown);
        [E,H]=EHfields(obj,frequency,Points,varargin);
        varargout=pattern(obj,frequency,varargin);
        varargout=patternAzimuth(obj,frequency,elevation,varargin);
        varargout=patternElevation(obj,frequency,azimuth,varargin);
        msiwrite(obj,freq,fname,varargin);
    end

    methods(Hidden,Static)

        [quantitity,unit]=getfieldlabels(optype);
    end

    methods(Static,Access={?em.EmStructures,?em.FieldAnalysisWithWave,...
        ?em.WireStructures,?em.ArrayAnalysis})
        [tab1,tab2,tab3]=createradpattableinfo(parseobj,MagE,...
        az,el);

        plottype=plotradpattern(MagE,theta,phi,frequency,...
        coord,slice,slicestyle,optype,azimuth,elevation,varargin);

        function pvec=poynting(E,H)
            pvec=0.5*real(cross(E,conj(H)));
        end

        function radpwr=radPower(R,n_s,Poynting,Area_s)

            radpwr=R^2*sum(abs(dot(n_s,Poynting)).*Area_s);
        end

        function D=calculateDirectivity(MagE,R,PowerDivision,Normalize)
            eta=sqrt(1.25663706e-06/8.85418782e-12);
            U=R^2*MagE.^2/(2*eta);
            Dlin=4*pi*U/abs(PowerDivision);
            if Normalize
                Dlin=Dlin./max(Dlin);
            end
            D=10*log10(Dlin);
        end

        function[Points,n_s,Area_s]=generateRadiationSphere(R,Tilt,TiltAxis,sphereChoice)

            switch sphereChoice
            case 'low'

                load([matlabroot,('/toolbox/antenna/antenna/+em/@FieldAnalysisWithFeed/spherenew.mat')]);%#ok<LOAD>

            case 'high'

                load([matlabroot,('/toolbox/antenna/antenna/+em/@FieldAnalysisWithFeed/spherenew15000.mat')]);%#ok<LOAD>
            end


            if any(Tilt~=0)
                tempTilt=Tilt;
                numTilt=numel(Tilt);
                tempAxis=TiltAxis;


                em.internal.checktiltaxisconsistency(tempTilt,tempAxis)

                p_s=em.internal.orientgeom(p_s,tempTilt,numTilt,tempAxis);%#ok<NODEF>
                TrianglesTotal=length(t_s);

                Area_s=zeros(1,TrianglesTotal);
                Center_s=zeros(3,TrianglesTotal);
                n_s=zeros(3,TrianglesTotal);
                for m=1:TrianglesTotal
                    N=t_s(1:3,m);
                    Vec1=p_s(:,N(1))-p_s(:,N(2));
                    Vec2=p_s(:,N(3))-p_s(:,N(2));
                    crossval=cross(Vec1,Vec2);
                    Area_s(m)=norm(crossval)/2;
                    n_s(:,m)=crossval/norm(crossval);
                    Center_s(:,m)=1/3*sum(p_s(:,N),2);
                end
            end
            Points=R*Center_s;
        end

    end

    methods(Access={?em.EmStructures,?em.FieldAnalysisWithWave,...
        ?em.ArrayAnalysis})

        [E,H]=fieldm(obj,frequency,Points,Radius);
        p=createSpherePoints(obj,N);
        addantenna(obj);
        addpatplusant(obj,patternOptions);
        [parseobj,azimuth,elevation]=patternparser(obj,frequency,...
        inputdata,nolhs);
        [MagE,PhaseE]=calcefield(obj,freq,theta1,phi1,polarization,...
        Normalize,coord,R,calc_emb_pattern,ElemNumber);


        function MagE=directivity(obj,freq,theta1,phi1,pol,Normalize,coord,...
            R,calc_emb_pattern,ElemNumber,Termination,type,s)









            if nargin==9
                ElemNumber=[];
                Termination=50;
                if isRadiatorLossy(obj)
                    type='Gain';
                else
                    type='Directivity';
                end
            end


            absE=checkpatterncache(obj,freq,phi1,theta1,pol,...
            ElemNumber,Termination,calc_emb_pattern);
            if isempty(absE)
                absE=calcefield(obj,freq,theta1,phi1,pol,[],...
                coord,R,calc_emb_pattern,ElemNumber);
            end


            if strcmpi(type,'Gain')
                if obj.SolverStruct.hasDielectric
                    if getNumFeedLocations(obj)==1
                        if strcmpi(class(obj),'infiniteArray')&&isprop(obj.Element,'Substrate')...
                            &&obj.Element.Substrate.LossTangent~=0
                            PowerDivision=calc_radpower(obj,freq,R,calc_emb_pattern,...
                            ElemNumber);
                        else
                            PowerDivision=em.EmStructures.calcFeedpower(obj,freq);
                        end
                    else
                        PowerDivision=em.EmStructures.calcFeedpowerArray(obj,...
                        freq,calc_emb_pattern,ElemNumber);
                    end
                else
                    if isfield(obj.MesherStruct,'thickness')
                        metalthickness=obj.MesherStruct.thickness;
                        conductivity=obj.MesherStruct.conductivity;
                    else
                        metalthickness=0;
                        conductivity=inf;
                    end
                    PowerDivision=calc_radpower(obj,freq,R,calc_emb_pattern,...
                    ElemNumber)+em.EmStructures.conductionloss(obj,freq,...
                    metalthickness,conductivity)+em.EmStructures.lumpedLoss...
                    (obj,freq,calc_emb_pattern,ElemNumber);


                end
            elseif strcmpi(type,'RealizedGain')
                if obj.SolverStruct.hasDielectric
                    if getNumFeedLocations(obj)==1
                        if strcmpi(class(obj),'infiniteArray')&&isprop(obj.Element,'Substrate')...
                            &&obj.Element.Substrate.LossTangent~=0
                            PowerDivision=calc_radpower(obj,freq,R,calc_emb_pattern,...
                            ElemNumber);
                        else
                            PowerDivision=em.EmStructures.calcFeedpower(obj,freq);
                        end
                    else
                        PowerDivision=em.EmStructures.calcFeedpowerArray(obj,...
                        freq,calc_emb_pattern,ElemNumber);
                    end
                else
                    if isfield(obj.MesherStruct,'thickness')
                        metalthickness=obj.MesherStruct.thickness;
                        conductivity=obj.MesherStruct.conductivity;
                    else
                        metalthickness=0;
                        conductivity=inf;
                    end
                    PowerDivision=calc_radpower(obj,freq,R,calc_emb_pattern,...
                    ElemNumber)+em.EmStructures.conductionloss(obj,freq,...
                    metalthickness,conductivity)+em.EmStructures.lumpedLoss...
                    (obj,freq,calc_emb_pattern,ElemNumber);


                end

                if getNumFeedLocations(obj)==1
                    PortEfficiency=em.EmStructures.calcPortEfficiency(obj,freq,0,0,s);
                else
                    PortEfficiency=em.EmStructures.calcPortEfficiency(obj,freq,calc_emb_pattern,ElemNumber,s);
                end
                PowerDivision=PowerDivision/PortEfficiency;
            elseif strcmpi(type,'Directivity')
                PowerDivision=calc_radpower(obj,freq,R,calc_emb_pattern,...
                ElemNumber);
            end


            MagE=em.FieldAnalysisWithFeed.calculateDirectivity(absE,R,...
            PowerDivision,Normalize);

            if isfield(obj.MesherStruct,'infGP')&&obj.MesherStruct.infGP
                MagE=MagE+10*log10(2);
            end

            savepatterncache(obj,absE,theta1,phi1,freq,...
            ElemNumber,Termination,pol,calc_emb_pattern);

        end

    end

    methods(Access=protected)

        function MagE=checkpatterncache(obj,freq,phi1,theta1,pol,...
            ElemNumber,Termination,calc_emb_pattern)

            MagE=[];
            if isfield(obj.SolverStruct.Solution,'Dirfreq')&&...
                ~isempty(obj.SolverStruct.Solution.Dirfreq)&&...
                ~isscalar(phi1)&&~isscalar(theta1)
                if(isequal(obj.SolverStruct.Solution.theta,theta1)&&...
                    isequal(obj.SolverStruct.Solution.phi,phi1)&&...
                    strcmpi(obj.SolverStruct.Solution.pol,pol))
                    idx=find(obj.SolverStruct.Solution.Dirfreq==freq,1);
                    if~isempty(idx)
                        if~calc_emb_pattern
                            if~isempty(obj.SolverStruct.Solution.Directivity)
                                MagE=obj.SolverStruct.Solution.Directivity;
                            end
                        else
                            idx=find(obj.SolverStruct.Solution.EmbElement==ElemNumber);
                            if~isempty(idx)
                                if isequal(obj.SolverStruct.Solution.EmbTermination(idx),Termination)
                                    MagE=obj.SolverStruct.Solution.EmbDirectivity(:,idx).';
                                else
                                    obj.SolverStruct.Solution.EmbDirectivity=[];
                                    obj.SolverStruct.Solution.EmbElement=[];
                                    obj.SolverStruct.Solution.EmbTermination=[];
                                end
                            end
                        end
                    end
                end
            end
        end

        function savepatterncache(obj,MagE,theta1,phi1,freq,...
            ElemNumber,Termination,pol,calc_emb_pattern)

            if~isscalar(theta1)&&~isscalar(phi1)
                if calc_emb_pattern
                    obj.SolverStruct.Solution.Embfreq=freq;
                    obj.SolverStruct.Solution.EmbElement=...
                    [obj.SolverStruct.Solution.EmbElement,ElemNumber];
                    obj.SolverStruct.Solution.EmbTermination=...
                    [obj.SolverStruct.Solution.EmbTermination,Termination];
                    obj.SolverStruct.Solution.EmbDirectivity=...
                    [obj.SolverStruct.Solution.EmbDirectivity,MagE.'];
                else
                    obj.SolverStruct.Solution.Directivity=MagE;
                end
                obj.SolverStruct.Solution.Dirfreq=freq;
                obj.SolverStruct.Solution.theta=theta1;
                obj.SolverStruct.Solution.phi=phi1;
                obj.SolverStruct.Solution.cep=calc_emb_pattern;
                obj.SolverStruct.Solution.pol=pol;
            end
        end


        function RadiatedPower=calc_radpower(obj,freq,R,...
            calc_emb_pattern,ElemNumber)

            sphereChoice='low';
            if isa(obj,'em.Array')
                if getTotalArrayElems(obj)>100
                    sphereChoice='high';
                end
            end
            if strcmpi(class(obj),'sectorInvertedAmos')
                sphereChoice='high';
            end
            [Points,n_s,Area_s]=...
            em.FieldAnalysisWithFeed.generateRadiationSphere(R,...
            obj.Tilt,obj.TiltAxis,sphereChoice);
            [E,H]=calcEHfields(obj,freq,Points,...
            calc_emb_pattern,0,[],ElemNumber);
            Poynting=0.5*real(cross(E,conj(H)));
            RadiatedPower=R^2*sum(abs(dot(n_s,Poynting)).*Area_s);
            clear Area_s Center_s n_s p_s t_s

        end

    end

end