classdef(Hidden)FadeTimer<handle



    properties
ExpectedStartTime








        FadeTime(1,1){mustBeGreaterThanOrEqual(FadeTime,0)}=0.25


Running


Timer
    end

    properties(SetAccess=private)


        CurrentFade(1,1){mustBeGreaterThanOrEqual(CurrentFade,0),...
        mustBeLessThanOrEqual(CurrentFade,1)}=0;
    end

    properties(Access=private,Transient)
        StartTime=[]
        StartLevel=0
        LastCallTime=[]
        Queued=false;
    end

    events
Fade
    end

    methods
        function this=FadeTimer(varargin)
            this.Timer=timer(varargin{:});

            this.Timer.TimerFcn=@(e,d)this.timercb;
        end

        function result=get.Running(this)
            result='off';
            if isvalidTimer(this)
                result=this.Timer.Running;
            end
        end

        function fade(this)
            t_call=datetime('now');


            if isempty(this)||~isvalid(this)
                return;
            end



            if strcmpi(this.Running,'off')
                this.Queued=false;
                return;
            end

            if~isempty(this.LastCallTime)&&...
                seconds(t_call-this.LastCallTime)>2*this.Timer.Period


                this.CurrentFade=1;
            else
                if isempty(this.StartTime)


                    this.CurrentFade=this.StartLevel;
                    this.StartTime=t_call;
                else


                    rate=1/this.FadeTime;
                    newfade=this.StartLevel+rate*(seconds(t_call-this.StartTime));
                    this.CurrentFade=max(0,min(1,newfade));
                end
            end
            this.LastCallTime=t_call;

            if this.CurrentFade>=1

                stop(this);
            end

            this.notify('Fade');
            this.Queued=false;
        end

        function timercb(this)
            if~this.Queued
                this.Queued=true;
                cb=@(e,d)this.fade;
                matlab.graphics.internal.drawnow.callback(cb);
            end
        end

        function result=isvalidTimer(this)
            result=~isempty(this.Timer)&&isvalid(this.Timer);
        end

        function start(this,level)
            if nargin<2
                level=0;
            end
            this.StartLevel=level;
            this.LastCallTime=[];
            this.StartTime=[];



            dtnow=datetime('now');
            if~isempty(this.ExpectedStartTime)&&(dtnow>this.ExpectedStartTime)

                this.CurrentFade=1;
                stop(this);
                this.notify('Fade');
            else

                start(this.Timer);
            end

            this.ExpectedStartTime=[];
        end

        function stop(this)
            stop(this.Timer);
            this.StartTime=[];
            this.LastCallTime=[];
            this.StartLevel=0;
        end

        function delete(this)
            if~isempty(this.Timer)&&isvalid(this.Timer)
                stop(this.Timer);
                delete(this.Timer);
            end
        end
    end

end