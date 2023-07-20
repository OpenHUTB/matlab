classdef TimeoutTimer<handle



























    properties
        Duration=1.0
        TimeoutFcn=[]
    end

    properties(Hidden)
hTimer
    end

    properties(Access=private)
pShowAfterTic
    end

    methods
        function w=TimeoutTimer(varargin)
            createTimer(w);
            setProps(w,varargin{:});
        end

        function delete(w)


            ht=w.hTimer;
            if~isempty(ht)&&isvalid(ht)
                delete(ht);
            end
            w.hTimer=[];
        end

        function start(w,delta)






            if isinf(w.Duration)
                w.pShowAfterTic=tic;
            else
                if nargin>1
                    updateDuration(w,delta);
                else
                    updateDuration(w);
                end
                w.pShowAfterTic=tic;
                if~isRunning(w)
                    start(w.hTimer);
                end
            end
        end

        function e=elapsed(w)


            t=w.pShowAfterTic;
            if isempty(t)
                e=[];
            else
                e=toc(t);
            end
        end

        function y=isRunning(w)


            ht=w.hTimer;
            if~isempty(ht)&&isvalid(ht)
                y=strcmpi(ht.Running,'on');
            else
                y=false;
            end
        end

        function wasRunning=stop(w)


            wasRunning=isRunning(w);
            if wasRunning
                stop(w.hTimer);
            end
        end

        function wasRunning=stopAndWait(w)


            wasRunning=stop(w);
            if wasRunning
                waitfor(w.hTimer);
            end
        end

        function set.Duration(w,val)
            validateattributes(val,{'double'},...
            {'scalar','real','>=',0},...
            'TimeoutTimer','Duration');
            w.Duration=val;
            updateDuration(w);
        end

        function set.TimeoutFcn(w,val)

            w.TimeoutFcn=val;
        end
    end

    methods(Access=private)
        function setProps(w,fcn,d)

            if nargin>1
                w.TimeoutFcn=fcn;
            end
            if nargin>2
                w.Duration=d;
            end
        end

        function createTimer(w)


            ht=timer;
            w.hTimer=ht;
            ht.Name='TimeoutTimer';
            ht.BusyMode='drop';
            ht.ExecutionMode='singleShot';
            ht.ObjectVisibility='off';



            ht.TimerFcn=@(t,ev)localTimeoutFcn(w,ev);
            ht.ErrorFcn=@(t,ev)localErrorFcn(w,ev);

            updateDuration(w);
        end

        function updateDuration(w,delta)






            stopAndWait(w);
            ht=w.hTimer;
            if~isempty(ht)&&isvalid(ht)
                if isinf(w.Duration)
                    ht.StartDelay=0;
                else
                    if nargin>1

                        dly=max(0,round((w.Duration+delta)*1000)/1000);
                        ht.StartDelay=dly;
                    else
                        ht.StartDelay=round(w.Duration*1000)/1000;
                    end
                end
            end
        end

        function localTimeoutFcn(w,ev)









            fcn=w.TimeoutFcn;
            if isempty(fcn)
                fcn=@defaultTimeoutFcn;
            end
            feval(fcn,w,ev);
        end

        function localErrorFcn(w,~)

            stopAndWait(w);
            fprintf('Error while executing TimeoutFcn function.\n');
            rethrow(lasterror);%#ok<LERR>
        end
    end
end

function defaultTimeoutFcn(~,~)

    disp('TimeoutTimer expired with no callback function specified.');
end
