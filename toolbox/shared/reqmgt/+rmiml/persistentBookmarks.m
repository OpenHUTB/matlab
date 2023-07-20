function result=persistentBookmarks(varargin)




    result=com.mathworks.services.Prefs.getBooleanPref('RMI.BOOKMARKS',false);

    if nargin>0
        value=varargin{1};
        if isa(value,'double')&&(value==0||value==1)
            value=~(value==0);
        end
        if isa(value,'logical')&&value~=result
            com.mathworks.services.Prefs.setBooleanPref('RMI.BOOKMARKS',value);
            com.mathworks.toolbox.simulink.slvnv.RmiDataLink.fireRmiSettingEvent('RMI.BOOKMARKS');
            if value
                disp(getString(message('Slvnv:rmiml:EnablingPersistentBookmarks')));
            else
                disp(getString(message('Slvnv:rmiml:DisablingPersistentBookmarks')));
            end
        end
    end
end
