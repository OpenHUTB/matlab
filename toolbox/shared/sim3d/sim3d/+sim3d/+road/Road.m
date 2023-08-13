classdef Road<sim3d.AbstractActor

 properties(SetAccess='private',GetAccess='public')
        splineValues=[];
        splineValuesSize=1;
        bankAngleValues=[];
        bankAngleValuesSize=1;
        pathWidth=[];
        pathWidthSize=1;


        SplineLoc;


        BankAngles;


        RoadWidth;


        LaneStyle;


        LaneStyleColor;


LaneWidth


        ActorTag;


        CrownHeight;
        CrownType;


        MeshLength;
        MeshWidth;
        VertCrownCount;
        VertFlatCount;
        AbsWidth;
        ClosedLoop;
        MarkWidth;
        DashLength;
        DashSpace;
        NormalPath;
        LaneStencils;
        MarkerStencils;
        RoadColor;
    end

    properties(SetAccess='public',GetAccess='public')

        ActorID;
    end

    properties(Access=private)
        RoadConfig=[];
        ConfigWriter=[];
        RoadConfigStruct=[];
    end

    properties(Access=private,Constant=true)
        MaxStrLengthName=128;
        MaxStrLengthMesh=256;
        MaxLaneNum=100;

        ValidMarkerTypes=["Unmarked","Solid","Dashed","DoubleSolid","DoubleDashed","SolidDashed","DashedSolid","ShortDashed"];
        ValidColorKeys=[" ","w","y","o","r","b","br","g","p","pr","yg"];
        ValidColorRGBA={...
        [13,13,13,255],...
        [231,231,231,255],...
        [247,209,23,255],...
        [229,114,0,255],...
        [166,25,46,255],...
        [0,56,130,255],...
        [105,63,35,255],...
        [0,103,71,255],...
        [219,77,105,255],...
        [109,32,119,255],...
        [196,214,0,255]};
        ValidCrownTypes=["Parabolic","Radial","Linear"];
    end

    methods
        function self=Road(actorName,splineLoc,bankAngles,roadWidth,laneStyle,laneStyleColor,laneWidth,varargin)
            narginchk(7,inf);
            r=sim3d.road.Road.parseInputs(varargin{:});
            numberOfParts=1;
            self@sim3d.AbstractActor(actorName,'Scene Origin',r.Translation,r.Rotation,r.Scale,...
            'ActorClassId',r.ActorID,'NumberOfParts',numberOfParts);


            self.splineValues=single(ones(1,3));
            self.splineValuesSize=uint32(0);

            self.bankAngleValues=single(zeros(1,1));
            self.bankAngleValuesSize=uint32(0);

            self.pathWidth=single(zeros(1,1));
            self.pathWidthSize=uint32(0);

            normPathBuffer=char(zeros(1,sim3d.utils.CreateActor.MaxStrLengthMesh));
            normStr='NormalPath';
            normPathLength=length(normStr);
            normPathBuffer(1:normPathLength)=normStr(1:normPathLength);

            laneWidthBuffer=single(ones(1,sim3d.road.Road.MaxLaneNum));
            markerBuffer=int32(zeros(1,sim3d.road.Road.MaxLaneNum+1));
            colorBuffer=uint8(zeros(1,4*(sim3d.road.Road.MaxLaneNum+1)));
            laneStencilBuffer=uint16(zeros(1,sim3d.road.Road.MaxLaneNum));
            markerStencilBuffer=uint16(zeros(1,sim3d.road.Road.MaxLaneNum+1));
            roadColorBuffer=uint8(zeros(1,4));
            splineValuesBuffer=single(ones(1,3));
            bankAngleValuesBuffer=single(zeros(1,1));
            pathWidthBuffer=single(zeros(1,1));

            self.RoadConfigStruct=struct(...
            'Length',single(0),...
            'Width',single(0),...
            'HMax',single(0),...
            'Crown',int32(0),...
            'VertNum',uint32(0),...
            'VertFlatWidth',uint32(0),...
            'NumLanes',uint32(0),...
            'LaneWidths',laneWidthBuffer,...
            'Markers',markerBuffer,...
            'LaneStencils',laneStencilBuffer,...
            'MarkerStencils',markerStencilBuffer,...
            'ColorsRGBA',colorBuffer,...
            'RoadColor',roadColorBuffer,...
            'MarkWidth',single(0),...
            'DashLength',single(0),...
            'DashSpace',single(0),...
            'NormPath',normPathBuffer,...
            'AbsWidth',false,...
            'ClosedLoop',false,...
            'SplineValues',splineValuesBuffer,...
            'SplineValuesSize',uint32(0),...
            'BankAngleValues',bankAngleValuesBuffer,...
            'PathWidth',pathWidthBuffer);


            self.ActorTag=actorName;


            self.SplineLoc=splineLoc*[1,0,0;0,-1,0;0,0,1];
            self.BankAngles=deg2rad(bankAngles);
            self.RoadWidth=roadWidth;
            self.LaneStyle=laneStyle;
            self.LaneStyleColor=laneStyleColor;
            self.LaneWidth=laneWidth;



            self.Translation=single(r.Translation);
            self.Rotation=single(r.Rotation);
            self.Scale=single(r.Scale);
            self.ActorID=r.ActorID;


            self.CrownHeight=r.CrownHeight;
            self.CrownType=r.CrownType;
            self.MeshLength=r.MeshLength;
            self.MeshWidth=r.MeshWidth;
            self.VertCrownCount=r.VertCrownCount;
            self.VertFlatCount=r.VertFlatCount;
            self.AbsWidth=r.AbsWidth;
            self.MarkWidth=r.MarkWidth;
            self.DashLength=r.DashLength;
            self.DashSpace=r.DashSpace;
            self.NormalPath=r.NormalPath;
            self.LaneStencils=r.LaneStencils;
            self.MarkerStencils=r.MarkerStencils;
            self.RoadColor=r.RoadColor;
            self.ClosedLoop=r.ClosedLoop;

            if length(self.LaneStencils)==1
                self.LaneStencils=self.LaneStencils*ones(1,length(laneWidth));
            end
            if length(self.MarkerStencils)==1
                self.MarkerStencils=self.MarkerStencils*ones(1,length(laneWidth)+1);
            end

            self.setTexProperties(self.MarkWidth,self.DashLength,self.DashSpace,self.AbsWidth,self.NormalPath,self.RoadColor);
            self.setMeshProperties(self.MeshLength,self.MeshWidth,self.CrownHeight,self.CrownType,self.VertCrownCount,self.VertFlatCount,self.ClosedLoop);
            self.setLaneConfig(length(laneWidth),laneWidth,laneStyle,laneStyleColor,self.LaneStencils,self.MarkerStencils);

            self.setSpline(self.SplineLoc);
            self.setBank(self.BankAngles);
            self.setPathWidth(self.RoadWidth);

            self.writeConfig();
        end

        function setup(self)
            setup@sim3d.AbstractActor(self);
            roadTopicStr=['RoadConfigTopic',(self.ActorTag)];
            self.ConfigWriter=sim3d.io.Publisher(roadTopicStr,'Packet',self.RoadConfigStruct);
            self.ConfigWriter.send(self.RoadConfigStruct);
        end

        function writeConfig(self)
            if self.splineValuesSize~=self.bankAngleValuesSize
                self.bankAngleValues=single(zeros(self.splineValuesSize,1));
                self.bankAngleValuesSize=self.splineValuesSize;
            end
            if self.splineValuesSize~=self.pathWidthSize
                self.pathWidth=single(zeros(self.splineValuesSize,1));
                self.pathWidthSize=self.splineValuesSize;
            end
        end


        function[translation,rotation,scale]=read(self)

            if~isempty(self.Reader)
                [translation,rotation,scale]=self.Reader.read;
            else
                translation=[];
                rotation=[];
                scale=[];
            end
        end

        function delete(self)
            if~isempty(self.ConfigWriter)
                self.ConfigWriter.delete();
                self.ConfigWriter=[];
            end

            delete@sim3d.AbstractActor(self);
        end

        function setSpline(self,splineValues)
            splineDimension1=size(splineValues,1);
            splineDimension2=size(splineValues,2);
            if splineDimension1>sim3d.utils.CreateActor.MaxNumOfSplinePts
                splineSizeException1=MException('sim3d:Road:setSpline:SplnSizeErrorDim1',...
                'Spline size definition error: Number of spline points [%d] exceeds maximum allowed [%d]',...
                splineDimension1,sim3d.utils.CreateActor.MaxNumOfSplinePts);
                throw(splineSizeException1);
            end
            if splineDimension2~=sim3d.utils.CreateActor.SplineDimension
                splineSizeException2=MException('sim3d:Road:setSpline:SplnSizeErrorDim2',...
                'Spline size definition error: expected [Nx%d] but found [Nx%d]',...
                sim3d.utils.CreateActor.SplineDimension,splineDimension2);
                throw(splineSizeException2);
            end
            self.splineValues=single(reshape(splineValues',size(splineValues)));
            self.splineValuesSize=uint32(size(self.splineValues,1));
            self.RoadConfigStruct.SplineValues=single(splineValues);
            self.RoadConfigStruct.SplineValuesSize=self.splineValuesSize;
        end

        function setBank(self,bankAngleValues)
            bankAngleDimension1=size(bankAngleValues,1);
            bankAngleDimension2=size(bankAngleValues,2);
            if bankAngleDimension1>sim3d.utils.CreateActor.MaxNumOfSplinePts
                bankAngleSizeException1=MException('sim3d:Road:setSpline:BnkAnglSizeErrorDim1',...
                'Bank angle size definition error: Number of bank angle points [%d] exceeds maximum allowed [%d]',...
                bankAngleDimension1,sim3d.utils.CreateActor.MaxNumOfSplinePts);
                throw(bankAngleSizeException1);
            end
            if bankAngleDimension2~=sim3d.utils.CreateActor.BankAngleDimension
                bankAngleSizeException2=MException('sim3d:Road:setSpline:BnkAnglSizeErrorDim2',...
                'Bank angle size definition error: expected [Nx%d] but found [Nx%d]',...
                sim3d.utils.CreateActor.SplineDimension,bankAngleDimension2);
                throw(bankAngleSizeException2);
            end
            self.bankAngleValues=single(reshape(bankAngleValues',size(bankAngleValues)));
            self.bankAngleValuesSize=uint32(size(self.bankAngleValues,1));
            self.RoadConfigStruct.BankAngleValues=self.bankAngleValues;
        end

        function setPathWidth(self,pathWidth)
            pathWidthDimension1=size(pathWidth,1);
            pathWidthDimension2=size(pathWidth,2);
            if pathWidthDimension1>sim3d.utils.CreateActor.MaxNumOfSplinePts
                bankAngleSizeException1=MException('sim3d:Road:setSpline:BnkAnglSizeErrorDim1',...
                'Path width size definition error: Number of path width points [%d] exceeds maximum allowed [%d]',...
                pathWidthDimension1,sim3d.utils.CreateActor.MaxNumOfSplinePts);
                throw(bankAngleSizeException1);
            end
            if pathWidthDimension2~=sim3d.utils.CreateActor.PathWidthDimension
                bankAngleSizeException2=MException('sim3d:Road:setSpline:BnkAnglSizeErrorDim2',...
                'PathWidth angle size definition error: expected [Nx%d] but found [Nx%d]',...
                sim3d.utils.CreateActor.SplineDimension,pathWidthDimension2);
                throw(bankAngleSizeException2);
            end
            self.pathWidth=single(reshape(pathWidth',size(pathWidth)));
            self.pathWidthSize=uint32(size(self.pathWidth,1));
            self.RoadConfigStruct.PathWidth=self.pathWidth;
        end

        function setTexProperties(self,mw,ml,sl,bwid,npath,roadClr)
            [r,c]=size(roadClr);
            if r~=1||c~=4
                setupException=MException('sim3d:Road:setTexProperties:InvalidColorError',...
                'Road color array is incorrectly shaped');
                throw(setupException);
            end

            self.RoadConfigStruct.MarkWidth=single(mw);
            self.RoadConfigStruct.DashLength=single(ml);
            self.RoadConfigStruct.DashSpace=single(sl);
            self.RoadConfigStruct.AbsWidth=logical(bwid);

            npathLen=length(npath);
            self.RoadConfigStruct.NormPath=char(zeros(1,sim3d.utils.CreateActor.MaxStrLengthMesh));
            self.RoadConfigStruct.NormPath(1:npathLen)=npath(1:npathLen);
            self.RoadConfigStruct.RoadColor(1:4)=uint8(roadClr(1:4));
        end

        function setMeshProperties(self,len,wid,hm,crn,vn,vfn,closed)
            if len<0||wid<0||hm<0||~any(self.ValidCrownTypes==crn)||vn<2||vfn<2
                setupException=MException('sim3d:Road:setLaneConfig:InvalidMeshPropertiesError',...
                'Mesh property(s) out of bounds');
                throw(setupException);
            end

            self.RoadConfigStruct.Length=single(len*100);
            self.RoadConfigStruct.Width=single(wid*100);
            self.RoadConfigStruct.HMax=single(hm);
            self.RoadConfigStruct.Crown=int32(find(self.ValidCrownTypes==crn)-1);
            self.RoadConfigStruct.VertNum=uint32(vn);
            self.RoadConfigStruct.VertFlatWidth=uint32(vfn);
            self.RoadConfigStruct.ClosedLoop=logical(closed);
        end

        function setLaneConfig(self,laneCount,wids,marks,clrs,laneStencils,markerStencils)
            if length(wids)~=laneCount||length(marks)~=laneCount+1||length(clrs)~=laneCount+1||length(laneStencils)~=laneCount||length(markerStencils)~=laneCount+1||laneCount<=0
                setupException=MException('sim3d:Road:setLaneConfig:InvalidSize',...
                'LaneWidths, LaneConfig, and/or LaneColors is an improper size');
                throw(setupException);
            end

            self.RoadConfigStruct.NumLanes=uint32(laneCount);

            self.RoadConfigStruct.LaneWidths=single(zeros(1,sim3d.road.Road.MaxLaneNum));
            self.RoadConfigStruct.LaneWidths(1:laneCount)=single(wids(1:laneCount));

            self.RoadConfigStruct.Markers=int32(zeros(1,sim3d.road.Road.MaxLaneNum+1));
            if~all(ismember(marks,self.ValidMarkerTypes))
                setupException=MException('sim3d:Road:setLaneConfig:InvalidLaneTypeError',...
                'Unrecognizd lane type, must be one of "%s"',strjoin(self.ValidMarkerTypes));
                throw(setupException);
            end
            tags=arrayfun(@(x)(find(self.ValidMarkerTypes==x)-1),marks);
            self.RoadConfigStruct.Markers(1:(laneCount+1))=int32(tags(1:(laneCount+1)));

            self.RoadConfigStruct.ColorsRGBA=uint8(zeros(1,4*(sim3d.road.Road.MaxLaneNum+1)));
            if~all(ismember(clrs,self.ValidColorKeys))
                setupException=MException('sim3d:Road:setLaneConfig:InvalidLaneColorError',...
                'Unrecognizd color, must be one of "%s"',strjoin(self.ValidColorKeys));
                throw(setupException);
            end

            if any(laneStencils>255)||any(laneStencils<0)||any(markerStencils>255)||any(markerStencils<0)
                setupException=MException('sim3d:Road:SetLaneConfig:InvalidStencilID',...
                'Stencil ID out of bounds');
                throw(setupException);
            end
            self.RoadConfigStruct.LaneStencils(1:laneCount)=uint16(laneStencils(1:laneCount));
            self.RoadConfigStruct.MarkerStencils(1:(laneCount+1))=uint16(markerStencils(1:(laneCount+1)));


            ValidColorMap=containers.Map(self.ValidColorKeys,self.ValidColorRGBA);
            ctags=arrayfun(@(x)(ValidColorMap(x)),clrs,'UniformOutput',false);
            rgba=reshape(cat(1,ctags{:})',1,[]);
            self.RoadConfigStruct.ColorsRGBA(1:(length(rgba)))=int32(rgba(1:(length(rgba))));
        end

        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.SplineTrack;
        end
    end


    methods(Access=private,Static=true,Hidden=true)
        function r=parseInputs(varargin)

            defaultParams=struct(...
            'Translation',[0,0,0],...
            'Rotation',[0,0,0],...
            'Scale',[1,1,1],...
            'ActorID',7,...
            'CrownHeight',0,...
            'CrownType',"Parabolic",...
            'MeshLength',18,...
            'MeshWidth',18,...
            'VertCrownCount',20,...
            'VertFlatCount',3,...
            'AbsWidth',true,...
            'ClosedLoop',false,...
            'MarkWidth',0.13,...
            'DashLength',3.0,...
            'DashSpace',9.0,...
            'LaneStencils',7,...
            'MarkerStencils',6,...
            'RoadColor',[13,13,13,255],...
            'NormalPath','/MathWorksSimulation/LandScape/Roads/FourLaneRoad/Texture/T_FourLaneRoad_N');


            parser=inputParser;

            parser.addParameter('Translation',defaultParams.Translation);
            parser.addParameter('Rotation',defaultParams.Rotation);
            parser.addParameter('Scale',defaultParams.Scale);
            parser.addParameter('ActorID',defaultParams.ActorID);
            parser.addParameter('CrownHeight',defaultParams.CrownHeight);
            parser.addParameter('CrownType',defaultParams.CrownType);
            parser.addParameter('MeshLength',defaultParams.MeshLength);
            parser.addParameter('MeshWidth',defaultParams.MeshWidth);
            parser.addParameter('VertCrownCount',defaultParams.VertCrownCount);
            parser.addParameter('VertFlatCount',defaultParams.VertFlatCount);
            parser.addParameter('AbsWidth',defaultParams.AbsWidth);
            parser.addParameter('ClosedLoop',defaultParams.ClosedLoop);
            parser.addParameter('MarkWidth',defaultParams.MarkWidth);
            parser.addParameter('DashLength',defaultParams.DashLength);
            parser.addParameter('DashSpace',defaultParams.DashSpace);
            parser.addParameter('LaneStencils',defaultParams.LaneStencils);
            parser.addParameter('MarkerStencils',defaultParams.MarkerStencils);
            parser.addParameter('RoadColor',defaultParams.RoadColor);
            parser.addParameter('NormalPath',defaultParams.NormalPath);


            parser.parse(varargin{:});
            r=parser.Results;
        end
    end
end
