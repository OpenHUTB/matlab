

classdef LoggerMgr<handle

    properties(Access=protected)
NameToLoggers
DefaultLogger
DefaultLevel
DefaultHandlerFcn
    end

    methods



        function delete(this)
            this.NameToLoggers=[];
            this.DefaultLogger=[];
            this.DefaultHandlerFcn=[];
        end




        function setDefaultLevel(this,level)
            this.DefaultLevel=polyspace.internal.logging.Level.convert(level);
        end




        function setDefaultHandler(this,DefaultHandlerFcn)
            this.DefaultHandlerFcn=DefaultHandlerFcn;
        end
    end

    methods(Access=private)



        function this=LoggerMgr()
            this.NameToLoggers=containers.Map('KeyType','char','ValueType','any');
            this.DefaultLogger=polyspace.internal.logging.Logger();
            this.DefaultLevel=this.DefaultLogger.Level;
            this.DefaultHandlerFcn=this.DefaultLogger.HandlerFcn;
        end
    end

    methods(Static)



        function mgrObj=instance()
            mlock;
            persistent mgrObjSingleton;
            if isempty(mgrObjSingleton)||~isvalid(mgrObjSingleton)
                mgrObjSingleton=polyspace.internal.logging.LoggerMgr();
            end
            mgrObj=mgrObjSingleton;
        end




        function reset(logName)
            obj=polyspace.internal.logging.LoggerMgr.instance();

            if nargin<1
                names=obj.NameToLoggers.keys();
                for ii=1:numel(names)
                    logObj=obj.NameToLoggers(names{ii});
                    delete(logObj);
                end
                obj.NameToLoggers=containers.Map('KeyType','char','ValueType','any');
            else
                if obj.NameToLoggers.isKey(logName)
                    logObj=obj.NameToLoggers(logName);
                    obj.NameToLoggers.remove(logName);
                    delete(logObj);
                end
            end

        end




        function logObj=getLogger(logName)
            obj=polyspace.internal.logging.LoggerMgr.instance();
            if nargin<1||isempty(logName)
                logObj=obj.DefaultLogger;
            else
                if obj.NameToLoggers.isKey(logName)
                    logObj=obj.NameToLoggers(logName);
                else
                    logObj=polyspace.internal.logging.Logger(logName);
                    logObj.Level=obj.DefaultLevel;
                    obj.NameToLoggers(logName)=logObj;
                end
            end
        end




        function names=getLoggerNames()
            obj=polyspace.internal.logging.LoggerMgr.instance();
            names=obj.NameToLoggers.keys();
        end
    end
end
