classdef Connection<cad.TreeNode&cad.DependentObject




    properties
        StartLayer=[];
        StopLayer=[];
Center
Diameter
Name
        Type=[];
PropertyChangedListener
        Impedance=[]
        Frequency=[]
        FeedVoltage=1;
        FeedPhase=0;
        CategoryType='Connection';
    end

    methods
        function self=Connection(Type,Layer,Id,center,width)
            self.StartLayer=Layer;
            self.StopLayer=Layer;
            self.Id=Id;
            self.Center=center;
            self.Diameter=width;
            self.Type=Type;
            self.Name=[Type,num2str(Id)];


            if strcmpi(Type,'Feed')
                self.PropertyValueMap=struct('FeedPhase',[],'FeedVoltage',[],'Center',[]);
            elseif strcmpi(Type,'Load')
                self.PropertyValueMap=struct('Impedance',[],'Frequency',[],'Center',[]);
            elseif strcmpi(Type,'Via')
                self.PropertyValueMap=struct('Center',[]);
            end


            self.ObjectType=self.Type;

        end


        function gid=getGroupId(self)
            if isempty(self.StartLayer)
                startid=NaN;
            else
                startid=self.StartLayer.Id;
            end

            if isempty(self.StopLayer)
                stopid=NaN;
            else
                stopid=self.StopLayer.Id;
            end

            gid=[startid,stopid];
        end

        function set.Diameter(self,val)
            self.Diameter=val;
            self.notify('PropertyChanged');
        end

        function set.FeedVoltage(self,val)
            self.FeedVoltage=val;
            self.notify('PropertyChanged');
        end
        function set.FeedPhase(self,val)
            self.FeedPhase=val;
            self.notify('PropertyChanged');
        end
        function set.Impedance(self,val)
            self.Impedance=val;
            self.notify('PropertyChanged');
        end
        function set.Frequency(self,val)
            self.Frequency=val;
            self.notify('PropertyChanged');
        end

        function updateLayers(self)
            updateStartLayer(self)
            if isempty(self.StartLayer)||isempty(self.StopLayer)
                return;
            end
            if self.StopLayer.Id~=self.StartLayer.Id
                updateStopLayer(self)
            end
        end

        function deleteListeners(self)
            self.deleteListeners@cad.TreeNode();



        end

        function updateStartLayer(self)
            if~isempty(self.StartLayer)
                self.StartLayer.notify('Updated');
            end
        end

        function updateStopLayer(self)
            if~isempty(self.StopLayer)
                self.StopLayer.notify('Updated');
            end
        end

        function set.Center(self,val)
            self.Center=val;
            updateLayers(self);
            self.notify('PropertyChanged');

        end

        function set.StartLayer(self,val)

            self.StartLayer=val;
            self.notify('PropertyChanged');

        end

        function set.StopLayer(self,val)

            self.StopLayer=val;
            self.notify('PropertyChanged');

        end

        function set.Name(self,val)

            self.Name=val;
            self.notify('PropertyChanged');

        end

        function info=getInfo(self)
            info=getInfo@cad.TreeNode(self);
            info.Id=self.Id;
            infoSL=getInfo(self.StartLayer);
            args.StartLayer=infoSL;
            infoStopL=getInfo(self.StopLayer);
            args.StopLayer=infoStopL;

            args.Center=self.Center;
            args.Diameter=self.Diameter;
            info.Args=args;
            info.Name=self.Name;
            info.Type=self.Type;
            info.CategoryType=self.Type;
            r=self.Diameter/2;
            center=self.Center;
            theta=linspace(0,2*pi,29);
            vert=[cos(theta').*r,sin(theta').*r];
            vert=vert+center;



            info.ShapeObj=struct('Vertices',[vert,zeros(size(vert,1),1)]);
            info.GroupInfo.Id=[];
            if strcmpi(self.Type,'Feed')
                info.GroupInfo.Color=[1,0,0];
                if isempty(self.PropertyValueMap.FeedVoltage)
                    info.Args.FeedVoltage=self.FeedVoltage;
                else
                    info.Args.FeedVoltage=getExpressionWithoutInputs(self,self.PropertyValueMap.FeedVoltage);
                end
                if isempty(self.PropertyValueMap.FeedPhase)
                    info.Args.FeedPhase=self.FeedPhase;
                else
                    info.Args.FeedPhase=getExpressionWithoutInputs(self,self.PropertyValueMap.FeedPhase);
                end
            elseif strcmpi(self.Type,'Via')
                info.GroupInfo.Color=[0,1,0];
            elseif strcmpi(self.Type,'Load')
                info.GroupInfo.Color=[0,0,1];
                if isempty(self.PropertyValueMap.Impedance)
                    info.Args.Impedance=self.Impedance;
                else
                    info.Args.Impedance=getExpressionWithoutInputs(self,self.PropertyValueMap.Impedance);
                end
                if isempty(self.PropertyValueMap.Frequency)
                    info.Args.Frequency=self.Frequency;
                else
                    info.Args.Frequency=getExpressionWithoutInputs(self,self.PropertyValueMap.Frequency);
                end
            end

            if~isempty(self.PropertyValueMap.Center)
                info.Args.Center=getExpressionWithoutInputs(self,self.PropertyValueMap.Center);
            end
            info.PropertyValueMap=self.PropertyValueMap;

            if isfield(self.PropertyValueMap,'Center')&&~isempty(info.PropertyValueMap.Center)
                info.EnableMove=0;
            else
                info.EnableMove=1;
            end

            if~isempty(self.StartLayer.Model)&&~isempty(self.StartLayer.Model.VarProperties)
                model=self.StartLayer.Model;
                if strcmpi(self.Type,'Via')
                    if isfield(model.VarProperties.PropertyValueMap,'ViaDiameter')&&...
                        ~isempty(model.VarProperties.PropertyValueMap.ViaDiameter)
                        info.EnableResize=0;
                        info.Args.Diameter=getExpressionWithoutInputs(self,model.VarProperties.PropertyValueMap.ViaDiameter);
                    else
                        info.EnableResize=1;
                    end
                else
                    if isfield(model.VarProperties.PropertyValueMap,'FeedDiameter')&&...
                        ~isempty(model.VarProperties.PropertyValueMap.FeedDiameter)
                        info.EnableResize=0;
                        if~strcmpi(self.Type,'Load')
                            info.Args.Diameter=getExpressionWithoutInputs(self,model.VarProperties.PropertyValueMap.FeedDiameter);
                        end
                    else
                        info.EnableResize=1;
                    end
                end
            else
                info.EnableResize=1;
            end



            info.GroupInfo.Transparency=1;
            info.ParentType='Layer';
            info.ParentId=self.StartLayer.Id;
            info.ResizeEqual=1;
        end

        function scriptval=getPropertyScript(self,propname,fact)
            if~isempty(self.PropertyValueMap.(propname))
                if strcmpi(propname,'Center')
                    scriptval=['(',getExpressionWithoutInputs(self,self.PropertyValueMap.(propname)),').*',num2str(fact)];
                else
                    scriptval=getExpressionWithoutInputs(self,self.PropertyValueMap.(propname));
                end
            else





                if strcmpi(self.Type,'Load')&&strcmpi(propname,'Center')
                    scriptval=mat2str([self.Center,self.StartLayer.ZVal].*fact);
                else
                    scriptval=mat2str(self.(propname));
                end
            end
        end

        function centerval=getCenterval(self)
            if~isempty(self.PropertyValueMap.Center)
                centerval=getExpressionWithoutInputs(self,self.PropertyValueMap.Center);
            else
                centerval=self.Center;
            end
        end

        function obj=copy(self,varargin)
            obj=em.internal.pcbDesigner.Connection(self.Type,[],self.Id,self.Center,self.Diameter);
            obj.Name=self.Name;
            if~isempty(varargin)
                vm=varargin{1};
                self.copyPropertyValueMap(obj,vm);
            end
        end

        function loadobj=createLoadObj(self)
            loadobj=lumpedElement;
            loadobj.Impedance=self.Impedance;
            loadobj.Frequency=self.Frequency;
            loadobj.Location=[self.Center,self.StartLayer.ZVal];
        end




        function validationHandleOut=getDefaultValidation(self,propName)
            switch propName
            case 'Center'
                validationHandleOut=@(x)validateattributes(x,{'double'},{'nonempty','nonnan','finite','real','nrows',1,'ncols',2});
            case 'FeedPhase'
                validationHandleOut=@(x)validateattributes(x,{'double'},{'nonempty','nonnan','finite','real','scalar'});
            case 'FeedVoltage'
                validationHandleOut=@(x)validateattributes(x,{'double'},{'nonempty','nonnan','finite','real','scalar','positive'});
            case 'Frequency'
                validationHandleOut=@(x)frequencyValidationFcn(self,x);
            case 'Impedance'
                validationHandleOut=@(x)impedanceValidationFcn(self,x);
            otherwise
                validationHandleOut=@(x)validateattributes(x,{'double'},{'nonempty','nonnan','finite','real','scalar','nonzero','positive'});
            end
        end

        function impedanceValidationFcn(self,propVal)
            if~isempty(propVal)
                validateattributes(propVal,{'numeric'},...
                {'finite','nonnan'});
                validateattributes(real(propVal),{'numeric'},...
                {'real','finite','nonnan','nonnegative'});
            end
        end
        function frequencyValidationFcn(self,propVal)
            if~isempty(propVal)
                validateattributes(propVal,{'numeric'},...
                {'real','finite','nonnan','positive'});
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













        function self=loadobj(self)
            if isfield(self.PropertyValueMap,'Property')
                if strcmpi(self.Type,'Feed')
                    self.PropertyValueMap=struct('FeedPhase',[],'FeedVoltage',[],'Center',[]);
                elseif strcmpi(self.Type,'Load')
                    self.PropertyValueMap=struct('Impedance',[],'Frequency',[],'Center',[]);
                elseif strcmpi(self.Type,'Via')
                    self.PropertyValueMap=struct('Center',[]);
                end
            end

            self.ObjectType=self.Type;
        end
    end

    events
PropertyChanged
    end
end
