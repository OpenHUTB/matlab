classdef Block<ee.internal.loadflow.Super




    properties(Abstract)
BlockType
ComponentPath
    end

    properties
        Model=[];
    end

    properties(Dependent,Access=protected)
DisplayName
    end

    methods
        function obj=Block(varargin)

            if isa(varargin{1},'ee.internal.loadflow.Model')
                model=varargin{1};
            else

                model=ee.internal.loadflow.Model(bdroot(varargin{1}));
            end
            switch nargin
            case 1

                blockPath=model.Name;
            case 2
                blockPath=varargin{2};
            otherwise
            end

            obj.Model=model;
            if strcmp('block_diagram',get_param(blockPath,'Type'))


                switch class(obj.ComponentPath)
                case 'char'
                    componentPathCell={obj.ComponentPath};
                case 'cell'
                    componentPathCell=obj.ComponentPath;
                end
                blocks={};

                for componentPathIdx=1:length(componentPathCell)
                    thisComponentPath=componentPathCell{componentPathIdx};
                    blocks=vertcat(blocks,find_system(blockPath,obj.FindArgs{:},...
                    'ComponentPath',thisComponentPath));%#ok<AGROW>
                end
                for blockindex=1:length(blocks)
                    thisBlock=blocks{blockindex};

                    if~model.BlockFactoryMap.isKey(thisBlock)
                        model.BlockFactoryMap(thisBlock)=ee.internal.loadflow.BlockFactory(obj,model,thisBlock);
                    end
                    obj(blockindex,1)=model.BlockFactoryMap(thisBlock);%#ok<AGROW>
                end
                if isempty(blocks)
                    obj=ee.internal.loadflow.EmptyBlockFactory(obj);
                end
            else
                obj.Name=blockPath;
            end
        end

        function disp(obj)
            if length(obj)==1
                disp@ee.internal.loadflow.Super(obj);
            else
                for objectindex=1:length(obj)
                    thisObject=obj(objectindex);
                    fprintf('%s %i: %s\n',thisObject.BlockType,objectindex,thisObject.DisplayName);
                end
                fprintf('\n');
            end
        end

        function value=get.DisplayName(obj)
            value=strrep(obj.Name,newline,' ');
        end

        function value=getAttachedBusbarValue(obj,thisPortType,valueRequired)
            [busbar,busbarPortIdx]=obj.getBusbar(thisPortType);
            switch lower(valueRequired)
            case 'name'
                if~isempty(busbar)
                    value=busbar(1).Name;
                else
                    value='';
                end
            case 'ratedvoltage'
                if~isempty(busbar)
                    value=busbar(1).RatedVoltage;
                else
                    value=nan;
                end
            case 'reactivepower'
                if~isempty(busbar)
                    powerFlows=busbar.getReactivePowerFlows;
                    if~any(isnan(powerFlows),'all')
                        value=0;
                        for busbarIdx=1:size(powerFlows,1)
                            value=value+powerFlows(busbarIdx,busbarPortIdx(busbarIdx));
                        end
                    else
                        value=nan;
                    end
                else
                    value=nan;
                end
            case 'realpower'
                if~isempty(busbar)
                    powerFlows=busbar.getRealPowerFlows;
                    if~any(isnan(powerFlows),'all')
                        value=0;
                        for busbarIdx=1:size(powerFlows,1)
                            value=value+powerFlows(busbarIdx,busbarPortIdx(busbarIdx));
                        end
                    else
                        value=nan;
                    end
                else
                    value=nan;
                end
            case 'voltageangle'
                if~isempty(busbar)
                    value=busbar.VoltageAngle;
                else
                    value=nan;
                end
            case 'voltagemagnitude'
                if~isempty(busbar)
                    value=busbar.VoltageMagnitude;
                else
                    value=nan;
                end
            otherwise
                error(message('physmod:ee:loadflow:UnrecognizedRequiredValue'));
            end
        end

        function[busbar,busbarPortNumber]=getBusbar(obj,portType)


            connectedBlocks=ee.internal.graph.findConnectedPhysicalBlocks(obj.Name,portType);


            allBusbars={obj.Model.Busbar.Name};


            [~,~,busbarIndex]=intersect(connectedBlocks,allBusbars);


            if isempty(busbarIndex)
                busbar=ee.internal.loadflow.Busbar.empty;
            else
                busbar=obj.Model.Busbar(busbarIndex);
            end

            if nargout==2
                if isempty(busbar)
                    busbarPortNumber=[];
                else
                    busbarPortNumber=busbar.findPortNumber(obj.Name);
                end
            end
        end

        function value=getSimulationData(obj)
            value=obj.Model.SimulationData.getSimulationData(obj.Name);
        end

        function value=getSimulationDataAtTime(obj,variablename,variableunit,varargin)
            value=obj.Model.SimulationData.getSimulationDataAtTime(obj.Name,...
            obj.Model.SimulationTime,...
            variablename,...
            variableunit,...
            varargin{:});
        end

        function value=getValue(obj,parameterName,requiredUnit)
            import ee.internal.mask.getValue;
            if obj.isVisible(parameterName)
                try
                    value=getValue(obj.Name,parameterName,requiredUnit);
                catch err

                    if strcmp('physmod:ee:library:MaskParameterUnitNotCommensurate',err.identifier)
                        rethrow(err);
                    else
                        value=nan;
                    end
                end
            else
                value=nan;
            end
        end

        function tf=isVisible(obj,parameterName)
            maskNames=get_param(obj.Name,'MaskNames');
            idx=strcmp(parameterName,maskNames);
            if~any(idx)
                tf=false;
                return
            end
            maskVisibilities=get_param(obj.Name,'MaskVisibilities');
            switch maskVisibilities{idx}
            case 'on'
                tf=true;
            case 'off'
                tf=false;
            otherwise
                error(message('physmod:ee:loadflow:UnrecognizedVisibilityValue'));
            end
        end

        function setLocalLogging(obj,tf)
            for objectindex=1:length(obj)
                thisObject=obj(objectindex);
                switch tf
                case true
                    set_param(thisObject.Name,'LogSimulationData','on');
                case false
                    set_param(thisObject.Name,'LogSimulationData','off');
                otherwise
                    error(message('physmod:ee:loadflow:UnrecognizedLogSimulationDataValue'));
                end
            end
        end

        function setValue(obj,parameterName,parameterValue,parameterUnit)
            import ee.internal.mask.setValue;
            if isnumeric(parameterValue)
                parameterValue=sprintf('%g',parameterValue);
            end
            setValue(obj.Name,parameterName,parameterValue,parameterUnit);
            if~obj.isVisible(parameterName)
                warning('physmod:ee:loadflow:SetValueHasNoEffect',getString(message('physmod:ee:loadflow:SetValueHasNoEffect',parameterName)));
            end
        end
    end
end

