classdef Pattern<handle&matlabshared.satellitescenario.ScenarioGraphic



    properties(Dependent)





        Size(1,1)double{mustBeNonnegative,mustBeFinite}





        Colormap{validateColorMap(Colormap)}




        Transparency(1,1)double{mustBeGreaterThanOrEqual(Transparency,0),mustBeLessThanOrEqual(Transparency,1)}
    end

    properties(Access={?matlabshared.satellitescenario.ScenarioGraphic})
        pSize(1,1)double{mustBeNonnegative,mustBeFinite}=1000000
        pColormap{validateColorMap(pColormap)}=jet
        pTransparency(1,1)double{mustBeGreaterThanOrEqual(pTransparency,0),mustBeLessThanOrEqual(pTransparency,1)}=0.7
Parent
    end

    properties(Access={?satelliteScenario,?matlabshared.satellitescenario.Viewer,?satcom.satellitescenario.internal.CommDevice,?tShow})
PatternGraphic
        Resolution char{mustBeMember(Resolution,{'high','medium','low'})}="high"
Frequency
FileName
        PatternData=struct("r",[],"az",[],"el",[],"resolution","")
    end

    properties














        VisibilityMode{mustBeMember(VisibilityMode,{'inherit','manual'})}='inherit'
    end

    methods(Hidden)
        updateVisualizations(pat,viewer,plotInViewer)
        function ID=getGraphicID(pat)
            ID=pat.PatternGraphic;
        end

        function addCZMLGraphic(pat,writer,times,initiallyVisible)


            parent=pat.Parent;
            simulator=parent.Simulator;
            idx=getIdxInSimulatorStruct(parent);
            antenna=parent.Antenna;



            if isa(antenna,'phased.internal.AbstractArray')

                if simulator.SimulationMode==1
                    warning(message('shared_orbit:orbitPropagator:UnableDynamicPhasedPatternPlaybackManualSim',...
                    parent.Name));
                    return
                end


                switch parent.Type
                case 5
                    parentStruct=simulator.Transmitters(idx);
                otherwise
                    parentStruct=simulator.Receivers(idx);
                end


                if parentStruct.PointingMode~=5
                    warning(message('shared_orbit:orbitPropagator:UnableDynamicPhasedPatternPlaybackAutoSim',...
                    parent.Name));
                    return
                end
            end

            id=pat.getGraphicID;
            positions=pat.Parent.pPositionHistory';
            if isempty(pat.FileName)

                updateVisualizations(pat,pat.Scenario.Viewers(1),false);
            end
            fileURL=globe.internal.ConnectorServiceProvider.getResourceURL(pat.FileName,['geo3dmodel',char(id)]);


            attitudes=pat.Parent.AttitudeHistory';
            numAttitudes=size(attitudes,1);
            quats=zeros(numAttitudes,4);



            latHistory=deg2rad(pat.Parent.Parent.pLatitudeHistory);
            lonHistory=deg2rad(pat.Parent.Parent.pLongitudeHistory);
            attitudes=deg2rad(attitudes);
            for k=1:numAttitudes
                quats(k,:)=euler2Quaternion(lonHistory(k),latHistory(k),attitudes(k,3),attitudes(k,2),attitudes(k,1)+pi);
            end

            addModel(writer,id,positions,times,fileURL,...
            'Orientation',quats,...
            'Interpolation','lagrange',...
            'InterpolationDegree',5,...
            'CoordinateDefinition','cartesian',...
            'ReferenceFrame','inertial',...
            'ID',id,...
            'InitiallyVisible',initiallyVisible);
        end

        function addGraphicToClutterMap(pat,viewer)
            parent=pat.Parent;
            while isprop(parent,'Parent')
                parent=parent.Parent;
            end
            addGraphicToClutterMap(parent,viewer);
            if~isfield(viewer.DeclutterMap.(parent.getGraphicID),pat.getGraphicID)
                viewer.DeclutterMap.(parent.getGraphicID).(pat.getGraphicID)=pat;
            end
        end

        function initializePatternData(pat,antenna,frequency)
            isElectromagneticAntenna=isa(antenna,'em.Antenna')||isa(antenna,'em.Array')||...
            isa(antenna,'installedAntenna');
            isPhasedAntenna=isa(antenna,'phased.internal.AbstractAntennaElement')||...
            isa(antenna,'phased.internal.AbstractArray')||...
            isa(antenna,'phased.internal.AbstractSubarray');
            isCommAntenna=isa(antenna,'arrayConfig');
            isGaussianAntenna=isa(antenna,'satcom.satellitescenario.GaussianAntenna');

            resolution=pat.Resolution;

            if(isElectromagneticAntenna)

                resolutionValue=rfprop.Constants.AntennaPatternResolution.(resolution);
                interpRes=rfprop.Constants.AntennaPatternInterpolation.(resolution);
            elseif ischar(antenna)

                resolutionValue=rfprop.Constants.IsotropicPatternResolution.(resolution);
                interpRes=resolutionValue;
            else


                resolutionValue=rfprop.Constants.PhasedPatternResolution.(resolution);
                interpRes=resolutionValue;
            end



            if ischar(antenna)

                pAz=-180:resolutionValue:180;
                pEl=-90:resolutionValue:90;
                r=zeros(numel(pEl),numel(pAz));
            else



                if(strcmp(resolutionValue,'auto'))

                    [r,pAz,pEl]=pattern(antenna,frequency);
                else

                    pAz=-180:resolutionValue:180;
                    pEl=-90:resolutionValue:90;
                    [r,pAz,pEl]=pattern(antenna,frequency,pAz,pEl);
                end
            end



            if isGaussianAntenna
                r=max(r,0);
            end



            if isPhasedAntenna||isCommAntenna
                dBRange=50;
                r=limitDynamicdBRange(r,dBRange);
            end

            [mAz,mEl]=meshgrid(pAz,pEl);

            patternRes=360/(length(pAz)-1);



            if(interpRes<patternRes)

                queryAz=-180:interpRes:180;
                queryEl=-90:interpRes:90;
                [queryAzMesh,queryElMesh]=meshgrid(queryAz,queryEl);
                r=interp2(mAz,mEl,r,queryAzMesh,queryElMesh);
                az=queryAz;
                el=queryEl;
            else

                az=pAz;
                el=pEl;
            end
            pat.PatternData.r=r;
            pat.PatternData.az=az;
            pat.PatternData.el=el;
            pat.PatternData.resolution=resolution;
        end
    end

    methods
        function pat=Pattern(trx,fq,varargin)


            if nargin>0
                pat.Parent=trx;
                pat.PatternGraphic=genvarname("Transmitter"+trx.ID+"Pattern");
                pat.Scenario=trx.Scenario;
                pat.Frequency=fq;
                parseShowInputs(pat,varargin{:});
            end
        end

        function size=get.Size(pat)
            size=pat.pSize;
        end

        function colorMap=get.Colormap(pat)
            colorMap=pat.pColormap;
        end

        function transparency=get.Transparency(pat)
            transparency=pat.pTransparency;
        end

        function set.Size(pat,size)
            pat.pSize=size;
            if isa(pat.Scenario,'satelliteScenario')
                updateViewers(pat,pat.Scenario.Viewers,false,true);
            end
        end

        function set.Colormap(pat,Colormap)
            pat.pColormap=validateColorMap(Colormap);
            if isa(pat.Scenario,'satelliteScenario')
                updateViewers(pat,pat.Scenario.Viewers,false,true);
            end
        end

        function set.Transparency(pat,transparency)
            pat.pTransparency=transparency;
            if isa(pat.Scenario,'satelliteScenario')
                updateViewers(pat,pat.Scenario.Viewers,false,true);
            end
        end

        function delete(pat)



            if isempty(pat.Parent)
                return
            end

            removeGraphic(pat);
            if(isa(pat.Scenario,'satelliteScenario')&&isvalid(pat.Scenario))
                removeFromScenarioGraphics(pat.Scenario,pat);
            end
            if isvalid(pat.Parent)
                pat.Parent.Pattern=[];
            end


            if~isempty(pat.FileName)
                try
                    delete(pat.FileName);
                catch


                end
            end
        end
    end

    methods(Access=?satcom.satellitescenario.internal.CommDevice)
        function parseShowInputs(pat,varargin)
            paramNames={'Size','Colormap','Transparency','Resolution'};
            pstruct=coder.internal.parseParameterInputs(paramNames,satelliteScenario.InputParserOptions,varargin{:});
            size=coder.internal.getParameterValue(pstruct.Size,pat.Size,varargin{:});
            cmap=coder.internal.getParameterValue(pstruct.Colormap,pat.Colormap,varargin{:});
            transparency=coder.internal.getParameterValue(pstruct.Transparency,pat.Transparency,varargin{:});
            resolution=coder.internal.getParameterValue(pstruct.Resolution,pat.Resolution,varargin{:});


            if(pstruct.Size>0&&~isequal(pat.pSize,size))||...
                (pstruct.Colormap>0&&~isequal(pat.pColormap,cmap))||...
                (pstruct.Transparency>0&&~isequal(pat.pTransparency,transparency))||...
                (pstruct.Resolution>0&&~isequal(pat.Resolution,resolution))
                pat.Scenario.NeedToSimulate=true;
                pat.Scenario.Simulator.NeedToSimulate=true;
            end




            pat.pSize=size;
            pat.pColormap=cmap;
            pat.pTransparency=transparency;



            pat.Resolution=resolution;
        end
    end




    methods(Static,Access=protected)
        patternModel=createPatternModel(antenna,frequency,NameValueArgs)
    end

    methods(Static,Access=?tPatternTransform)
        function[yaw,pitch,roll]=ned2bodyframe(attitude)
            N_C_B=matlabshared.orbit.internal.Transforms.ned2bodyTransform(attitude*pi/180);
            N_C_NDash=[0,1,0;1,0,0;0,0,-1];
            NDash_C_B=N_C_B*(N_C_NDash');
            pitch=asind(NDash_C_B(1,3));
            if abs(pitch-90)<1e-6
                yaw=atan2d(-NDash_C_B(2,1),-NDash_C_B(3,1));
                roll=0;
            elseif abs(pitch-(-90))<1e-6
                yaw=atan2d(-NDash_C_B(2,1),NDash_C_B(3,1));
                roll=0;
            else
                yaw=atan2d(NDash_C_B(1,2),NDash_C_B(1,1));
                roll=atan2d(NDash_C_B(2,3),NDash_C_B(3,3));
            end
        end
    end
end

function cmap=validateColorMap(cmap)
    try
        if ischar(cmap)||isstring(cmap)
            validateattributes(cmap,{'char','string'},{'scalartext'},...
            'pattern','Colormap');


            cmap=char(lower(cmap));
            k=min(strfind(cmap,'('));
            if~isempty(k)
                cmap=feval(cmap(1:k-1),str2double(cmap(k+1:end-1)));
            else
                cmap=feval(cmap);
            end
        else

            if~ischar(cmap)&&~isstring(cmap)
                validateattributes(cmap,{'numeric'},...
                {'real','finite','nonnan','nonsparse','ncols',3,'>=',0,'<=',1},...
                'pattern','Colormap');
            end
        end
    catch ME
        throwAsCaller(ME);
    end
end

function e=euler2Quaternion(longitude,latitude,yaw,pitch,roll)
    I_C_1=[0,0,-1;0,1,0;1,0,0];
    one_C_2=[1,0,0;0,cos(longitude),-sin(longitude);0,sin(longitude),cos(longitude)];
    two_C_3=[cos(latitude),0,-sin(latitude);0,1,0;sin(latitude),0,cos(latitude)];
    three_C_4=[cos(yaw),-sin(yaw),0;sin(yaw),cos(yaw),0;0,0,1];
    four_C_5=[cos(pitch),0,sin(pitch);0,1,0;-sin(pitch),0,cos(pitch)];
    five_C_6=[1,0,0;0,cos(roll),-sin(roll);0,sin(roll),cos(roll)];
    six_C_B=[1,0,0;0,-1,0;0,0,-1];

    I_C_B=I_C_1*one_C_2*two_C_3*three_C_4*four_C_5*five_C_6*six_C_B;

    C11=I_C_B(1,1);
    C12=I_C_B(1,2);
    C13=I_C_B(1,3);
    C21=I_C_B(2,1);
    C22=I_C_B(2,2);
    C23=I_C_B(2,3);
    C31=I_C_B(3,1);
    C32=I_C_B(3,2);
    C33=I_C_B(3,3);

    if 1+trace(I_C_B)~=0
        e4=(1/2)*sqrt(1+C11+C22+C33);
        e1=(C32-C23)/(4*e4);
        e2=(C13-C31)/(4*e4);
        e3=(C21-C12)/(4*e4);
    else
        if(C11>C22)&&(C11>C33)
            e1Times4=sqrt(1+C11-C22-C33)*2;
            e1=e1Times4/4;
            e2=(C12+C21)/e1Times4;
            e3=(C13+C31)/e1Times4;
            e4=(C23-C32)/e1Times4;
        elseif C22>C33
            e2Times4=sqrt(1+C22-C11-C33)*2;
            e1=(C12+C21)/e2Times4;
            e2=e2Times4/4;
            e3=(C23+C32)/e2Times4;
            e4=(C31-C13)/e2Times4;
        else
            e3Times4=sqrt(1+C33-C11-C22)*2;
            e1=(C13+C31)/e3Times4;
            e2=(C23+C32)/e3Times4;
            e3=e3Times4/4;
            e4=(C12-C21)/e3Times4;
        end
    end



    e=[e1;e2;e3;e4];

end

function dBRespLimited=limitDynamicdBRange(dBResp,dRange)




    respmax=max(dBResp,[],'all');
    respmin=respmax-dRange;
    dBRespLimited=dBResp;
    dBRespLimited(dBResp<respmin)=respmin;
end
