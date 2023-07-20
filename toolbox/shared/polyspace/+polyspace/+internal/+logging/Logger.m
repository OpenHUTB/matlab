

classdef Logger<handle

    properties
        Level;
        HandlerFcn;
    end

    properties(SetAccess=protected)
        Name;
    end

    methods



        function delete(this)
            polyspace.internal.logging.LoggerMgr.reset(this.Name);
        end
    end

    methods(Access={?polyspace.internal.logging.LoggerMgr})



        function this=Logger(name)
            if nargin<1
                name='';
            end
            this.Name=name;
            this.Level=polyspace.internal.logging.Level.INFO;
            this.HandlerFcn=@iDefaultHandler;
        end
    end

    methods



        function setLevel(this,level)
            this.Level=level;
        end




        function setHandler(this,HandlerFcn)
            this.HandlerFcn=HandlerFcn;
        end




        function set.Level(this,level)
            this.Level=polyspace.internal.logging.Level.convert(level);
        end




        function severe(this,varargin)
            this.log(polyspace.internal.logging.Level.SEVERE,varargin{:});
        end




        function warning(this,varargin)
            this.log(polyspace.internal.logging.Level.WARNING,varargin{:});
        end




        function info(this,varargin)
            this.log(polyspace.internal.logging.Level.INFO,varargin{:});
        end




        function config(this,varargin)
            this.log(polyspace.internal.logging.Level.CONFIG,varargin{:});
        end




        function fine(this,varargin)
            this.log(polyspace.internal.logging.Level.FINE,varargin{:});
        end

        function finer(this,varargin)
            this.log(polyspace.internal.logging.Level.FINER,varargin{:});
        end




        function finest(this,varargin)
            this.log(polyspace.internal.logging.Level.FINEST,varargin{:});
        end




        function log(this,level,msg,varargin)

            if(this.Level==polyspace.internal.logging.Level.OFF)||(this.Level>level)
                return
            end


            nameStr='';
            if~isempty(this.Name)
                nameStr=['(',this.Name,') '];
            end
            handlerFcn=this.HandlerFcn;
            if all(isspace(sprintf(msg,varargin{:})))
                handlerFcn(msg,varargin{:});
            else
                handlerFcn(['%s %s%s: ',msg,'\n'],...
                datestr(now),...
                nameStr,...
                char(level),...
                varargin{:});
            end
        end
    end

    methods(Static)



        function obj=getLogger(varargin)
            obj=polyspace.internal.logging.LoggerMgr.getLogger(varargin{:});
        end




        function setLevelForAll(level)
            names=polyspace.internal.logging.LoggerMgr.getLoggerNames();
            names=[{''},names];
            for ii=1:numel(names)
                obj=polyspace.internal.logging.LoggerMgr.getLogger(names{ii});
                obj.setLevel(level);
            end
        end




        function setHandlerForAll(HandlerFcn)
            names=polyspace.internal.logging.LoggerMgr.getLoggerNames();
            names=[{''},names];
            for ii=1:numel(names)
                obj=polyspace.internal.logging.LoggerMgr.getLogger(names{ii});
                obj.setHandler(HandlerFcn);
            end
        end




        function setDefaultLevel(level)
            polyspace.internal.logging.LoggerMgr.instance().setDefaultLevel(level);
        end




        function setDefaultHandler(DefaultHandlerFcn)
            polyspace.internal.logging.LoggerMgr.instance().setDefaultHandler(DefaultHandlerFcn);
        end
    end

end


function iDefaultHandler(varargin)
    fprintf(1,varargin{:});
end
