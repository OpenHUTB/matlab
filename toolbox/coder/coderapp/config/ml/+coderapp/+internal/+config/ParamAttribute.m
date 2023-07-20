classdef(Sealed)ParamAttribute



    properties

        Name char{mustBeValidAttrName}



        Validator char=''

        FromCanonical char=''

        ToCanonical char=''

        FromSchema char='identity'
        Exclude logical=false
    end

    methods
        function this=ParamAttribute(name,varargin)
            if nargin<1
                return
            end
            if iscell(name)
                this=repmat(coderapp.internal.config.ParamAttribute(),1,nargin);
                argCells={name,varargin{:}};%#ok<CCAT>
                for i=1:numel(argCells)
                    if~iscell(argCells{i})
                        error('Invoking Attribute constructor with a cell array requires all arguments be cell arrays');
                    end
                    this(i)=coderapp.internal.config.ParamAttribute(argCells{i}{:});
                end
            else
                this.Name=name;
                if nargin<2
                    return
                end
                assert(mod(numel(varargin),2)==0,'Arguments should be provided as property-value pairs');
                for i=1:2:numel(varargin)
                    this.(varargin{i})=varargin{i+1};
                end
            end
        end
    end
end


function mustBeValidAttrName(arg)
    if~isempty(arg)&&~isvarname(arg)
        error('Attributes must be valid MATLAB names');
    end
end