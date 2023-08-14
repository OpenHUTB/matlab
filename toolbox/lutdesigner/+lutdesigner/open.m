function varargout=open(varargin)



    narginchk(0,1);

    lutDesigner=lutdesigner.LookupTableDesigner.getInstance();

    if nargin>0
        lutDesigner.setContext(varargin{1});
    end

    lutDesigner.open();

    if nargout>0
        varargout{1}=lutDesigner;
    end
end
