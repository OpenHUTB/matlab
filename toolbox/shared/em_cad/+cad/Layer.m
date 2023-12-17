classdef Layer<cad.TreeNode&cad.DependentObject

    properties
        Color=[0,0,1]
        Transparency=0.2;
        Type='Layer';
Model
LayerShape
Name
        MaterialType='Metal';
        Index;
        Overlay=0;
ZVal

Feed
Via
Load

        DielectricType='Air';
        EpsilonR=1
        LossTangent=0
        Thickness=0.60
DielectricShape

ModelListener

PropertyChangedListener

        CategoryType='Layer';
    end


    methods
        function self=Layer(Model,Color,Transparency,Id,varargin)

            self.Model=Model;
            self.Color=Color;
            self.Transparency=Transparency;
            self.Id=Id;
            self.Overlay=0;
            if~isempty(varargin)
                self.Name=varargin{1};
            else
                self.Name=[self.Type,num2str(self.Id)];
            end

            self.PropertyValueMap=struct('EpsilonR',[],'LossTangent',[],'Thickness',[]);


            self.ObjectType=self.Type;
        end


        function set.Color(self,val)

            self.Color=val;
            self.notify('PropertyChanged');
        end


        function set.Transparency(self,val)

            self.Transparency=val;
            self.notify('PropertyChanged');
        end


        function set.Overlay(self,val)

            self.Overlay=val;
            self.notify('PropertyChanged');
        end


        function set.Name(self,val)

            self.Name=val;
            self.notify('PropertyChanged');
        end


        function addShape(self,shapeObj)
            if isempty(self.LayerShape)
                self.LayerShape=shapeObj.AntennaShape;
            else
                self.LayerShape=self.LayerShape+shapeObj.AntennaShape;
            end
            addChild(self,shapeObj);
            self.notify('Updated');
        end


        function self=childUpdated(self,child)
            sout=[];
            for i=1:numel(self.Children)
                if isempty(sout)
                    sout=self.Children(i).AntennaShape;
                else
                    sout=sout+self.Children(i).AntennaShape;
                end
            end
            self.LayerShape=sout;
            self.notify('Updated');

        end


        function childrenChanged(self)
            childUpdated(self,0);
        end


        function addFeed(self,feedobj)

            if isempty(self.Feed)
                self.Feed=feedobj;
                self.notify('Updated');
                return;
            end
            ids=[self.Feed.Id];
            if~any(ids==feedobj.Id)
                self.Feed=[self.Feed,feedobj];
            end
            self.notify('Updated');
        end


        function removeFeed(self,feedobj)

            if isempty(self.Feed)
                self.notify('Updated');
                return;
            end

            ids=[self.Feed.Id];
            idx=ids==feedobj.Id;
            if any(idx)
                self.Feed(idx)=[];
            end
            self.notify('Updated');
        end


        function addVia(self,viaobj)
            if isempty(self.Via)
                self.Via=viaobj;
                self.notify('Updated');
                return;
            end
            ids=[self.Via.Id];
            if~any(ids==viaobj.Id)
                self.Via=[self.Via,viaobj];
            end
            self.notify('Updated');
        end


        function removeVia(self,viaobj)
            if isempty(self.Via)
                self.notify('Updated');
                return;
            end
            ids=[self.Via.Id];
            idx=ids==viaobj.Id;
            if any(idx)
                self.Via(idx)=[];
            end
            self.notify('Updated');
        end


        function addLoad(self,loadobj)
            if isempty(self.Load)
                self.Load=loadobj;
                self.notify('Updated');
                return;
            end
            ids=[self.Load.Id];
            if~any(ids==loadobj.Id)
                self.Load=[self.Load,loadobj];
            end
            self.notify('Updated');
        end


        function removeLoad(self,loadobj)
            if isempty(self.Load)
                self.notify('Updated');
                return;
            end
            ids=[self.Load.Id];
            idx=ids==loadobj.Id;
            if any(idx)
                self.Load(idx)=[];
            end
            self.notify('Updated');
        end


        function info=getInfo(self)
            info=getInfo@cad.TreeNode(self);
            info.CategoryType='Layer';

            info.Color=self.Color;
            info.Transparency=self.Transparency;
            info.Type=self.Type;
            info.Name=self.Name;
            info.MaterialType=self.MaterialType;
            info.Index=self.Index;
            info.Overlay=self.Overlay;

            if strcmpi(self.MaterialType,'Dielectric')
                info.Args.Type='Dielectric';
                info.Args.Color=self.Color;
                info.Args.Transparency=self.Transparency;
                info.Args.Overlay=self.Overlay;
                info.Args.DielectricType=self.DielectricType;

                if isempty(self.PropertyValueMap.EpsilonR)
                    info.Args.EpsilonR=self.EpsilonR;
                else
                    info.Args.EpsilonR=getExpressionWithoutInputs(self,self.PropertyValueMap.EpsilonR);
                end
                if isempty(self.PropertyValueMap.LossTangent)
                    info.Args.LossTangent=self.LossTangent;
                else
                    info.Args.LossTangent=getExpressionWithoutInputs(self,self.PropertyValueMap.LossTangent);
                end
                if isempty(self.PropertyValueMap.Thickness)
                    info.Args.Thickness=self.Thickness;
                else
                    info.Args.Thickness=getExpressionWithoutInputs(self,self.PropertyValueMap.Thickness);
                end
            else
                info.Args.Type='Metal';
                info.Args.Color=self.Color;
                info.Args.Transparency=self.Transparency;
                info.Args.Overlay=self.Overlay;
            end
            info.PropertyValueMap=self.PropertyValueMap;
            info.LayerShape=self.LayerShape;

            info.ZVal=self.ZVal;
            info.NumChildren=numel(self.Children);
        end


        function info=getLayerInfo(self)

            info=getInfo(self);
            info.CategoryType='Layer';
            info.ChildrenInfo={};
            for i=1:numel(self.Children)
                info.ChildrenInfo{i}=getInfo(self.Children(i));
            end
            info.FeedInfo={};
            for i=1:numel(self.Feed)
                info.FeedInfo{i}=getInfo(self.Feed(i));
            end
            info.ViaInfo={};
            for i=1:numel(self.Via)
                info.ViaInfo{i}=getInfo(self.Via(i));
            end

            info.LoadInfo={};
            for i=1:numel(self.Load)
                info.LoadInfo{i}=getInfo(self.Load(i));
            end

            if strcmpi(self.MaterialType,'Dielectric')
                info.Args.Type='Dielectric';
                info.Args.Color=self.Color;
                info.Args.Transparency=self.Transparency;
                info.Args.Overlay=self.Overlay;
                info.Args.DielectricType=self.DielectricType;
                if isempty(self.PropertyValueMap.EpsilonR)
                    info.Args.EpsilonR=self.EpsilonR;
                else
                    info.Args.EpsilonR=getExpressionWithoutInputs(self,self.PropertyValueMap.EpsilonR);
                end
                if isempty(self.PropertyValueMap.LossTangent)
                    info.Args.LossTangent=self.LossTangent;
                else
                    info.Args.LossTangent=getExpressionWithoutInputs(self,self.PropertyValueMap.LossTangent);
                end
                if isempty(self.PropertyValueMap.Thickness)
                    info.Args.Thickness=self.Thickness;
                else
                    info.Args.Thickness=getExpressionWithoutInputs(self,self.PropertyValueMap.Thickness);
                end
            else
                info.Args.Type='Metal';
                info.Args.Color=self.Color;
                info.Args.Transparency=self.Transparency;
                info.Args.Overlay=self.Overlay;
            end

            info.PropertyValueMap=self.PropertyValueMap;
            info.DielectricShape=self.DielectricShape;
            info.ZVal=self.ZVal;
            info.LayerShape=self.LayerShape;
        end


        function deleteListeners(self)

            deleteListeners@cad.TreeNode(self);

        end


        function obj=copy(self,varargin)
            obj=cad.Layer(self.Model,self.Color,self.Transparency,self.Id,self.Name);

            obj.Name=self.Name;
            obj.MaterialType=self.MaterialType;
            obj.Index=self.Index;
            obj.Overlay=self.Overlay;
            obj.ZVal=self.ZVal;
            obj.DielectricType=self.DielectricType;
            obj.EpsilonR=self.EpsilonR;
            obj.LossTangent=self.LossTangent;
            obj.Thickness=self.Thickness;
            obj.DielectricShape=self.DielectricShape;
            n=numel(self.Children);

            if~isempty(varargin)
                vm=varargin{1};
                self.copyPropertyValueMap(obj,vm);
            end

            for i=1:n
                childobj=self.Children(i);
                childobj=copy(childobj,varargin{:});
                addShape(obj,childobj);
                addGroupToChildren(obj,childobj);
            end

        end


        function addGroupToChildren(self,obj)
            childrenShapes=getChildrenShapes(obj);
            for i=1:numel(childrenShapes)
                addGroupToChildren(self,childrenShapes(i))
            end
            obj.Group=self;
        end


        function d=createDielectric(self)

            d=dielectric;
            d.Name=self.DielectricType;
            d.EpsilonR=self.EpsilonR;
            d.LossTangent=self.LossTangent;
            d.Thickness=self.Thickness;
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

            if strcmpi(self.MaterialType,'Dielectric')

                txt=txtfcn(txt,['%Creating ',self.Name,' dielectric layer.']);
                txt=txtfcn(txt,[self.Name,' = dielectric("Name",''',self.DielectricType...
                ,''',"EpsilonR",',getPropertyScript(self,'EpsilonR',1),',"LossTangent",'...
                ,getPropertyScript(self,'LossTangent',1)...
                ,',"Thickness",',getPropertyScript(self,'Thickness',fact),');']);
            else

                txt=txtfcn(txt,['%Creating ',self.Name,' metal layer.']);
                addstring='';
                for i=1:numel(self.Children)

                    txt=[txt,genScript(self.Children(i),[startString,'    '],fact)];
                    if isempty(addstring)
                        addstring=self.Children(i).Name;
                    else
                        addstring=[addstring,' + ',self.Children(i).Name];
                    end
                end
                if strcmpi(self.Name,'BoardShape')
                    txt=txtfcn(txt,['BoardShape = ',addstring,';']);
                else
                    txt=txtfcn(txt,[self.Name,' = ',addstring,';']);
                end
            end

        end


        function scriptval=getPropertyScript(self,propname,fact)
            if~isempty(self.PropertyValueMap.(propname))
                if strcmpi(propname,'Thickness')
                    scriptval=['(',getExpressionWithoutInputs(self,self.PropertyValueMap.(propname)),').*',num2str(fact)];
                else
                    scriptval=getExpressionWithoutInputs(self,self.PropertyValueMap.(propname));
                end
            else
                if any(strcmpi(propname,{'LossTangent','EpsilonR'}))
                    scriptval=num2str(self.(propname));
                else
                    scriptval=num2str(self.(propname).*fact);
                end
            end
        end



        function validationHandleOut=getDefaultValidation(self,propName)
            switch propName
            case 'LossTangent'
                validationHandleOut=@(x)validateattributes(x,{'numeric'},{'nonempty','real','finite','nonnan','nonnegative','<=',0.03});
            otherwise
                validationHandleOut=@(x)validateattributes(x,{'double'},{'nonempty','nonnan','finite','real','scalar','nonzero','positive'});
            end
        end


        function assignValueToProperty(self,propname,value,varname)
            valueOp=getValueOfProperty(self,propname,value,varname);
            if~isa(valueOp,'MException')
                self.(propname)=valueOp;
            end
        end

    end


    methods(Static=true,Hidden)
        function r=loadobj(obj)
            r=obj;
            if isfield(obj.PropertyValueMap,'Property')
                r.PropertyValueMap=struct('EpsilonR',[],'LossTangent',[],'Thickness',[]);
            end
            r.ObjectType=obj.MaterialType;
        end
    end

    events
PropertyChanged

    end
end

