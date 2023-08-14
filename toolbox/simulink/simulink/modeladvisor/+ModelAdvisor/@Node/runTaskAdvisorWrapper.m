function runTaskAdvisorWrapper(this)


    mdl=bdroot;



    if isfield(this.MAObj.UserData,'globalTimer')&&...
        isvalid(this.MAObj.UserData.globalTimer)
        stop(this.MAObj.UserData.globalTimer);
        delete(this.MAObj.UserData.globalTimer);
    end


    this.MAObj.GlobalTimeOut=false;


    this.MAObj.UserData.globalTimer=timer(...
    'ExecutionMode','singleShot');
    this.MAObj.UserData.globalTimer.TimerFcn={@terminate,mdl,this.MAObj};


    if strcmp(this.getID,'com.mathworks.Simulink.PerformanceAdvisor.PerformanceAdvisor')
        timeOutValueStr=this.InputParameters{4}.Value;


    elseif strcmp(this.getID,'com.mathworks.Simulink.PerformanceAdvisor.Baseline')||...
        strcmp(this.getID,'com.mathworks.Simulink.PerformanceAdvisor.Simulation')||...
        strcmp(this.getID,'com.mathworks.Simulink.PerformanceAdvisor.SimulationTargets')

        parent=this.getParent;
        timeOutValueStr=parent.InputParameters{4}.Value;


    elseif strcmp(this.getID,'com.mathworks.Simulink.PerformanceAdvisor.BeforeUpdate')||...
        strcmp(this.getID,'com.mathworks.Simulink.PerformanceAdvisor.UpdateDiagram')||...
        strcmp(this.getID,'com.mathworks.Simulink.PerformanceAdvisor.Runtime')||...
        strcmp(this.getID,'com.mathworks.Simulink.PerformanceAdvisor.SimulationModesComparison')||...
        strcmp(this.getID,'com.mathworks.Simulink.PerformanceAdvisor.SimulationCompilerOptimization')

        subparent=this.getParent;
        parent=subparent.getParent;
        timeOutValueStr=parent.InputParameters{4}.Value;


    else

        parent=this.getParent;
        while(~strcmp(parent.getID,'com.mathworks.Simulink.PerformanceAdvisor.PerformanceAdvisor'))
            parent=parent.getParent;
            if isempty(parent)
                break;
            end
        end


        if~isempty(parent)&&strcmp(parent.getID,'com.mathworks.Simulink.PerformanceAdvisor.PerformanceAdvisor')
            timeOutValueStr=parent.InputParameters{4}.Value;
        end
    end

    try
        timeOutValue=eval(timeOutValueStr);
        if timeOutValue<=0
            msgbox(DAStudio.message('SimulinkPerformanceAdvisor:advisor:TimeoutPositive'));
            stop(this.MAObj.UserData.globalTimer);
            delete(this.MAObj.UserData.globalTimer);
            return;
        end
    catch
        msgbox(DAStudio.message('SimulinkPerformanceAdvisor:advisor:TimeoutPositive'));
        stop(this.MAObj.UserData.globalTimer);
        delete(this.MAObj.UserData.globalTimer);
        return;
    end


    this.MAObj.UserData.globalTimer.StartDelay=60*timeOutValue;
    start(this.MAObj.UserData.globalTimer);


    runTaskAdvisor(this);

end

function terminate(src,~,mdl,mdladvObj)

    mdladvObj.GlobalTimeOut=true;


    set_param(mdl,'simulationcommand','stop');


    stop(src);
    delete(src);

end