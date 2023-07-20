function varargout=selectionLink(varargin)










    if nargout==0

        rmiml.selectionLinkHelper(varargin{:});

    else

        if mod(nargin,2)==0




            if~rmi.isInstalled()
                varargout{1}=java.util.ArrayList(0);
                return;
            end
        end

        result=rmiml.selectionLinkHelper(varargin{:});

        if ischar(result)

            varargout{1}=result;

        elseif iscell(result)


            if isempty(result)
                varargout{1}=java.util.ArrayList(0);
            else
                varargout{1}=rmiut.cellToJava(result,true);
            end

        else
            error('unexpected type returned by %s','rmiml.selectionLinkHelper()');
        end
    end

end
