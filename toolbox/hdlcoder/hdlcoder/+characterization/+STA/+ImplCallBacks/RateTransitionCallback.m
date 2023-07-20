
classdef RateTransitionCallback<characterization.STA.ImplementationCallback





    methods
        function self=RateTransitionCallback()
            self@characterization.STA.ImplementationCallback();
        end


        function modelInfo=processConfig(~,modelInfo)
            x=modelInfo.modelIndependantParams('OutPortSampleTime');
            stime=str2double(x{1});

            if(stime==5)
                width=-1;
            elseif(stime==10)
                width=0;
            elseif(stime==20)
                width=1;
            else
                error('RateTransition call back: OutPortSampleTime has invalid value');
            end

            modelInfo.currentWidthSettings={1,width};

        end

    end

end
