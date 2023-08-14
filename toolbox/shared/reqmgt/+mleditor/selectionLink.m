function varargout=selectionLink(varargin)






    unBlock=slreq.app.MainManager.blockEditors();

    if nargout==0


        rmiml.selectionLinkHelper(varargin{:});

    else



        if~rmi.isInstalled()
            varargout{1}={};
            return;
        end

        result=rmiml.selectionLinkHelper(varargin{:});

        if ischar(result)

            varargout{1}=result;

        elseif iscell(result)


            if isempty(result)
                varargout{1}={};
            else

                varargout{1}=[result(:,1),result(:,3)];
            end

        else
            error('unexpected type returned by %s','rmiml.selectionLinkHelper()');
        end
    end

end

