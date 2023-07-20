classdef PlatformClassSpecifications<fusion.internal.scenarioApp.dataModel.ClassSpecifications

    methods
        function this=PlatformClassSpecifications()
            this.Name='PlatformClassSpecifications';
            if ispref('TrackingScenarioDesigner',this.Name)
                map=getpref('TrackingScenarioDesigner',this.Name);
                if~isa(map,'containers.Map')
                    map=[];
                end
            else
                map=[];
            end
            if isempty(map)
                map=this.getFactoryClassMap;
            end
            processOpenData(this,map);
        end
    end

    methods(Static)
        function map=getFactoryClassMap()

            map=containers.Map(1,...
            fusion.internal.scenarioApp.dataModel.PlatformClassSpecifications.getNewSpecification('name','Plane','Category','Air',...
            'DefaultSpeed',250,'Length',40,'Width',30,'Height',10,'RCSSignature',rcsSignature('Pattern',20)));
            map(2)=fusion.internal.scenarioApp.dataModel.PlatformClassSpecifications.getNewSpecification('name','Car','Category','Ground',...
            'DefaultSpeed',30,'Length',4.7,'Width',1.8,'Height',1.4,'ZOffset',0.7,'XOffset',-0.6);
            map(3)=fusion.internal.scenarioApp.dataModel.PlatformClassSpecifications.getNewSpecification('name','Tower','Category','Ground',...
            'DefaultSpeed',0,'Length',10,'Width',10,'Height',60,'ZOffset',30);
            map(4)=fusion.internal.scenarioApp.dataModel.PlatformClassSpecifications.getNewSpecification('name','Boat','Category','Maritime',...
            'DefaultSpeed',12,'Length',200,'Width',20,'Height',30,'ZOffset',10);
        end

        function spec=getNewSpecification(varargin)
            rcs=toStruct(rcsSignature);
            ir=toStruct(irSignature);
            ts=toStruct(tsSignature);


            spec=struct(...
            'name',getString(message('fusion:trackingScenarioApp:Component:EditorDefaultNewClassName')),...
            'Category','Ground',...
            'DefaultSpeed',1,...
            'Length',1,...
            'Width',1,...
            'Height',1,...
            'XOffset',0,...
            'YOffset',0,...
            'ZOffset',0,...
            'OrientationAccuracy',[0,0,0],...
            'PositionAccuracy',0,...
            'VelocityAccuracy',0,...
            'RCSSignature',rcs,...
            'IRSignature',ir,...
            'TSSignature',ts);

            if nargin>0
                if isstruct(varargin{1})
                    fields=fieldnames(varargin{1});
                    for indx=1:numel(fields)
                        val=varargin{1}.(fields{indx});
                        if any(strcmp(fields{indx},{'RCSSignature','IRSignature','TSSignature'}))&&...
                            isa(val,'fusion.internal.interfaces.BaseSignature')
                            val=toStruct(val);
                        end
                        spec.(fields{indx})=val;
                    end
                else
                    for indx=1:2:numel(varargin)
                        val=varargin{indx+1};
                        if any(strcmp(varargin{indx},{'RCSSignature','IRSignature','TSSignature'}))&&...
                            isa(val,'fusion.internal.interfaces.BaseSignature')
                            val=toStruct(val);
                        end
                        spec.(varargin{indx})=val;
                    end
                end
            end
        end

    end


end