classdef SessionData<handle




    properties(Access=private)
Data
    end

    methods(Hidden=true)
        function self=SessionData(Data)
            self.Data=Data;
        end

        function data=getData(self)
            data=self.Data;
        end
        function[val,msg]=isequalSessionObj(self,obj2)
            obj1=self.Data;
            if isa(obj2,'em.internal.pcbDesigner.SessionData')
                obj2=getData(obj2);
            end
            props={'LayerIDVal',...
            'ViaIDVal',...
            'ShapeIDVal',...
            'FeedIDVal',...
            'LoadIDVal',...
            'OperationsIDVal',...
            'BoardShape',...
            'Group',...
            'LayerStack',...
            'ShapeStack',...
            'OperationsStack',...
            'FeedStack',...
            'ViaStack',...
            'LoadStack',...
            'ZVal',...
            'Metal',...
            'Grid',...
            'Units',...
            'FeedViaModel',...
            'FeedPhase',...
            'FeedVoltage',...
            'Name',...
            'Mesh',...
            'Plot',...
            'PlotFrequency',...
            'FrequencyRange',...
            };

            if~isa(obj1.FeedDiameter,'function_handle')
                props=[props,{'FeedDiameter'}];
            else
                try
                    val=strcmpi(func2str(obj1.FeedDiameter),func2str(obj2.FeedDiameter));
                catch
                    val=0;
                end
                if~val
                    msg=['Feed Diameter not equal'];
                    return;
                end

            end
            if~isa(obj1.ViaDiameter,'function_handle')
                props=[props,{'ViaDiameter'}];
            else
                try
                    val=strcmpi(func2str(obj1.ViaDiameter),...
                    func2str(obj2.ViaDiameter));
                catch
                    val=0;
                end
                if~val
                    msg=['Via Diameter not equal'];
                    return;
                end
            end
            for i=1:numel(props)
                if any(strcmpi(props{i},{'OperationsStack','LayerStack','ShapeStack','ViaStack','FeedStack','LoadStack'}))
                    val=isequal(numel(obj1.(props{i})),numel(obj2.(props{i})));
                    if~val
                        msg=['Numel ',props{i},' not equal'];
                        return;
                    end
                    if numel(obj1.(props{i}))==numel(obj2.(props{i}))
                        for j=1:numel(obj1.(props{i}))
                            stackobj1=obj1.(props{i})(j);
                            stackobj2=obj1.(props{i})(j);

                            if strcmpi(props{i},'LayerStack')
                                [val,msg]=verifyLayerObj(self,stackobj1,stackobj2);
                            elseif strcmpi(props{i},'ShapeStack')
                                [val,msg]=verifyShapeObj(self,stackobj1,stackobj2);
                            elseif strcmpi(props{i},'FeedStack')
                                [val,msg]=verifyConnObj(self,stackobj1,stackobj2);
                            elseif strcmpi(props{i},'ViaStack')
                                [val,msg]=verifyConnObj(self,stackobj1,stackobj2);
                            elseif strcmpi(props{i},'LoadStack')
                                [val,msg]=verifyConnObj(self,stackobj1,stackobj2);
                            elseif strcmpi(props{i},'OperationsStack')
                                [val,msg]=verifyOperationObj(self,stackobj1,stackobj2);
                            end
                            if~val
                                return;
                            end
                        end
                    end
                elseif any(strcmpi(props{i},{'BoardShape','Group'}))
                    [val,msg]=verifyLayerObj(self,obj1.(props{i}),obj2.(props{i}));
                    if~val
                        return;
                    end
                else

                    val=isequal(obj1.(props{i}),obj2.(props{i}));
                    if~val
                        msg=[props{i},' not equal'];
                        return;
                    end
                end
            end

            if isfield(obj1,'VariablesManager')&&isfield(obj2,'VariablesManager')
                vm1=obj1.VariablesManager;
                vm2=obj2.VariablesManager;
                for i=1:numel(vm1.Variables)
                    [val,msg]=verifyVariables(self,vm1.Variables(1),vm2.Variables(1));
                    if~val
                        return;
                    end
                end
            elseif~isfield(obj1,'VariablesManager')
                val=~isfield(obj2,'VariablesManager');
                if~val
                    val=isempty(obj2.VariablesManager.Variables);
                end
                if~val
                    msg='variablesmanager not equal';
                    return;
                end
            elseif~isfield(obj2,'VariablesManager')
                val=~isfield(obj1,'VariablesManager');
                if~val
                    val=isempty(obj1.VariablesManager.Variables);
                end
                if~val
                    msg='variablesmanager not equal';
                    return;
                end

            end

            msg='passed';
        end

        function[val,msg]=verifyLayerObj(self,obj1,obj2,varargin)
            if isempty(varargin)
                verifyChildObj=1;
            else
                verifyChildObj=varargin{1};
            end

            props={'Color',...
            'Transparency',...
            'Type',...
            'LayerShape',...
            'Name',...
            'MaterialType',...
            'Index',...
            'Overlay',...
            'ZVal',...
            'Feed',...
            'Via',...
            'Load',...
            'DielectricType',...
            'EpsilonR',...
            'LossTangent',...
            'Thickness',...
            'DielectricShape',...
            'ModelListener',...
            'PropertyChangedListener',...
            'CategoryType',...
            'Id',...
            'Parent',...
            'Children',...
            'TriggerUpdate'};
            for i=1:numel(props)
                if any(strcmpi(props{i},{'Feed','Via','Load','Children'}))
                    val=isequal(numel(obj1.(props{i})),numel(obj2.(props{i})));
                    if~val
                        msg=[obj1.Name,' Numel ',props{i},' not equal'];
                        return;
                    end
                    if numel(obj1.(props{i}))==numel(obj2.(props{i}))&&verifyChildObj
                        for j=1:numel(obj1.(props{i}))
                            stackobj1=obj1.(props{i})(j);
                            stackobj2=obj1.(props{i})(j);

                            if strcmpi(props{i},'Children')
                                [val,msg]=verifyShapeObj(self,stackobj1,stackobj2);
                            elseif strcmpi(props{i},'Feed')
                                [val,msg]=verifyConnObj(self,stackobj1,stackobj2);
                            elseif strcmpi(props{i},'Via')
                                [val,msg]=verifyConnObj(self,stackobj1,stackobj2);
                            elseif strcmpi(props{i},'Load')
                                [val,msg]=verifyConnObj(self,stackobj1,stackobj2);
                            end
                            if~val
                                return;
                            end
                        end
                    end
                elseif strcmpi(props{i},'LayerShape')
                    if isempty(obj1.LayerShape)
                        val=isequal(obj1.(props{i}),obj2.(props{i}));
                        msg=['layerShape not equal'];

                    else
                        if strcmpi(obj1.MaterialType,'Dielectric')
                            [val,msg]=verifyLayerObj(self,obj1.(props{i}),obj2.(props{i}),0);
                        else

                            val=isverticesEqual(self,obj1.(props{i}).Vertices,obj2.(props{i}).Vertices);
                            msg=[obj1.Name,' layershape not equal'];
                        end
                    end
                    if~val
                        return;
                    end
                else
                    val=isequal(obj1.(props{i}),obj2.(props{i}));
                    if~val
                        msg=[obj1.Name,' ',props{i},' not equal'];
                        return;
                    end
                end
            end

            [val,msg]=verifyMapObj(self,obj1,obj2,'DependentMap');
            if~val
                return;
            end

            [val,msg]=verifyPropvalueMap(self,obj1,obj2);
            if~val
                return;
            end
        end

        function val=isverticesEqual(self,vert1,vert2)
            val=isequal(vert1(~isnan(vert1(1,:)),:),vert2(~isnan(vert2(1,:)),:));
        end
        function[val,msg]=verifyShapeObj(self,obj1,obj2,varargin)
            if isempty(varargin)
                verifyChildObj=1;
            else
                verifyChildObj=varargin{1};
            end
            props={'DefaultShape',...
            'Type',...
            'CategoryType',...
            'Args',...
            'ResizeEqual',...
            'InitialArgs',...
            'Group',...
            'PropertyChangedListener',...
            'Name',...
            'Operations',...
            'Triangulation',...
            'AntennaShape',...
            'Selected',...
            'ReindexListener',...
            'Id',...
            'Parent',...
            'Children',...
            'TriggerUpdate',...
            };
            for i=1:numel(props)
                if any(strcmpi(props{i},{'Children','Parent','Group'}))
                    val=isequal(numel(obj1.(props{i})),numel(obj2.(props{i})));
                    if~val
                        msg=[obj1.Name,' Numel ',props{i},' not equal'];
                        return;
                    end
                    if numel(obj1.(props{i}))==numel(obj2.(props{i}))&&verifyChildObj
                        for j=1:numel(obj1.(props{i}))
                            stackobj1=obj1.(props{i})(j);
                            stackobj2=obj1.(props{i})(j);

                            if strcmpi(props{i},'Children')
                                [val,msg]=verifyOperationObj(self,stackobj1,stackobj2);
                            elseif any(strcmpi(props{i},{'Group','Parent'}))
                                if strcmpi(obj1.(props{i}).CategoryType,'Layer')
                                    [val,msg]=verifyLayerObj(self,stackobj1,stackobj2,0);
                                else
                                    [val,msg]=verifyOperationObj(self,stackobj1,stackobj2,0);
                                end

                            end
                            if~val
                                return;
                            end
                        end
                    end
                elseif strcmpi(props{i},'AntennaShape')
                    if isempty(obj1.AntennaShape)
                        val=isequal(obj1.AntennaShape,obj2.AntennaShape);
                    else
                        val=isverticesEqual(self,obj1.AntennaShape.Vertices,obj2.AntennaShape.Vertices);
                    end
                    msg=['Antenna SHape not equal'];
                    if~val
                        return;
                    end
                elseif strcmpi(props{i},'DefaultShape')
                    if isempty(obj1.DefaultShape)
                        val=isequal(obj1.DefaultShape,obj2.DefaultShape);
                    else
                        val=isverticesEqual(self,obj1.DefaultShape.Vertices,obj2.DefaultShape.Vertices);
                    end
                    msg=['DefaultShape not equal'];
                    if~val
                        return;
                    end

                elseif strcmpi(props{i},'Triangulation')
                    if isempty(obj1.Triangulation)
                        val=isequal(obj1.Triangulation,obj2.Triangulation);
                    else
                        val=isverticesEqual(self,obj1.Triangulation.Points,obj2.Triangulation.Points);
                    end
                    msg=['Triangulation not equal'];
                    if~val
                        return;
                    end
                else

                    val=isequal(obj1.(props{i}),obj2.(props{i}));
                    if~val
                        msg=[obj1.Name,' ',props{i},' not equal'];
                        return;
                    end
                end
            end
            [val,msg]=verifyMapObj(self,obj1,obj2,'DependentMap');
            if~val
                return;
            end

            [val,msg]=verifyPropvalueMap(self,obj1,obj2);
            if~val
                return;
            end

        end


        function[val,msg]=verifyOperationObj(self,obj1,obj2,varargin)
            if isempty(varargin)
                verifyChildObj=1;
            else
                verifyChildObj=varargin{1};
            end
            props={'Name',...
            'Index',...
            'Type',...
            'Children',...
            'Parent',...
            'CategoryType'};


            for i=1:numel(props)
                if any(strcmpi(props{i},{'Children','Parent'}))
                    val=isequal(numel(obj1.(props{i})),numel(obj2.(props{i})));
                    if~val
                        msg=[obj1.Name,' Numel ',props{i},' not equal'];
                        return;
                    end
                    if numel(obj1.(props{i}))==numel(obj2.(props{i}))&&verifyChildObj
                        for j=1:numel(obj1.(props{i}))
                            stackobj1=obj1.(props{i})(j);
                            stackobj2=obj1.(props{i})(j);

                            if strcmpi(props{i},'Children')
                                [val,msg]=verifyShapeObj(self,stackobj1,stackobj2);
                            elseif any(strcmpi(props{i},{'Parent'}))
                                [val,msg]=verifyShapeObj(self,stackobj1,stackobj2,0);


                            end
                            if~val
                                return;
                            end
                        end
                    end
                else

                    val=isequal(obj1.(props{i}),obj2.(props{i}));
                    msg=[obj1.Name,' ',props{i},' not equal'];

                    if~val
                        return;
                    end
                end
            end

        end

        function[val,msg]=verifyConnObj(self,obj1,obj2,varargin)
            if isempty(varargin)
                verifyChildObj=1;
            else
                verifyChildObj=varargin{1};
            end
            props={'StartLayer',...
            'StopLayer',...
            'Center',...
            'Diameter',...
            'Name',...
            'Type',...
            'PropertyChangedListener',...
            'Impedance',...
            'Frequency',...
            'FeedVoltage',...
            'FeedPhase',...
            'CategoryType',...
            'Id',...
            'Parent',...
            'Children',...
            'TriggerUpdate',...
            };

            for i=1:numel(props)
                if any(strcmpi(props{i},{'StartLayer','StopLayer'}))
                    if verifyChildObj
                        stackobj1=obj1.(props{i});
                        stackobj2=obj2.(props{i});
                        [val,msg]=verifyLayerObj(self,stackobj1,stackobj2,0);
                    end
                    if~val
                        return;
                    end
                else

                    val=isequal(obj1.(props{i}),obj2.(props{i}));
                    if~val
                        msg=[obj1.Name,' ',props{i},' not equal'];
                        return;
                    end
                end
            end
            [val,msg]=verifyMapObj(self,obj1,obj2,'DependentMap');
            if~val
                return;
            end

            [val,msg]=verifyPropvalueMap(self,obj1,obj2);
            if~val
                return;
            end
        end

        function[val,msg]=verifyMapObj(self,obj1,obj2,prop)
            if strcmpi(prop,'DependentMap')
                mapStack1=obj1.DependentMap;
                mapStack2=obj2.DependentMap;
            else
                mapStack1=obj1.VariableMap;
                mapStack2=obj2.VariableMap;
            end

            val=isequal(numel(mapStack1),numel(mapStack2));
            if~val
                msg=[obj1.Name,' doesnot have equal ',prop];
                return
            end

            for i=1:numel(mapStack1)
                firstObj=mapStack1(i);
                secondObj=mapStack2(i);
                val1=isequal(firstObj.Variable.Name,secondObj.Variable.Name);
                val2=isequal(firstObj.PropertyName,secondObj.PropertyName);
                val3=isequal(firstObj.DependentObject.Name,secondObj.DependentObject.Name);

                val=val1&val2&val3;
                if~val
                    msg=[obj1.Name,' doesnot have equal mapObj for property ',secondObj.PropertyName];
                    return;
                end
            end
            msg='passed';
        end

        function[val,msg]=verifyVariables(self,obj1,obj2)
            if isa(obj1.Value,'function_handle')
                val=strcmpi(func2str(obj1.Value),func2str(obj2.Value));
            else
                val=isequal(obj1.Value,obj2.Value);
            end
            if~val
                msg=['variable ',obj1.Name,' not equal.'];
                return;
            end

            [val,msg]=verifyMapObj(self,obj1,obj2,'VariableMap');
            if~val
                return;
            end

            [val,msg]=verifyMapObj(self,obj1,obj2,'DependentMap');
            if~val
                return;
            end
            msg='passed';
        end

        function[val,msg]=verifyPropvalueMap(self,obj1,obj2)
            mapStack1=obj1.PropertyValueMap;
            mapStack2=obj2.PropertyValueMap;
            f=fields(mapStack1);
            for i=1:numel(f)
                if isempty(mapStack1.(f{i}))
                    val=isempty(mapStack2.(f{i}));

                else
                    val=strcmpi(func2str(mapStack1.(f{i})),func2str(mapStack2.(f{i})));
                end
                if~val
                    msg=[obj1.Name,'propertyValueMap not equal'];
                    return;
                end
            end
            msg='passed';
        end



    end
end
