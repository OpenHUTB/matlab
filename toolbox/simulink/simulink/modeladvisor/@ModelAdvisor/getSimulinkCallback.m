function output=getSimulinkCallback(callbackstyle,systemName,varargin)




    if ishandle(systemName)
        systemName=getfullname(systemName);
    end
    systemName=modeladvisorprivate('HTMLjsencode',systemName,'encode');

    switch callbackstyle
    case 'hilite_system'



        if nargin==3&&strcmp(varargin{1},'off')
            output=['matlab: modeladvisorprivate hiliteSystem ',systemName{:},' ''',varargin{1},''''];
        else
            output=['matlab: modeladvisorprivate hiliteSystem ',systemName{:}];
        end
    case 'open_system'
        output=['matlab: modeladvisorprivate hiliteSystem ',systemName{:}];
    case 'hilite_file'
        output=['matlab: modeladvisorprivate hiliteFile ',systemName{:}];
    otherwise
        DAStudio.error('Simulink:tools:MAInvalidSLCallbackStyle');
    end
