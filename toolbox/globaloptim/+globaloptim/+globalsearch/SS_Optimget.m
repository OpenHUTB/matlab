function o=SS_Optimget(options,name,default,flag)





























    if nargin<2
        error(message('globaloptim:ssv1:SSOPTIMGET:inputarg'));
    end
    if nargin<3
        default=[];
    end
    if nargin<4
        flag=[];
    end


    if isequal('fast',flag)
        o=ssoptimgetfast(options,name,default);
        return
    end

    if~isempty(options)&&~isa(options,'struct')
        error(message('globaloptim:ssv1:SSOPTIMGET:firstargerror'));
    end

    if isempty(options)
        o=default;
        return;
    end

    optionsstruct=struct('RefSetSize',[],...
    'RefSetType',[],...
    'GoodFraction',[],...
    'InitialSetMethod',[],...
    'MaxEvaluations',[],...
    'TimeLimit',[],...
    'ObjectiveLimit',[],...
    'StallTimeLimit',[],...
    'IntensifyMethod',[],...
    'IntensifyPoint',[],...
    'IntensifyLength',[],...
    'CombineMethod',[],...
    'WeightedDimensions',[],...
    'DimensionWeights',[],...
    'DistanceMeasureFcn',[],...
    'Display',[],...
    'OutputInterval',[],...
    'OutputFcns',[],...
    'PlotInterval',[],...
    'PlotFcns',[],...
    'Vectorized',[],...
    'UseParallel',[]);

    Names=fieldnames(optionsstruct);

    names=lower(Names);

    lowName=lower(name);
    j=strmatch(lowName,names);
    if isempty(j)
        error(message('globaloptim:ssv1:SSOPTIMGET:invalidproperty',name));
    elseif length(j)>1

        k=strmatch(lowName,names,'exact');
        if length(k)==1
            j=k;
        else
            msg=sprintf('Ambiguous property name ''%s'' ',name);
            msg=[msg,'(',Names{j(1),:}];
            for k=j(2:length(j))'
                msg=[msg,', ',Names{k,:}];
            end
            error(message('globaloptim:ssv1:SSOPTIMGET:ambiguousproperty',msg));
        end
    end

    if any(strcmp(Names,Names{j,:}))
        o=options.(Names{j,:});
        if isempty(o)
            o=default;
        end
    else
        o=default;
    end


    function value=ssoptimgetfast(options,name,defaultopt)








        if~isempty(options)
            value=options.(name);
        else
            value=[];
        end

        if isempty(value)
            value=defaultopt.(name);
        end


