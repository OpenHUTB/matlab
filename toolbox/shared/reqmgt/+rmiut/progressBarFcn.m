function resultOut=progressBarFcn(varargin)

    persistent waitH;

    nvarargin=length(varargin);
    if nvarargin==2&&isempty(varargin{2})
        if~isempty(waitH)&&ishandle(waitH)
            delete(waitH);
            drawnow;
            waitH=[];
            return;
        end
    end

    method=varargin{1};

    if~ischar(method)
        if~isempty(waitH)&&ishandle(waitH)
            delete(waitH);
            drawnow;
            waitH=[];
        end
        return;
    end

    switch lower(method)
    case 'set'

        if nargin>2
            msg=strrep(varargin{3},'_',' ');
        else
            msg=getString(message('Slvnv:rmiut:progressBar:ProcessingPleaseWait'));
        end

        if isempty(waitH)||~ishandle(waitH)

            if nargin>3
                winTitle=varargin{4};
            else
                winTitle=getString(message('Slvnv:rmiut:progressBar:ProcessingPleaseWait'));
            end

            waitH=waitbar(varargin{2},msg,...
            'Name',winTitle,...
            'CreateCancelBtn',@rmiut.progressBarFcn);

        end

        waitbar(varargin{2},waitH,msg);
        drawnow;

    case 'exists'
        resultOut=~isempty(waitH)&&ishandle(waitH);

    case 'delete'
        if~isempty(waitH)&&ishandle(waitH)
            delete(waitH);
            drawnow;
            waitH=[];
            return;
        end
    case 'iscanceled'
        resultOut=false;
        if isempty(waitH)||~ishandle(waitH)
            resultOut=true;
        end
    otherwise
        error(message('Slvnv:reqmgt:rmi:progressBarFcnUnknownMethod'));
    end
end
