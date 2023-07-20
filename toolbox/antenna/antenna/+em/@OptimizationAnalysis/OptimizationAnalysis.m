classdef OptimizationAnalysis<handle

    properties(Access=private)
        OptimStruct=struct('CenterFrequency',[],...
        'ObjectiveFunction',[],...
        'ObjectiveUnits',[],...
        'NoOfObjectives',1,...
        'PropertyNames',[],...
        'LowerBounds',[],...
        'UpperBounds',[],...
        'SubObjects',[],...
        'PairedProps',[],...
        'PlotConstraintNo',[],...
        'Weights',[],...
        'ConstraintsFunction',[],...
        'ConstraintsFunctionName',[],...
        'ConstraintsUnits',[],...
        'Operator',[],...
        'Value',[],...
        'NoOfConstraints',0,...
        'Angles',[0,0;90,-90],...
        'EnableCoupling',true,...
        'EnableLog',false,...
        'ReferenceImpedance',50,...
        'FrequencyRange',[],...
        'Bandwidth',[],...
        'MainLobeDirection',[0,90],...
        'Optimizer','sadea',...
        'PlotType','convergence',...
        'Iterations',200,...
        'UseParallel',false,...
        'Samples',30,...
        'SadeaSettings',[],...
        'OptimOptions',[],...
        'CurrentIteration',struct('Iteration',0,...
        'ObjectiveValue',0,...
        'ConstraintValue',0,...
        'ConstraintName','',...
        'DesignValues',[]),...
        'Figure',[],...
        'ResultsPlots',struct(...
        'BuildingObjectiveValues',[],...
        'BuildingIterationsStack',[],...
        'RunningObjectiveValues',[],...
        'RunningConstraintValues',[],...
        'RunningIterationsStack',[],...
        'RunType','Building',...
        'Panel',[],...
        'Layout',[],...
        'StatusLayout',[],...
        'ResultsLayout',[],...
        'ObjectiveLayout',[],...
        'DesignVectorLayout',[],...
        'StatusPanel',[],...
        'ResultsPanel',[],...
        'ObjectivePanel',[],...
        'DesignVectorPanel',[],...
        'EmptyPanel1',[],...
        'EmptyPanel2',[],...
        'ObjectiveTable',[],...
        'DesignVectorTable',[],...
        'objectiveSampleAxes',[],...
        'objectiveSampleAxesToolbar',[],...
        'objectiveIterationAxes',[],...
        'objectiveIterationAxesToolbar',[],...
        'constraintAxes',[],...
        'constraintAxesToolbar',[],...
        'objectiveFunctionLabel',[],...
        'objectiveFunctionValue',[],...
        'designVectorLabel',[],...
        'designVectorValue',[],...
        'iterationLabel',[],...
        'iterationValue',[],...
        'erformanceVectorLabel',[],...
        'erformanceVectorValue',[],...
        'OptimizedMainObject',[],...
        'DesignVector',[],...
        'DesignValuesStack',[],...
        'PerformanceVector',[]),...
        'Sadea',[],...
        'StopFlag',false,...
        'hSamples',[],...
        'AlgSettings',[],...
        'Results',[],...
        'ObjectiveFunctionName','maximizeGain',...
        'CachedConfiguration',[],...
        'VectorProperties',[],...
        'ValidatingInShow',[],...
        'ValidatingInSet',[],...
        'IntegerProperties',[],...
        'StringProperties',[],...
        'maxNoOfConstraints',[],...
        'CurrentObject',[],...
        'SetValuesFcn',[]);
    end

    methods
        varargout=optimize(obj,frequency,objectiveFunction,varargin);

    end

    methods(Hidden)
        setPairedProps(obj,nameObjectCell);
        setValuesFcn(obj,setFcn);
    end

    methods(Access=private)
        function loadOptimStructContants(obj)
            obj.OptimStruct.VectorProperties={'Tilt','ArmLength','ArmElevation',...
            'FeedVoltage','FeedPhase','FeedOffset','PatchCenterOffset',...
            'SlotCenter','FeedLocation','FeedLocations','ViaLocations',...
            'Side','BoardWidth','ArmWidth','ArmSpacing','FractalCenterOffset',...
            'ElementSpacing','AmplitudeTaper','PhaseShift','Size',...
            'RowSpacing','ColumnSpacing','ScanAzimuth','ScanElevation',...
            'FeedWidth','Impedance','Frequency','Direction','Polarization',...
            'ConeRadii','ConeHeight','NarrowRadius','BroadRadius',...
            'BoomOffset','Radius','FocalLength','Radii','CorrugateDepth',...
            'HatHeight','azimuth','elevation','ScaleFields',...
            'TransmitAngle','ReceiveAngle','Weights','FrequencyRange',...
            'MainLobeDirection','Center','Vertices','DirectorLength',...
            'DirectorSpacing','Gap','FeedOffset','ReflectorTilt',...
            'SlotSpacing','SlotOffset','SlotAngle'};
            obj.OptimStruct.ValidatingInShow={'bicone','customAntennaMesh','customArrayGeometry',...
            'dipoleCrossed','dipoleMeander','dipoleVee','discone'...
            ,'fractalCarpet','gregorian','infiniteArray','linearArray','lpda'...
            ,'monocone','monopole','patchMicrostrip','patchMicrostripTriangular'...
            ,'pcbStack','planeWaveExcitation','quadCustom','rectangularArray','slot','customDualReflectors'};
            obj.OptimStruct.ValidatingInSet={'lpda','lumpedElement','patchMicrostrip'};
            obj.OptimStruct.IntegerProperties={'NumArms','NumDirectors','NumLoops',...
            'NumRungs','NumPetals','NumIterations','NumElements',...
            'NumFeeds','NumSlots','NumPoints'};
            obj.OptimStruct.StringProperties={'WindingDirection','Operation','Name',...
            'Revision','Type','Reference','Location',...
            'FileName','Units'};
            obj.OptimStruct.maxNoOfConstraints=5;
        end


        function rtn=getObjectiveFunction(obj)
            if isempty(obj.OptimStruct.ObjectiveFunction)
                rtn='NotInitialized';
            else
                rtn=obj.OptimStruct.ObjectiveFunction;
            end
        end
        function setObjectiveFunctionName(obj,newName)
            switch newName
            case 'maximizeGain'
                obj.OptimStruct.ObjectiveFunctionName='MaximizeGain';
            case 'frontToBackRatio'
                obj.OptimStruct.ObjectiveFunctionName='F/BLobeRatio';
            case 'maximizeBandwidth'
                obj.OptimStruct.ObjectiveFunctionName='MaxBandwidth';
            case 'minimizeBandwidth'
                obj.OptimStruct.ObjectiveFunctionName='MinBandwidth';




            case 'maximizeSLL'
                obj.OptimStruct.ObjectiveFunctionName='MaximizeSLL';


            case 'minimizeArea'
                obj.OptimStruct.ObjectiveFunctionName='MinimizeArea';
            end
        end






























        function setPropertyNames(obj,newPropertyNames)
            obj.OptimStruct.PropertyNames=[];
            obj.OptimStruct.SubObjects=[];
            cellfun(@(x)validateattributes(x,{'char','string'},...
            {'nonempty'},...
            'optimize','property names'),newPropertyNames,...
            'UniformOutput',false);

            obj.OptimStruct.SubObjects={obj};
            makePropObjectPair(obj,newPropertyNames);


            if isa(obj,'pcbStack')


                obj.OptimStruct.PropertyNames=newPropertyNames;
            else
                for i=1:2:length(obj.OptimStruct.PairedProps)
                    obj.OptimStruct.PropertyNames{end+1}=obj.OptimStruct.PairedProps{i};
                end
            end
        end


        function setLowerBounds(obj,newLowerBounds)
            if isequal(size(newLowerBounds),[1,1])
                validateattributes(newLowerBounds{:},{'double'},...
                {'nonempty','nrows',1}...
                ,'optimize','lower bounds');
            end
            cellfun(@(x)validateattributes(x,{'double'},...
            {'nonempty','real','nonnan','finite'}...
            ,'optimize','lower bounds'),newLowerBounds,...
            'UniformOutput',false);
            obj.OptimStruct.LowerBounds=cell2mat(newLowerBounds);

            if numel(obj.OptimStruct.PropertyNames)>numel(obj.OptimStruct.LowerBounds)
                error(message("antenna:optimizertab:EmptyDesignVariables"));
            end

            obj.OptimStruct.LowerBounds=handleVectorExceptions(obj,obj.OptimStruct.LowerBounds);
        end


        function setUpperBounds(obj,newUpperBounds)
            if isequal(size(newUpperBounds),[1,1])
                validateattributes(newUpperBounds{:},{'double'},...
                {'nonempty','nrows',1}...
                ,'optimize','upper bounds');
            end
            cellfun(@(x)validateattributes(x,{'double'},...
            {'nonempty','real','nonnan','finite'}...
            ,'optimize','upper bounds'),newUpperBounds,...
            'UniformOutput',false);
            obj.OptimStruct.UpperBounds=cell2mat(newUpperBounds);

            if numel(obj.OptimStruct.PropertyNames)>numel(obj.OptimStruct.UpperBounds)
                error(message("antenna:optimizertab:EmptyDesignVariables"));
            end

            obj.OptimStruct.UpperBounds=handleVectorExceptions(obj,obj.OptimStruct.UpperBounds);
        end



        function setConstraintsFunctionName(obj,newName)
            if isempty(newName)
                return
            else
                for i=1:length(newName)
                    validatestring(newName{i},{'Area','Volume','S11',...
                    'Gain','F/B','SLL','Sij','Sii'},...
                    {'nonempty','scalar','real','nonnan','finite'}...
                    ,'optimize','constraints');
                    obj.OptimStruct.ConstraintsFunctionName=newName;
                end

            end
        end

        function setOperator(obj,newOperator)
            if isempty(newOperator)
                return
            else
                for i=1:length(newOperator)
                    validatestring(newOperator{i},{'>','<'},...
                    'optimize','constraints');
                    obj.OptimStruct.Operator=newOperator;
                end
            end
        end

        function setValue(obj,newValue)
            if strcmpi(newValue,'NotInitialized')
                return
            else
                for i=1:length(newValue)
                    validateattributes(newValue{i},{'numeric','numeric'},...
                    {'nonempty','real','nonnan','finite'}...
                    ,'optimize','lower bounds');
                    obj.OptimStruct.Value=newValue;
                end
            end
        end









































        function setMainLobeDirection(obj,newMainLobeDirection)
            obj.OptimStruct.MainLobeDirection=newMainLobeDirection;
            obj.OptimStruct.Angles=[obj.OptimStruct.MainLobeDirection(1),180+obj.OptimStruct.MainLobeDirection(1);...
            obj.OptimStruct.MainLobeDirection(2),180+obj.OptimStruct.MainLobeDirection(2)];
        end






























        optimParser(obj,frequency,objectiveFunction,varargin);


        objectiveFunctionParser(obj,newObjectiveFunction);
        f=maximizeBandwidth(obj);
        f=maximizeCorrelation(obj);
        f=maximizeFBr(obj);
        f=maximizeGain(obj);
        f=maximizeSLL(obj);
        f=minimizeArea(obj);
        f=minimizeBandwidth(obj);
        f=minimizeCorrelation(obj);
        objectiveValue=processObjective(obj,inputObjVal,OptimizationType,Conflict,DisplayValue);


        constraintsParser(obj,newFunction);
        f=SLLConstraint(obj);
        f=areaConstraint(obj);
        f=arrayThinning(obj);
        f=correlationConstraint(obj);
        f=fBrConstraint(obj);
        f=gainConstraint(obj);
        f=s11Constraint(obj);
        f=sijConstraint(obj);
        f=volumeConstraint(obj);
        constraintvalue=processConstraint(obj,DesiredValue,inputConstraintVal,ConstraintType,Conflict,DisplayValue,Type);


        decorateAxes(obj,AxesType);
        refreshOptimResults(obj);
        initResults(obj,varargin);
        resultsSummary(obj);
        makeResultsLinePlots(obj,Type);
        rtn=printPlain(~,Val);
        setupPlotPositions(obj);


        designVariablesParser(obj,newPropertyName,newLowerBounds,newUpperBounds);
        rtn=handleVectorExceptions(obj,PropertyName,src);


        rtn=calcArea(obj);
        rtn=processCouplingWithPattern(obj,Lobe);
        rtn=getPropIndex(obj);
        setValues2Antenna(obj,propValues);
        rtn=processSparameter(obj,Type);
        rtn=processSparameterCross(obj,Type);
        rtn=checkCachedModel(obj);

        function makeEqualWeights(obj)
            obj.OptimStruct.Weights={};
            for i=1:obj.OptimStruct.NoOfConstraints
                obj.OptimStruct.Weights{i}=100/obj.OptimStruct.NoOfConstraints;
            end
        end


























        function Parameters=packDesignVariables(obj)
            Nvars=numel(obj.OptimStruct.LowerBounds);
            Parameters=cell(Nvars);
            for j=1:Nvars
                Parameters{j}={num2str(obj.OptimStruct.LowerBounds(j)),...
                num2str(obj.OptimStruct.UpperBounds(j))};
            end
        end

        function setProperty(obj,Name,Value)
            idx=find(strcmpi(Name,obj.OptimStruct.PairedProps));
            if isstruct(obj.OptimStruct.PairedProps{idx(1)+1})

            else
                set(obj.OptimStruct.PairedProps{idx(1)+1},Name,Value);
            end
            if~isempty(obj.OptimStruct.SetValuesFcn)

                obj=obj.OptimStruct.SetValuesFcn(Name,Value);
            end
        end

        function rtn=getProperty(obj,Name)
            idx=find(strcmpi(Name,obj.OptimStruct.PairedProps));
            if isstruct(obj.OptimStruct.PairedProps{idx(1)+1})
                rtn=obj.OptimStruct.PairedProps{idx(1)+1}.(Name);
            else
                rtn=get(obj.OptimStruct.PairedProps{idx(1)+1},Name);
            end
        end

        function ConstraintsWithPenalty=packConstraints(obj)
            if~isempty(obj.OptimStruct.ConstraintsFunction)
                if length(obj.OptimStruct.ConstraintsFunction)~=length(obj.OptimStruct.Weights)
                    error(message("antenna:antennaerrors:IncorrectNoOfWeights"));
                end
                ConstraintsWithPenalty=cell(numel(obj.OptimStruct.ConstraintsFunction));
                for k=1:numel(obj.OptimStruct.ConstraintsFunction)
                    ConstraintsWithPenalty{k}={obj.OptimStruct.ConstraintsFunction{k},obj.OptimStruct.Weights{k}};
                end
            else
                ConstraintsWithPenalty=[];
            end
        end






































































































































































































































































        function makeFrequencyRange(obj)

            if isempty(obj.OptimStruct.FrequencyRange)
                if isempty(obj.OptimStruct.Bandwidth)
                    obj.OptimStruct.Bandwidth=0.015*obj.OptimStruct.CenterFrequency;
                end
                fmin=obj.OptimStruct.CenterFrequency-2*(obj.OptimStruct.Bandwidth);
                fmax=obj.OptimStruct.CenterFrequency+2*(obj.OptimStruct.Bandwidth);
                Nf=101;
                obj.OptimStruct.FrequencyRange=linspace(fmin,fmax,Nf);
            end
        end

        function makePropObjectPair(obj,propNames)
            if isempty(obj.OptimStruct.PairedProps)
                for i=1:length(propNames)

                    [~]=eval(['obj.',propNames{i}]);%#ok<*EVLDOT>
                    propParts=strsplit(propNames{i},'.');
                    obj.OptimStruct.PairedProps{end+1}=propParts{end};
                    if isscalar(propParts)
                        obj.OptimStruct.PairedProps{end+1}=obj;
                    else
                        subObjString=strjoin(propParts(1:end-1),'.');
                        obj.OptimStruct.PairedProps{end+1}=eval(['obj.',subObjString]);
                    end
                end
            end
        end





























    end
end