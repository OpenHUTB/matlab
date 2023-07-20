classdef AppPropertiesDialogWrapper<handle







    methods(Access=private)



        function obj=AppPropertiesDialogWrapper()
        end
    end

    methods(Access=public,Static)



        function obj=open(hCallingApp,appName,tg)
            obj=slrealtime.internal.guis.Explorer.AppPropertiesDialogWrapper.getInstance(hCallingApp,appName,tg);


            obj.UIFigure.Visible='off';
            obj.UIFigure.Visible='on';

            if nargout==0
                clear obj
            end
        end
    end

    methods(Access={?slrealtime.internal.guis.Explorer.AppPropertiesDialog},Static)



        function dialogClosed(appName)
            slrealtime.internal.guis.Explorer.AppPropertiesDialogWrapper.removeInstance(appName);
        end
    end

    methods(Access=private,Static)



        function obj=getInstance(hCallingApp,appName,tg)
            obj=slrealtime.internal.guis.Explorer.AppPropertiesDialogWrapper.manageInstance('get',appName);
            if(isempty(obj)||~isvalid(obj))
                obj=slrealtime.internal.guis.Explorer.AppPropertiesDialog(hCallingApp,appName,tg);
                slrealtime.internal.guis.Explorer.AppPropertiesDialogWrapper.setInstance(appName,obj);
            end
        end

        function setInstance(appName,obj)
            slrealtime.internal.guis.Explorer.AppPropertiesDialogWrapper.manageInstance('set',appName,obj);
        end

        function removeInstance(appName)
            slrealtime.internal.guis.Explorer.AppPropertiesDialogWrapper.manageInstance('remove',appName);
        end

        function varargout=manageInstance(command,varargin)
            mlock;
            persistent theInstanceMap;

            if isempty(theInstanceMap)
                theInstanceMap=containers.Map('KeyType','char','ValueType','any');
            end
            switch(command)
            case 'get'
                appName=varargin{1};
                if theInstanceMap.isKey(appName)
                    varargout{1}=theInstanceMap(appName);
                else
                    varargout{1}=[];
                end
            case 'set'
                appName=varargin{1};
                instance=varargin{2};
                theInstanceMap(appName)=instance;
            case 'remove'
                appName=varargin{1};
                theInstanceMap.remove(appName);
            otherwise
                assert(false);
            end
        end
    end
end
