classdef(Abstract)WireStructures<matlab.mixin.SetGet&matlab.mixin.CustomDisplay&matlab.mixin.Copyable

    properties(Constant,Hidden)
        MinRelDist=0.001;
        r2NFSegLenRatio=7;
        nMatchPtNFSeg=3;
        minr2SegLenRatio=3;
        maxr2lambda=0.01;
    end

    properties(Hidden)

hwait
        useCCode=true
    end

    properties(Access=protected)

WiresInt


ExtraConnsInt




ExtraConnsWireInd


FeedWireIntInd


FeedIndInWireInt


ExVec
DirtyEx

        SolverStruct=struct('Solution',[],'Source',[],...
        'HasSourceChanged',1);

        MesherStruct=struct('Geometry',struct('wires',...
        em.wire.Part.empty,...
        'volDataReal',[],...
        'volData',[],...
        'wireNodesOrig',[],...
        'doNotPlot',0,...
        'wireRadMultiplier',1,...
        'MaxFeatureSize',[]),...
        'Mesh',struct('ExtraMeshNodes',{[]},...
        'MeshGrowthRate',[],...
        'MaxEdgeLength',[],...
        'wiresSeg',...
        em.wire.Part.empty,...
        'volDataSeg',[],...
        'wiresMPt',...
        em.wire.Part.empty,...
        'volDataMPt',[],...
        'wiresBoth',...
        em.wire.Part.empty,...
        'volDataBoth',[],...
        'wireNodes',[],...
        'matchPts',[],...
        'bothPts',[],...
        'numParts',[]),...
        'HasStructureVisChanged',1,...
        'HasStructureChanged',1,...
        'MeshingChoice','auto',...
        'MeshingFrequency',[],...
        'MeshingLambda',[],...
        'HasMeshChanged',0,...
        'infGP',false,...
        'infGPconnected',false,...
        'CacheFlag',1,...
        'DisplayWaitBar',0,...
        'Version',[]);
    end

    properties(Access={?planeWaveExcitation,?em.Antenna,?em.Array,...
        ?em.WireStructures})

FeedLocationsInt


FeedVoltageInt


FeedPhaseInt


Source
    end

    properties(Access={?planeWaveExcitation,?em.WireStructures})
Medium
    end

    methods(Access={?planeWaveExcitation,?em.Antenna,?em.Array,...
        ?em.WireStructures})

        createInternalWires(obj);


        extraMeshNodes=getExtraMeshNodes(obj);


        setExtraMeshNodes(obj,val);

        function outVec=Ex_inc(obj,posVec,medium,freq)
            outVec=obj.Polarization(:).'.*...
            exp(-1j*medium.WaveNumber(freq).*...
            (posVec*obj.Direction(:)));
        end

    end

    methods(Access=protected)
        parseWireStack(obj,varargin);
        status=analyze(obj,frequency,ElemNumber,ZL);
        MagE=directivity(obj,freq,theta1,phi1,pol,Normalize,...
        coord,R,calc_emb_pattern,type,s);
        [E,H]=calcEHfields(obj,freq,Points,calc_emb_pattern,...
        hemispehere,ang);
        [charges,Points,hfig]=chargem(obj,frequency,flag,scale);
        [currents,Points,hfig]=currentm(obj,frequency,flag,scale);
        p=createSpherePoints(obj,N);
        R=findBoundingSphereRadius(obj)
        [clrbarHdl,axesHdl,hfig]=surfaceplot(obj,data,scale);
        N=getNumFeedLocations(obj);
        function value=getTotalArrayElems(obj)
            value=size(unique(obj.FeedWireIntInd),2);
        end
        function tf=isFigureBroughtForward(obj,hfig)%#ok<INUSL>
            tf=antennashared.internal.figureForwardState(hfig);
        end
        addantenna(obj);
        addpatplusant(obj,patternOptions);
        [MagE,PhaseE]=calcefield(obj,freq,theta1,phi1,...
        polarization,Normalize,coord,R,calc_emb_pattern);


        function group=objectProps(obj,propertyDisplayList,title)
            propList=properties(obj);
            numProps=max(size(propertyDisplayList));
            for i=1:numProps
                if(strcmpi(propertyDisplayList{i},...
                    propList(strcmpi(propertyDisplayList{i},...
                    propList))))
                    antennaProps.(char(propertyDisplayList{i}))=...
                    get(obj,propertyDisplayList{i});
                else

                end
                group=matlab.mixin.util.PropertyGroup(antennaProps,...
                title);
            end
        end


        tf=isPropertyChanged(obj,val1,val2);



        tf=checkHasStructureChanged(obj);


        propVal=getHasStructureChanged(obj);
        resetHasStructureChanged(obj);

        checkTiltAxisConsistency(obj,propVal);
        pnew=orientGeom(obj,p);

        function tf=isObjectFromCurrentVersion(obj)
            tf=isequal(obj.MesherStruct.Version,...
            em.internal.getCurrentVersion);
        end

        [parseobj,azimuth,elevation]=patternparser(obj,frequency,...
        inputdata,nolhs);

        parseobj=surfaceparser(obj,iputdata,funName);

        function geom=getGeometry(obj)
            geom=obj.MesherStruct.Geometry;
        end


        [wires,vol,matchPts]=getMesh(obj,varargin);


        resetHasMeshChanged(obj);


        meshstruct=meshinfo(obj);

        updateMesh(obj,varargin);

        meshGenerator(obj,varargin);

        saveMesh(obj,m);

        copyMeshObjects(obj,m);

        state=getMeshMode(obj);


        setHasMeshChanged(obj);


        edgeLength=getMeshEdgeLength(obj);


        setMeshEdgeLength(obj,val);


        growthRate=getMeshGrowthRate(obj);


        setMeshGrowthRate(obj,val)


        lambda=getMeshingLambda(obj);


        setMeshingLambda(obj,propVal);


        setHasStructureChanged(obj)

        meshControlOptions=parseMeshInputs(obj,varargin);

        function restoreCacheFlag(obj,s)
            obj.MesherStruct.HasStructureChanged=...
            s.MesherStruct.CacheFlag;
        end

        function copyObj=copyElement(obj)


            copyObj=copyElement@matlab.mixin.Copyable(obj);
            copyObj.Source=copy(obj.Source);
            for wireInd=1:length(obj.Wires)
                copyObj.Wires{wireInd}=...
                copyElement@matlab.mixin.Copyable(obj.Wires{wireInd});
            end


            s=saveobj(obj);
            if copyObj.useCCode
                copyObj.Medium=em.wire.solver.BasicHomMedium(1,1);
            else
                copyObj.Medium=em.wire.solver.BasicHomMediumM(1,1);
            end
            if isa(obj.Source,'planeWaveExcitation')
                copyObj.Medium.EMSolObj.EincFunc=@obj.Ex_inc;
            end
            copyObj.createInternalWires;
            if~isempty(obj.MesherStruct.Mesh.wiresSeg)

                copyObj.MesherStruct.Mesh.MaxEdgeLength=[];
                copyObj.MesherStruct.Mesh.MeshGrowthRate=[];
                updateMesh(copyObj,obj.MesherStruct.Mesh.MaxEdgeLength,...
                obj.MesherStruct.Mesh.MeshGrowthRate);
                copyObj.MesherStruct.Mesh.volDataBoth.Colors=...
                obj.MesherStruct.Mesh.volDataBoth.Colors;

                Freqs=obj.Medium.EMSolObj.Freqs;
                if~isempty(Freqs)
                    NExVecs=obj.Medium.EMSolObj.ExVecObj.NExVecs;
                    if NExVecs==1
                        ElemNumber=[];
                    else
                        ElemNumber=1:NExVecs;
                    end
                    status=analyze(copyObj,Freqs,ElemNumber,true);
                    if status
                        copyObj=[];
                        return;
                    end
                    copySolution(copyObj.Medium.EMSolObj,...
                    obj.Medium.EMSolObj);


                    copyObj.SolverStruct=obj.SolverStruct;
                end
            end
            restoreCacheFlag(copyObj,s);


            copyObj.MesherStruct.CacheFlag=obj.MesherStruct.CacheFlag;
        end

        function excludedprops=getPropertyExclusionList(obj)
            if isa(obj.Source,'planeWaveExcitation')
                excludedprops={'FeedVoltage','FeedPhase'};
            else
                excludedprops={'Direction','Polarization'};
            end
        end

        [res,distGrid,sumRad]=checkIntersect(obj,distGrid,radFactor);

    end

    methods

        show(obj);
        varargout=mesh(obj,varargin);
        m=meshconfig(obj,mode);


        varargout=impedance(obj,freq,ElemNumber);
        varargout=returnLoss(obj,freq,Z0,ElemNumber);
        S=sparameters(obj,freq,ZL);
        varargout=vswr(obj,freq,Z0,ElemNumber);


        AR=axialRatio(obj,frequency,azimuth,elevation);
        [BW,Angles]=beamwidth(obj,frequency,azimuth,elevation,dBdown);
        [E,H]=EHfields(obj,frequency,Points,varargin);
        varargout=pattern(obj,frequency,varargin);
        varargout=patternAzimuth(obj,frequency,elevation,varargin);
        varargout=patternElevation(obj,frequency,azimuth,varargin);


        varargout=charge(obj,frequency,varargin);
        varargout=current(obj,frequency,varargin);
        current=feedCurrent(obj,freq);


        function set.useCCode(obj,propVal)
            validateattributes(propVal,{'logical'},{'scalar'});
            if isPropertyChanged(obj,obj.useCCode,propVal)


                setHasStructureChanged(obj);
                obj.useCCode=propVal;
            end
        end
        memEstimate=memoryEstimate(obj,varargin);
        antennaInfo=info(obj);
        function save(obj,filename)%#ok<INUSL>
            objname=inputname(1);
            eval([objname,'= obj;']);
            save(filename,objname);
        end

    end

    methods(Hidden)

        Pnodes=exportGeometry(obj)
        [Pnodes,Pmatch]=exportMesh(obj);

        function rObj=superLoadWireStructures(obj,s)
            objFullProp=metaclass(obj).PropertyList;
            p=objFullProp(arrayfun(@(x)strcmp(x.DefiningClass.Name,...
            'em.WireStructures'),objFullProp));
            for k=1:length(p)
                if isfield(s,p(k).Name)&&~isempty(s.(p(k).Name))
                    try
                        obj.(p(k).Name)=s.(p(k).Name);
                    catch
                    end
                end
            end
            rObj=obj;
        end

        function s=saveobj(obj)
            obj.MesherStruct.CacheFlag=...
            obj.MesherStruct.HasStructureChanged;

            obj.ExVec=obj.Medium.EMSolObj.ExVecObj.Vec;
            obj.DirtyEx=obj.Medium.EMSolObj.DirtyEx;
            s=obj;
        end

        function res=isequalInt(obj,otherObj)



            res=em.WireStructures.isequalBoth(obj,otherObj,'isequal');
        end

        function res=isequal(obj,otherObj)
            res=em.WireStructures.isequalBoth(obj,otherObj,'isequal');
        end

        function res=isequaln(obj,otherObj)
            res=em.WireStructures.isequalBoth(obj,otherObj,'isequaln');
        end

        function value=isRadiatorLossy(obj)%#ok<MANU>
            value=false;
        end

        function R=getRadiationSphereRadius(obj,f)
            s=settings;
            Rset=...
            s.antenna.Solver.FarFieldSphereRadiusInLambda.ActiveValue;
            R=Rset*299792458/f;


            maxR=findBoundingSphereRadius(obj);
            if maxR>R/20
                R=100*(R+maxR);
            end
        end

    end

    methods(Static,Access={?planeWaveExcitation,?em.Antenna,?em.Array,...
        ?em.WireStructures})
        function messCell=CheckNodesDistances(wire)
            NFSegLen=em.WireStructures.r2NFSegLenRatio*wire.SegmentRadius;
            messCell={};
            NodePos=SegmentsPosOnWire(wire);

            distEdges=NodePos(end);
            if distEdges<=2*NFSegLen
                error(message(...
                'antenna:antennaerrors:WireEdgesTooClose',...
                num2str(2*em.WireStructures.r2NFSegLenRatio)));
            end
            if any(diff(NodePos)<em.WireStructures.minr2SegLenRatio*...
                wire.SegmentRadius)
                ApproxBrokenMsg=message(...
                'antenna:antennaerrors:ThinWireApproxInvalid').string;
                messCell={message(...
                'antenna:antennaerrors:WireNodesTooClose',...
                num2str(em.WireStructures.minr2SegLenRatio),...
                ApproxBrokenMsg)};
            end
        end

        function[wire,messCell]=CheckAndClearNodesForFeed(wire)
            NFSegLen=em.WireStructures.r2NFSegLenRatio*wire.SegmentRadius;
            nodes=wire.wireNodesOrig;
            NodePos=SegmentsPosOnWire(wire);
            gapPos=wire.GapPositions_*NodePos(end);


            distEdges=abs(NodePos([1,end])-gapPos);
            if any(distEdges<=2*NFSegLen)
                error(message(...
                'antenna:antennaerrors:FeedTooCloseToWireEdges',...
                num2str(em.WireStructures.r2NFSegLenRatio)));
            end




            dist=abs(NodePos-gapPos);
            indNodes2Remove=find(dist<=1.001*NFSegLen);
            messCell={};
            if~isempty(indNodes2Remove)
                midPt=(nodes(:,indNodes2Remove(1)-1)+...
                nodes(:,indNodes2Remove(end)+1))/2;
                feedPointOrig=wire.GapLocations;
                deltaMid2Feed=midPt-feedPointOrig;
                nodes(:,indNodes2Remove(1)-1)=...
                nodes(:,indNodes2Remove(1)-1)-deltaMid2Feed/2;
                nodes(:,indNodes2Remove(end)+1)=...
                nodes(:,indNodes2Remove(end)+1)-deltaMid2Feed/2;
                nodes=nodes(:,[(1:indNodes2Remove(1)-1)...
                ,indNodes2Remove(end)+1:end]);
                wire.wireNodesOrig=nodes;


                feedPoint=feedPointOrig+deltaMid2Feed/2;
                wire.GapPositions_=wire.relLocationOnWire(feedPoint);
            end
        end
    end

    methods(Static,Access=protected)
        function checkFrequency(frequency)

            fmin=1e3;
            [fmin_eng,~,fmin_str]=engunits(fmin);
            fmax=200e9;
            [fmax_eng,~,fmax_str]=engunits(fmax);
            if any(frequency<=fmin)
                error(message(...
                'antenna:antennaerrors:InvalidValueGreater',...
                'frequency',[num2str(fmin_eng),' ',fmin_str,'Hz']));
            elseif any(frequency>fmax)
                error(message('antenna:antennaerrors:InvalidValueLess',...
                'frequency',[num2str(fmax_eng),' ',fmax_str,'Hz']));
            end
        end

        function res=isequalBoth(obj1,obj2,eqCmd)

            if~isa(obj1,'wireStack')||~isa(obj2,'wireStack')
                res=false;
                return
            end



            res=em.WireStructures.CompareNonHandleProps(obj1,obj2,...
            [{'MesherStruct','ExVec','DirtyEx','hwait'}...
            ,getPropertyExclusionList(obj1)],eqCmd);
            if~res||~isequal(obj1.Source,obj2.Source)
                return
            end



            res=em.WireStructures.CompareNonHandleProps(...
            obj1.MesherStruct,obj2.MesherStruct,{'CacheFlag'},eqCmd);
            if~res
                return
            end



            for wireInd=1:length(obj1.WiresInt)
                res=em.WireStructures.CompareNonHandleProps(...
                obj1.WiresInt{wireInd},obj2.WiresInt{wireInd},...
                [],eqCmd);
                if~res
                    return
                end
            end










            resFuncs=strcmp(func2str(obj1.Medium.EMSolObj.EincFunc),...
            func2str(obj2.Medium.EMSolObj.EincFunc));



            keepDefEincFuncObj=obj1.Medium.EMSolObj.DefEincFunc;
            keepEincFuncObj=obj1.Medium.EMSolObj.EincFunc;
            keepDefEincFuncOtherObj=obj2.Medium.EMSolObj.DefEincFunc;
            keepEincFuncOtherObj=obj2.Medium.EMSolObj.EincFunc;
            obj1.Medium.EMSolObj.DefEincFunc=[];
            obj1.Medium.EMSolObj.EincFunc={[]};
            obj2.Medium.EMSolObj.DefEincFunc=[];
            obj2.Medium.EMSolObj.EincFunc={[]};




            exPartsObj=obj1.Medium.allExWireParts;
            KeptExFuncs={};
            for exPartInd=1:length(exPartsObj)
                KeptExFuncs{exPartInd}=...
                exPartsObj(exPartInd).ExFieldFun;%#ok<*AGROW>
                exPartsObj(exPartInd).ExFieldFun=[];
            end
            exPartsOtherObj=obj2.Medium.allExWireParts;
            KeptExFuncsOther={};
            for exPartInd=1:length(exPartsOtherObj)
                KeptExFuncsOther{exPartInd}=...
                exPartsOtherObj(exPartInd).ExFieldFun;%#ok<*AGROW>
                exPartsOtherObj(exPartInd).ExFieldFun=[];
            end

            resMedium=builtin(eqCmd,obj1.Medium,obj2.Medium);


            for exPartInd=1:length(exPartsOtherObj)
                exPartsOtherObj(exPartInd).ExFieldFun=...
                KeptExFuncsOther{exPartInd};
            end
            for exPartInd=1:length(exPartsObj)
                exPartsObj(exPartInd).ExFieldFun=KeptExFuncs{exPartInd};
            end


            obj2.Medium.EMSolObj.EincFunc={keepEincFuncOtherObj};
            obj2.Medium.EMSolObj.DefEincFunc=keepDefEincFuncOtherObj;
            obj1.Medium.EMSolObj.EincFunc={keepEincFuncObj};
            obj1.Medium.EMSolObj.DefEincFunc=keepDefEincFuncObj;
            res=resMedium&resFuncs;
        end

        function res=CompareNonHandleProps(obj1,obj2,excList,eqCmd)
            hmeta=metaclass(obj1);
            hmetaOther=metaclass(obj2);
            metaProps=hmeta.PropertyList;
            metaPropsOther=hmetaOther.PropertyList;
            if numel(metaProps)~=numel(metaPropsOther)
                res=false;
                return
            end
            res=true;
            for i=1:numel(metaProps)
                propName=metaProps(i).Name;
                if~any(strcmp(propName,excList))
                    if(isa(obj1.(propName),'cell'))
                        tfArray=cellfun(@(x)~isa(x,'handle'),...
                        obj1.(propName));

                        if numel(obj2.(propName))~=numel(tfArray)||...
                            ~builtin(eqCmd,obj1.(propName)(tfArray),...
                            obj2.(propName)(tfArray))
                            res=false;
                            break
                        end
                    else
                        if~isa(obj1.(propName),'handle')
                            if~builtin(eqCmd,obj1.(propName),...
                                obj2.(propName))
                                res=false;
                                break
                            end
                        end
                    end
                end
            end
        end

    end

    methods(Static=true,Hidden)
        function r=loadobj(obj)
            r=obj;
            obj.Medium.EMSolObj.DirtyEx=obj.DirtyEx;
            r.Medium.EMSolObj.ExVecObj.Vec=r.ExVec;
            r.MesherStruct.HasStructureChanged=...
            obj.MesherStruct.CacheFlag;
        end
    end

end