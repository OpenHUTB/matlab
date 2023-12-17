classdef Polygon<cad.Shape&cad.DependentObject

    properties
DefaultShape
        Type='Polygon';

        CategoryType='Shape';
Args
        ResizeEqual=0;

InitialArgs
Group

PropertyChangedListener

    end


    methods
        function self=Polygon(Group,Id,Type,varargin)

            self@cad.Shape(Id);
            self.Type=Type;

            if any(strcmpi(varargin,'Name'))
                idx=find(strcmpi(varargin,'Name'));
                self.Name=varargin{idx+1};
                varargin(idx:idx+1)=[];
            else
                self.Name=[self.Type,num2str(self.Id)];
            end

            parseArgs(self,varargin{:});

            self.Group=Group;

            self.ObjectType=self.Type;
        end


        function gid=getGroupId(self)

            if isempty(self.Group)
                gid=[];
            else
                gid=self.Group.Id;
            end
        end


        function deleteListeners(self)
            self.deleteListeners@cad.Shape();
            if~isempty(self.PropertyChangedListener)
                self.PropertyChangedListener.delete;
            end
        end


        function sout=getShape(self)
            createGeometry(self.DefaultShape);

            sout=copy(self.DefaultShape);
        end


        function set.Args(self,val)

            self.Args=val;
            self.updateShape();

            self.notify('PropertyChanged');
        end


        function p=parseArgs(self,varargin)

            if strcmpi(self.Type,'Rectangle')
                p=inputParser;
                p.addParameter('Length',1);
                p.addParameter('Width',2);
                p.addParameter('Center',[0,0]);

                p.addParameter('Angle',0);

                self.PropertyValueMap=struct('Angle',[],'Length',[],'Width',[],'Center',[]);

            elseif strcmpi(self.Type,'Circle')
                p=inputParser;
                p.addParameter('Radius',1);
                p.addParameter('Center',[0,0]);

                p.addParameter('Angle',0);
                self.PropertyValueMap=struct('Angle',[],'Center',[],'Radius',[]);
            elseif strcmpi(self.Type,'Ellipse')
                p=inputParser;
                p.addParameter('MajorAxis',1);
                p.addParameter('MinorAxis',0.5);
                p.addParameter('Center',[0,0]);

                p.addParameter('Angle',0);
                self.PropertyValueMap=struct('Angle',[],'Center',[],'MajorAxis',[],'MinorAxis',[]);

            elseif strcmpi(self.Type,'Polygon')
                p=inputParser;
                p.addParameter('Vertices',[0,0.5774,0;...
                -0.5,0.2884,0;...
                0.5,0.2884,0]);
                p.addParameter('Angle',0);

            end

            parse(p,varargin{:});
            args=p.Results;

            args.Axis=[0,0,0];
            self.Args=args;

            self.InitialArgs=self.Args;
        end


        function generatePolygon(self)

            if strcmpi(self.Type,'Rectangle')
                l=self.Args.Length;
                w=self.Args.Width;
                c=self.Args.Center;
                rectObj=antenna.Rectangle('Length',l,'Width',w,'Center',c);
                vert=rectObj.ShapeVertices;
            elseif strcmpi(self.Type,'Circle')
                r=self.Args.Radius;

                p=30;
                c=self.Args.Center;
                theta=linspace(0,2*pi,p-1);
                theta=theta';
                circObj=antenna.Circle('Radius',r,'Center',c);

                vert=circObj.ShapeVertices;
            elseif strcmpi(self.Type,'Ellipse')
                r=self.Args.MajorAxis;
                r2=self.Args.MinorAxis;

                p=30;
                c=self.Args.Center;
                theta=linspace(0,2*pi,p-1);
                theta=theta';

                ellipseObj=antenna.Ellipse('MajorAxis',r,'Center',c,'MinorAxis',r2);
                vert=ellipseObj.ShapeVertices;
            elseif strcmpi(self.Type,'Polygon')
                vert=self.Args.Vertices;
                c=mean(vert);
            end

            if~isempty(self.DefaultShape)
                poly=self.DefaultShape;
                poly.Vertices=vert;
            else
                poly=antenna.Polygon('Vertices',vert);
            end

            for i=1:numel(self.Args.Angle)
                if self.Args.Angle(i)==0
                    continue;
                end
                poly=rotate(poly,self.Args.Angle(i),[c(1),c(2),-1],[c(1),c(2),1]);

            end

            self.DefaultShape=poly;
            if~isempty(self.AntennaShape)
                n=size(poly.Vertices,1);
                self.AntennaShape=copy(self.DefaultShape);
            else
                n=size(self.DefaultShape.Vertices,1);
                self.AntennaShape=copy(self.DefaultShape);

            end

        end


        function translateShape(self,pt1,pt2)

            center=[];
            if strcmpi(self.Type,'Circle')
                center=[self.Args.Center,0];
            elseif strcmpi(self.Type,'Ellipse')
                center=[self.Args.Center,0];
            elseif strcmpi(self.Type,'Rectangle')
                center=[self.Args.Center,0];
            elseif strcmpi(self.Type,'Polygon')
                center=mean(self.Args.Vertices);
            end
            diffBetFirstPTAndCenter=pt1;
            diffMove=pt2-diffBetFirstPTAndCenter;
            if mean(abs(diffMove))<1e-10
                return;
            else
                if strcmpi(self.Type,'Circle')
                    self.Args.Center=center(1:2)+diffMove(1:2);
                elseif strcmpi(self.Type,'Ellipse')
                    self.Args.Center=center(1:2)+diffMove(1:2);
                elseif strcmpi(self.Type,'Rectangle')
                    self.Args.Center=center(1:2)+diffMove(1:2);
                elseif strcmpi(self.Type,'Polygon')
                    vert=self.Args.Vertices;
                    if size(vert,2)==2
                        vert=[vert,zeros(size(vert,1),1)];
                    end
                    self.Args.Vertices(:,1:2)=vert(:,1:2)+diffMove(1:2);
                end
            end

        end


        function resizeShape(self,BoundsVal)
            initialBoundsVal=BoundsVal{1};
            FinalBoundsVal=BoundsVal{2};
            iniCenter=mean(initialBoundsVal');
            FinCenter=mean(FinalBoundsVal');

            inixsize=initialBoundsVal(1,2)-initialBoundsVal(1,1);
            iniysize=initialBoundsVal(2,2)-initialBoundsVal(2,1);

            finxsize=FinalBoundsVal(1,2)-FinalBoundsVal(1,1);
            finysize=FinalBoundsVal(2,2)-FinalBoundsVal(2,1);

            xSizeratioChange=finxsize/inixsize;
            ySizeratioChange=finysize/iniysize;

            if strcmpi(self.Type,'Circle')
                centerval=self.Args.Center;
                centerval=centerval-iniCenter(1:2);
                centerval(2)=centerval(2)*ySizeratioChange;
                centerval(1)=centerval(1)*xSizeratioChange;
                centerval=centerval+FinCenter;
                self.Args.Center=centerval;
                self.Args.Radius=self.Args.Radius*max([abs(xSizeratioChange),abs(ySizeratioChange)]);
            elseif strcmpi(self.Type,'Ellipse')
                centerval=self.Args.Center;
                centerval=centerval-iniCenter(1:2);
                centerval(2)=centerval(2)*ySizeratioChange;
                centerval(1)=centerval(1)*xSizeratioChange;
                centerval=centerval+FinCenter;
                self.Args.Center=centerval;
                self.Args.MajorAxis=self.Args.MajorAxis*abs(xSizeratioChange);
                self.Args.MinorAxis=self.Args.MinorAxis*abs(ySizeratioChange);
            elseif strcmpi(self.Type,'Rectangle')
                centerval=self.Args.Center;
                centerval=centerval-iniCenter(1:2);
                centerval(2)=centerval(2)*ySizeratioChange;
                centerval(1)=centerval(1)*xSizeratioChange;
                centerval=centerval+FinCenter;
                self.Args.Center=centerval;
                self.Args.Length=self.Args.Length*abs(xSizeratioChange);
                self.Args.Width=self.Args.Width*abs(ySizeratioChange);
            elseif strcmpi(self.Type,'Polygon')
                vert=(self.Args.Vertices(~isnan(self.DefaultShape.Vertices(:,1)),:));
                if size(vert,2)==2
                    vert=[vert,zeros(size(vert,1),1)];
                end
                vert=vert-[iniCenter,0];
                vert(:,2)=vert(:,2)*ySizeratioChange;
                vert(:,1)=vert(:,1)*xSizeratioChange;
                vert=vert+[FinCenter,0];
                if size(self.Args.Vertices,2)==2

                    self.Args.Vertices=[self.Args.Vertices,zeros(size(vert,1),1)];
                end
                self.Args.Vertices(~isnan(self.DefaultShape.Vertices(:,1)),:)=vert;
            end
        end


        function rotateShape(self,RotateVal,axis)

            args=self.Args;
            rotatediff=RotateVal{2}-RotateVal{1};
            rotshape=rotate(self.DefaultShape,rotatediff,[axis(1:2),-1],[axis(1:2),1]);
            newvert=rotshape.ShapeVertices;

            if strcmpi(self.Type,'Polygon')
                args.Vertices=newvert;
            elseif strcmpi(self.Type,'Rectangle')
                meanval=mean(newvert);
                args.Center=meanval(1:2);
                val=args.Angle+rotatediff;

                if val<0
                    val=-1*mod(abs(val),360);
                else
                    val=mod(abs(val),360);
                end
                args.Angle=val;
            elseif strcmpi(self.Type,'Circle')
                meanval=mean(newvert);
                args.Center=meanval(1:2);
                val=args.Angle+rotatediff;

                if val<0
                    val=-1*mod(abs(val),360);
                else
                    val=mod(abs(val),360);
                end
                args.Angle=val;
            elseif strcmpi(self.Type,'Ellipse')
                meanval=mean(newvert);
                args.Center=meanval(1:2);
                val=args.Angle+rotatediff;

                if val<0
                    val=-1*mod(abs(val),360);
                else
                    val=mod(abs(val),360);
                end
                args.Angle=val;
            end
            self.Args=args;
        end


        function changeValue(self,infoval)

            if strcmpi(infoval.Property,'Name')
                self.Name=infoval.Value;
                self.notify('PropertyChanged');
            else
                self.Args.(infoval.Property)=infoval.Value;
            end
        end


        function revertShape(self)

            self.Args=self.InitialArgs;
        end


        function info=getInfo(self)
            info=self.getInfo@cad.TreeNode();
            info.Type=self.Type;
            if~isempty(self.Parent)
                info.ParentType=self.Parent.Type;
                info.ParentParentType={};
                if~isempty(self.Parent.Parent)
                    info.ParentParentType=self.Parent.Parent.Type;
                end
            else
                info.ParentParentType={};
                info.ParentType={};
            end
            if~isempty(self.Children)
                info.ChildrenType={self.Children.Type};
            else
                info.ChildrenType={};
            end
            info.ChildrenChildrenType=cell(1,numel(self.Children));
            for i=1:numel(self.Children)
                if~isempty(self.Children(i).Children)
                    info.ChildrenChildrenType{i}={self.Children(i).Children.Type};
                else
                    info.ChildrenChildrenType{i}={};
                end
            end
            info.Args=self.generateArgsWithValueMap;

            info.ShapeObj=copy(self.AntennaShape);
            info.Name=self.Name;

            info.GroupInfo=getInfo(self.Group);
            info.CategoryType=self.CategoryType;
            if(strcmpi(self.Type,'Circle')||~isempty(self.Children))

                info.ResizeEqual=1;
            elseif((strcmpi(self.Type,'Rectangle')&&any(abs(self.Args.Angle)==[0,90,180,270,360])))||strcmpi(self.Type,'Polygon')

                info.ResizeEqual=0;
            else

                info.ResizeEqual=1;
            end
            info.PropertyValueMap=self.PropertyValueMap;


            info.EnableMove=1;
            info.EnableResize=1;
            info.EnableRotate=1;

            if isempty(self.Children)
                [Posvar,DimVar,AngVar]=checkVarForProps(self);
                if Posvar
                    info.ResizeEqual=1;
                    info.EnableMove=0;
                end
                if DimVar
                    info.EnableResize=0;
                end
                if AngVar
                    info.EnableRotate=0;
                end
            else
                [childrenPosvar,childrenDimVar,childrenAngVar]=checkChildrenHaveVariableForProperty(self);
                [Posvar,DimVar,AngVar]=checkVarForProps(self);
                if Posvar||childrenPosvar
                    info.EnableResize=0;
                    info.EnableMove=0;
                    info.EnableRotate=0;
                end
                if DimVar||childrenDimVar
                    info.EnableResize=0;
                end

                if AngVar||childrenAngVar
                    info.EnableRotate=0;
                end
            end
        end


        function mapargs=generateArgsWithValueMap(self)
            props=fields(self.Args);
            for i=1:numel(props)
                if isfield(self.PropertyValueMap,props{i})
                    if~isempty(self.PropertyValueMap.(props{i}))
                        mapargs.(props{i})=self.getExpressionWithoutInputs...
                        (self.PropertyValueMap.(props{i}));
                    else
                        mapargs.(props{i})=self.Args.(props{i});
                    end
                else
                    mapargs.(props{i})=self.Args.(props{i});
                end
            end
        end


        function txt=genScript(self,varargin)

            if~isempty(varargin)
                startString=varargin{1};
                fact=varargin{2};
            else
                startString='';
                fact=1;
            end
            txt='';
            txtfcn=@(x,y)[x,startString,y,newline];
            txt=txtfcn(txt,['%Creating ',self.Name,' shape.']);
            switch self.Type
            case 'Circle'
                txt=txtfcn(txt,[self.Name,' = antenna.Circle;']);
                txt=txtfcn(txt,[self.Name,'.Name = ','"',self.Name,'"',';']);
                txt=txtfcn(txt,[self.Name,'.Radius = ',getPropertyScript(self,'Radius',fact),';']);
                txt=txtfcn(txt,[self.Name,'.Center = ',getPropertyScript(self,'Center',fact),';']);
                txt=txtfcn(txt,[self.Name,' = ','rotate(',self.Name,',',num2str(self.Args.Angle)...
                ,',','[',self.Name,'.Center',',-1]',','...
                ,'[',self.Name,'.Center',',1]',');']);
            case 'Rectangle'
                txt=txtfcn(txt,[self.Name,' = antenna.Rectangle;']);
                txt=txtfcn(txt,[self.Name,'.Name = ','"',self.Name,'"',';']);
                txt=txtfcn(txt,[self.Name,'.Center = ',getPropertyScript(self,'Center',fact),';']);
                txt=txtfcn(txt,[self.Name,'.Length = ',getPropertyScript(self,'Length',fact),';']);
                txt=txtfcn(txt,[self.Name,'.Width = ',getPropertyScript(self,'Width',fact),';']);
                txt=txtfcn(txt,[self.Name,' = ','rotate(',self.Name,',',num2str(self.Args.Angle)...
                ,',','[',self.Name,'.Center',',-1]',','...
                ,'[',self.Name,'.Center',',1]',');']);
            case 'Ellipse'
                txt=txtfcn(txt,[self.Name,' = antenna.Ellipse;']);
                txt=txtfcn(txt,[self.Name,'.Name = ','"',self.Name,'"',';']);
                txt=txtfcn(txt,[self.Name,'.Center = ',getPropertyScript(self,'Center',fact),';']);
                txt=txtfcn(txt,[self.Name,'.MajorAxis = ',getPropertyScript(self,'MajorAxis',fact),';']);
                txt=txtfcn(txt,[self.Name,'.MinorAxis = ',getPropertyScript(self,'MinorAxis',fact),';']);
                txt=txtfcn(txt,[self.Name,' = ','rotate(',self.Name,',',num2str(self.Args.Angle)...
                ,',','[',self.Name,'.Center',',-1]',','...
                ,'[',self.Name,'.Center',',1]',');']);
            case 'Polygon'
                txt=txtfcn(txt,[self.Name,' = antenna.Polygon;']);
                txt=txtfcn(txt,[self.Name,'.Name = ','"',self.Name,'"',';']);
                txt=txtfcn(txt,[self.Name,'.Vertices = ',mat2str(self.Args.Vertices.*fact),';']);
                center=mean(self.Args.Vertices).*fact;
                txt=txtfcn(txt,[self.Name,' = ','rotate(',self.Name,',',num2str(self.Args.Angle)...
                ,',',mat2str([center(1:2),-1]),',',mat2str([center(1:2),1]),');']);
            end


            for i=1:numel(self.Children)
                opn=self.Children(i);
                opnChildren=opn.Children;
                for j=1:numel(opnChildren)

                    txt=[txt,genScript(opnChildren(j),[startString,'    '],fact)];

                    switch opn.Type
                    case 'Add'
                        txt=txtfcn(txt,[self.Name,' = ',self.Name,' + ',opnChildren(j).Name,';%Add']);
                    case 'Subtract'
                        txt=txtfcn(txt,[self.Name,' = ',self.Name,' - ',opnChildren(j).Name,';%Subtract']);
                    case 'Intersect'
                        txt=txtfcn(txt,[self.Name,' = ',self.Name,' & ',opnChildren(j).Name,';%Intersect']);
                    case 'Xor'
                        txt=txtfcn(txt,[self.Name,' = (',self.Name,' + ',opnChildren(j).Name,...
                        ') - (',self.Name,' & ',opnChildren(j).Name,');%Xor']);
                    end
                end

            end

        end


        function scriptval=getPropertyScript(self,propname,fact)
            if~isempty(self.PropertyValueMap.(propname))
                scriptval=['(',getExpressionWithoutInputs(self,self.PropertyValueMap.(propname)),').*',num2str(fact)];
            else
                if strcmpi(propname,'Center')
                    scriptval=mat2str(self.Args.Center.*fact);
                else
                    scriptval=num2str(self.Args.(propname).*fact);
                end
            end
        end


        function obj=copy(self,varargin)
            obj=cad.Polygon(self.Group,self.Id,self.Type);
            obj.InitialArgs=self.InitialArgs;
            obj.Args=self.Args;
            obj.Name=self.Name;
            n=numel(self.Children);
            if~isempty(varargin)
                vm=varargin{1};
                copyPropertyValueMap(self,obj,vm);
            end
            for i=1:numel(self.Children)
                opnObj=copy(self.Children(i),varargin{:});
                addChild(obj,opnObj);
            end

            updateShape(obj);
        end


        function obj=copyNode(self,varargin)
            obj=cad.Polygon(self.Group,self.Id,self.Type);
            obj.InitialArgs=self.InitialArgs;
            obj.Args=self.Args;
            obj.Name=self.Name;
            if~isempty(varargin)
                vm=varargin{1};
                copyPropertyValueMap(self,obj,vm);
            end
            updateShape(obj);
        end


        function validationHandleOut=getDefaultValidation(self,propName)
            switch propName
            case 'Angle'
                validationHandleOut=@(x)validateattributes(x,{'double'},{'nonempty','nonnan','finite','real','nrows',1,'ncols',1});
            case 'Center'
                validationHandleOut=@(x)validateattributes(x,{'double'},{'nonempty','nonnan','finite','real','nrows',1,'ncols',2});
            otherwise
                validationHandleOut=@(x)validateattributes(x,{'double'},{'nonempty','nonnan','finite','real','scalar','nonzero','positive'});
            end
        end


        function assignValueToProperty(self,propname,value,varname)
            opVal=self.getValueOfProperty(propname,value,varname);
            if~isa(opVal,'MException')
                self.Args.(propname)=opVal;
            end

        end

    end


    methods(Static=true,Hidden)
        function self=loadobj(self)
            if isfield(self.PropertyValueMap,'Property')

                if strcmpi(self.Type,'Rectangle')
                    self.PropertyValueMap=struct('Angle',[],'Length',[],'Width',[],'Center',[]);

                elseif strcmpi(self.Type,'Circle')
                    self.PropertyValueMap=struct('Angle',[],'Center',[],'Radius',[]);
                elseif strcmpi(self.Type,'Ellipse')
                    self.PropertyValueMap=struct('Angle',[],'Center',[],'MajorAxis',[],'MinorAxis',[]);

                end
            end
            self.ObjectType=self.Type;
        end
    end


    events
PropertyChanged
    end


end

