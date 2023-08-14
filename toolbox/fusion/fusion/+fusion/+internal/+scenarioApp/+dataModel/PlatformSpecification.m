classdef PlatformSpecification<fusion.internal.scenarioApp.dataModel.Specification

    properties
        ID=0;
        SimID;

        Dimension=zeros(1,6);


        OrientationAccuracy=[0,0,0];
        PositionAccuracy=0;
        VelocityAccuracy=0;


        HasConstantRCS=true;
        RCSSignature=rcsSignature
        IRSignature=irSignature
        TSSignature=tsSignature


TrajectorySpecification

    end


    properties(Dependent)
Position
Orientation
DefaultSpeed
EndTime
    end

    methods
        function this=PlatformSpecification(varargin)
            this@fusion.internal.scenarioApp.dataModel.Specification(...
            'TrajectorySpecification',fusion.internal.scenarioApp.dataModel.TrajectorySpecification,...
            varargin{:});
        end

        function value=get.Position(this)
            value=this.TrajectorySpecification.InitialPosition;
        end

        function set.Position(this,value)
            this.TrajectorySpecification.InitialPosition=value;
        end

        function value=get.Orientation(this)
            value=this.TrajectorySpecification.InitialOrientation;
        end

        function set.Orientation(this,value)
            this.TrajectorySpecification.InitialOrientation=value;
        end

        function value=get.DefaultSpeed(this)
            value=this.TrajectorySpecification.DefaultGroundSpeed;
        end

        function set.DefaultSpeed(this,value)
            this.TrajectorySpecification.DefaultGroundSpeed=value;
        end

        function value=get.EndTime(this)
            value=this.TrajectorySpecification.EndTime;
        end

        function deleteTrajectory(this)
            deleteTrajectory(this.TrajectorySpecification);
        end

        function importPlatform(this,platform,platformID,warningHandler)



            this.Dimension=horzcat(platform.Dimensions.Length,...
            platform.Dimensions.Width,...
            platform.Dimensions.Height,...
            platform.Dimensions.OriginOffset);

            this.ID=platformID-1;


            for i=1:numel(platform.Signatures)
                importSignature(this,platform.Signatures{i},warningHandler);
            end




            if isa(platform.PoseEstimator,'insSensor')
                this.OrientationAccuracy(1)=platform.PoseEstimator.RollAccuracy;
                this.OrientationAccuracy(2)=platform.PoseEstimator.PitchAccuracy;
                this.OrientationAccuracy(3)=platform.PoseEstimator.YawAccuracy;
                this.PositionAccuracy=platform.PoseEstimator.PositionAccuracy;
                this.VelocityAccuracy=platform.PoseEstimator.VelocityAccuracy;
            else
                warningHandler.addMessage('CustomPoseEstimatorIgnored',platformID);
            end


            importTrajectory(this.TrajectorySpecification,platform.Trajectory,warningHandler,platformID);

        end

        function applyToScenario(this,scenario)
            pvPairs=toPvPairs(this);
            p=platform(scenario,pvPairs{:});
            this.SimID=p.PlatformID;


            applyToPlatform(this.TrajectorySpecification,p,scenario.UpdateRate);


            p.PoseEstimator.RollAccuracy=this.OrientationAccuracy(1);
            p.PoseEstimator.PitchAccuracy=this.OrientationAccuracy(2);
            p.PoseEstimator.YawAccuracy=this.OrientationAccuracy(3);
            p.PoseEstimator.PositionAccuracy=this.PositionAccuracy;
            p.PoseEstimator.VelocityAccuracy=this.VelocityAccuracy;
        end

        function pvPairs=toPvPairs(this)
            dim=struct('Length',this.Dimension(1),...
            'Width',this.Dimension(2),...
            'Height',this.Dimension(3),...
            'OriginOffset',this.Dimension(4:6));
            sign{1}=this.RCSSignature;
            sign{2}=this.IRSignature;
            sign{3}=this.TSSignature;

            pvPairs={
            'ClassID',this.ClassID,...
            'Dimensions',dim,...
            'Signatures',sign};
        end

        function importSignature(this,signature,warningHandler)%#ok<INUSD>
            signatureClass=class(signature);
            switch signatureClass
            case 'rcsSignature'
                this.RCSSignature=signature;
            case 'irSignature'
                this.IRSignature=signature;
            case 'tsSignature'
                this.TSSignature=signature;
            end
        end


        function code=generateMatlabCode(this,sceneName)

            varName=matlab.lang.makeValidName(this.Name);
            createcode=varName+" = platform("+sceneName+",'ClassID',"+this.ClassID+");";
            dimstruct=struct('Length',this.Dimension(1),...
            'Width',this.Dimension(2),...
            'Height',this.Dimension(3),...
            'OriginOffset',this.Dimension(4:6));
            dimcode=fieldsToCode(this,dimstruct,varName+".Dimensions = struct( ...",');');


            signaturecode=getSignaturesCode(this);


            trajcode=getTrajectoryCode(this);

            code=vertcat(createcode,dimcode,signaturecode,trajcode);
        end

        function trajcode=getTrajectoryCode(this)

            varName=matlab.lang.makeValidName(this.Name);
            if size(this.TrajectorySpecification.Position,1)==1

                if~isequal(this.Position,[0,0,0])
                    positioncode=varName+".Trajectory.Position = "+mat2str(this.Position)+";";
                else
                    positioncode=string.empty;
                end
                if~isequal(this.Orientation,[0,0,0])
                    orientationcode=varName+".Trajectory.Orientation = quaternion("+...
                    mat2str(this.Orientation(3:-1:1))+", 'eulerd','zyx','frame');";
                else
                    orientationcode=string.empty;
                end
                trajcode=[positioncode;orientationcode];
            else
                preamble=varName+".Trajectory = ";
                trajcode=generateCode(this.TrajectorySpecification,preamble,";");
            end

        end

        function signaturecode=getSignaturesCode(this)


            defaultRcs=rcsSignature;

            if~isequal(defaultRcs,this.RCSSignature)
                rcscode=fieldsToCode(this,this.RCSSignature,"rcsSignature(...",')');
                signaturecode=[matlab.lang.makeValidName(this.Name)+".Signatures = {...";"    "+rcscode];
                signaturecode(end,1)=signaturecode(end,1)+"};";
            else
                signaturecode=string.empty;
            end
        end

        function faces=generateFaces(this,frame,position,orientationQ)
            if nargin==2
                position=this.Position;
                orientationQ=quaternion(this.Orientation(end:-1:1),'eulerd','zyx','frame');
            end
            L=this.Dimension(1);
            W=this.Dimension(2);
            H=this.Dimension(3);



            f=[1,1,1;1,-1,1;1,-1,-1;1,1,-1].*[L,W,H];
            l=[1,1,1;1,1,-1;-1,1,-1;-1,1,1].*[L,W,H];
            u=[1,1,1;-1,1,1;-1,-1,1;1,-1,1].*[L,W,H];
            b=[-1,1,1;-1,1,-1;-1,-1,-1;-1,-1,1].*[L,W,H];
            r=[-1,-1,1;-1,-1,-1;1,-1,-1;1,-1,1].*[L,W,H];
            d=[1,1,-1;1,-1,-1;-1,-1,-1;-1,1,-1].*[L,W,H];

            faces=[f;l;u;b;r;d]/2;


            originOffset=this.Dimension(4:6);
            faces=faces-originOffset;

            if strcmp(frame,'global')

                R=rotmat(orientationQ,'frame');
                faces=faces*R+position;
            end


            faces=reshape(faces',3,4,[]);
        end
    end
    methods(Access=protected)

        function cpObj=copyElement(this)

            cpObj=copyElement@matlab.mixin.Copyable(this);

            cpObj.TrajectorySpecification=copy(this.TrajectorySpecification);
        end
    end
end
