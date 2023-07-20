
function obj=approximation(varargin)





    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if(nargin==1)
        varargin{2}=varargin{1};
        varargin{1}='Function';
    end

    objUserIn=struct(varargin{:});
    try
        objUserIn.Function;
    catch mEx
        error(message('float2fixed:MFG:CoderAppxInvalidFcn',func2str(objUserIn.Function)));
    end
    if(isempty(objUserIn.Function))
        error(message('float2fixed:MFG:CoderAppxInvalidFcn','[]'))
    end

    if(isfield(objUserIn,'Architecture'))
        architecture=objUserIn.Architecture;
    else
        architecture='LookupTable';
    end

    if(strncmpi('LookupTable',architecture,length(architecture)))
        obj=coder.mathfcngenerator.LookupTable(varargin{:});
    elseif(strncmpi('CORDIC',architecture,length(architecture)))
        error(message('float2fixed:MFG:CORDICUnsupported'));
        obj=coder.mathfcngenerator.CORDIC(varargin{:});%#ok<UNRCH> % this line will be uncommented
    elseif(strncmpi('Flat',architecture,length(architecture)))
        obj=coder.mathfcngenerator.Flat(varargin{:});
    else
        fstr=objUserIn.Function;
        if~ischar(fstr)
            fstr=func2str(fstr);
        end
        error(message('float2fixed:MFG:CoderAppxUnsupportedArch',architecture,fstr));
    end

end
