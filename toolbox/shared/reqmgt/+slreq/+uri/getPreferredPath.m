function varargout=getPreferredPath(varargin)





    if nargin==1


        if varargin{1}
            slreq.uri.ResourcePathHandler.enable();
        else
            slreq.uri.ResourcePathHandler.disable();
        end

    else




        varargout{1}=slreq.uri.ResourcePathHandler.getInstance.getPreferredPath(varargin{:});

    end
end
