classdef Timer<coder.profile.Timer




    methods
        function this=Timer(model)
            hCS=getActiveConfigSet(model);
            counting={'down','up'};
            targetInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
            profiler=codertarget.attributes.getAttribute(model,'Profiler');
            if isnan(str2double(profiler.TimerTicksPerS))
                this.setTicksPerSecond(feval(profiler.TimerTicksPerS,hCS));
            else
                this.setTicksPerSecond(str2double(profiler.TimerTicksPerS));
            end
            this.setTimerDataType(profiler.TimerDataType);
            this.setSourceFile(codertarget.utils.replaceTokens(hCS,profiler.TimerSrcFile,targetInfo.Tokens));
            this.setHeaderFile(codertarget.utils.replaceTokens(hCS,profiler.TimerIncludeFile,targetInfo.Tokens));
            this.setReadTimerExpression([profiler.TimerReadFcn,'()']);
            idx=int32(str2double(profiler.TimerUpcounting));
            this.setCountDirection(counting{idx+1});
        end
    end
end