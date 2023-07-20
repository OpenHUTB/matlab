classdef Actor<handle




    properties(Access=private)
        mActor;
    end

    methods(Access=public)

        function obj=Actor(type,varargin)
            obj.initializeActor(type);
            if length(varargin)==1
                obj.setStruct(varargin{1});
            else
                obj.set(varargin{:});
            end
        end

        function actor=getStruct(obj)
            actor=obj.mActor;
        end

        function setStruct(obj,value)
            errMsg=message('ssm:mcosMessages:IncorrectDatatype',...
            'struct','struct');
            assert(isa(value,'struct'),errMsg);
            obj.mActor=value;
        end

        function ret=getId(obj)
            ret=obj.mActor.id;
        end

        function varargout=setId(obj,value,varargin)
            errMsg=message('ssm:mcosMessages:IncorrectDatatype',...
            'id','char');
            assert(isa(value,'char'),errMsg);
            if nargin==3
                varargin{1}.id=value;
                varargout=varargin;
            else
                obj.mActor.id=value;
            end
        end

        function ret=getName(obj)
            ret=obj.mActor.name;
        end

        function varargout=setName(obj,value,varargin)
            errMsg=message('ssm:mcosMessages:IncorrectDatatype',...
            'name','char');
            assert(isa(value,'char'),errMsg);
            if nargin==3
                varargin{1}.name=value;
                varargout=varargin;
            else
                obj.mActor.name=value;
            end
        end

        function ret=getBehaviorId(obj)
            ret=obj.mActor.behavior_id;
        end

        function varargout=setBehaviorId(obj,value,varargin)
            errMsg=message('ssm:mcosMessages:IncorrectDatatype',...
            'behavior id','char');
            assert(isa(value,'char'),errMsg);
            if nargin==3
                varargin{1}.behavior_id=value;
                varargout=varargin;
            else
                obj.mActor.behavior_id=value;
            end
        end

        function ret=getAssetReference(obj)
            ret=obj.mActor.asset_reference;
        end

        function varargout=setAssetReference(obj,value,varargin)
            errMsg=message('ssm:mcosMessages:IncorrectDatatype',...
            'Asset reference','char');
            assert(isa(value,'char'),errMsg);
            if nargin==3
                varargin{1}.asset_reference=value;
                varargout=varargin;
            else
                obj.mActor.asset_reference=value;
            end
        end

        function ret=getBoundingBox(obj)
            ret=zeros(2,3);
            bbox=obj.mActor.bounding_box;
            colNames=fieldnames(bbox);
            for j=1:length(colNames)
                elemNames=fieldnames(bbox.(colNames{j}));
                for k=1:length(elemNames)
                    ret(j,k)=bbox.(colNames{j}).(elemNames{k});
                end
            end
        end

        function varargout=setBoundingBox(obj,value,varargin)
            vects=value;

            errMsg=message('ssm:mcosMessages:IncorrectDatatype',...
            'bounding box','2x3 double matrix');
            assert(isa(vects,'double'),errMsg);
            assert(isequal(size(vects),[2,3]),errMsg);

            bbox=obj.mActor.bounding_box;
            bbox.min.x=vects(1,1);
            bbox.min.y=vects(1,2);
            bbox.min.z=vects(1,3);
            bbox.max.x=vects(2,1);
            bbox.max.y=vects(2,2);
            bbox.max.z=vects(2,3);

            if nargin==3
                varargin{1}.bounding_box=bbox;
                varargout=varargin;
            else
                obj.mActor.bounding_box=bbox;
            end
        end

        function ret=getPaintColor(obj)
            ret=zeros(1,4);
            paintColor=obj.mActor.paint_color;
            colNames=fieldnames(paintColor);
            for j=1:length(colNames)
                ret(j)=paintColor.(colNames{j});
            end
        end

        function varargout=setPaintColor(obj,value,varargin)
            errMsg=message('ssm:mcosMessages:IncorrectDatatype',...
            'paint color','1x4 double matrix');
            assert(isa(value,'double'),errMsg);
            assert(isequal(size(value),[1,4]),errMsg);

            paintColor=obj.mActor.paint_color;
            paintColor.r=value(1);
            paintColor.g=value(2);
            paintColor.b=value(3);
            paintColor.a=value(4);

            if nargin==3
                varargin{1}.paint_color=paintColor;
                varargout=varargin;
            else
                obj.mActor.paint_color=paintColor;
            end
        end

        function mat4x4=getPose(obj)
            mat4x4=zeros(4,4);

            pose=obj.mActor.pose.matrix;
            colNames=fieldnames(pose);
            for j=1:length(colNames)
                elemNames=fieldnames(pose.(colNames{j}));
                for k=1:length(elemNames)
                    mat4x4(k,j)=pose.(colNames{j}).(elemNames{k});
                end
            end
        end

        function varargout=setPose(obj,value,varargin)
            mat4x4=value;

            errMsg=message('ssm:mcosMessages:IncorrectDatatype',...
            'pose','4x4 double matrix');
            assert(isa(mat4x4,'double'),errMsg);
            assert(isequal(size(mat4x4),[4,4]),errMsg);

            pose=obj.mActor.pose.matrix;
            colNames=fieldnames(pose);
            for j=1:length(colNames)
                elemNames=fieldnames(pose.(colNames{j}));
                for k=1:length(elemNames)
                    pose.(colNames{j}).(elemNames{k})=mat4x4(k,j);
                end
            end

            if nargin==3
                varargin{1}.pose.matrix=pose;
                varargout=varargin;
            else
                obj.mActor.pose.matrix=pose;
            end
        end

        function arrMat4x4=getWheels(obj)
            wheels=obj.mActor.wheels;
            arrMat4x4=cell(1,length(wheels));
            for i=1:length(wheels)
                mat4x4=zeros(4,4);
                wheelpose=obj.mActor.wheels{i}.matrix;
                colNames=fieldnames(wheelpose);
                for j=1:length(colNames)
                    elemNames=fieldnames(wheelpose.(colNames{j}));
                    for k=1:length(elemNames)
                        mat4x4(k,j)=wheelpose.(colNames{j}).(elemNames{k});
                    end
                end
                arrMat4x4{i}=mat4x4;
            end
        end

        function varargout=setWheels(obj,value,varargin)
            arrMat4x4=value;
            errMsg=message('ssm:mcosMessages:IncorrectDatatype',...
            'wheels','cell array of 4x4 double matrix of size 4');
            assert(isa(arrMat4x4,'cell'),errMsg);
            assert(isequal(size(arrMat4x4),[1,4]),errMsg);
            for i=1:length(arrMat4x4)
                mat4x4=arrMat4x4{i};
                assert(isa(mat4x4,'double'),errMsg);
                assert(isequal(size(mat4x4),[4,4]),errMsg);

                wheelPose=obj.mActor.wheels{i}.matrix;
                colNames=fieldnames(wheelPose);
                for j=1:length(colNames)
                    elemNames=fieldnames(wheelPose.(colNames{j}));
                    for k=1:length(elemNames)
                        wheelPose.(colNames{j}).(elemNames{k})=mat4x4(k,j);
                    end
                end

                if nargin==3
                    varargin{1}.wheels{i}.matrix=wheelPose;
                    varargout=varargin;
                else
                    obj.mActor.wheels{i}.matrix=wheelPose;
                end
            end
        end

        function ret=getParent(obj)
            ret=obj.mActor.parent;
        end

        function varargout=setParent(obj,value,varargin)
            errMsg=message('ssm:mcosMessages:IncorrectDatatype',...
            'parent','char');
            assert(isa(value,'char'),errMsg);
            if nargin==3
                varargin{1}.parent=value;
                varargout=varargin;
            else
                obj.mActor.parent=value;
            end
        end

        function ret=getVelocity(obj)
            ret=zeros(1,3);
            velocity=obj.mActor.velocity;
            colNames=fieldnames(velocity);
            for j=1:length(colNames)
                ret(j)=velocity.(colNames{j});
            end
        end

        function varargout=setVelocity(obj,value,varargin)
            errMsg=message('ssm:mcosMessages:IncorrectDatatype',...
            'velocity','1x3 double matrix');
            assert(isa(value,'double'),errMsg);
            assert(isequal(size(value),[1,3]),errMsg);

            velocity=obj.mActor.velocity;
            velocity.x=value(1);
            velocity.y=value(2);
            velocity.z=value(3);

            if nargin==3
                varargin{1}.velocity=velocity;
                varargout=varargin;
            else
                obj.mActor.velocity=velocity;
            end
        end

        function ret=getAngularVelocity(obj)
            ret=zeros(1,3);
            angularVelocity=obj.mActor.angular_velocity;
            colNames=fieldnames(angularVelocity);
            for j=1:length(colNames)
                ret(j)=angularVelocity.(colNames{j});
            end
        end

        function varargout=setAngularVelocity(obj,value,varargin)
            errMsg=message('ssm:mcosMessages:IncorrectDatatype',...
            'angular_velocity','1x3 double matrix');
            assert(isa(value,'double'),errMsg);
            assert(isequal(size(value),[1,3]),errMsg);

            angularVelocity=obj.mActor.angular_velocity;
            angularVelocity.x=value(1);
            angularVelocity.y=value(2);
            angularVelocity.z=value(3);

            if nargin==3
                varargin{1}.angular_velocity=angularVelocity;
                varargout=varargin;
            else
                obj.mActor.angular_velocity=angularVelocity;
            end
        end

        function ret=getChildren(obj)
            ret=obj.mActor.childActors;
        end

        function addChild(obj,childActor)

            obj.mActor.childActors{end+1}=childActor.getStruct;


            obj.mActor.children{end+1}=childActor.getStruct.name;
        end

        function ret=getBehaviors(obj)
            ret=obj.mActor.behaviors;
        end

        function addBehavior(obj,behavior)

            obj.mActor.behaviors{end+1}=behavior;
        end

        function set(obj,varargin)

            errMsg=message('ssm:mcosMessages:NameValuePairExpected');
            assert(mod(length(varargin),2)==0,errMsg);




            tempActor=obj.mActor;

            for i=1:2:length(varargin)
                errMsg=message('ssm:mcosMessages:NameValuePairExpected');
                assert(isa(varargin{i},'char'),errMsg);

                switch varargin{i}
                case 'id'
                    tempActor=obj.setId(varargin{i+1},tempActor);
                case 'name'
                    tempActor=obj.setName(varargin{i+1},tempActor);
                case 'behavior_id'
                    tempActor=obj.setBehaviorId(varargin{i+1},tempActor);
                case 'asset_reference'
                    tempActor=obj.setAssetReference(varargin{i+1},tempActor);
                case 'bounding_box'
                    tempActor=obj.setBoundingBox(varargin{i+1},tempActor);
                case 'paint_color'
                    tempActor=obj.setPaintColor(varargin{i+1},tempActor);
                case 'pose'
                    tempActor=obj.setPose(varargin{i+1},tempActor);
                case 'wheels'
                    tempActor=obj.setWheels(varargin{i+1},tempActor);
                case 'parent'
                    tempActor=obj.setParent(varargin{i+1},tempActor);
                case 'velocity'
                    tempActor=obj.setVelocity(varargin{i+1},tempActor);
                case 'angular_velocity'
                    tempActor=obj.setAngularVelocity(varargin{i+1},tempActor);
                otherwise
                    errMsg=message('ssm:mcosMessages:InexistentField',...
                    varargin{i});
                    error(errMsg);
                end
            end


            obj.mActor=tempActor;
        end
    end

    methods(Static)
        function pose=createPoseStructFromMatrix(mat4x4)
            vector4=struct('x',0,'y',0,'z',0,'w',0);
            matrix=struct(...
            'col0',vector4,'col1',vector4,...
            'col2',vector4,'col3',vector4);
            colNames=fieldnames(matrix);
            for j=1:length(colNames)
                elemNames=fieldnames(matrix.(colNames{j}));
                for k=1:length(elemNames)
                    matrix.(colNames{j}).(elemNames{k})=mat4x4(k,j);
                end
            end
            pose=struct('matrix',matrix);
        end

        function velocity=createVelocityStructFromArray(array)
            velocity=struct('x',array(1),'y',array(2),'z',array(3));
        end

        function wheels=createWheelsStructFromStruct(cellsOfmat4x4)
            wheels=cell(1,4);
            for i=1:length(cellsOfmat4x4)
                wheels{i}=ssm.Actor.createPoseStructFromMatrix(...
                cellsOfmat4x4{i});
            end
        end
    end

    methods(Access=private)
        function initializeActor(obj,type)
            vector3=struct('x',0,'y',0,'z',0);
            bbox=struct('min',vector3,'max',vector3);
            paintColor=struct('r',0,'g',0,'b',0,'a',0);

            vector4=struct('x',0,'y',0,'z',0,'w',0);
            matrix=struct(...
            'col0',vector4,'col1',vector4,...
            'col2',vector4,'col3',vector4);
            pose=struct('matrix',matrix);

            obj.mActor=struct(...
            'id','',...
            'name','',...
            'asset_reference','',...
            'bounding_box',bbox,...
            'paint_color',paintColor,...
            'pose',pose,...
            'parent','',...
            'children',{{}}...
            );

            switch type
            case 'world'
                obj.mActor.childActors={};
                obj.mActor.behaviors={};
            case 'vehicle'
                obj.mActor.behavior_id='';
                obj.mActor.velocity=vector3;
                obj.mActor.angular_velocity=vector3;
                obj.mActor.wheels={pose,pose,pose,pose};
            otherwise
                errMsg=message('ssm:mcosMessages:UnsupportedActorType',...
                type);
                error(errMsg);
            end
        end
    end
end
