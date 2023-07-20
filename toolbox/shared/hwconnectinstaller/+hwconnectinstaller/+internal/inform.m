function inform(varargin)




    persistent showmessage;
    mlock;


    if(isempty(showmessage))
        showmessage=false;
    end


    if((nargin>1)&&strncmp(varargin{1},'showmessage',length(varargin{1})))
        showmessage=varargin{2};
    end

    if(showmessage)
        disp(varargin{1});
    end

