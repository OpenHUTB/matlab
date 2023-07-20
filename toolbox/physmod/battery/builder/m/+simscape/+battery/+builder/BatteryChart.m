classdef BatteryChart<matlab.graphics.chartcontainer.ChartContainer




















































    properties(Dependent)


        Battery(:,1){...
        mustBeA(Battery,"simscape.battery.builder.internal.Battery"),...
        mustBeScalarOrEmpty}=...
        simscape.battery.builder.Cell.empty(0,1)
    end


    properties


        SimulationStrategyVisible(1,1)...
        matlab.lang.OnOffSwitchState="off"


        SimulationStrategyLineColor=[0.85,0.325,0.098]


        SimulationStrategyLineWidth(1,1)double{mustBePositive}=1.5


        SimulationStrategyLineStyle(1,1)string...
        {mustBeMember(SimulationStrategyLineStyle,...
        ["-","--",":","-.","none"])}=":"


        AxesVisible(1,1)matlab.lang.OnOffSwitchState="on"

        AxesXDir(1,1)string...
        {mustBeMember(AxesXDir,["normal","reverse"])}="reverse"

        AxesYDir(1,1)string...
        {mustBeMember(AxesYDir,["normal","reverse"])}="normal"

        AxesZDir(1,1)string...
        {mustBeMember(AxesZDir,["normal","reverse"])}="normal"

        LightColor=[1,1,1]

        LightStyle(1,1)string{mustBeMember(LightStyle,...
        ["ambient","infinite","local"])}="infinite"

        LightPosition(1,3)double...
        {mustBeReal,mustBeFinite}=[-1,-1,1]

        LightVisible(1,1)matlab.lang.OnOffSwitchState="on"
    end


    properties(Access=private,Transient,NonCopyable)

        Axes(1,1)matlab.graphics.axis.Axes

        Light(1,1)matlab.graphics.primitive.Light

        BatteryPatch(1,1)matlab.graphics.primitive.Patch

        SimulationStrategyPatch(1,1)matlab.graphics.primitive.Patch

        SimulationStrategyToggleButton(1,1)...
        matlab.ui.controls.ToolbarStateButton
    end


    properties(Access=private)

        Battery_(:,1){...
        mustBeA(Battery_,"simscape.battery.builder.internal.Battery"),...
        mustBeScalarOrEmpty}=...
        simscape.battery.builder.Cell.empty(0,1)

        DataStorage(1,1)struct
    end


    properties(Access=private,Transient)

        PatchUpdateRequired(1,1)logical=true
    end


    methods

        function varargout=xlabel(obj,varargin)


            [varargout{1:nargout}]=xlabel(obj.Axes,varargin{:});

        end

        function varargout=ylabel(obj,varargin)


            [varargout{1:nargout}]=ylabel(obj.Axes,varargin{:});

        end

        function varargout=zlabel(obj,varargin)


            [varargout{1:nargout}]=zlabel(obj.Axes,varargin{:});

        end

        function varargout=title(obj,varargin)


            [varargout{1:nargout}]=title(obj.Axes,varargin{:});

        end

        function varargout=subtitle(obj,varargin)


            [varargout{1:nargout}]=subtitle(obj.Axes,varargin{:});

        end

        function grid(obj,varargin)


            grid(obj.Axes,varargin{:})

        end

        function box(obj,varargin)


            box(obj.Axes,varargin{:})

        end

        function varargout=xlim(obj,varargin)


            [varargout{1:nargout}]=xlim(obj.Axes,varargin{:});

        end

        function varargout=ylim(obj,varargin)


            [varargout{1:nargout}]=ylim(obj.Axes,varargin{:});

        end

        function varargout=zlim(obj,varargin)


            [varargout{1:nargout}]=zlim(obj.Axes,varargin{:});

        end

        function varargout=xticks(obj,varargin)


            [varargout{1:nargout}]=xticks(obj.Axes,varargin{:});

        end

        function varargout=yticks(obj,varargin)


            [varargout{1:nargout}]=yticks(obj.Axes,varargin{:});

        end

        function varargout=zticks(obj,varargin)


            [varargout{1:nargout}]=zticks(obj.Axes,varargin{:});

        end

        function varargout=xticklabels(obj,varargin)


            [varargout{1:nargout}]=xticklabels(obj.Axes,varargin{:});

        end

        function varargout=yticklabels(obj,varargin)


            [varargout{1:nargout}]=yticklabels(obj.Axes,varargin{:});

        end

        function varargout=zticklabels(obj,varargin)


            [varargout{1:nargout}]=zticklabels(obj.Axes,varargin{:});

        end

        function varargout=xtickformat(obj,varargin)


            [varargout{1:nargout}]=xtickformat(obj.Axes,varargin{:});

        end

        function varargout=ytickformat(obj,varargin)


            [varargout{1:nargout}]=ytickformat(obj.Axes,varargin{:});

        end

        function varargout=ztickformat(obj,varargin)


            [varargout{1:nargout}]=ztickformat(obj.Axes,varargin{:});

        end

        function varargout=xtickangle(obj,varargin)


            [varargout{1:nargout}]=xtickangle(obj.Axes,varargin{:});

        end

        function varargout=ytickangle(obj,varargin)


            [varargout{1:nargout}]=ytickangle(obj.Axes,varargin{:});

        end

        function varargout=ztickangle(obj,varargin)


            [varargout{1:nargout}]=ztickangle(obj.Axes,varargin{:});

        end

        function varargout=colormap(obj,varargin)


            [varargout{1:nargout}]=colormap(obj.Axes,varargin{:});

        end

        function varargout=view(obj,varargin)


            [varargout{1:nargout}]=view(obj.Axes,varargin{:});

        end

        function setDefaultLabels(obj)


            xlabel(obj,"X Forward direction, m")
            ylabel(obj,"Y Lateral direction, m")
            zlabel(obj,"Z Vertical direction, m")

        end

    end


    methods

        function value=get.Battery(obj)

            value=obj.Battery_;

        end

        function set.Battery(obj,value)


            obj.PatchUpdateRequired=true;


            obj.Battery_=value;

        end

        function set.SimulationStrategyLineColor(obj,value)

            obj.SimulationStrategyLineColor=...
            validatecolor(value,"one");

        end

        function set.LightColor(obj,value)
            obj.LightColor=validatecolor(value,"one");
        end

        function value=get.DataStorage(obj)

            ax=obj.getAxes();


            textProps=["BackgroundColor","Color","EdgeColor",...
            "FontAngle","FontName","FontSize","FontSmoothing",...
            "FontUnits","FontWeight","HandleVisibility",...
            "HorizontalAlignment","Interpreter","LineStyle",...
            "LineWidth","Margin","Position","Rotation",...
            "String","Tag","Units","VerticalAlignment","Visible"];
            for prop=textProps
                value.XLabel.(prop)=ax.XLabel.(prop);
                value.YLabel.(prop)=ax.YLabel.(prop);
                value.ZLabel.(prop)=ax.ZLabel.(prop);
                value.Title.(prop)=ax.Title.(prop);
                value.Subtitle.(prop)=ax.Subtitle.(prop);
            end

            value.XGrid=ax.XGrid;
            value.XMinorGrid=ax.XMinorGrid;
            value.YGrid=ax.YGrid;
            value.YMinorGrid=ax.YMinorGrid;
            value.Box=ax.Box;
            value.XLim=ax.XLim;
            value.XLimMode=ax.XLimMode;
            value.YLim=ax.YLim;
            value.YLimMode=ax.YLimMode;
            value.ZLim=ax.ZLim;
            value.ZLimMode=ax.ZLimMode;
            value.XTick=ax.XTick;
            value.XTickMode=ax.XTickMode;
            value.XTickLabel=ax.XTickLabel;
            value.XTickLabelMode=ax.XTickLabelMode;
            value.XTickLabelRotation=ax.XTickLabelRotation;
            value.XTickLabelRotationMode=ax.XTickLabelRotationMode;
            value.XTickLabelFormat=ax.XAxis.TickLabelFormat;
            value.YTick=ax.YTick;
            value.YTickMode=ax.YTickMode;
            value.YTickLabel=ax.YTickLabel;
            value.YTickLabelMode=ax.YTickLabelMode;
            value.YTickLabelRotation=ax.YTickLabelRotation;
            value.YTickLabelRotationMode=ax.YTickLabelRotationMode;
            value.YTickLabelFormat=ax.YAxis.TickLabelFormat;
            value.ZTick=ax.ZTick;
            value.ZTickMode=ax.ZTickMode;
            value.ZTickLabel=ax.ZTickLabel;
            value.ZTickLabelMode=ax.ZTickLabelMode;
            value.ZTickLabelRotation=ax.ZTickLabelRotation;
            value.ZTickLabelRotationMode=ax.ZTickLabelRotationMode;
            value.ZTickLabelFormat=ax.ZAxis.TickLabelFormat;
            value.View=ax.View;
            value.Colormap=ax.Colormap;
        end

        function set.DataStorage(obj,value)

            ax=obj.getAxes();
            textProps=["BackgroundColor","Color","EdgeColor",...
            "FontAngle","FontName","FontSize","FontSmoothing",...
            "FontUnits","FontWeight","HandleVisibility",...
            "HorizontalAlignment","Interpreter","LineStyle",...
            "LineWidth","Margin","Position","Rotation",...
            "String","Tag","Units","VerticalAlignment","Visible"];
            for prop=textProps
                ax.XLabel.(prop)=value.XLabel.(prop);
                ax.YLabel.(prop)=value.YLabel.(prop);
                ax.ZLabel.(prop)=value.ZLabel.(prop);
                ax.Title.(prop)=value.Title.(prop);
                ax.Subtitle.(prop)=value.Subtitle.(prop);
            end
            ax.XGrid=value.XGrid;
            ax.XMinorGrid=value.XMinorGrid;
            ax.YGrid=value.YGrid;
            ax.YMinorGrid=value.YMinorGrid;
            ax.Box=value.Box;
            ax.XLim=value.XLim;
            ax.XLimMode=value.XLimMode;
            ax.YLim=value.YLim;
            ax.YLimMode=value.YLimMode;
            ax.ZLim=value.ZLim;
            ax.ZLimMode=value.ZLimMode;
            ax.XTick=value.XTick;
            ax.XTickMode=value.XTickMode;
            ax.XTickLabel=value.XTickLabel;
            ax.XTickLabelMode=value.XTickLabelMode;
            ax.XTickLabelRotation=value.XTickLabelRotation;
            ax.XTickLabelRotationMode=value.XTickLabelRotationMode;
            ax.XTickLabelFormat=value.XAxis.TickLabelFormat;
            ax.YTick=value.YTick;
            ax.YTickMode=value.YTickMode;
            ax.YTickLabel=value.YTickLabel;
            ax.YTickLabelMode=value.YTickLabelMode;
            ax.YTickLabelRotation=value.YTickLabelRotation;
            ax.YTickLabelRotationMode=value.YTickLabelRotationMode;
            ax.YTickLabelFormat=value.YAxis.TickLabelFormat;
            ax.ZTick=value.ZTick;
            ax.ZTickMode=value.ZTickMode;
            ax.ZTickLabel=value.ZTickLabel;
            ax.ZTickLabelMode=value.ZTickLabelMode;
            ax.ZTickLabelRotation=value.ZTickLabelRotation;
            ax.ZTickLabelRotationMode=value.ZTickLabelRotationMode;
            ax.ZTickLabelFormat=value.ZAxis.TickLabelFormat;
            ax.View=value.View;
            ax.Colormap=value.Colormap;
        end

    end

    methods(Access=protected)

        function setup(obj)



            obj.Axes=obj.getAxes();
            cmap=gray();
            cmap=cmap(200:end-20,:);
            set(obj.Axes,...
            "XDir","reverse",...
            "DataAspectRatio",[1,1,1],...
            "XGrid","on",...
            "YGrid","on",...
            "View",[-37.5,30],...
            "Colormap",cmap,...
            "Interactions",[]);


            axtb=axtoolbar(obj.Axes,["rotate","restoreview"]);
            obj.SimulationStrategyToggleButton=...
            axtoolbarbtn(axtb,"state","ValueChangedFcn",@obj.onSimulationStrategyToggleButtonPushed,...
            "Icon",fullfile(matlabroot,'toolbox','physmod','battery','builder','m','+simscape','+battery','+builder','+internal','Strategy.png'),...
            "Tooltip","Show/hide simulation strategy",...
            "Value","off");


            obj.BatteryPatch=patch(...
            "Parent",obj.Axes,...
            "HandleVisibility","off",...
            "FaceLighting","gouraud",...
            "FaceColor","interp",...
            "CDataMapping","direct",...
            "EdgeColor","none",...
            "Faces",NaN,...
            "Vertices",NaN(1,2),...
            "FaceVertexCData",NaN);

            obj.SimulationStrategyPatch=patch(...
            "Parent",obj.Axes,...
            "Visible","off",...
            "DisplayName","Simulation Strategy",...
            "FaceColor","none",...
            "CDataMapping","direct",...
            "EdgeColor",obj.SimulationStrategyLineColor,...
            "LineStyle",obj.SimulationStrategyLineStyle,...
            "LineWidth",obj.SimulationStrategyLineWidth,...
            "Faces",NaN,...
            "Vertices",NaN(1,2),...
            "FaceVertexCData",NaN);


            obj.Light=light("Parent",obj.Axes,...
            "Position",[-1,-1,1]);


            legend(obj.Axes,"Location","southoutside")

        end

        function update(obj)


            if obj.PatchUpdateRequired


                if~isempty(obj.Battery)


                    batteryPatchDef=obj.Battery.BatteryPatchDefinition;
                    set(obj.BatteryPatch,...
                    "Faces",batteryPatchDef.faces,...
                    "Vertices",batteryPatchDef.vertices,...
                    "FaceVertexCData",batteryPatchDef.facevertexcdata)
                    strategyPatchDef=...
                    obj.Battery.SimulationStrategyPatchDefinition;
                    set(obj.SimulationStrategyPatch,...
                    "Faces",strategyPatchDef.faces,...
                    "Vertices",strategyPatchDef.vertices,...
                    "FaceVertexCData",strategyPatchDef.facevertexcdata)
                else

                    set([obj.BatteryPatch,...
                    obj.SimulationStrategyPatch],...
                    "Faces",NaN,...
                    "Vertices",NaN(1,2),...
                    "FaceVertexCData",NaN)
                end


                obj.PatchUpdateRequired=false;

            end


            simStratVisible=obj.SimulationStrategyVisible;
            set(obj.SimulationStrategyPatch,...
            "Visible",simStratVisible,...
            "EdgeColor",obj.SimulationStrategyLineColor,...
            "LineStyle",obj.SimulationStrategyLineStyle,...
            "LineWidth",obj.SimulationStrategyLineWidth)
            set(obj.Axes,...
            "Visible",obj.AxesVisible,...
            "XDir",obj.AxesXDir,...
            "YDir",obj.AxesYDir,...
            "ZDir",obj.AxesZDir)

            set(obj.Light,...
            "Color",obj.LightColor,...
            "Style",obj.LightStyle,...
            "Position",obj.LightPosition,...
            "Visible",obj.LightVisible)
            obj.Axes.Legend.Visible=simStratVisible;
            obj.SimulationStrategyToggleButton.Value=simStratVisible;

        end

        function propGroups=getPropertyGroups(obj)



            batteryList=struct("Battery",obj.Battery);
            batteryGroup=matlab.mixin.util.PropertyGroup(...
            batteryList,"Battery:");

            simStratList=struct("SimulationStrategyVisible",...
            obj.SimulationStrategyVisible,...
            "SimulationStrategyLineColor",...
            obj.SimulationStrategyLineColor,...
            "SimulationStrategyLineStyle",...
            obj.SimulationStrategyLineStyle,...
            "SimulationStrategyLineWidth",...
            obj.SimulationStrategyLineWidth);
            simStratGroup=matlab.mixin.util.PropertyGroup(...
            simStratList,"Simulation Strategy:");

            axesList=struct("AxesVisible",obj.AxesVisible,...
            "AxesXDir",obj.AxesXDir,...
            "AxesYDir",obj.AxesYDir,...
            "AxesZDir",obj.AxesZDir);
            axesGroup=matlab.mixin.util.PropertyGroup(...
            axesList,"Axes Properties:");

            lightList=struct("LightColor",obj.LightColor,...
            "LightStyle",obj.LightStyle,...
            "LightPosition",obj.LightPosition,...
            "LightVisible",obj.LightVisible);
            lightGroup=matlab.mixin.util.PropertyGroup(...
            lightList,"Light Properties:");

            generalList=struct("Parent",obj.Parent,...
            "Layout",obj.Layout,...
            "Units",obj.Units,...
            "Position",obj.Position,...
            "Visible",obj.Visible);
            generalGroup=matlab.mixin.util.PropertyGroup(...
            generalList,"General:");

            propGroups=[batteryGroup,simStratGroup,axesGroup,...
            lightGroup,generalGroup];

        end

    end

    methods(Access=private)

        function onSimulationStrategyToggleButtonPushed(obj,~,~)





            onoff=obj.SimulationStrategyToggleButton.Value;
            obj.SimulationStrategyPatch.Visible=onoff;
            obj.Axes.Legend.Visible=onoff;

        end

    end

end
