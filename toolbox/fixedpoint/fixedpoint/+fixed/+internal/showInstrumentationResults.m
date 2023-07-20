function showInstrumentationResults(varargin)




    narginchk(1,inf);
    [mex_file_name,opts]=parseargs(varargin{:});
    fixed.internal.InstrumentationManager.showResults(mex_file_name,varargin,opts);

end


function[mex_file_name,opts]=parseargs(varargin)









    mex_file_name='';
    opts=fixed.internal.getDefaultInstrumentationOptions();

    argc=1;
    nargs=nargin;

    arg='';

    function a=itCurrent()
        if argc>numel(varargin)
            error(message('fixed:instrumentation:MissingParameterOption',arg));
        end
        a=varargin{argc};
    end

    function b=itHasCurrent()
        b=argc<=nargs;
    end

    function itAdvance()
        argc=argc+1;
    end

    function unrecognizedOption()
        error(message('fixed:instrumentation:UnrecognizedOption',arg));
    end

    while itHasCurrent()
        arg=itCurrent();
        if~ischar(arg)
            disp(arg);
            error(message('fixed:instrumentation:CannotProcessOptions'));
        end
        arg=strtrim(arg);
        if coder.internal.isOptionPrefix(arg(1))
            if numel(arg)<2
                unrecognizedOption();
            end
            switch lower(arg(2:end))
            case 'browser'
                opts.doPrintable=true;
                warning(message('fixed:instrumentation:ObsoleteOption',...
                '-browser',...
                'showInstrumentationResults',...
                '-printable'));
            case 'defaultdt'
                itAdvance();
                opts.defaultDT=parseDefaultDT(itCurrent());
            case 'proposewl'
                opts.doProposeWL=true;
            case 'proposefl'
                opts.doProposeFL=true;
            case 'optimizewholenumbers'
                opts.doOptimizeWholeNumbers=true;
            case 'printable'
                opts.doPrintable=true;
            case 'percentsafetymargin'
                itAdvance();
                opts.percentSafetyMargin=parsePercentSafetyMargin(itCurrent());
            case 'log2display'
                opts.doLog2Display=true;
            case 'proposefortemps'
                opts.doProposeForTemps=true;
            case 'showcode'
                opts.doShowCode=true;
            case 'nocode'
                opts.doShowCode=false;
            case 'prototypetable'
                opts.doPrototypeTable=true;
            case 'showattachedfimath'
                opts.doShowAttachedFimath=true;
            case 'prototypefimath'
                itAdvance();
                opts.prototypeFimath=parsePrototypeFimath(itCurrent());
            otherwise
                unrecognizedOption();
            end
        else
            mex_file_name=arg;
        end
        itAdvance();
    end




    if isempty(mex_file_name)
        error(message('fixed:instrumentation:MissingKey','showInstrumentationResults'));
    end
    if opts.doProposeWL&&opts.doProposeFL
        error(message('fixed:instrumentation:CannotProposeWLandFL'));
    end
    if opts.doOptimizeWholeNumbers&&~opts.doProposeWL&&~opts.doProposeFL
        error(message('fixed:instrumentation:NoOptimizeWholeWithoutProposeWLorFL'));
    end
    if opts.doPrototypeTable
        opts.doPrintable=true;
    end

end

function defaultDT=parseDefaultDT(T)
    if isnumerictype(T)
        defaultDT=T;
    elseif ischar(T)
        switch lower(T)
        case{'remainfloat','remain floating-point'}
            defaultDT=numerictype('double');
        case{'double','single',...
            'int8','int16','int32','int64',...
            'uint8','uint16','uint32','uint64'}
            defaultDT=numerictype(T);
        otherwise
            error(message('fixed:instrumentation:BadDefaultDT'));
        end
    elseif isa(T,'Simulink.NumericType')
        try
            a=fi([],T);
        catch me
            error(message('fixed:instrumentation:BadDefaultDT'));
        end
        defaultDT=numerictype(a);
    else
        error(message('fixed:instrumentation:BadDefaultDT'));
    end
end

function percentSafetyMargin=parsePercentSafetyMargin(N)
    if isnan(N)||~isnumeric(N)||length(N)~=1||N<0||~isreal(N)
        error(message('fixed:instrumentation:BadPercentSafetyMargin'));
    end
    percentSafetyMargin=double(N);
end

function prototypeFimath=parsePrototypeFimath(F)
    if isfimath(F)
        prototypeFimath=F;
    else
        error(message('fixed:instrumentation:BadPrototypeFimath'));
    end
end
