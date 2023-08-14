function options=SS_Optimset(varargin)




































































































    if(nargin==0)&&(nargout==0)
        fprintf('           RefSetSize: [ positive scalar | {20} ]\n');
        fprintf('           RefSetType: [ {''normal''} | ''tiered'' ]\n');
        fprintf('         GoodFraction: [ positive scalar in range [0,1] | {1} ]\n');
        fprintf('     InitialSetMethod: [ ''rand'' | {''stratRand''} ]\n\n');

        fprintf('   DiversifyRetention:  [ positive scalar fraction or integer | {0.5} ]\n');

        fprintf('       MaxEvaluations: [ positive scalar | {50000} ]\n');
        fprintf('            TimeLimit: [ positive scalar | {Inf} ]\n');
        fprintf('       ObjectiveLimit: [ scalar | {-Inf} ]\n');
        fprintf('       StallTimeLimit: [ positive scalar | {Inf} ]\n\n');

        fprintf('      IntensifyMethod: [ ''off'' | {''one''} | ''two'' | ''both'' ]\n');
        fprintf('       IntensifyPoint: [ positive scalar | {3000} ]\n');
        fprintf('      IntensifyLength: [ positive scalar | {200} ]\n\n');

        fprintf('        CombineMethod: [ ''linear'' | {''hypercube''} ]\n');
        fprintf('   WeightedDimensions: [ ''on'' | {''off''} ]\n');
        fprintf('     DimensionWeights: [ Vector | {[]} ]\n');
        fprintf('   DistanceMeasureFcn: [ function_handle | {@SS_ComputeSquareDists} ]\n\n');

        fprintf('              Display: [ ''off'' | ''iter'' | ''diagnose'' | {''final''} ]\n');
        fprintf('     UsePointDatabase: [ ''on'' | {''off''} ]\n');
        fprintf('       OutputInterval: [ positive scalar | {100} ]\n');
        fprintf('           OutputFcns: [ function_handle | @ssoutputgen | {[]} ]\n');
        fprintf('         PlotInterval: [ positive scalar | {100} ]\n');
        fprintf('             PlotFcns: [ function_handle | @ssplotbestf | {[]} ]\n\n');

        fprintf('           Vectorized: [ ''on'' | {''off''} ]\n');
        fprintf('          UseParallel: [ logical scalar | true | {false} ]\n');
        fprintf(' MaxPointDatabaseSize: [ positive scalar | {Inf} ]\n');
        return;
    end

    numberargs=nargin;



    options=i_createDefaultOptions;

    Names=fieldnames(options);
    m=size(Names,1);
    names=lower(Names);

    i=1;
    while i<=numberargs
        arg=varargin{i};
        if ischar(arg)
            break;
        end
        if~isempty(arg)
            if~isa(arg,'struct')
                error(message('globaloptim:ssv2:SSOPTIMSET:invalidArgument',i));
            end
            for j=1:m
                if any(strcmp(fieldnames(arg),Names{j,:}))
                    val=arg.(Names{j,:});
                else
                    val=[];
                end
                if~isempty(val)
                    if ischar(val)
                        val=deblank(val);
                    end
                    checkfield(Names{j,:},val);
                    options.(Names{j,:})=val;
                end
            end
        end
        i=i+1;
    end


    if rem(numberargs-i+1,2)~=0
        error(message('globaloptim:ssv2:SSOPTIMSET:invalidArgPair'));
    end
    expectval=0;
    while i<=numberargs
        arg=varargin{i};

        if~expectval
            if~ischar(arg)
                error(message('globaloptim:ssv2:SSOPTIMSET:invalidArgFormat',i));
            end

            lowArg=lower(arg);
            j=strmatch(lowArg,names);
            if isempty(j)
                error(message('globaloptim:ssv2:SSOPTIMSET:invalidParamName',arg));
            elseif length(j)>1

                k=strmatch(lowArg,names,'exact');
                if length(k)==1
                    j=k;
                else
                    msg=sprintf('Ambiguous parameter name ''%s'' ',arg);
                    msg=[msg,'(',Names{j(1),:}];%#ok<AGROW>
                    for k=j(2:length(j))'
                        msg=[msg,', ',Names{k,:}];%#ok<AGROW>
                    end
                    error(message('globaloptim:ssv2:SSOPTIMSET:ambiguousParamName',msg));
                end
            end
            expectval=1;

        else
            if ischar(arg)
                arg=(deblank(arg));
            end
            checkfield(Names{j,:},arg);
            options.(Names{j,:})=arg;
            expectval=0;
        end
        i=i+1;
    end

    if expectval
        error(message('globaloptim:ssv2:SSOPTIMSET:invalidParamVal',arg));
    end



    function checkfield(field,value)






        if isempty(value)
            return
        end

        switch field

        case{'RefSetSize'}
            if~(isa(value,'double')&&isscalar(value)&&value>=0)
                if ischar(value)
                    error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotAPosScalarButString','OPTIONS',field));
                else
                    error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotAPosScalar','OPTIONS',field));
                end
            end

        case{'InitialSetMethod'}
            if~isa(value,'char')||~any(strcmpi(value,{'rand','stratRand'}))
                error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotOneOrOther','OPTIONS',field,'rand','stratRand'));
            end

        case{'RefSetType'}
            if~isa(value,'char')||~any(strcmpi(value,{'normal','tiered'}))
                error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotOneOrOther','OPTIONS',field,'normal','tiered'));
            end

        case{'CombineMethod'}
            if~isa(value,'char')||~any(strcmpi(value,{'linear','hypercube'}))
                error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotOneOrOther','OPTIONS',field,'linear','hypercube'));
            end

        case{'IntensifyMethod'}
            if~isa(value,'char')||~any(strcmpi(value,{'off','one','two','both'}))
                error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotAnIntensifyMethod','OPTIONS',field,'off','one','two','both'));
            end

        case{'UsePointDatabase','WeightedDimensions'}
            if~isa(value,'char')||~any(strcmpi(value,{'on','off'}))
                error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotOneOrOther','OPTIONS',field,'on','off'));
            end

        case{'PlotFcns','OutputFcns','DistanceMeasureFcn'}
            if~(iscell(value)||isa(value,'function_handle'))
                error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotAFunctionOrCellArray','OPTIONS',field));
            end

        case 'GoodFraction'
            if~isa(value,'double')
                if ischar(value)
                    error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotAPosRealNumButString','OPTIONS',field));
                else
                    error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotAPosRealNum','OPTIONS',field));
                end
            elseif value>1||value<=0
                error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotAPosRealNumInRange','OPTIONS',field));
            end

        case{'DiversityRetention'}
            if~isa(value,'double')
                if ischar(value)
                    if~strcmpi(value,'all')
                        error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotAPosRealNumOrAll','OPTIONS',field,'all'));
                    end
                else
                    error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotAPosRealNumOrAll','OPTIONS',field,'all'));
                end
            end

        case{'ObjectiveLimit'}
            if~isa(value,'double')||~isscalar(value)
                if ischar(value)
                    error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotARealScalarButString','OPTIONS',field));
                else
                    error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotARealScalar','OPTIONS',field));
                end
            end

        case{'OutputInterval','PlotInterval','MaxEvaluations','TimeLimit','StallTimeLimit','IntensifyPoint','IntensifyLength'}
            if~isa(value,'double')||~isscalar(value)||value<0
                if ischar(value)
                    error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotAPosRealNumButString','OPTIONS',field));
                else
                    error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotAPosRealNum','OPTIONS',field));
                end
            end

        case{'DimensionWeights'}
            if~isnumeric(value)||ndims(value)>1
                error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotANumericVector','OPTIONS',field));
            end

        case{'Display'}
            if~isa(value,'char')||~any(strcmpi(value,{'off','none','iter','diagnose','final'}))
                error(message('globaloptim:saoptimset:checkfield:NotADisplayType','OPTIONS',field,'off','iter','diagnose','final'));
            end

        case{'Vectorized'}
            if~isa(value,'char')||~any(strcmp(value,{'on','off'}))
                error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotOneOrOther','OPTIONS',field,'off','on'));
            end

        case 'UseParallel'
            [~,valid]=validateopts_UseParallel(value,false,false);
            if~valid
                error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotLogicalScalar','OPTIONS',field));
            end

        case 'MaxPointDatabaseSize'
            if~(isscalar(value)&&isa(value,'double')&&value>=0)
                if ischar(value)
                    error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotANonNegRealNumButString','OPTIONS',field));
                else
                    error(message('globaloptim:ssv2:SSOPTIMSET:checkfield:NotANonNegRealNum','OPTIONS',field));
                end
            end

        otherwise
            error(message('globaloptim:ssv2:SSOPTIMSET:unknownOptionsField'))
        end

        function defaultopt=i_createDefaultOptions

            defaultopt=struct('RefSetSize',10,...
            'RefSetType','normal',...
            'GoodFraction',1,...
            'DiversityRetention',0.5,...
            'InitialSetMethod','stratRand',...
            'MaxEvaluations',Inf,...
            'TimeLimit',Inf,...
            'ObjectiveLimit',-Inf,...
            'StallTimeLimit',Inf,...
            'IntensifyMethod','one',...
            'IntensifyPoint',3000,...
            'IntensifyLength',200,...
            'CombineMethod','linear',...
            'WeightedDimensions','off',...
            'DimensionWeights',[],...
            'DistanceMeasureFcn',@globaloptim.globalsearch.SS_ComputeSquareDists,...
            'Display','final',...
            'UsePointDatabase','off',...
            'OutputInterval',100,...
            'OutputFcns',[],...
            'PlotInterval',100,...
            'PlotFcns',[],...
            'Vectorized','off',...
            'UseParallel',false,...
            'MaxPointDatabaseSize',Inf);
