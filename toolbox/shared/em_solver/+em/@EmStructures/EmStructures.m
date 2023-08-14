classdef(Abstract)EmStructures<matlab.mixin.SetGet&matlab.mixin.CustomDisplay&matlab.mixin.Copyable







    properties(Access={?em.PortAnalysis,...
        ?em.SharedPortAnalysis,...
        ?em.SurfaceAnalysis,...
        ?rfpcb.TxLine,...
        ?em.EmSolver,...
        ?em.SharedSurfaceAnalysis,...
        ?em.FieldAnalysisWithFeed,...
        ?em.FieldAnalysisWithWave,...
        ?em.ArrayAnalysis,...
        ?em.DesignAnalysis,...
        ?em.EmStructures})
        SolverStruct=struct('RWG',[],'Solution',[],'Load',[],'FieldSolver2d',[],...
        'Source',[],'HasSourceChanged',1,'Solver',[],'HasSolverChanged',0,'HasSolverTypeChanged',0);
    end
    properties(Access=private)


CancelStatus
    end









































    methods
        function save(obj,filename)%#ok<INUSL>
            objname=inputname(1);
            eval([objname,'= obj;']);
            save(filename,objname);
        end
    end

    methods(Hidden)

        function solvertype(obj,solvername)
            if strcmpi(solvername,'mcode')
                obj.SolverStruct.UseMcode=1;
                obj.SolverStruct.HasStructureChanged=1;
            elseif strcmpi(solvername,'ccode')
                obj.SolverStruct.UseMcode=0;
                obj.SolverStruct.HasStructureChanged=1;
            elseif strcmpi(solvername,'lpkcode')
                obj.SolverStruct.UseMcode=-1;
                obj.SolverStruct.HasStructureChanged=1;
            end
        end

        function propVal=getIntegrationScheme(obj)

            if isa(obj,'rfpcb.PrintedLine')||isa(obj,'pcbComponent')
                propVal=1;
            else
                s=settings;
                propVal=s.antenna.Solver.UseR2018aIntegrationScheme.ActiveValue;
            end
        end

        function propVal=getSolverType(obj)
            if isfield(obj.MesherStruct,'UsePO')
                if obj.MesherStruct.UsePO
                    propVal='PO';
                else
                    propVal='MoM';
                end
            else
                propVal='MoM';
            end
        end

        tf=isMeshClosed(obj)

        function rObj=superLoadEmStructures(obj,s)
            tempstruct=obj.SolverStruct;
            f=fieldnames(s.SolverStruct);
            for i=1:numel(f)
                tempstruct=setfield(tempstruct,f{i},getfield(s.SolverStruct,f{i}));
            end
            obj.SolverStruct=tempstruct;
            rObj=obj;
        end

        function s=saveobj(obj)




            obj.MesherStruct.CacheFlag=obj.MesherStruct.HasStructureChanged;
            s=obj;
        end

        function props=getObjectProperties(obj)
            G=getPropertyGroups(obj);
            props=fields(G.PropertyList);
        end

        function R=getRadiationSphereRadius(obj,f)
            s=settings;
            Rset=s.antenna.Solver.FarFieldSphereRadiusInLambda.ActiveValue;
            R=Rset*299792458/f;



            maxR=findBoundingSphereRadius(obj);
            if maxR>R/20
                R=100*(R+maxR);
            end
        end

        af=afcalc(obj,f,phi,theta);

        function res=isequalInt(obj,otherObj,isWeakCmp)




            if nargin==2
                isWeakCmp=false;


            end


            if~isa(obj,'em.EmStructures')||~isa(otherObj,'em.EmStructures')
                res=false;
                return
            end




            if isempty(obj)
                if isempty(otherObj)
                    res=builtin('isequal',metaclass(obj),...
                    metaclass(otherObj));
                    return
                else
                    res=false;
                    return
                end
            end
            if isempty(otherObj)
                res=false;
                return
            end



            tempCache=obj.MesherStruct.CacheFlag;
            obj.MesherStruct.CacheFlag=otherObj.MesherStruct.CacheFlag;

            TempDisplayWaitBar=obj.MesherStruct.DisplayWaitBar;
            obj.MesherStruct.DisplayWaitBar=...
            otherObj.MesherStruct.DisplayWaitBar;

            if isfield(obj.MesherStruct.Geometry,'multiplier')
                tempVisData.multiplier=...
                obj.MesherStruct.Geometry.multiplier;
            else
                tempVisData.multiplier=[];
            end
            if isfield(otherObj.MesherStruct.Geometry,'multiplier')
                obj.MesherStruct.Geometry.multiplier=...
                otherObj.MesherStruct.Geometry.multiplier;
            elseif isfield(obj.MesherStruct.Geometry,'multiplier')
                obj.MesherStruct.Geometry=...
                rmfield(obj.MesherStruct.Geometry,'multiplier');
            end
            if isfield(obj.MesherStruct.Geometry,'unit')
                tempVisData.unit=obj.MesherStruct.Geometry.unit;
            else
                tempVisData.unit=[];
            end
            if isfield(otherObj.MesherStruct.Geometry,'unit')
                obj.MesherStruct.Geometry.unit=...
                otherObj.MesherStruct.Geometry.unit;
            elseif isfield(obj.MesherStruct.Geometry,'unit')
                obj.MesherStruct.Geometry=...
                rmfield(obj.MesherStruct.Geometry,'unit');
            end




            if isprop(obj,'Substrate')&&isprop(otherObj,'Substrate')
                tempSubstrate=copy(obj.Substrate);
                resCO=replaceCO(obj.Substrate,otherObj.Substrate);
            end
            if isWeakCmp


                tempMeshingChoice=obj.MesherStruct.MeshingChoice;
                obj.MesherStruct.MeshingChoice=...
                otherObj.MesherStruct.MeshingChoice;
                tempSolution=obj.SolverStruct.Solution;
                obj.SolverStruct.Solution=otherObj.SolverStruct.Solution;
                res=builtin('isequal',obj,otherObj);
                obj.SolverStruct.Solution=tempSolution;
                obj.MesherStruct.MeshingChoice=tempMeshingChoice;
            else
                res=builtin('isequal',obj,otherObj);
            end
            obj.MesherStruct.CacheFlag=tempCache;
            obj.MesherStruct.DisplayWaitBar=TempDisplayWaitBar;
            if~isempty(tempVisData.multiplier)
                obj.MesherStruct.Geometry.multiplier=...
                tempVisData.multiplier;
            elseif isfield(obj.MesherStruct.Geometry,'multiplier')
                obj.MesherStruct.Geometry=...
                rmfield(obj.MesherStruct.Geometry,'multiplier');
            end
            if~isempty(tempVisData.unit)
                obj.MesherStruct.Geometry.unit=tempVisData.unit;
            elseif isfield(obj.MesherStruct.Geometry,'unit')
                obj.MesherStruct.Geometry=...
                rmfield(obj.MesherStruct.Geometry,'unit');
            end
            if isprop(obj,'Substrate')&&isprop(otherObj,'Substrate')
                replaceCO(obj.Substrate,tempSubstrate);
                if res
                    res=resCO;
                end
            end
        end

        function setNumFeedEdge(obj,n)
            obj.SolverStruct.numfeededge=n;
        end

        function n=getNumFeedEdge(obj)
            n=obj.SolverStruct.numfeededge;
        end

        memEstimate=protectedmemoryEstimate(obj,varargin)
        antennaInfo=protectedinfo(obj)
    end


    methods(Access={?em.PortAnalysis,...
        ?em.SharedPortAnalysis,...
        ?em.SurfaceAnalysis,...
        ?em.SharedSurfaceAnalysis,...
        ?rfpcb.TxLine,...
        ?em.EmSolver,...
        ?em.FieldAnalysisWithFeed,...
        ?em.FieldAnalysisWithWave,...
        ?em.ArrayAnalysis,...
        ?em.DesignAnalysis,...
        ?em.EmStructures})

        function checkarrayaparams(obj,val)
            if isa(obj,'em.Array')
                validateattributes(val,...
                {'numeric'},{'finite','real','positive','nonnan',...
                'scalar','<=',getTotalArrayElems(obj)},...
                'pattern');
            else
                error(message('antenna:antennaerrors:InvalidOption'));
            end
        end

        function status=analyze(obj,frequency,ElemNumber,ZL,isLinpar)

            status=0;
            if nargin==2
                ElemNumber=[];
                ZL=50;
                addtermination=0;
                isLinpar=false;
            elseif nargin==3
                addtermination=0;
                ZL=50;
                isLinpar=false;
            elseif nargin==4
                isLinpar=false;
                if isempty(ElemNumber)
                    addtermination=0;
                else
                    addtermination=1;
                end
            else
                if isempty(ElemNumber)
                    addtermination=0;
                else
                    addtermination=1;
                end
            end


            em.MeshGeometry.checkFrequency(frequency);
            if isLinpar

                get2dCrossSectionParams(obj);

            else



                if strcmpi(obj.MesherStruct.MeshingChoice,'Auto')
                    if isa(obj,'rfpcb.PCBComponent')||isa(obj,'pcbComponent')||isa(obj,'rfpcb.PCBSubComponent')||isa(obj,'rfpcb.PCBVias')
                        tf_structure=checkHasStructureChanged(obj);
                        tf_mesh=checkHasMeshChanged(obj);
                        if~isempty(obj.SolverStruct.Solution)&&...
                            ~(length(fieldnames(obj.SolverStruct.Solution))==2&&isfield(obj.SolverStruct.Solution,'FieldSolver2d'))
                            tf_frequency=isempty(find(obj.SolverStruct.Solution.Frequency==...
                            max(frequency),1))&&...
                            isempty(find(obj.SolverStruct.Solution.YPFrequency==...
                            max(frequency),1))&&...
                            isempty(find(obj.SolverStruct.Solution.Embfreq==...
                            max(frequency),1));
                        else
                            tf_frequency=true;
                        end
                        tf=tf_structure||tf_mesh||tf_frequency;
                    else
                        tf=true;
                    end
                    if tf
                        [~,~]=getMesh(obj,max(frequency));
                    end
                else
                    [~,~]=getMesh(obj);
                end
            end



            if~isempty(obj.SolverStruct.Solution)&&length(frequency)>2
                numcalculations=length(setdiff(frequency,...
                obj.SolverStruct.Solution.Frequency));
            else
                numcalculations=length(frequency);
            end


            if obj.MesherStruct.HasMeshChanged
                numcalculations=length(frequency);
            end

            if isequal(obj.MesherStruct.DisplayWaitBar,1)
                obj.MesherStruct.DisplayWaitBar=0;
            end
            if numcalculations>2
                msg=sprintf('Calculating solution for %d frequency points',...
                length(frequency));
                hwait=waitbar(0,msg,'Name','Frequency sweep',...
                'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
                cleanup=onCleanup(@()delete(hwait));
                setappdata(hwait,'canceling',0);
            else
                hwait=[];
            end


            try
                for m=1:length(frequency)

                    if isLinpar
                        linparsolver(obj,frequency(m));
                    else
                        if isprop(obj,'SolverType')&&strcmpi(obj.SolverType,'MoM-PO')
                            momposolver(obj,frequency(m),ElemNumber,ZL,addtermination,hwait);
                        elseif isprop(obj,'SolverType')&&strcmpi(obj.SolverType,'FMM')
                            fmmsolver(obj,frequency(m),ElemNumber,ZL,addtermination,hwait);
                        else
                            momsolver(obj,frequency(m),ElemNumber,ZL,addtermination,hwait);
                        end
                    end
                    if numcalculations>2

                        if~isvalid(hwait)||getappdata(hwait,'canceling')
                            status=1;
                            break
                        end
                        msg=sprintf('Calculating %d/%d frequency points',...
                        m,length(frequency));
                        waitbar(m/length(frequency),hwait,msg);
                    end
                end
            catch ME


                delete(hwait);
                rethrow(ME)
            end

            if numcalculations>2
                delete(hwait);
            end
        end



        function[E,H]=calcEHfields(obj,freq,Points,...
            calc_emb_pattern,hemispehere,ang,ElemNumber)

            if nargin==4
                hemispehere=0;
                ang=[];
                ElemNumber=0;
            end

            if nargin==5
                ang=[];
                ElemNumber=0;
            end

            if isempty(calc_emb_pattern)
                calc_emb_pattern=0;
            end

            if calc_emb_pattern
                I=obj.SolverStruct.Solution.embeddedI(:,ElemNumber);
            else
                if strcmpi(obj.SolverStruct.Source.type,'voltage')
                    [~,idx_sol]=intersect(obj.SolverStruct.Solution.Frequency...
                    ,freq);
                    I=obj.SolverStruct.Solution.I(:,idx_sol);
                elseif strcmpi(obj.SolverStruct.Source.type,'planewave')
                    idx_sol=find(obj.SolverStruct.Solution.Sfrequency...
                    ==freq,1);
                    I=obj.SolverStruct.Solution.SI(:,idx_sol);
                elseif strcmpi(obj.SolverStruct.Source.type,'planewave-rcs')
                    idx_solang=find(obj.SolverStruct.RCSSolution.TxAngle==ang,1);
                    I=squeeze(obj.SolverStruct.RCSSolution.I);
                end
            end
            CenterRho(:,1,:)=obj.SolverStruct.RWG.Center-...
            obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(1,:));
            CenterRho(:,2,:)=obj.SolverStruct.RWG.Center-...
            obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(2,:));
            CenterRho(:,3,:)=obj.SolverStruct.RWG.Center-...
            obj.MesherStruct.Mesh.p(:,obj.MesherStruct.Mesh.t(3,:));

            if hemispehere
                E=nan(size(Points));
                H=nan(size(Points));
                [~,indexRemove]=find(Points(3,:)<0);
                [~,indexKeep]=find(Points(3,:)>=0);
                Points(:,indexRemove)=[];
            end

            if isfield(obj.SolverStruct,'UseMcode')&&...
                (obj.SolverStruct.UseMcode==1)
                [E1,H1]=fieldm(obj,freq,Points,2);
            else

                if(isfield(obj.MesherStruct,'UsePO')&&obj.MesherStruct.UsePO)||...
                    (isfield(obj.MesherStruct,'UseFMM')&&obj.MesherStruct.UseFMM)||...
                    (isprop(obj,'SolverType')&&strcmpi(obj.SolverType,'FMM'))
                    [Er,Ei,Hr,Hi]=em.EmStructures.fieldpo_c(...
                    obj.SolverStruct.RWG.Center,...
                    obj.SolverStruct.RWG.TrianglePlus,...
                    obj.SolverStruct.RWG.TriangleMinus,...
                    obj.SolverStruct.RWG.EdgeLength,real(I),...
                    imag(I),freq,Points);
                    E1=complex(Er,Ei);
                    H1=complex(Hr,Hi);


                elseif isscalar(freq)
                    [Er,Ei,Hr,Hi]=em.EmStructures.fieldm_c(...
                    obj.MesherStruct.Mesh.p,obj.MesherStruct.Mesh.t,...
                    obj.SolverStruct.RWG.Center,...
                    obj.SolverStruct.RWG.Area,...
                    obj.SolverStruct.RWG.TrianglePlus,...
                    obj.SolverStruct.RWG.TriangleMinus,...
                    obj.SolverStruct.RWG.VerP,...
                    obj.SolverStruct.RWG.VerM,...
                    obj.SolverStruct.RWG.EdgeLength,...
                    CenterRho,obj.SolverStruct.RWG.facesize,...
                    real(I(1:obj.SolverStruct.RWG.EdgesTotal)),...
                    imag(I(1:obj.SolverStruct.RWG.EdgesTotal)),...
                    freq,Points,2);
                    E1=complex(Er,Ei);
                    H1=complex(Hr,Hi);
                    if isfield(obj.MesherStruct.Mesh,'T')&&~isempty(obj.MesherStruct.Mesh.T)
                        D=I(obj.SolverStruct.RWG.EdgesTotal+1:end);
                        [Edr,Edi,Hdr,Hdi]=em.EmStructures.fieldd_c(...
                        obj.SolverStruct.const,obj.SolverStruct.strdiel,...
                        real(D),imag(D),freq,Points,2);
                        Ed=complex(Edr,Edi);
                        Hd=complex(Hdr,Hdi);
                        E1=E1+Ed;
                        H1=H1+Hd;
                    end
                else
                    E1=zeros(3,numel(freq));
                    H1=zeros(3,numel(freq));
                    for m=1:numel(freq)
                        [Er,Ei,Hr,Hi]=em.EmStructures.fieldm_c(...
                        obj.MesherStruct.Mesh.p,obj.MesherStruct.Mesh.t,...
                        obj.SolverStruct.RWG.Center,...
                        obj.SolverStruct.RWG.Area,...
                        obj.SolverStruct.RWG.TrianglePlus,...
                        obj.SolverStruct.RWG.TriangleMinus,...
                        obj.SolverStruct.RWG.VerP,...
                        obj.SolverStruct.RWG.VerM,...
                        obj.SolverStruct.RWG.EdgeLength,...
                        CenterRho,obj.SolverStruct.RWG.facesize,...
                        real(I(1:obj.SolverStruct.RWG.EdgesTotal,m)),...
                        imag(I(1:obj.SolverStruct.RWG.EdgesTotal,m)),...
                        freq(m),Points,2);
                        E1(:,m)=complex(Er,Ei);
                        H1(:,m)=complex(Hr,Hi);
                        if isfield(obj.MesherStruct.Mesh,'T')&&~isempty(obj.MesherStruct.Mesh.T)
                            D=I(obj.SolverStruct.RWG.EdgesTotal+1:end,m);
                            [Edr,Edi,Hdr,Hdi]=em.EmStructures.fieldd_c(...
                            obj.SolverStruct.const,obj.SolverStruct.strdiel,...
                            real(D),imag(D),freq(m),Points,2);
                            Ed=complex(Edr,Edi);
                            Hd=complex(Hdr,Hdi);
                            E1(:,m)=E1(:,m)+Ed;
                            H1(:,m)=H1(:,m)+Hd;
                        end
                    end
                end
            end
            if isscalar(freq)
                if hemispehere
                    E(:,indexKeep)=E1;
                    H(:,indexKeep)=H1;
                else
                    E=E1;
                    H=H1;
                end
            else
                E=E1;
                H=H1;
            end

        end



        function group=objectProps(obj,propertyDisplayList,title)
            propList=properties(obj);
            numProps=max(size(propertyDisplayList));
            for i=1:numProps
                if(strcmpi(propertyDisplayList{i},propList(strcmpi(propertyDisplayList{i},propList))))
                    antennaProps.(char(propertyDisplayList{i}))=get(obj,propertyDisplayList{i});
                else

                end
            end

            if isa(obj,'installedAntenna')||isa(obj,'em.ParabolicAntenna')||isa(obj,'planeWaveExcitation')
                antennaProps.SolverType=obj.SolverType;
            end
            group=matlab.mixin.util.PropertyGroup(antennaProps,title);
        end

        function clearSolutionData(obj)
            obj.SolverStruct.RWG=[];
            obj.SolverStruct.Solution=[];
        end

        function objOut=copySolutionData(obj,otherObj)
            if nargin==1
                objOut.SolverStruct.RWG=obj.SolverStruct.RWG;
                objOut.SolverStruct.Solution=obj.SolverStruct.Solution;
            else
                obj.SolverStruct.RWG=otherObj.SolverStruct.RWG;
                obj.SolverStruct.Solution=otherObj.SolverStruct.Solution;
                objOut=obj;
            end
        end

        function disableSource(obj)%#ok<MANU>

        end

        function setSourceVoltage(obj,value,dim)
            if iscolumn(value)
                value=value.';
            end
            if nargin<3
                obj.SolverStruct.Source.voltage=value;
            else
                obj.SolverStruct.Source.voltage=ones(1,dim)*value;
            end
        end

        function setPhaseShift(obj,value,dim)
            if iscolumn(value)
                value=value.';
            end
            if nargin<3
                obj.SolverStruct.Source.phaseshift=value;
            else
                obj.SolverStruct.Source.phaseshift=ones(1,dim)*value;
            end
        end

        function setTotalArrayElems(obj,value)
            obj.SolverStruct.TotalArrayElems=value;
        end

        function value=getTotalArrayElems(obj)
            value=obj.SolverStruct.TotalArrayElems;
        end

        function N=getNumFeedLocations(obj)
            N=size(obj.FeedLocation,1);
            if isprop(obj,'Element')&&isa(obj.Element,'em.Array')
                obj.MesherStruct.HasStructureChanged=0;
            end
        end

        function tf=isFigureBroughtForward(obj,hfig)%#ok<INUSL>
            tf=antennashared.internal.figureForwardState(hfig);
        end
        setHasSolverChanged(obj,tf)
        setHasSolverTypeChanged(obj,tf)
        checkSolvervsObjType(obj,propVal)
        checkSolvervsInfiniteGndPlane(obj,propVal)
        checkSolvervsDielectric(obj,propVal)
        checkSolvervsLoad(obj,propVal)
        source(obj,type,varargin);
        output=sourceInfo(obj);
        [Zimp,frq,loadedge]=calcloadimp(obj,calculate_load,hwait);
        V=voltagevector(obj,ElemNumber,omega,pwavesource);
        V=voltagevectorfmm(obj,ElemNumber,omega,pwavesource)
        [ZL,loadedge]=loadingedge(obj,calculate_load,frequency,...
        Zterm,addtermination,hwait);
        [ZL,loadedge]=loadingedgerfpcb(obj,~,frequency,...
        Zterm,addtermination,hwait)
        savesolution(obj,I,frequency,addtermination,ElemNumber);
        savemomposolution(obj,I,frequency,addtermination,ElemNumber);
        savercssolution(obj,IPO,frequency,P,T);
        [static_soln,dynamic_soln,calculate_load]=checkcache(obj,...
        frequency,ElemNumber,Zterm,addtermination,Termination);
        [calculate_static_soln,calculate_dynamic_soln]=checkrcscache(obj,...
        frequency,kvector,polvector)
        momsolver(obj,frequency,ElemNumber,ZL,addtermination,hwait,pwavesource,D);
        momposolver(obj,frequency,ElemNumber,ZL,addtermination,hwait,pwavesource);
        momsolver_infmetalarray(obj,frequency,ElemNumber,Zterm,addtermination,hwait,pwavesource,D,...
        calculate_static_soln,calculate_dynamic_soln,calculate_load);
        fmmsolver(obj,frequency,ElemNumber,Zterm,addtermination,hwait);
        I=emsolver(obj,V,ZL,loadedge,omega);
        I=solver_infmetalarrayPoisson(obj,V,omega);
        I=solver_infmetalarrayDirect(obj,V,omega);
        momsolver_infdielarray(obj,frequency,ElemNumber,Zterm,addtermination,hwait,pwavesource,D,...
        calculate_static_soln,calculate_dynamic_soln,calculate_load);
        I=solver_infdielarray(geom,const,obj,V,omega);
        posolver(obj,frequency,kvector,polvector,sourceloc,P,T,enablegpu)
        selfint=metalselfint(obj,p,t,metalbasis,TetrahedraTotal);

        V=voltage_radiation(obj,ElemNumber);
        V=voltage_scattered(obj,omega,dir,Pol)
        V=voltagemompo(obj,ElemNumber,omega,pwavesource)

        metalbasis=overrideFeedEdgeBasis(obj,metalbasis,p,t);

        [E,H]=calculatePOEfield(obj,freq,Point)
        R=findBoundingSphereRadius(obj)


        momsolver_mat(obj,frequency,ElemNumber,ZL,addtermination);
        momsolver_IGP(obj,frequency,ElemNumber,ZL,calcembpat);


        linparsolver(obj,frequency);
        savelinparsolution(obj,frequency,RLGC);
        saveFieldSolver2d(obj,l);
    end

    methods(Access=protected)

        function checkIntersection(obj)

            geom=obj.MesherStruct.Geometry;
            list={'yagiUda','cassegrain','gregorian','cavity','cavityCircular'...
            ,'reflector','reflectorCylindrical','reflectorCircular','reflectorParabolic',...
            'reflectorCorner','reflectorGrid','reflectorSpherical','quadCustom',...
            'cassegrainOffset','gregorianOffset','customDualReflectors'};
            if isscalar(geom)

                if getDynamicPropertyState(obj)&&~getInfGPState(obj)
                    geom.polygons(1)=[];
                end
                if~any(strcmpi(class(obj),list))
                    if isa(obj.Element,'draRectangular')||isa(obj.Element,'draCylindrical')
                        if numel(obj.Element.Substrate.EpsilonR)>1

                            if isa(obj,'linearArray')||isa(obj,'circularArray')
                                cellSize=obj.NumElements;
                            elseif isa(obj,'rectangularArray')
                                cellSize=obj.Size(1)*obj.Size(2);
                            end
                        else
                            cellSize=numel(geom.SubstratePolygons);
                        end
                    else
                        cellSize=numel(geom.polygons);
                    end
                else
                    cellSize=numel(geom.polygons);
                end
                p_element=cell(cellSize,1);
                t_element=cell(cellSize,1);

                for m=1:cellSize
                    if~any(strcmpi(class(obj),list))
                        if isa(obj.Element,'draRectangular')||isa(obj.Element,'draCylindrical')
                            if numel(obj.Element.Substrate.EpsilonR)>1
                                subpol={};
                                for b=1:numel(obj.Element.Substrate.EpsilonR):numel(geom.SubstratePolygons)
                                    subpol=[subpol,{cell2mat({geom.SubstratePolygons{b:b+numel(obj.Substrate.EpsilonR)-1}}')}];
                                end
                                subpol=subpol';
                                t=subpol{m};

                            else
                                t=geom.SubstratePolygons{m};
                            end
                        else
                            t=geom.polygons{m};
                        end
                    else
                        t=geom.polygons{m};
                    end
                    maxidx=max(t,[],"all");
                    minidx=min(t,[],"all");
                    if~any(strcmpi(class(obj),list))
                        if isa(obj.Element,'draRectangular')||isa(obj.Element,'draCylindrical')
                            p=geom.SubstrateVertices(minidx:maxidx,:);
                        else
                            p=geom.BorderVertices(minidx:maxidx,:);
                        end
                    else
                        p=geom.BorderVertices(minidx:maxidx,:);
                    end
                    if minidx~=1
                        t=t-minidx+1;
                    end
                    t(:,4)=0;
                    p_element{m}=p';
                    t_element{m}=t';
                end
                flag=em.internal.isIntersecting(p_element,t_element,geom);
            else
                cellSize=numel(geom);
                p_element=cell(cellSize,1);
                t_element=cell(cellSize,1);
                for m=1:cellSize
                    p_element{m}=geom{m}.BorderVertices.';
                    t=vertcat(geom{m}.polygons{:});
                    t(:,4)=0;
                    t_element{m}=t.';
                end
                flag=em.internal.isIntersecting(p_element,t_element,[]);
            end

            if any(flag)
                error(message('antenna:antennaerrors:IntersectingGeometry'));
            end
        end

        function restoreCacheFlag(obj,s)
            obj.MesherStruct.HasStructureChanged=s.MesherStruct.CacheFlag;
            obj.SolverStruct.HasSolverTypeChanged=false;
        end

        function copyObj=copyElement(obj)


            copyObj=copyElement@matlab.mixin.Copyable(obj);








            hmeta=metaclass(obj);
            metaProps=hmeta.PropertyList;
            x={};
            for i=1:numel(metaProps)


                if~any(strcmpi(metaProps(i).Name,{'SolverStruct','MesherStruct'}))
                    propGetAccess=metaProps(i).GetAccess;
                    propSetAccess=metaProps(i).SetAccess;
                    if any(strcmpi('public',propGetAccess))&&any(strcmpi('public',propSetAccess))
                        propName=metaProps(i).Name;
                        if(isa(obj.(propName),'cell'))
                            tfArray=cellfun(@(x)isa(x,'handle'),obj.(propName));
                            if(all(tfArray))


                                x=[x,{propName}];%#ok<AGROW>
                            end
                        else
                            tf=isa(obj.(propName),'handle');
                            if tf
                                x=[x,{propName}];%#ok<AGROW>
                            end
                        end

                    end
                end
            end






            if~isempty(x)
                s=saveobj(obj);
            end


            for j=1:numel(x)
                if(iscell(s.(x{j})))
                    tempX=cell(1,numel(s.(x{j})));
                    dielecFlag=0;
                    for k=1:numel(s.(x{j}))
                        if(isa(s.(x{j}){k},'dielectric'))

                            temphand=copy(s.(x{j}){k});

                            temphand.Parent=[];

                            dielecFlag=1;
                        else
                            temphand=copy(s.(x{j}){k});
                        end
                        tempX{k}=temphand;
                    end

                    tempgeom=copyObj.MesherStruct.Geometry;
                    copyObj.(x{j})=tempX;

                    copyObj.MesherStruct.Geometry=tempgeom;

                else
                    if any(strcmpi(x{j},{'Substrate','Exciter','Element','Conductor','Platform'}))

                        tempprop=copy(s.(x{j}));


                        if isprop(tempprop,'Parent')
                            tempprop.Parent=[];
                        end

                        if(isa(obj,'pcbStack')||isa(obj,'pcbComponent'))&&...
                            strcmpi(x{j},'Substrate')
                            if numel(tempprop.EpsilonR)>1
                                tempprop.Name=fliplr(tempprop.Name);
                            end
                            tempprop.LossTangent=fliplr(tempprop.LossTangent);
                            tempprop.EpsilonR=fliplr(tempprop.EpsilonR);
                            tempprop.Thickness=fliplr(tempprop.Thickness);
                        end



                        tempgeom=copyObj.MesherStruct.Geometry;
                        tempmesh=copyObj.copyMeshData;
                        tempsol=copyObj.copySolutionData;


                        copyObj.(x{j})=tempprop;

                        copyObj.copySolutionData(tempsol);
                        copyObj.copyMeshData(tempmesh);
                        copyObj.MesherStruct.Geometry=tempgeom;
                    else
                        copyObj.(x{j})=copy(s.(x{j}));
                    end
                end
            end




            if~isempty(x)
                restoreCacheFlag(copyObj,s);
            end
        end
    end

    methods(Hidden)
        function c=clone(obj)
            c=copy(obj);
        end





    end

    methods(Access={?phased.internal.AbstractArray,...
        ?phased.internal.AbstractElement,...
        ?phased.internal.AbstractSubarray,...
        ?phased.internal.AbstractSensorOperation,...
        ?phased.internal.AbstractArrayOperation,...
        ?phased.internal.AbstractClutterSimulator,...
        ?phased.gpu.internal.AbstractClutterSimulator...
        ,?phasedsharedtests.AntennaAdapter})

        function E=step(obj,freq,angles)
            phi=angles(1,:);
            theta=90-angles(2,:);
            [x,y,z]=antennashared.internal.sph2cart(phi,theta,1e3);
            Points=zeros(3,numel(x));
            for m=1:size(theta,2)
                index1=size(theta,1)*(m-1);
                index2=size(theta,1)*m;
                Points(:,index1+1:index2)=[x(:,m).';y(:,m).';z(:,m).'];
            end
            addtermination=false;
            status=analyze(obj,freq);
            if status
                E=[];
                return;
            end
            E=zeros(3,numel(theta),numel(freq));
            for m=1:numel(freq)
                E(:,:,m)=calcEHfields(obj,freq(m),Points,addtermination);
            end
        end

    end

    methods(Static=true,Access={?em.PortAnalysis,...
        ?em.SharedPortAnalysis,...
        ?em.SurfaceAnalysis,...
        ?em.SharedSurfaceAnalysis,...
        ?em.FieldAnalysisWithFeed,...
        ?em.FieldAnalysisWithWave,...
        ?em.ArrayAnalysis,...
        ?em.DesignAnalysis,...
        ?em.WireStructures,...
        ?em.EmStructures})


        metalbasis=alignfeedcurrents(metalbasis,t,feededge,objname);


        diel=volumemesh(P,T,const);


        [azimuth,elevation,flag_az,flag_el]=checkMonotonic(azimuth,elevation);


        [coeff,weights,IndexF]=gausstri(arg1,arg2);


        [coeff,weights,IndexT]=gausstet(arg1,arg2);


        metalbasis=basis_metal_c(p,t);
        [geom,const]=function_BASISmetal(P,t,NumRWG);
        IS=function_SELF_INTEGRALS(Vertex);


        feededge=feeding_edge(p,Edge,FeedLocation,FeedType,Element);


        feededge=getFeedEdges(obj,p,Edges);


        metalbasis=retain_independent_basis(t,metalbasis);


        selfint=calc_integral_c(p,t,Center,Area,norm_t,facesize,...
        coeff,weights,order);

        selfint=calc_integral_igp_c(p,t,Center,Area,norm_t,facesize,...
        coeff,weights,order);

        selfint=calc_integral_igp_conn_c(p,t,Center,Area,norm_t,...
        facesize,coeff,weights,order);

        selfint=calc_integral_infarray_c(p,t);


        strdiel=basis_dielectric_c(P,T,Faces,Edges,AT,const);

        intdiel=calc_integral_diel_c(P,T,facesboundary,CenterF,...
        AreaF,Facesize,CenterT,VolumeT,Tetsize,coeffS,weightsS,...
        radiusF,coeffT,weightsT,radiusT);

        intmetaldiel=calc_integral_metal_diel_c(P,T,facesboundary,...
        t,CenterF,AreaF,Facesize,CenterT,VolumeT,Tetsize,...
        Center,Area,facesize,coeffS,weightsS,radiusM,coeffT,...
        weightsT,radiusT);

        strdiel=embedded_basis(strdiel,t,AT,FacesNontrivial,const);


        Z=zmm_c(Center,TrianglePlus,TriangleMinus,CenterRho,VerP,...
        VerM,EdgeLength,PointsM,PointsMRho,OrderM,WM,ttIS,...
        ttJS,ttSS,ttRS,omega_re,omega_im);

        [I_re,I_im]=zmm_solve_metal_c(rwgbasis,selfint,CenterRho,...
        PointsM,PointsMRho,WM,omega_re,omega_im,V_re,V_im,...
        terminatingedge,ZL_re,ZL_im);

        [I_re,I_im]=zmm_po_c(rwgbasis,selfint,CenterRho,...
        PointsM,PointsMRho,WM,omega_re,omega_im,V_re,V_im,...
        terminatingedge,ZL_re,ZL_im);

        [I_re,I_im]=zmm_igp_bal_c(Center,TrianglePlus,TriangleMinus,CenterRho,VerP,...
        VerM,EdgeLength,PointsM,PointsMRho,OrderM,WM,ttIS,...
        ttJS,ttSS,ttRS,omega_re,omega_im,V_re,V_im,...
        terminatingedge,ZL_re,ZL_im,selfneighbors);

        [I_re,I_im]=zmm_igp_conn_c(Center,TrianglePlus,TriangleMinus,CenterRho,VerP,...
        VerM,EdgeLength,PointsM,PointsMRho,OrderM,WM,ttIS,...
        ttJS,ttSS,ttRS,omega_re,omega_im,V_re,V_im,...
        terminatingedge,ZL_re,ZL_im,numjoints);

        [I_re,I_im]=zmm_infarray_c(Center,TrianglePlus,TriangleMinus,CenterRho,VerP,...
        VerM,EdgeLength,PointsM,PointsMRho,OrderM,WM,ttIS,...
        ttJS,ttSS,ttRS,omega_re,omega_im,V_re,V_im,dx,dy,phi,...
        theta,terms,numjoints);



        [Zsurf]=Zsurf_calc(omega,metalthickness,conductivity);

        [FeedPower]=calcFeedpower(obj,freq);

        [Pmloss]=conductionloss(obj,freq,metalthickness,conductivity);

        [FeedPower]=calcFeedpowerArray(obj,freq,calc_emb_pattern,...
        ElemNumber);
        RadiatedPower=calc_radiatedpower(obj,freq,R);

        [PortEfficiency]=calcPortEfficiency(obj,freq,calc_emb_pattern,...
        ElemNumber,s);
        PL=lumpedLoss(obj,freq,calc_emb_pattern,ElemNumber);



        [Z]=zmm_cond(EdgesTotal,TrianglesTotal,Center,TrianglePlus,...
        TriangleMinus,CenterRho,VerP,VerM,EdgeLength,PointsM,...
        PointsMRho,OrderM,WM,ttIS,ttJS,ttSS,ttRS,omega,Area,Zsurf);


        [I_re,I_im]=zmm_solve_metal_c_cond(rwgbasis,selfint,CenterRho,...
        coeffM,Vertexes,WM,omega_re,omega_im,V_re,V_im,...
        terminatingedge,ZL_re,ZL_im,Zs_re,Zs_im);




        [I_re,I_im]=zmetal_diel_solve_c_cond(metalbasis,metalselfint,CenterRho,...
        PointsM,PointsMRho,WM,omega_re,omega_im,V_re,V_im,...
        terminatingedge,ZL_re,ZL_im,strdiel,intdiel,intmetaldiel,const,Zs_re,Zs_im);



        [Er,Ei,Hr,Hi]=fieldm_c(P,t,Center,Area,TrianglePlus,...
        TriangleMinus,VerP,VerM,EdgeLength,CenterRho,facesize,...
        Ir,Ii,freq,Points,Radius);

        [Er,Ei,Hr,Hi]=fieldpo_c(Center,Area,TrianglePlus,...
        TriangleMinus,EdgeLength,Ir,Ii,freq,Points);

        [Edr,Edi,Hdr,Hdi]=fieldd_c(const,strdiel,Ir,Ii,freq,Points,Radius);

        [I_re,I_im]=zmetal_diel_solve_c(metalbasis,metalselfint,CenterRho,...
        PointsM,PointsMRho,WM,omega_re,omega_im,V_re,V_im,...
        terminatingedge,ZL_re,ZL_im,strdiel,intdiel,intmetaldiel,const);


        Integrals=calc_integrals(P,t,cent_t,area_t,norm_t,order);
        Integrals=calc_integrals_IGP(P,t,cent_t,area_t,norm_t,order);
        Integrals=calc_integrals_conn_IGP(P,t,cent_t,area_t,norm_t,order);

        [I,IRho]=pot_integrals(VertexesInt,ObsPoint)

        [Z]=zmm(EdgesTotal,TrianglesTotal,Center,TrianglePlus,...
        TriangleMinus,CenterRho,VerP,VerM,EdgeLength,PointsM,...
        PointsMRho,OrderM,WM,ttIS,ttJS,ttSS,ttRS,omega);

        [Z]=zmm_IGP(EdgesTotal,TrianglesTotal,Center,TrianglePlus,...
        TriangleMinus,CenterRho,VerP,VerM,EdgeLength,PointsM,...
        PointsMRho,OrderM,WM,ttIS,ttJS,ttSS,ttRS,neighbors1,omega);

        [Z]=zmm_IGP_conn(EdgesTotal,TrianglesTotal,Center,TrianglePlus,...
        TriangleMinus,CenterRho,VerP,VerM,EdgeLength,PointsM,...
        PointsMRho,OrderM,WM,ttIS,ttJS,ttSS,ttRS,omega,dx,dy,phi,theta);

        [I,IRho]=midpoint_integrals(PointA,RhoA,PointB,RhoB,omega);

        [I,IRho]=neighbor_integrals(PointA,RhoA,PointB,RhoB,Order,...
        Weights,omega);



        [Edge_,TrianglePlus,TriangleMinus,VerP,VerM]=...
        create_fedding_edge(p,t,Edge_,TrianglePlus,TriangleMinus,...
        VerP,VerM,TrianglesTotal,NumJoints,ismatlab);

        [RWGevector,RWGCenter,DipoleCenter,DipoleMoment]=...
        basis_metal_po_c(P,RWG,FCRhoP,FCRhoM,EdgesTotalMoM);

        [metalbasis,EdgesTotalrad]=basis_mompo(prad,trad,p,t);

        [metalbasis]=basis_po(p,t);

        metalbasis=findLitRegions(metalbasis,p,t,idPO,feededge,mode);
        metalbasis=findLitRegionsEm(metalbasis,P,t,idPO,feededge,mode)
        metalbasis=findLitRegionsOnGpu(metalbasis,p,t,idPO,sourceloc,mode);


    end

    methods(Static=true,Hidden)
        function r=loadobj(obj)
            r=obj;
            r.MesherStruct.HasStructureChanged=obj.MesherStruct.CacheFlag;
            if isa(r,'em.Antenna')||strcmpi(class(r),'customArrayMesh')
                if strcmpi(class(r),'infiniteArray')
                    if~isempty(r.Element.Load.Impedance)
                        setLoadChanged(r.Element.Load,false);
                    end
                elseif~strcmpi(class(r),'customArrayMesh')&&~strcmpi(class(r),'dipoleCrossed')...
                    &&~strcmpi(class(r),'eggCrate')
                    if~isempty(r.Load.Impedance)
                        setLoadChanged(r.Load,false);
                    end
                end
            elseif isa(r,'em.Array')
                if isscalar(r.Element)
                    if isprop(r.Element,'Element')
                        if isprop(r.Element.Element,'Element')
                            setLoadChanged(r.Element.Element.Element.Load,false);
                        else
                            setLoadChanged(r.Element.Element.Load,false);
                        end
                    else
                        if isprop(r.Element,'Load')
                            setLoadChanged(r.Element.Load,false);
                        end
                    end
                elseif iscell(r.Element)
                    for m=1:numel(r.Element)
                        if~any(strcmpi(class(r.Element{m}),{'linearArray','rectangularArray','circularArray'}))
                            if isprop(r.Element{m},'Load')
                                setLoadChanged(r.Element{m}.Load,false);
                            end
                        end
                    end
                else

                    for m=1:numel(r.Element)
                        if~any(strcmpi(class(r.Element(m)),{'linearArray','rectangularArray','circularArray'}))
                            if isprop(r.Element(m),'Load')
                                setLoadChanged(r.Element(m).Load,false);
                            end
                        end
                    end
                end
            elseif strcmpi(class(r),'planeWaveExcitation')
                if isa(r.Element,'em.Antenna')||strcmpi(class(r.Element),'customArrayMesh')
                    setLoadChanged(r.Element.Load,false);
                elseif isa(r.Element,'em.Array')
                    setLoadChanged(r.Element.Element.Load,false);
                end
            end
        end

    end
end

