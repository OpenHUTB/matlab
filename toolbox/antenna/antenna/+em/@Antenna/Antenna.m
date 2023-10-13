classdef Antenna<em.EmStructures&...
    em.MeshGeometry&...
    em.MeshGeometryAnalysis&...
    em.PortAnalysis&...
    em.SharedPortAnalysis&...
    em.SurfaceAnalysis&...
    em.FieldAnalysisWithFeed&...
    em.FieldAnalysisWithWave&...
    em.DesignAnalysis&...
    em.OptimizationAnalysis


    properties(SetObservable)

Load

Conductor
    end

    properties(Constant,GetAccess=protected)




        DefaultFeedLocation=[0,0,0]
    end

    properties(Access=protected)
        privateSubstrate=dielectric('Name','Air')
    end

    methods

        function set.Load(obj,propVal)
            if strcmpi(class(getParent(obj)),'infiniteArray')&&...
                isa(propVal,'lumpedElement')
                if~isempty(propVal.Impedance)
                    error(message('antenna:antennaerrors:Unsupported',...
                    'Load','Infinite array'));
                end
            end

            if~isempty(propVal)&&~isa(propVal,'lumpedElement')
                error(message('antenna:antennaerrors:AntennaLoad'));
            end

            if isa(obj,'eggCrate')&&isa(propVal,'lumpedElement')
                if~isempty(propVal.Impedance)
                    error(message('antenna:antennaerrors:Unsupported',...
                    'Load','eggCrate'));
                end
            end

            if isprop(obj,'SolverType')&&strcmpi(obj.SolverType,'FMM')
                if~isempty(propVal.Impedance)
                    error(message('antenna:antennaerrors:Unsupported',...
                    'Load','SolverType as FMM'));
                end
            end
            rootObj=findParentRoot(obj);

            if isprop(rootObj,'SolverType')&&strcmpi(rootObj.SolverType,'FMM')
                if~isempty(propVal.Impedance)
                    error(message('antenna:antennaerrors:Unsupported',...
                    'Load','SolverType as FMM'));
                end
            end

            if isPropertyChanged(obj,obj.Load,propVal)
                if~isempty(propVal)
                    for m=1:numel(propVal)
                        if~isempty(propVal(m).Impedance)
                            if~isscalar(propVal(m).Impedance)&&...
                                (numel(propVal(m).Impedance)~=...
                                numel(propVal(m).Frequency))
                                error(message('antenna:antennaerrors:FreqDepLoad'));
                            elseif~isempty(propVal(m).Frequency)&&...
                                (numel(propVal(m).Impedance)~=...
                                numel(propVal(m).Frequency))
                                error(message('antenna:antennaerrors:FreqDepLoad'));
                            end
                        end
                    end

                    if isa(obj,'rhombic')



                        [newpropVal]=addload(obj);
                        obj.Load=[newpropVal,propVal];

                    else
                        obj.Load=propVal;
                    end
                    obj.MesherStruct.HasLoadChanged=1;
                end
            end
        end

        function set.Conductor(obj,propVal)
            if isa(obj,'infiniteArray')||isa(obj,'em.ParabolicAntenna')||...
                isa(obj,'dipoleCrossed')||isa(obj,'eggCrate')
                if isempty(propVal)
                    return;
                else
                    error(message('antenna:antennaerrors:NoConductorProperty'));
                end
            end

            validateattributes(propVal,{'metal'},{'nonempty','scalar'},...
            class(obj),'Conductor');

            if propVal.Conductivity<1e5
                error(message('antenna:antennaerrors:LowConductivity'));
            end
            if~isempty(obj.Conductor)
                if isequal(obj.Conductor.Thickness,propVal.Thickness)&&...
                    isequal(obj.Conductor.Conductivity,propVal.Conductivity)
                    obj.Conductor=copy(propVal);
                    obj.Conductor.Parent=obj;
                    return;
                end
            end

            obj.Conductor=copy(propVal);

            obj.Conductor.Parent=obj;
            setHasStructureChanged(obj);
            parentObj=getParent(obj);
            while~isempty(parentObj)
                setHasStructureChanged(parentObj);
                parentObj=getParent(parentObj);
            end

            clearGeometryData(obj);
            clearMeshData(obj);
            clearSolutionData(obj);

        end
    end

    methods(Access=protected)

        function checkGPdims(obj,propVal,dimstr)

            if~isempty(obj.Tilt)&&all(obj.Tilt~=0)&&(propVal==inf)
                error(message('antenna:antennaerrors:Unsupported',...
                'Tilt','Infinite ground plane'));
            end

            finiteGPelems={'pifa','patchMicrostripInsetfed',...
            'invertedF','fractalIsland','fractalCarpet',...
            'sectorInvertedAmos','reflectorCorner',...
            'invertedLCoplanar','invertedFCoplanar','reflectorGrid',...
            'reflectorCylindrical'};

            finiteGPparents={'installedAntenna','infiniteArray'};

            zeroGPLength={'reflector'};
            classobj=class(obj);
            parentobj=getParent(obj);
            if any(strcmpi(classobj,finiteGPelems))||...
                any(strcmpi(class(parentobj),finiteGPparents))||...
                isa(parentobj,'em.BackingStructure')||...
                isa(parentobj,'em.ParabolicAntenna')
                validateattributes(propVal,{'numeric'},...
                {'nonempty','scalar','real','nonnan','finite','positive'},...
                classobj,dimstr);
            elseif any(strcmpi(classobj,zeroGPLength))

                validateattributes(propVal,{'numeric'},...
                {'nonempty','scalar','real','nonnan','nonnegative'},...
                classobj,dimstr);
            elseif~isempty(parentobj)&&~isempty(getParent(parentobj))


                parentobj2=getParent(parentobj);
                if em.internal.checkLRCArray(parentobj)&&...
                    (isa(parentobj2,'em.BackingStructure')||...
                    isa(parentobj2,'em.ParabolicAntenna'))
                    error(message('antenna:antennaerrors:InfGPArrayinFrontofReflector',...
                    class(parentobj2)));
                end
            else

                validateattributes(propVal,{'numeric'},...
                {'nonempty','scalar','real','nonnan','positive'},...
                classobj,dimstr);
            end
        end

        function clearAllStructs(obj,propVal)
            if isinf(propVal)
                clearGeometryData(obj);
                clearMeshData(obj);
                clearSolutionData(obj);
            end
        end

        function assignSubstrate(obj,propVal)

            validateattributes(propVal,{'dielectric'},{'nonempty','scalar'},...
            class(obj),'Substrate')


            if~isequal(obj.privateSubstrate,propVal)

                temp=copy(propVal);


                if any(strcmpi(class(getParent(obj)),{'installedAntenna'}))
                    if~isequal(temp.EpsilonR,1)
                        error(message('antenna:antennaerrors:Unsupported',...
                        'Element with dielectric materials',class(getParent(obj))));
                    end
                end


                if isa(getParent(obj),'em.ParabolicAntenna')
                    if~isequal(temp.EpsilonR,1)
                        error(message('antenna:antennaerrors:Unsupported',...
                        'Exciter with dielectric materials',class(getParent(obj))));
                    end
                end



                parentobj=getParent(obj);
                if~isequal(propVal.EpsilonR,1)&&isa(parentobj,'em.BackingStructure')...
                    &&isDielectricSubstrate(parentobj)
                    error(message('antenna:antennaerrors:Unsupported',...
                    'Dielectric materials in exciter substrate',...
                    strcat(class(parentobj),' with substrate')));
                end


                if isa(obj,'em.HelixAntenna')&&~isa(obj,'dipoleHelixMultifilar')&&...
                    ((iscell(propVal.Name)&&numel(propVal.Name)>1)||...
                    numel(propVal.EpsilonR)>1||numel(propVal.LossTangent)>1)
                    error(message('antenna:antennaerrors:InvalidMultipleSubstrate',...
                    class(obj)));
                end



                if isa(obj,'em.HelixAntenna')&&~(propVal.EpsilonR==1)&&~isscalar(obj.Radius)
                    error(message('antenna:antennaerrors:InvalidRadiusForSubstrate',...
                    class(obj)));
                end











                temp.Shape=obj.privateSubstrate.Shape;
                checkDielectricMaterialDimensions(temp);
                setSubstrateDimensions(obj,temp,'all');
                obj.privateSubstrate=temp;
                obj.privateSubstrate.Parent=obj;
                setHasStructureChanged(obj);

                clearGeometryData(obj);
                clearMeshData(obj);
                clearSolutionData(obj);
            end

        end


        function feedpoint=getFeedPoint(obj)
            feed_x=obj.DefaultFeedLocation(1);
            feed_y=obj.DefaultFeedLocation(2);
            feed_z=obj.DefaultFeedLocation(3);
            feedpoint=[feed_x,feed_y,feed_z];
        end

        function feedpoint=setOrientation(obj,propVal)
            feedpoint=orientGeom(obj,propVal')';
        end


        function setSubstrateDimensions(obj,sub,flag)
            if strcmpi(sub.Shape,'box')
                switch flag
                case 'Length'
                    setSubstrateLength(obj,sub);
                case 'Width'
                    setSubstrateWidth(obj,sub);
                case 'Height'
                    setSubstrateThickness(obj,sub);
                otherwise
                    setSubstrateLength(obj,sub);
                    setSubstrateWidth(obj,sub);
                    setSubstrateThickness(obj,sub);
                end
            elseif strcmpi(sub.Shape,'cylinder')
                switch flag
                case 'Radius'
                    setSubstrateRadius(obj,sub);
                case 'Height'
                    setSubstrateThickness(obj,sub);
                otherwise
                    setSubstrateRadius(obj,sub);
                    setSubstrateThickness(obj,sub);
                end
            elseif strcmpi(sub.Shape,'polyhedron')
                switch flag
                case 'Vertices'
                    setSubstrateVertices(obj,sub);
                case 'Height'
                    setSubstrateThickness(obj,sub);
                otherwise
                    setSubstrateVertices(obj,sub);
                    setSubstrateThickness(obj,sub);
                end
            end
        end

        function setSubstrateElectricalParameters(~,sub,temp)
            sub.EpsilonR=temp.EpsilonR;
            sub.LossTangent=temp.LossTangent;
        end

        function setSubstrateLength(obj,sub)


            if isprop(obj,'GroundPlaneLength')
                if~isempty(obj.GroundPlaneLength)
                    if(~isinf(obj.GroundPlaneLength))&&(~isequal(obj.GroundPlaneLength,0))
                        sub.Length=obj.GroundPlaneLength;
                    end
                end
            elseif isprop(obj,'BoardLength')
                if~isempty(obj.BoardLength)
                    sub.Length=obj.BoardLength;
                end
            end
        end

        function setSubstrateWidth(obj,sub)


            if isprop(obj,'GroundPlaneWidth')
                if~isempty(obj.GroundPlaneLength)
                    if(~isinf(obj.GroundPlaneWidth))&&(~isequal(obj.GroundPlaneWidth,0))
                        sub.Width=obj.GroundPlaneWidth;
                    end
                end
            elseif isprop(obj,'BoardWidth')
                if~isempty(obj.BoardWidth)
                    sub.Width=obj.BoardWidth;
                end
            end
        end

        function setSubstrateThickness(obj,sub)





            mc=metaclass(obj);
            mp=findobj(mc.SuperclassList,'Name','em.MicrostripAntenna');
            if isempty(mp)
                mp=findobj(mc.SuperclassList,'Name','em.FractalAntenna');
            end
            if isempty(mp)
                mp=findobj(mc.SuperclassList,'Name','em.PrintedAntenna');
            end
            if isscalar(sub.Thickness)
                if~isempty(mp)&&any(strcmpi(mp.Name,...
                    {'em.MicrostripAntenna','em.FractalAntenna','em.PrintedAntenna'}))
                    sub.Thickness=obj.Height;
                elseif isa(obj,'monopoleTopHat')
                    sub.Thickness=sub.Thickness;
                elseif isa(obj,'em.HelixAntenna')&&~isa(obj,'dipoleHelixMultifilar')
                    if~isempty(obj.Turns)&&~isempty(obj.Spacing)&&...
                        ~isempty(obj.Width)
                        if(isa(obj,'helix')||isa(obj,'helixMultifilar'))&&...
                            ~isempty(obj.FeedStubHeight)
                            sub.Thickness=(obj.Turns*obj.Spacing)+obj.Width+obj.FeedStubHeight;
                        elseif isa(obj,'dipoleHelix')
                            sub.Thickness=(obj.Turns*obj.Spacing)+obj.Width;
                        end
                    else
                        sub.Thickness=sub.Thickness;
                    end
                else
                    sub.Thickness=obj.Spacing;
                end
            end
        end

        function setSubstrateRadius(obj,sub)


            if isprop(obj,'GroundPlaneRadius')&&~isa(obj,'em.HelixAntenna')
                if~isinf(obj.GroundPlaneRadius)
                    sub.Radius=obj.GroundPlaneRadius;
                end
            elseif isa(obj,'em.HelixAntenna')&&~isa(obj,'dipoleHelixMultifilar')
                sub.Radius=obj.Radius(1);
            end
        end


        function setSubstrateVertices(obj,sub)


            if~isinf(obj.GroundPlaneVertices)
                sub.Vertices=obj.GroundPlaneVertices;
            end
        end
    end

    methods(Static=true,Access=protected)
        function dimValue=roundDim(actualValue)


            mulFactor=1;
            dimValue=(actualValue.*mulFactor)./mulFactor;
        end

    end

    methods(Access={?planeWaveExcitation,?em.WireStructures,...
        ?em.Array,?em.Antenna})
        function[val,messCell]=isConvertable2Wire(obj)
            val=false;
            messCell={'antenna:antennaerrors:NotConvertableToWire',...
            class(obj)};
        end

        function messCell=WarnOnConvertion2Wire(obj)
            if~isempty(obj.Load.Impedance)
                messCell={message(...
                'antenna:antennaerrors:LoadIgnoredInWire')};
            else
                messCell={};
            end
        end

        function name=wireName(obj,nameType)
            nameOrig=char(class(obj));
            name=[upper(nameOrig(1)),nameOrig(2:end)];
            if nargin>1&&strcmpi(nameType,'Plural')
                name=[name,' antennas'];
            end
        end
    end

    methods(Hidden)
        function[edgeLength,growthRate]=calculateWireMeshParams(obj,lambda)%#ok<INUSL>
            s=lambda/8;
            edgeLength=s;
            growthRate=2.0;
        end

        function wireStackOut=wire(obj)
            [isConv,messCell]=obj.isConvertable2Wire;
            if isConv
                wireStackOut=wireStack(obj);
                wireStackOut.Name=obj.wireName('Singular');
            else
                error(message(messCell{:}));
            end
        end

        function value=isRadiatorLossy(obj)
            value=0;
            sz=size(obj.privateSubstrate.LossTangent,2);
            if isa(obj,'em.BackingStructure')&&isDielectricSubstrate(obj.Exciter)
                if isa(obj.Exciter,'em.Array')
                    value=~isequal(obj.Exciter.Element.privateSubstrate.LossTangent,zeros(1,sz));
                else
                    value=~isequal(obj.Exciter.privateSubstrate.LossTangent,zeros(1,sz));
                end
            end
            value=(~isequal(obj.privateSubstrate.LossTangent,zeros(1,sz))||value);

            if~value
                if isa(obj,'dipoleCrossed')||isa(obj,'eggCrate')
                    value=~isequal(obj.Element.Conductor.Thickness,0)||...
                    ~isinf(obj.Element.Conductor.Conductivity);
                else
                    if isprop(obj,'Conductor')&&~isempty(obj.Conductor)
                        value=~isequal(obj.Conductor.Thickness,0)||...
                        ~isinf(obj.Conductor.Conductivity);
                    end
                end
            end


            if~value
                if isprop(obj,'MesherStruct')&&~isfield(obj.MesherStruct,'Load')
                    createGeometry(obj);
                end
                if isfield(obj.MesherStruct,'Load')
                    if~isempty(obj.MesherStruct.Load)

                        ZL=real(cell2mat(obj.MesherStruct.Load.Impedance));



                        if any(ZL>0)
                            value=1;
                        end
                    end
                end
            end
        end
    end

    methods(Static=true,Access={?em.Array,?em.Antenna,?em.MeshGeometry})

        function connectionTriangles=buildConnection(feedwidth,feedlocation,feededgeaxis)

            feed_x=feedlocation(1);
            feed_y=feedlocation(2);
            feed_z=feedlocation(3);%#ok<NASGU>
            W=feedwidth;
            feed_Span=sqrt(3)*W/2;
            switch feededgeaxis
            case 'Edge-Y'



                gd2=[feed_x-feed_Span,feed_x,feed_x;feed_y,feed_y-(W/2),feed_y+(W/2);0,0,0];
                gd3=[feed_x,feed_x+feed_Span,feed_x;feed_y-(W/2),feed_y,feed_y+(W/2);0,0,0];

            case 'Edge-X'


                gd2=[feed_x-(W/2),feed_x,feed_x+(W/2);feed_y,feed_y-feed_Span,feed_y;0,0,0];
                gd3=[feed_x-(W/2),feed_x,feed_x+(W/2);feed_y,feed_y+feed_Span,feed_y;0,0,0];
            end
            connectionTriangles={gd2,gd3};
        end
    end

    methods(Access={?em.MeshGeometry})

        function[p,t,feed_pt1,feed_pt2]=getStripMesh(obj,height,width,numSections,ang,...
            axispt1,axispt2,translateVector)

            if numSections==1
                numSections=numSections+1;
            end



            st=antenna.Rectangle('Length',height,'Width',width,'NumPoints',...
            [numSections,2,numSections,2]);
            pt=st.InternalPolyShape.triangulation.Points;
            tt=st.InternalPolyShape.triangulation.ConnectivityList;
            pt(:,3)=0;
            tt(:,4)=0;
            t=tt';
            pt=pt';

            if~(size(axispt1,1)==3)
                axispt1=axispt1';
            end

            if~(size(axispt2,1)==3)
                axispt2=axispt2';
            end

            if~(size(translateVector,1)==3)
                translateVector=translateVector';
            end


            for i=1:size(axispt1,2)
                pt=em.internal.rotateshape(pt,axispt1(:,i),axispt2(:,i),ang(i));
            end


            if~isempty(translateVector)
                for i=1:size(translateVector,2)
                    pt=em.internal.translateshape(pt,translateVector(:,i));
                end
            end
            pFeed=pt;


            minVal=min(pFeed(3,:));
            id=find(pFeed(3,:)==minVal);

            feed_pt1=pFeed(:,id(1));
            feed_pt2=pFeed(:,id(2));

            if isa(obj,'em.BackingStructure')
                FeedPoints=obj.PortPoints;
                FeedPoints(2,:)=sort(FeedPoints(2,:));



                pFeed(2,pFeed(2,:)==feed_pt1(2,1))=FeedPoints(2,1);
                pFeed(2,pFeed(2,:)==feed_pt2(2,1))=FeedPoints(2,2);

                feed_pt1=FeedPoints(:,1);
                feed_pt2=FeedPoints(:,2);


                if isa(obj.Exciter,'customAntennaMesh')||isa(obj.Exciter,'customAntennaGeometry')
                    S=obj.Spacing;
                    Wfeed=getFeedWidth(obj.Exciter);
                    numSections=ceil(S/Wfeed);
                    pFeed=em.internal.makestrip(S,Wfeed,numSections+1,...
                    'linear',[],[],'YZ');
                    pFeed=em.internal.translateshape(pFeed,[0,0,S/2]);
                    feedsize=size(pFeed,2);
                    FeedPoints=obj.PortPoints;
                    pFeed(1,1:2:feedsize)=FeedPoints(1,1);
                    pFeed(1,2:2:feedsize)=FeedPoints(1,2);
                    pFeed(2,1:2:feedsize)=FeedPoints(2,1);
                    pFeed(2,2:2:feedsize)=FeedPoints(2,2);


                    [pFeed,t]=em.Antenna.linearmesher(pFeed);
                end
            end
            p=pFeed;
        end
    end

    methods(Static=true,Access={?em.Antenna})
        function[varargout]=linearmesher(varargin)



            t=[];
            p=varargin{1};
            idxPmax=max(size(p));
            idxp=1:idxPmax;

            idxStencil1=1:idxPmax-2;
            t(1,:)=idxp(idxStencil1);
            idxStencil2=2:idxPmax-1;
            t(2,:)=idxp(idxStencil2);
            idxStencil3=3:idxPmax;
            t(3,:)=idxp(idxStencil3);
            t(4,:)=0;
            varargout{1}=p;
            varargout{2}=t;
        end
    end

    methods(Hidden)
        function rObj=superLoadAntenna(obj,s,varargin)

            if(s.MesherStruct.Version==em.internal.getCurrentVersion)
                if isobject(s)
                    rObj=s;
                else
                    obj.privateSubstrate=s.privateSubstrate;
                    obj.Load=s.Load;
                    obj=checkConductor(obj,s);
                    obj=superLoadEmStructures(obj,s);
                    rObj=obj;
                end
            else

                if(s.MesherStruct.Version>=2.0)
                    obj.privateSubstrate=s.privateSubstrate;
                end
                if isprop(s,'Load')
                    obj.Load=s.Load;
                end


                obj=checkConductor(obj,s);

                if nargin>2&&(s.MesherStruct.Version<2.0)
                    obj=superLoadMeshGeometry(obj,s,varargin{1});
                else
                    obj=superLoadMeshGeometry(obj,s);
                end
                obj=superLoadEmStructures(obj,s);
                rObj=obj;
            end
        end

        function obj=checkConductor(obj,s)
            if(s.MesherStruct.Version>=5.0)&&...
                ~isa(obj,'infiniteArray')&&~isa(obj,'dipoleCrossed')&&...
                ~isa(obj,'cassegrain')&&~isa(obj,'gregorian')&&...
                ~isa(obj,'reflectorParababolic')&&~isa(obj,'reflectorSpherical')
                obj.Conductor=s.Conductor;
            end
        end
    end


    methods(Hidden)

        function flag=isElementFromAntenna(obj)%#ok<MANU>
            flag=true;
        end

        function num=getDOF(obj)%#ok<MANU>
            num=1;
        end
    end

    methods(Access={?phased.internal.AbstractArray,...
        ?phased.internal.AbstractElement,...
        ?phased.internal.AbstractSubarray,...
        ?phased.internal.AbstractSensorOperation,...
        ?phased.internal.AbstractArrayOperation,...
        ?phased.internal.AbstractClutterSimulator,...
        ?phased.gpu.internal.AbstractClutterSimulator})

        function newObj=cloneSensor(obj)
            newObj=phased.internal.AntennaAdapter('Antenna',obj);
        end
    end

end

