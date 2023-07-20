function varargout=pirNetworkForFilterComp(varargin)















    persistent hNList;
    if isempty(hNList)
        hNList=[];
    end

    if nargin==0


        if isempty(hNList)
            varargout{1}=[];
        else
            varargout{1}=hNList(end);
        end
    elseif nargin==1
        if strcmpi(varargin{1},'pop')


            if~isempty(hNList)
                hNList(end)=[];
            end
        else

            hNList=[];
        end
    else


        if~isempty(hNList)
            hNList(end+1)=varargin{2};
        else
            hNList=varargin{2};
        end
    end
end
