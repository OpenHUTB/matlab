classdef hdlTimer


    properties(Hidden=true)
        inJVMmode=true;
        timerObj=[];
        timerActive=true;
    end

    methods(Static)

        function hdlPrintProgressDots(arg1,arg2,this)%#ok<INUSD>

            fprintf(1,'.');

            progressLen=get(arg1,'TasksExecuted');
            if mod(progressLen,80)==0
                fprintf(1,'\n');
            end
        end
    end

    methods
        function disp(this)
            fprintf('hdlTimer : timer object / state -> %d, jvm -> %d\n',this.timerActive,this.inJVMmode);
        end


        function this=hdlTimer()
            this.timerObj=timer('Name','myTimer',...
            'ExecutionMode','fixedSpacing',...
            'TimerFcn',@hdlTimer.hdlPrintProgressDots,...
            'StartFcn','',...
            'StopFcn','',...
            'StartDelay',10,...
            'Period',10);
        end


        function setup(this)
            if(this.inJVMmode)
                start(this.timerObj);
            end
        end


        function cleanup(this)
            if this.timerActive
                this.timerActive=false;
                if(this.inJVMmode)
                    stop(this.timerObj);
                end
                fprintf(1,'\n');
                delete(this.timerObj);
            end
        end
    end

end

