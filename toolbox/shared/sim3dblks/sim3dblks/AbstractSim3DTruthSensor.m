classdef(Hidden)AbstractSim3DTruthSensor<...
    matlabshared.tracking.internal.SimulinkBusUtilities&...
Simulation3DHandleMap

    properties(Nontunable)
        SensorIdentifier(1,1)uint32{mustBeLessThanOrEqual(SensorIdentifier,65535)}=uint32(1);
        VehicleIdentifier='';
        Translation=[0,0,0];
        Rotation=[0,0,0];
    end


    properties(Nontunable)
        UpdateInterval=0.1
        MaxNumDetectionsSource='Auto'
        MaxNumDetections(1,1){mustBePositive,mustBeInteger}=50
        HasNoise(1,1)logical=true
        InitialSeedSource='Repeatable'
        InitialSeed=0
        UsedSeed=0
    end


    properties(Access=protected,Hidden)
        pVersion=ver('driving');
    end


    properties(Constant,Hidden)
        MaxNumDetectionsSourceSet=matlab.system.StringSet({'Auto','Property'});
        InitialSeedSourceSet=matlab.system.StringSet({'Specify seed','Repeatable','Not repeatable'});
    end

    properties(Access=protected,Nontunable)
cRandStream
        pSim3DSensor=[];
        NumberOfRays=[];
    end


    properties(Access=protected)
        pHasFirstUpdate=false
        pTimeLastUpdate=0
    end


    properties(Access=private)
        pUseRandSeed=false
pRandState
        ModelName=[];
    end


    properties(Access={?driving.internal.AbstractDetectionGenerator,?matlab.unittest.TestCase})
pRandomDrawFunc
    end


    properties(Constant,Access=protected)
        pUpdateIntervalTolerance=1e-4
        pLargeVariance=100
    end


    methods(Abstract,Access=protected)
        num=getNumMeasOut(obj)
    end


    methods
        function set.Translation(obj,val)
            obj.checkTranslation(val);
            obj.Translation=val;
        end


        function set.Rotation(obj,val)
            obj.checkRotation(val);
            obj.Rotation=val;
        end


        function set.UpdateInterval(obj,val)
            obj.checkUpdateInterval(val);
            obj.UpdateInterval=val;
        end


        function set.InitialSeed(obj,val)
            validateattributes(val,{'double'},{'scalar','nonnegative','<',2^32,...
            'finite','nonnan','nonempty'},class(obj),...
            'InitialSeed');
            obj.InitialSeed=val;
        end
    end


    methods
        function obj=AbstractSim3DTruthSensor(varargin)
            setProperties(obj,numel(varargin),varargin{:});
        end
    end


    methods(Access=protected)

        function setupImpl(obj,varargin)
            if isSourceBlock(obj)
                obj.pUseRandSeed=true;
                if coder.target('MATLAB')
                    obj.cRandStream=RandStream('mt19937ar','Seed',obj.UsedSeed);
                else
                    rng(obj.UsedSeed);
                end
            end

            if coder.target('MATLAB')
                if isempty(obj.pRandomDrawFunc)
                    obj.pRandomDrawFunc=@rand;
                end
            else
                if~coder.internal.is_defined(obj.pRandomDrawFunc)
                    obj.pRandomDrawFunc=@rand;
                end
            end
            sim3d.engine.Engine.start();
            obj.pSim3DSensor=sim3d.sensors.TruthSensor(obj.SensorIdentifier,obj.VehicleIdentifier,obj.NumberOfRays,obj.Translation,obj.Rotation);
            obj.ModelName=['Sim3DTruthSensor/',num2str(obj.SensorIdentifier),'/',obj.VehicleIdentifier];
            if obj.loadflag
                obj.Sim3dSetGetHandle([obj.ModelName,'/pSim3DSensor'],obj.pSim3DSensor);
            end
        end


        function sts=getSampleTimeImpl(self)
            sampleTime=Simulation3DEngine.getEngineSampleTime(self.UpdateInterval);
            if self.UpdateInterval==-1
                if sampleTime==-1
                    sts=createSampleTime(self,'Type','Inherited');
                else
                    sts=createSampleTime(self,'Type','Discrete','SampleTime',sampleTime);
                end
            else
                sts=createSampleTime(self,'Type','Discrete','SampleTime',self.UpdateInterval);
            end
        end


        function flag=isInputComplexityMutableImpl(~,index)
            flag=true;
            if index==2
                flag=false;
            end
        end


        function resetImpl(obj)
            obj.pHasFirstUpdate=false;
            obj.pTimeLastUpdate=0;

            if obj.pUseRandSeed
                if coder.target('MATLAB')
                    reset(obj.cRandStream,obj.UsedSeed);
                else
                    rng(obj.UsedSeed);
                end
            end

        end


        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);
            s.pVersion=obj.pVersion;
            if isLocked(obj)
                s.pHasFirstUpdate=obj.pHasFirstUpdate;
                s.pTimeLastUpdate=obj.pTimeLastUpdate;
                s.pRandomDrawFunc=obj.pRandomDrawFunc;
                s.pUseRandSeed=obj.pUseRandSeed;
                s.pSim3DSensor=obj.pSim3DSensor;
                s.ModelName=obj.ModelName;
                if obj.pUseRandSeed
                    if coder.target('MATLAB')
                        s.pRandState=obj.cRandStream.State;
                    else
                        s.pRandState=rng;
                    end
                end
            end

        end


        function loadObjectImpl(obj,s,wasLocked)
            if isfield(s,'pVersion')
                obj.pVersion=s.pVersion;
                s=rmfield(s,'pVersion');
            else
                obj.pVersion=-1;
            end
            if wasLocked
                obj.pHasFirstUpdate=s.pHasFirstUpdate;
                s=rmfield(s,'pHasFirstUpdate');
                obj.pTimeLastUpdate=s.pTimeLastUpdate;
                s=rmfield(s,'pTimeLastUpdate');
                if obj.loadflag
                    obj.ModelName=s.ModelName;
                    obj.pSim3DSensor=obj.Sim3dSetGetHandle([obj.ModelName,'/pSim3DSensor']);
                else
                    obj.pSim3DSensor=s.pSim3DSensor;
                    s=rmfield(s,'pSim3DSensor');
                end
                if isfield(s,'pRandomDrawFunc')
                    obj.pRandomDrawFunc=s.pRandomDrawFunc;
                    s=rmfield(s,'pRandomDrawFunc');
                end
                if isfield(s,'pUseRandSeed')
                    obj.pUseRandSeed=s.pUseRandSeed;
                    s=rmfield(s,'pUseRandSeed');

                    if obj.pUseRandSeed
                        if coder.target('MATLAB')
                            obj.cRandStream=RandStream('mt19937ar');
                            obj.cRandStream.State=s.pRandState;
                        else
                            rng(s.pRandState);
                        end
                        s=rmfield(s,'pRandState');
                    end
                end
            end
            loadObjectImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj,s,wasLocked);
        end


        function releaseObjectImpl(obj)
            releaseObjectImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj,s,wasLocked);
            if obj.loadflag
                obj.Sim3dSetGetHandle([obj.ModelName,'/pSim3DSensor'],[]);
            end
        end


        function flag=isInactivePropertyImpl(obj,prop)
            flag=isInactivePropertyImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj,prop);
            if strcmp(obj.MaxNumDetectionsSource,'Auto')&&...
                strcmp(prop,'MaxNumDetections')
                flag=true;
            end

            if~isSourceBlock(obj)
                if strcmp(prop,'InitialSeedSource')||strcmp(prop,'InitialSeed')||strcmp(prop,'UsedSeed')
                    flag=true;
                end
            elseif strcmp(prop,'InitialSeed')&&~strcmp(obj.InitialSeedSource,'Specify seed')
                flag=true;
            end
        end


        function groups=getPropertyGroupsLongImpl(obj)
            propList={'MaxNumDetectionsSource'};
            if strcmp(obj.MaxNumDetectionsSource,'Property')
                propList=[propList,{'MaxNumDetections'}];
            end
            propList=[propList,{'DetectionCoordinates'}];
            groups=matlab.mixin.util.PropertyGroup(propList);
        end
    end


    methods(Static,Access=protected)

        function groups=getPropertyGroupsImpl
            slBusSection=getPropertyGroupsImpl@matlabshared.tracking.internal.SimulinkBusUtilities;
            pMaxNumDetectionsSource=matlab.system.display.internal.Property(...
            'MaxNumDetectionsSource',...
            'IsGraphical',false,...
            'UseClassDefault',false,...
            'Default','Property',...
            'StringSetValues',{'Property'});
            numDetList={pMaxNumDetectionsSource,'MaxNumDetections','DetectionCoordinates'};
            numDetSection=matlabshared.tracking.internal.getDisplaySection('driving',...
            'abstractDetectionGenerator','DetectionReporting',numDetList);

            portsSection=slBusSection;
            pUsedSeed=matlab.system.display.internal.Property(...
            'UsedSeed','IsGraphical',false,'UseClassDefault',false,...
            'Default','driving.internal.SimulinkUtilities.seedManager(gcb)');
            randList={'InitialSeedSource','InitialSeed',pUsedSeed};
            randSection=matlabshared.tracking.internal.getDisplaySection('driving',...
            'abstractDetectionGenerator','RandomNumberGeneratorSettings',randList);
            groups=[numDetSection,portsSection,randSection];
        end


        function simMode=getSimulateUsingImpl
            simMode="Interpreted execution";
        end


        function flag=showSimulateUsingImpl
            flag=false;
        end
    end


    methods(Access=protected)
        function[z,s]=intersectLines2D(~,x1,x2,y1,y2)
            z=NaN(1,2);
            s=NaN;

            r1=x1(:);
            v1=x2(:)-r1;

            r2=y1(:);
            v2=y2(:)-r2;

            n2=[-v2(2);v2(1)];

            den=n2'*v1;
            if round(den*1e6)==0
                return
            end

            num=n2'*(r2-r1);
            s=num/den;
            z=(r1+s*v1)';
        end


        function yi=linearExtrap(~,x,y,xi)
            if coder.target('MATLAB')
                yi=interp1(x,y,xi,'linear','extrap');
            else
                numLUT=numel(x);
                yi=NaN(size(xi),'like',xi);
                for m=1:numel(xi)
                    dist=abs(x(1:numLUT)-xi(m));
                    iLittler=x(1:numLUT)<xi(m);
                    iBigger=x(1:numLUT)>=xi(m);

                    iPt1=NaN;
                    if any(iLittler)
                        [mVal,iMin]=min(dist(iLittler));
                        iPt=find(iLittler);
                        iPt1=iPt(iMin(1));
                        iFnd=dist==mVal;
                        dist(iFnd)=NaN;
                        iLittler(iFnd)=false;
                    end

                    iPt2=NaN;
                    if any(iBigger)
                        [mVal,iMin]=min(dist(iBigger));
                        iPt=find(iBigger);
                        iPt2=iPt(iMin(1));
                        iFnd=dist==mVal;
                        dist(iFnd)=NaN;
                        iBigger(iFnd)=false;
                    end

                    if isnan(iPt1)&&any(iBigger)
                        [~,iMin]=min(dist(iBigger));
                        iPt=find(iBigger);
                        iTmp=iPt(iMin(1));
                        iPt1=iPt2;
                        iPt2=iTmp;
                    end

                    if isnan(iPt2)&&any(iLittler)
                        [~,iMin]=min(dist(iLittler));
                        iPt=find(iLittler);
                        iPt2=iPt(iMin(1));
                    end

                    if isnan(iPt1)||isnan(iPt2)
                        continue
                    end

                    x1=x(iPt1);
                    x2=x(iPt2);
                    y1=y(iPt1);
                    y2=y(iPt2);

                    slope=(y2-y1)/(x2-x1);
                    yi(m)=slope*(xi(m)-x1)+y1;
                end
            end
        end


        function val=randn(obj,varargin)
            if nargin<2
                argin={[1,1]};
            else
                argin=varargin;
            end

            if obj.pUseRandSeed
                if coder.target('MATLAB')
                    val=randn(obj.cRandStream,argin{:});
                else
                    val=randn(argin{:});
                end
            else
                val=randn(argin{:});
            end
        end


        function val=rand(obj,varargin)

            if nargin<2
                argin={[1,1]};
            else
                argin=varargin;
            end

            if obj.pUseRandSeed
                if coder.target('MATLAB')
                    val=rand(obj.cRandStream,argin{:});
                else
                    val=rand(argin{:});
                end
            else
                val=rand(argin{:});
            end
        end


        function val=randdraw(obj,varargin)

            if nargin<2
                argin={[1,1]};
            else
                argin=varargin;
            end

            if obj.pUseRandSeed
                if coder.target('MATLAB')
                    val=rand(obj.cRandStream,argin{:});
                else
                    val=rand(argin{:});
                end
            else
                if nargin(obj.pRandomDrawFunc)==0
                    val=obj.pRandomDrawFunc();
                else
                    val=obj.pRandomDrawFunc(argin{:});
                end
            end
        end
        function[detections,numDets]=initializeDetections(obj)
            numDets=0;
            maxNumDet=0;
            if strcmp(obj.MaxNumDetectionsSource,'Property')
                maxNumDet=obj.MaxNumDetections;
            end

            if maxNumDet>0
                d=defaultOutput(obj);
                detections=repmat(d,maxNumDet,1);
            else
                detections=cell(0,1);
            end
        end


        function detSen=egoToSensor(obj,detEgo)
            numDet=size(detEgo,2);

            hasVel=size(detEgo,1)>3;
            if hasVel
                detSen=zeros(6,numDet);
            else
                detSen=zeros(3,numDet);
            end
            Rego2sen=driving.internal.rotParentToChild(obj.Rotation(1),obj.Rotation(2),-1*obj.Rotation(3));
            posSen=Rego2sen*bsxfun(@minus,detEgo(1:3,:),obj.Translation');
            detSen(1:3,:)=posSen;

            if hasVel
                velSen=Rego2sen*detEgo(4:6,:);
                detSen(4:6,:)=velSen;
            end
        end

        function[detEgo,covEgo]=sensorToEgo(obj,detCart,covCart)

            hasCov=nargin>2;
            numDet=size(detCart,2);

            hasVel=size(detCart,1)>3;
            if hasVel
                detEgo=zeros(6,numDet);
            else
                detEgo=zeros(3,numDet);
            end
            isoPose=AbstractSim3DTruthSensor.unreal2iso(...
            struct(...
            'rotation',obj.Rotation,...
            'translation',obj.Translation));
            Rsen2ego=driving.internal.rotChildToParent(isoPose.rotation(1),isoPose.rotation(2),isoPose.rotation(3));
            posEgo=bsxfun(@plus,Rsen2ego*detCart(1:3,:),isoPose.translation');
            detEgo(1:3,:)=posEgo;

            if hasVel
                velEgo=Rsen2ego*detCart(4:6,:);
                detEgo(4:6,:)=velEgo;
            end

            if hasCov
                if hasVel
                    covEgo=zeros(6,6,numDet);
                    rotCov=blkdiag(Rsen2ego,Rsen2ego);
                else
                    covEgo=zeros(3,3,numDet);
                    rotCov=Rsen2ego;
                end

                for m=1:numDet
                    R=covCart(:,:,m);
                    R=rotCov*R*rotCov';

                    covEgo(:,:,m)=R;
                end
            end
        end
    end


    methods(Access=protected)
        function[Pp,Ps]=steadyStateKalmanCovariance(~,A,Q,H,R)
            Rf=H'*(R\H);
            Atinv=inv(A');

            Hf=[...
            Atinv,Atinv*Rf;...
            Q*Atinv,A+Q*Atinv*Rf];%#ok<MINV> % (eqn 38)

            numDims=size(A,1);
            if coder.target('MATLAB')
                [W,D]=eig(Hf);
            else
                [W,D]=eig(Hf,eye(size(Hf),'like',Hf));
            end

            dd=diag(D);
            [~,iSrt]=sort(abs(dd),'descend');
            W=W(:,iSrt);

            W11=W(1:numDims,1:numDims);
            W21=W(numDims+1:end,1:numDims);

            Pp=real(W21/W11);

            if nargout>1
                PsInv=inv(Pp)+H'*(R\H);

                [U,S,V]=svd(PsInv);
                S=diag(S);

                maxS=max(S);
                minS=maxS*1e-16;
                S=max(S,minS);

                Ps=U*diag(1./S)*V';
            end
        end


        function detections=assembleDetections(obj,time,dets,covmats,attribs,addMeasParams)

            if nargin<6
                addMeasParams=struct;
            end
            isEgo=strcmp(obj.DetectionCoordinates,'Ego Cartesian');
            numDet=size(dets,2);
            lenMeas=getNumMeasOut(obj);
            detections=cell(numDet,1);

            if isEgo
                frame=drivingCoordinateFrameType.Rectangular;
                orgPos=zeros(3,1);
                orient=eye(3);
            else
                switch obj.DetectionCoordinates
                case 'Sensor Cartesian'
                    frame=drivingCoordinateFrameType.Rectangular;
                case 'Sensor spherical'
                    frame=drivingCoordinateFrameType.Spherical;
                end
                isoPose=AbstractSim3DTruthSensor.unreal2iso(...
                struct('rotation',obj.Rotation,...
                'translation',obj.Translation));
                orgPos=isoPose.translation(:);
                orient=driving.internal.rotChildToParent(isoPose.rotation(1),isoPose.rotation(2),isoPose.rotation(3));
            end

            measParams0=struct(...
            'Frame',frame,...
            'OriginPosition',orgPos,...
            'Orientation',orient);
            flds=fieldnames(addMeasParams);
            for m=1:numel(flds)
                thisFld=flds{m};
                thisVal=addMeasParams.(thisFld);
                measParams0.(thisFld)=thisVal;
            end
            measParams={measParams0};

            for m=1:numDet
                objAttrib=assembleAttributes(obj,attribs,m);
                detections{m}=objectDetection(time,dets(1:lenMeas,m),...
                'SensorIndex',double(obj.SensorIdentifier),...
                'MeasurementNoise',covmats(1:lenMeas,1:lenMeas,m),...
                'MeasurementParameters',measParams,...
                'ObjectAttributes',objAttrib);
            end
        end


        function attribOut=assembleAttributes(~,attribs,m)
            num=numel(attribs);
            c=cell(1,num);
            for iVal=1:2:num
                c{iVal}=attribs{iVal};

                c{iVal+1}=indexLastDim(attribs{iVal+1},m);
            end
            attribOut={struct(c{:})};
        end
    end


    methods(Access=protected)
        function val=roundres(~,x,res)
            val=round(x/res)*res;
        end


        function xest=centroid(~,x,y)
            xest=sum(x(:).*y(:))/sum(y(:));
        end


        function u=faceNorm(~,face)
            v1=diff(face(:,1:2),1,2);
            v2=diff(face(:,2:3),1,2);
            u=cross(v1,v2);
            u=u/norm(u);
        end


        function vals=concatFieldValues(~,s,field)
            if coder.target('MATLAB')
                vals=[s.(field)];
            else
                numStructs=numel(s);
                if numStructs==0
                    vals=zeros(1,0);
                else
                    data=s(1).(field);
                    if isscalar(data)
                        sz=[numStructs,1];
                    else
                        sz=[numStructs,size(data)];
                    end
                    vals=zeros(sz);
                    for m=1:numStructs
                        vals(m,:)=s(m).(field);
                    end
                    vals=shiftdim(vals,1);
                end
            end
        end


        function s2=copyStructField(~,field,s1,s2)
            if coder.target('MATLAB')
                [s2.(field)]=deal(s1.(field));
            else
                num=numel(s1);
                for m=1:num
                    len2=numel(s2(m).(field));
                    len1=numel(s1(m).(field));
                    len=min(len1,len2);
                    s2(m).(field)(1:len)=s1(m).(field)(1:len);
                end
            end
        end
    end


    methods(Static)
        function seed=lastInitialSeed(blkPath)
            narginchk(0,1);

            if nargin<1
                blkPath=gcb;
            end
            [loadedModels,resolvedBlkPath]=driving.internal.SimulinkUtilities.loadModels(blkPath);
            mkClean=onCleanup(@()driving.internal.SimulinkUtilities.closeModels(loadedModels));
            if~strcmp(get_param(resolvedBlkPath,'BlockType'),'MATLABSystem')
                error(message('driving:abstractDetectionGenerator:mustBeMATLABSystemBlock'));
            end
            objClass=get_param(resolvedBlkPath,'System');
            sysObj=feval(objClass);
            if~(isa(sysObj,'driving.internal.AbstractDetectionGenerator')||...
                isa(sysObj,'AbstractSim3DTruthSensor'))
                error(message('driving:abstractDetectionGenerator:methodNotSupported','lastInitialSeed'));
            end
            seed=driving.internal.SimulinkUtilities.seedManager(blkPath,true);
        end
    end


    methods(Static,Hidden)
        function checkStructFields(actorStruct,nameStruct,validFields)
            fieldNames=fieldnames(actorStruct);
            for m=1:numel(fieldNames)
                thisField=fieldNames{m};
                cond=~any(strcmp(thisField,validFields));
                coder.internal.errorIf(cond,'driving:abstractDetectionGenerator:unrecogizedFields',...
                nameStruct,thisField);
            end
        end


        function checkTranslation(translation)
            validateattributes(translation,...
            {'double','single'},{'row','numel',3,'real','finite'},...
            mfilename,'Translation');
        end


        function checkRotation(rotation)
            validateattributes(rotation,...
            {'double','single'},{'row','numel',3,'real','finite'},...
            mfilename,'Rotation');
        end


        function checkUpdateInterval(updateInterval)
            if updateInterval==-1
                return
            end
            validateattributes(updateInterval,...
            {'double','single'},{'scalar','real','finite','positive'},...
            mfilename,'UpdateInterval');
        end
    end


    methods(Access=protected)
        function varargout=getOutputNamesImpl(~)
            varargout={'Detections'};
        end


        function num=getNumOutputsImpl(obj)
            if isSourceBlock(obj)
                num=1;
            else
                num=3;
            end
        end


        function dt1=getOutputDataTypeImpl(obj)
            dt1=getOutputDataTypeImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);
        end


        function sz1=getOutputSizeImpl(~)
            sz1=[1,1];
        end


        function cp1=isOutputComplexImpl(~)
            cp1=false;
        end


        function out1=isOutputFixedSizeImpl(~)
            out1=true;
        end


        function detUberStruct=sendToBus(obj,dets,numDets,isValidTime)
            fldNames={'Time','Measurement','MeasurementNoise','SensorIndex',...
            'ObjectClassID','ObjectAttributes','MeasurementParameters'};

            oneDet=struct;
            for iFld=1:numel(fldNames)
                data=dets{1}.(fldNames{iFld});
                if iscell(data)
                    val=data{1};
                else
                    val=data;
                end
                oneDet.(fldNames{iFld})=val;
            end
            oneDet=nullify(oneDet);
            detStruct=repmat(oneDet,obj.MaxNumDetections,1);
            for m=1:numDets
                for iFld=1:numel(fldNames)
                    data=dets{m}.(fldNames{iFld});
                    if iscell(data)
                        detStruct(m).(fldNames{iFld})=data{1};
                    else
                        detStruct(m).(fldNames{iFld})=data;
                    end
                end
            end
            detUberStruct=struct('NumDetections',numDets,'IsValidTime',isValidTime,'Detections',detStruct);
        end
    end


    methods(Static)
        function fov=fieldOfView(blkPath)
            narginchk(0,1);
            if nargin<1
                blkPath=gcb;
            end
            fov=eval(get_param(blkPath,'FieldOfView'));
        end
    end


    methods(Static,Access=protected)
        

function[roll,pitch,yaw]=rotmat2rpy(rotmat)

...
...
...
...
...
...
...
...
...
            roll=atan2d(rotmat(3,2),rotmat(3,3));
            pitch=atan2d(-rotmat(3,1),sqrt(sum(rotmat(1:2,1).^2)));
            yaw=atan2d(rotmat(2,1),rotmat(1,1));

            roll=mod(roll+180,360)-180;
            yaw=mod(yaw,360);
        end


        function Angle=SphericalSpace(FieldOfView,Resolution)
            NumAngles=round(FieldOfView./Resolution);
            Angle=(1:NumAngles)-(NumAngles./2)-0.5;
            Angle=Angle.*Resolution;
        end


        function V=SphereToCart(Az,El,R)
            [X,Y,Z]=sph2cart(...
            deg2rad(Az),...
            deg2rad(El),...
            R);

            X=X(:);
            Y=Y(:);
            Z=Z(:);

            V=single(horzcat(X,Y,Z));
        end


        function isoPose=unreal2iso(unrealPose)
            isoPose.translation=[1,-1,1].*unrealPose.translation;
            isoPose.rotation=[1,1,-1].*unrealPose.rotation;
        end
    end
end


function val=indexLastDim(x,m)
    if isvector(x)
        val=x(m);
    else
        shift=ndims(x)-1;
        tmp=shiftdim(x,shift);
        val=shiftdim(tmp(m,:),1);
    end
end


function[cond,invalidIdx]=findFirstInvalid(s,fld,testFcn)

    cond=false;
    invalidIdx=0;
    for idx=1:numel(s)
        invalidIdx=idx;
        cond=testFcn(s(idx).(fld));
        if cond
            break;
        end
    end
end


function out=nullify(in)
    out=in;
    flds=fieldnames(in);
    for m=1:numel(flds)
        thisFld=flds{m};
        for n=1:numel(in)
            thisVal=in(n).(thisFld);
            if isstruct(thisVal)
                nullVal=nullify(thisVal);
            else
                if isenum(thisVal)
                    nullVal=thisVal;
                else
                    nullVal=zeros(size(thisVal),'like',thisVal);
                end
            end
            out(n).(thisFld)=nullVal;
        end
    end
end
