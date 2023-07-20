function UD=save_to_location(UD)





    if~isempty(UD.simulink)&&~isempty(UD.simulink.fromWsH)&&...
        ishandle(UD.simulink.fromWsH)
        [UD,saveStruct]=create_save_struct(UD);
        set_param(UD.simulink.fromWsH,'SigBuilderData',saveStruct);
    end
