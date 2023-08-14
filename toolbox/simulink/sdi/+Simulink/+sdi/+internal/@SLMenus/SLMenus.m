classdef SLMenus





    methods(Static)
        schema=sdiToolbarMenu(cbinfo);
        schema=simOutputMenu(cbinfo);
        schema=streamStateflowStateActivity(cbinfo,objType);
        schema=visualizeSelectedSignals(cbinfo);
        schema=logSelectedSignals(cbinfo);
        schema=visualizeSignalsContextMenu(cbinfo);
        schema=simulationRecord(cbinfo);
        schema=simulationVisualize(cbinfo,isToolbar);
        schema=configureLogging(cbinfo);
        schema=aboutSDI(cbinfo);
        schema=openSDI(cbinfo,varargin);
        ret=getSetNewDataAvailable(mdl,val);
    end

end
