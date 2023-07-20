classdef ExitSimulateSection<fusion.internal.scenarioApp.toolstrip.Section
    properties(SetAccess=private)
StopButton
    end

    methods
        function this=ExitSimulateSection(hApplication,hToolstrip)
            this@fusion.internal.scenarioApp.toolstrip.Section(hApplication,hToolstrip);

            import matlab.ui.internal.toolstrip.*;
            hApp=this.Application;

            this.Title=msgString(this,'ExitSimulateSectionTitle');
            this.Tag='exitsimulate';
            stop=Button(msgString(this,'StopButtonText'),Icon.CLOSE_24);
            stop.Description=msgString(this,'StopButtonDescription');
            stop.Tag='stopscene';
            stop.Enabled=true;
            stop.ButtonPushedFcn=hApp.initCallback(@this.stopSceneCallback);
            this.StopButton=stop;

            add(addColumn(this),stop);
        end

    end

    methods(Access=protected)
        function stopSceneCallback(this,~,~)
            stopSimulator(this.Application);
        end
    end
end