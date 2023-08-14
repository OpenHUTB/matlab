function optimParser(obj,frequency,objectiveFunction,propertyNames,bounds,varargin)




    parserObj=inputParser;
    parserObj.FunctionName='optimize';
    addRequired(parserObj,'obj');
    addRequired(parserObj,'frequency',@(x)validateattributes(x,{'double'},...
    {'nonempty','scalar','real','nonnan','finite','positive'},...
    'optimize','CenterFrequency'));
    addRequired(parserObj,'objectiveFunction');
    addRequired(parserObj,'propertyNames',@(x)validateattributes(x,{'cell'},...
    {'nonempty'},...
    'optimize','property names'));
    if isa(obj,'customDualReflectors')

        propList={'ReflectorOffset','MainReflector','SubReflector'};
        for num=1:numel(propList)
            for numprop=1:numel(propertyNames)
                if any(strcmpi(propertyNames{numprop},propList))
                    error(message('antenna:antennaerrors:Unsupported',strcat(propertyNames{numprop}),'optimization'));
                end
            end
        end
    end
    addRequired(parserObj,'bounds',@(x)validateattributes(x,{'cell'},...
    {'nonempty','nrows',2}...
    ,'optimize','bounds'));
    addParameter(parserObj,'Weights',[],@(x)validateattributes(x,{'double'},...
    {'nonempty','vector','real','nonnan','finite','positive'},...
    'optimize','Weights'));
    addParameter(parserObj,'Constraints',[],@(x)validateattributes(x,{'cell'},...
    {'nonempty'}...
    ,'optimize','Constraints'));
    addParameter(parserObj,'UseParallel',false,@(x)validateattributes(x,{'numeric','logical'},...
    {'nonempty','binary','scalar','integer','nonnan','finite'},...
    'optimize','UseParallel'));
    addParameter(parserObj,'Iterations',200,@(x)validateattributes(x,{'double'},...
    {'nonempty','scalar','real','nonnan','finite','positive'},...
    'optimize','Iterations'));
    addParameter(parserObj,'EnableCoupling',true,@(x)validateattributes(x,{'numeric','logical'},...
    {'nonempty','binary','scalar','integer','nonnan','finite'},...
    'optimize','EnableCoupling'));
    addParameter(parserObj,'EnableLog',false,@(x)validateattributes(x,{'numeric','logical'},...
    {'nonempty','binary','scalar','integer','nonnan','finite'},...
    'optimize','EnableLog'));
    addParameter(parserObj,'FrequencyRange',[],@(x)validateattributes(x,{'double'},...
    {'nonempty','vector','real','nonnan','finite','positive'},...
    'optimize','FrequencyRange'));
    addParameter(parserObj,'MainLobeDirection',[0,90],@(x)validateattributes(x,{'double'},...
    {'nonempty','vector','real','nonnan','finite','numel',2},...
    'optimize','MainLobeDirection'));
    addParameter(parserObj,'ReferenceImpedance',50,@(x)validateattributes(x,{'double'},...
    {'nonempty','scalar','real','nonnan','finite','positive'},...
    'optimize','ReferenceImpedance'));
    addParameter(parserObj,'Samples',[],@(x)validateattributes(x,{'double'},...
    {'nonempty','scalar','real','nonnan','finite','positive'},...
    'optimize','Samples'));
    addParameter(parserObj,'PlotType','convergence',@(x)ischar(validatestring(x,...
    {'convergence','objective'},...
    'optimize','PlotType')));
    addParameter(parserObj,'Optimizer','sadea',@(x)ischar(validatestring(x,...
    {'sadea','surrogateopt'},...
    'optimize','Optimizer')));
    addParameter(parserObj,'ParentFigure',[]);
    addParameter(parserObj,'Angles',[0,0;90,-90]);
    addParameter(parserObj,'Bandwidth',[]);

    if isempty(varargin{:})
        parse(parserObj,obj,frequency,objectiveFunction,propertyNames,bounds);
    else
        parse(parserObj,obj,frequency,objectiveFunction,propertyNames,bounds,varargin{:}{:});
    end





    if(isa(obj,'em.Antenna')||isa(obj,'em.Array'))&&...
        ~isa(obj,'customAntennaMesh')&&...
        ~isa(obj,'customAntennaGeometry')&&~isa(obj,'installedAntenna')

    else

        error(message("antenna:antennaerrors:InvalidObject"))
    end
    if isa(obj,'pcbStack')
        if isempty(obj.OptimStruct.PairedProps)&&isempty(obj.OptimStruct.SetValuesFcn)

            error(message("antenna:antennaerrors:InvalidObject"));
        end
    end

    obj.OptimStruct.CenterFrequency=parserObj.Results.frequency;

    objectiveFunctionParser(obj,parserObj.Results.objectiveFunction);

    setPropertyNames(obj,parserObj.Results.propertyNames);
    setLowerBounds(obj,parserObj.Results.bounds(1,:));
    setUpperBounds(obj,parserObj.Results.bounds(2,:));






    obj.OptimStruct.Angles=parserObj.Results.Angles;

    obj.OptimStruct.Bandwidth=parserObj.Results.Bandwidth;



    obj.OptimStruct.FrequencyRange=parserObj.Results.FrequencyRange;

    obj.OptimStruct.ReferenceImpedance=parserObj.Results.ReferenceImpedance;

    setMainLobeDirection(obj,parserObj.Results.MainLobeDirection);




    obj.OptimStruct.Weights=num2cell(parserObj.Results.Weights);

    if~isempty(parserObj.Results.Constraints)
        constraintsParser(obj,parserObj.Results.Constraints);
    end




    obj.OptimStruct.Optimizer=parserObj.Results.Optimizer;

    obj.OptimStruct.PlotType=parserObj.Results.PlotType;

    obj.OptimStruct.hSamples=parserObj.Results.Samples;

    if isa(obj,'em.Antenna')
        if~parserObj.Results.EnableCoupling
            error(message("antenna:antennaerrors:AntennaEnableCoupling"));
        end
    elseif isa(obj,'em.Array')
        obj.OptimStruct.EnableCoupling=parserObj.Results.EnableCoupling;
    end


    obj.OptimStruct.EnableLog=parserObj.Results.EnableLog;



    obj.OptimStruct.Iterations=parserObj.Results.Iterations;

    obj.OptimStruct.UseParallel=parserObj.Results.UseParallel;

    obj.OptimStruct.Figure=parserObj.Results.ParentFigure;



    makeFrequencyRange(obj);


end

