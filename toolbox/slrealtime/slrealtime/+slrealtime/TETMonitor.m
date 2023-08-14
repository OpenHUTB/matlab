classdef TETMonitor<handle














    methods(Access=private)



        function obj=TETMonitor()
        end
    end

    methods(Access=public,Static)



        function open()
            obj=slrealtime.TETMonitor.getInstance();
            obj.show;
        end
    end

    methods(Access=public,Static,Hidden)



        function url=getURL()
            obj=slrealtime.TETMonitor.getInstance();
            url=obj.getUrlForTesting();
        end

        function commReady=getCommReady()
            obj=slrealtime.TETMonitor.getInstance();
            commReady=obj.getCommForTesting();
        end

        function addDummyTarget(targetName)
            obj=slrealtime.TETMonitor.getInstance();
            obj.add(targetName);
        end

        function removeDummyTarget(targetName)
            obj=slrealtime.TETMonitor.getInstance();
            obj.remove(targetName);
        end

        function close(varargin)


            if nargin==0
                isaExplorerTab=false;
            elseif nargin==1
                isaExplorerTab=varargin{1};
            end
            obj=slrealtime.TETMonitor.getInstance();
            obj.closeDlg(isaExplorerTab);
        end
    end

    methods(Access={?slrealtime.Target},Static,Hidden)



        function add(targetName)
            obj=slrealtime.TETMonitor.getInstance();
            obj.add(targetName);
        end

        function remove(targetName)
            obj=slrealtime.TETMonitor.getInstance();
            obj.remove(targetName);
        end

        function activate(targetName,modelName,tetInfo)
            obj=slrealtime.TETMonitor.getInstance();
            obj.activate(targetName,modelName,tetInfo);
        end

        function deactivate(targetName)
            obj=slrealtime.TETMonitor.getInstance();
            obj.deactivate(targetName);
        end

        function runOnce(targetName,tetInfo)
            obj=slrealtime.TETMonitor.getInstance();
            obj.runOnce(targetName,tetInfo);
        end
    end

    methods(Access=private,Static)



        function obj=getInstance()
            obj=slrealtime.TETMonitor.manageInstance('get');
            if isempty(obj)
                obj=slrealtime.internal.TETMonitor;
                slrealtime.TETMonitor.setInstance(obj);
            end
        end
        function setInstance(obj)
            slrealtime.TETMonitor.manageInstance('set',obj);
        end
        function varargout=manageInstance(command,varargin)
            mlock;
            persistent theInstance;
            switch(command)
            case 'get'
                varargout{1}=theInstance;
            case 'set'
                theInstance=varargin{1};
            otherwise
                assert(false);
            end
        end
    end
end
