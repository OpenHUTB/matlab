classdef VizDebugger<handle




    properties
df
dfPacket
axes
plugin
modelName
mf0Model
    end
    methods
        function obj=VizDebugger(modelName,mf0Model)
            obj.modelName=modelName;
            obj.mf0Model=mf0Model;


            settings=ssm.app.VizDebuggerSettings(obj.mf0Model);
            settings.isEnabled=false;
            settings.pmSettings=ssm.app.LoggingSettings(obj.mf0Model);
            settings.pmSettings.enableLogging=true;


            obj.df=matlab.ui.internal.divfigure;
            obj.dfPacket=...
            matlab.ui.internal.FigureServices.getDivFigurePacket(obj.df);
            settings.divFigurePacketJSONString=jsonencode(obj.dfPacket);

            obj.axes=axes(obj.df);
            obj.axes.XLim=[-100,100];
            obj.axes.YLim=[-100,100];
        end
        function delete(obj)
            delete(obj.df);
        end
        function ret=settingsChange(obj,settings)
            ret={};
            try
                if~isempty(settings.xLim)
                    val=evalin('base',settings.xLim);
                    validateattributes(val,{'double'},{'size',[1,2]});
                    obj.axes.XLim=val;
                end
                if~isempty(settings.yLim)
                    val=evalin('base',settings.yLim);
                    validateattributes(val,{'double'},{'size',[1,2]});
                    obj.axes.YLim=val;
                end



                if settings.isEnabled
                    obj.registerPlugin();
                else
                    obj.unregisterPlugin();
                end
            catch ME
                ret.errorTitle=message('ssm:genericUI:ErrorSetAxes').getString;
                ret.error=ME.message;
            end
        end
        function preRunSetup(obj)

            bd=obj.mf0Model.topLevelElements;
            for i=1:length(bd)
                if isa(bd(i),'ssm.app.VizDebuggerSettings')
                    settings=bd(i);
                    break;
                end
            end

            if settings.isEnabled

                if~isempty(ssm.app.VizDebugger.getOrSet('axes'))
                    cla(ssm.app.VizDebugger.getOrSet('axes'));
                end

                if isempty(settings.busObj)||...
                    isempty(settings.x_field)||...
                    isempty(settings.y_field)

                    settings.isEnabled=false;
                    obj.unregisterPlugin();
                    return;
                end
                ssm.app.VizDebugger.getOrSet('agentMap',containers.Map);
                ssm.app.VizDebugger.getOrSet('xField',settings.x_field);
                ssm.app.VizDebugger.getOrSet('yField',settings.y_field);
                ssm.app.VizDebugger.getOrSet('axes',obj.axes);
                ssm.app.VizDebugger.getOrSet('breakpoints',...
                settings.breakpoints);


                obj.registerPlugin();
            else

                obj.unregisterPlugin();
            end
        end
        function postRunCleanup(obj)
            getOrSet('clear all');
            unregisterPlugin(obj);
        end
        function registerPlugin(obj)
            if isempty(obj.plugin)
                obj.plugin=ssm.plugin.addPlugin(obj.modelName,true,...
                @ssm.app.VizDebugger.callback);
                ssm.app.VizDebugger.getOrSet('plugin',obj.plugin);
            end
        end
        function unregisterPlugin(obj)
            if~isempty(obj.plugin)
                ssm.plugin.removePlugin(obj.plugin);
                obj.plugin=[];
            end
        end
    end
    methods(Static)
        function ret=getOrSet(varargin)
            persistent axes agentMap xField yField breakpoints plugin
            switch varargin{1}
            case 'agentMap'
                if length(varargin)==2
                    agentMap=varargin{2};
                end
                ret=agentMap;
            case 'xField'
                if length(varargin)==2
                    xField=varargin{2};
                end
                ret=xField;
            case 'yField'
                if length(varargin)==2
                    yField=varargin{2};
                end
                ret=yField;
            case 'breakpoints'
                if length(varargin)==2
                    breakpoints=varargin{2};
                end
                ret=breakpoints;
            case 'axes'
                if length(varargin)==2
                    axes=varargin{2};
                end
                ret=axes;
            case 'plugin'
                if length(varargin)==2
                    plugin=varargin{2};
                end
                ret=plugin;
            case 'clear all'
                clear axes agentMap xField yField breakpoints plugin;
                ret='';
            otherwise
                ret='';
            end
        end
        function ret=breakpointCheck(agent)%#ok<INUSD>
            ret='';

            breakpoints=ssm.app.VizDebugger.getOrSet('breakpoints');
            bps=breakpoints.toArray;

            try
                for i=1:length(bps)
                    if eval(bps(i).condition)
                        ret='pause';
                        break;
                    end
                end
            catch ME
                disp(ME.message);
            end
        end
        function ret=callback(msg)
            ret='';
            x=2*cosd(0:10:360);
            y=2*sind(0:10:360);
            xField=ssm.app.VizDebugger.getOrSet('xField');
            yField=ssm.app.VizDebugger.getOrSet('yField');
            agentMap=ssm.app.VizDebugger.getOrSet('agentMap');
            for i=1:length(msg)
                data=msg(i);
                if isa(data,'cell')
                    data=data{1};
                end
                if strcmp(data.command,'INSERT OR UPDATE')
                    ret=ssm.app.VizDebugger.breakpointCheck(data);

                    xVal=eval(['data.',xField]);
                    yVal=eval(['data.',yField]);
                    if~agentMap.isKey(num2str(data.agent__ID__))
                        agentMap(num2str(data.agent__ID__))=...
                        patch(ssm.app.VizDebugger.getOrSet('axes'),...
                        x+xVal,y+yVal,[rand,rand,rand]);
                    else
                        set(agentMap(num2str(data.agent__ID__)),...
                        'Xdata',x+xVal,'Ydata',y+yVal);
                    end
                end
            end
        end
    end
end