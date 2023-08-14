function varargout=exportTo(varargin)





    import matlab.graphics.internal.export.Exporter
    import matlab.graphics.internal.export.ExporterValidator
    import matlab.graphics.internal.export.ExporterArgumentParser

    narginchk(2,inf);
    h=[];
    dest=[];
    varargin=matlab.graphics.internal.convertStringToCharArgs(varargin);


    try
        if ExporterValidator.validateHandle(varargin{1})
            h=varargin{1};
        end
    catch ex

        if ishghandle(varargin{1})
            throw(ex)
        end
    end

    if~isempty(h)
        if nargin>2
            nextArg=varargin{3};
        else
            nextArg=[];
        end
        dest=checkArgForDestination(varargin{2},nextArg);
    end
    if~isempty(h)
        varargin=[{'handle'},varargin(1:end)];
    end
    if~isempty(dest)
        args={varargin{1:2},'destination'};
        if length(varargin)>2
            args={args{:},varargin{3:end}};
        end
        varargin=args;
    end
    argParser=ExporterArgumentParser();
    exporter=Exporter(argParser);

    drawnow;

    results=exporter.process(varargin{:});
    if nargout
        varargout{1}=results;
    end

end


function dest=checkArgForDestination(arg,nextArg)
    import matlab.graphics.internal.export.ExporterArgumentParser

    dest=[];








    if isa(arg,'char')
        couldBeFileSpec=true;

        otherParameterNames=ExporterArgumentParser.getParameterNames();

        otherParameterNames(strcmp(otherParameterNames,'destination'))=[];




        if strcmpi(arg,'destination')&&...
            (isempty(nextArg)||any(strcmpi(nextArg,otherParameterNames)))
            couldBeFileSpec=true;
        elseif~isempty(nextArg)


            if~any(strcmpi(nextArg,otherParameterNames))
                couldBeFileSpec=false;
            end
        end
        if couldBeFileSpec
            dest=arg;
        end
    end
end
