function utype_register(tmwName,userName,userTypeDepend,varargin)























    userTypes=rtwprivate('rtwattic','AtticData','userTypes');
    index=length(userTypes);
    next=index+1;
    userTypes{next}.tmwName=tmwName;
    userTypes{next}.userName=userName;
    if strcmp(lower(userTypeDepend),'primary')||...
        strcmp(lower(userTypeDepend),'secondary')||...
        strcmp(lower(userTypeDepend),'yes')||...
        strcmp(lower(userTypeDepend),'no')

        if~isempty(varargin)
            userTypes{next}.userTypeDepend=varargin{1};
            if length(varargin)>1
                type=varargin{2};
            else
                type='';
            end
        else
            userTypes{next}.userTypeDepend='';
            type='';
        end
    else
        userTypes{next}.userTypeDepend=userTypeDepend;
        if~isempty(varargin)
            type=varargin{1};
        else
            type='';
        end
    end

    if isempty(type)==1
        userTypes{next}.type='Both';
    elseif strcmp(lower(type),'parameter')==1
        userTypes{next}.type='Parameter';
    elseif strcmp(lower(type),'signal')==1
        userTypes{next}.type='Signal';
    else
        userTypes{next}.type='Both';
    end
    rtwprivate('rtwattic','AtticData','userTypes',userTypes);

