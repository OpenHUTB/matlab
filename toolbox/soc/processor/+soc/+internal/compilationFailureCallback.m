function compilationFailureCallback(modelName,isModelRef,varargin)




    id='SimulinkDiscreteEvent:MatlabEventSystem:DefaultOutputConnection';
    prefName=['Warnings',strrep(id,':','')];
    prefName=prefName(1:63);
    warningStateAtStart=soc.internal.getPreference(prefName);
    if~isModelRef
        if ismember(warningStateAtStart,{'on','off'})

            warning(warningStateAtStart,id);
        end
    end



    if codertarget.utils.isTaskBlockUsed(getActiveConfigSet(modelName))&&...
        (~evalin('base','exist(''rteEvent'', ''var'')')||...
        ~evalin('base','exist(''rteTask'', ''var'')')||...
        ~evalin('base','exist(''rteSubTask'', ''var'')'))
        DAStudio.error('soc:scheduler:RteVariablesCleared');
    end
end
