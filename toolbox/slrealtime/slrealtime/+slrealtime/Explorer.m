classdef Explorer<handle











    methods(Access=private)



        function obj=Explorer()
        end
    end

    methods(Access=public,Static)



        function obj=open(varargin)


            if nargin==0
                tabToFocusStr='';
            elseif nargin==1
                tabToFocusStr=varargin{1};
            end

            obj=slrealtime.Explorer.getInstance(false,tabToFocusStr);





            if~isempty(obj)
                obj.App.bringToFront();
            end

            if nargout==0
                clear obj;
            end
        end
    end

    methods(Access={?slrealtime.internal.guis.Explorer.AppExplorer},Static)



        function dialogClosed()
            slrealtime.Explorer.setInstance([]);
        end
    end

    methods(Access=public,Static,Hidden)



        function obj=getObjForTesting()





            obj=slrealtime.Explorer.getInstance(true);
        end
        function obj=openForTesting()
            obj=slrealtime.Explorer.getInstance();
            waitfor(obj,'CompletelyOpened',true);
            if nargout==0
                clear obj;
            end
        end
        function closeForTesting(obj)



            if~isempty(obj)&&isvalid(obj)




                obj.App.close();
            else
                slrealtime.Explorer.setInstance([]);
            end
        end
    end

    methods(Access=private,Static)



        function obj=getInstance(varargin)
            if nargin==0
                testing=false;
                tabToFocusStr='';
            elseif nargin==1
                testing=varargin{1};
                tabToFocusStr='';
            elseif nargin==2
                testing=varargin{1};
                tabToFocusStr=varargin{2};
            end

            [obj,isopen]=slrealtime.Explorer.manageInstance('get');
            if testing
                return;
            end
            if isempty(obj)
                if isempty(isopen)||~isopen























                    slrealtime.Explorer.setIsOpen(true);
                    cleanupObj=onCleanup(@()slrealtime.Explorer.setIsOpen([]));
                else




                    return;
                end
                obj=slrealtime.internal.guis.Explorer.AppExplorer(tabToFocusStr);
                slrealtime.Explorer.setInstance(obj);
            else

                switch tabToFocusStr
                case 'TargetConfiguration'
                    obj.TargetConfigurationDocument.Selected=true;
                case 'SystemLogViewer'
                    obj.SystemLogViewerDocument.Selected=true;
                case 'TETMonitor'
                    obj.openTETMonitorDocument();
                end
            end
        end
        function setInstance(obj)
            slrealtime.Explorer.manageInstance('set',obj);
        end
        function setIsOpen(isopen)
            slrealtime.Explorer.manageInstance('setIsOpen',isopen);
        end
        function varargout=manageInstance(command,varargin)
            mlock;
            persistent theInstance;
            persistent isOpen;
            switch(command)
            case 'get'
                varargout{1}=theInstance;
                varargout{2}=isOpen;
            case 'set'
                theInstance=varargin{1};
            case 'setIsOpen'
                isOpen=varargin{1};
            otherwise
                assert(false);
            end
        end
    end
end
