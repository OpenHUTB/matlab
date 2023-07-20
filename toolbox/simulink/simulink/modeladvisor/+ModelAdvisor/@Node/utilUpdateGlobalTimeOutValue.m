function utilUpdateGlobalTimeOutValue(this,timeOutValueStr)

    try
        value=eval(timeOutValueStr);
        if value>0,

            if strcmp(this.getID,'com.mathworks.Simulink.PerformanceAdvisor.PerformanceAdvisor')
                this.InputParameters{4}.Value=timeOutValueStr;
            end
        else
            msgbox(DAStudio.message('SimulinkPerformanceAdvisor:advisor:TimeoutPositive'));
        end
    catch
        msgbox(DAStudio.message('SimulinkPerformanceAdvisor:advisor:TimeoutPositive'));
    end


end