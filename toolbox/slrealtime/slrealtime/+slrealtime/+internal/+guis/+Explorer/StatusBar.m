classdef StatusBar<handle




    properties
App
StatusLabel
ExecTimeLabel
RecordingStatusLabel

    end

    properties(Access=private)






    end


    methods

        function this=StatusBar(hApp)
            this.App=hApp;


            import matlab.ui.internal.statusbar.*

            bar=StatusBar();
            bar.Tag="statusBar";

            this.StatusLabel=StatusLabel();
            this.StatusLabel.Tag="statusLabel";
            this.StatusLabel.Width=500;
            bar.add(this.StatusLabel);









            this.ExecTimeLabel=StatusLabel();
            this.ExecTimeLabel.Tag="execTimeLabel";
            this.ExecTimeLabel.Description=message('slrealtime:explorer:executionTime').getString;
            bar.add(this.ExecTimeLabel);

            this.RecordingStatusLabel=StatusLabel();
            this.RecordingStatusLabel.Tag="recordingStatusLabel";
            this.RecordingStatusLabel.Description=message('slrealtime:explorer:recordingStatus').getString;
            bar.add(this.RecordingStatusLabel);

            this.App.App.add(bar);






        end

        function disable(this)
            this.StatusLabel.Text='';
            this.ExecTimeLabel.Text='';
        end









        function modelStateChanged(this,src,evnt,varargin)
            targetName=varargin{1};


            if~isempty(this.App.TargetManager)&&strcmp(this.App.TargetManager.getSelectedTargetName(),targetName)

                this.StatusLabel.Text=[char(evnt.AffectedObject.ModelState)...
                ,': ',evnt.AffectedObject.ModelProperties.Application];
            end
        end

        function execTimeChanged(this,src,evnt,varargin)
            targetName=varargin{1};


            if~isempty(this.App.TargetManager)&&strcmp(this.App.TargetManager.getSelectedTargetName(),targetName)
                execTime=evnt.AffectedObject.ModelExecProperties.ExecTime;
                if(execTime~=0)
                    this.ExecTimeLabel.Text=['T=',num2str(execTime)];




                else
                    this.ExecTimeLabel.Text='';




                end
            end
        end

        function recordingStatusChanged(this)
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(this.App.TargetManager.getSelectedTargetName());
            if~isempty(tg)
                if tg.get('Recording')
                    this.RecordingStatusLabel.Text='';
                else
                    this.RecordingStatusLabel.Text=['   [',char(string(message('slrealtime:explorer:recordingStopped'))),']'];
                end
            end
        end

    end

end
