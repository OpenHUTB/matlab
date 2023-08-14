function varargout=idForBlock(varargin)






    if numel(varargin)==1
        arg=varargin{1};

        if isjava(arg)
            if isa(arg,'java.util.Collection')
                arg=arg.toArray();
            end
            if arg.getClass().isArray()
                arg=cell(arg);
            end
        end

        if~iscell(arg)
            varargout={processSingleInput(arg)};
        else

            varargout={processAsCell(arg)};
        end
    elseif~isempty(varargin)

        output=processAsCell(varargin);
        assert(numel(output)==numel(varargin));
        [varargout{1:numel(varargin)}]=deal(output{:});
    else
        varargout={};
    end
end



function output=processAsCell(args)
    validateattributes(args,{'cell'},{'vector'});
    output=cell(size(args));

    for i=1:numel(args)
        output{i}=processSingleInput(args{i});
    end
end

function output=processSingleInput(input)
    if isa(input,'coder.internal.mlfb.BlockIdentifier')
        output=input;
    elseif~isempty(input)
        if isa(input,'java.lang.String')
            input=char(input);
        end
        validateattributes(input,{'char','double','DAStudio.Object','Simulink.DABaseObject'...
        ,'com.mathworks.toolbox.coder.mlfb.BlockId'},{'nonempty'});
        output=coder.internal.mlfb.BlockIdentifier(input);
    else
        output=[];
    end
end