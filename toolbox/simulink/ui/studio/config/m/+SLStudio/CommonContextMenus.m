function schemas=CommonContextMenus(varargin)
    if nargin==1

        param=varargin{1};
        if ischar(param)
            if strcmpi(param,'initialize')
                initializeContextMenus;
            else
                throw(getBadParamException);
            end
        else
            throw(getBadParamException);
        end
    elseif nargin==2

        selector=varargin{1};
        cbinfo=varargin{2};
        if isa(selector,'char')&&isa(cbinfo,'SLM3I.CallbackInfo')
            schemas=getContextMenu(selector,cbinfo);
        else
            throw(getBadParamException);
        end
    else
        throw(getBadParamException);
    end

end

function ex=getBadParamException
    ex=MException('Simulink:ContextMenus:BadParam',...
    'The parameter must be either the string ''initialize'' or ( char, cbinfo ).');
end

function initializeContextMenus

end

function schemas=getContextMenu(selector,cbinfo)
    switch selector
    case 'ModelBrowserHeaderContextMenu'
        schemas=ModelBrowserHeaderContextMenu(cbinfo);
    otherwise
        schemas={};
    end
end






function schemas=ModelBrowserHeaderContextMenu(cbinfo)
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schemas={im.getAction('Simulink:ShowReferenced'),...
    im.getAction('Simulink:ShowLibLinks'),...
    im.getAction('Simulink:LookUnderMasks'),...
    'separator',...
    im.getAction('Simulink:ShowModelBrowser')
    };
end




