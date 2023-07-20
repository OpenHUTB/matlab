function hasAutoscaler=hasOwnAutoscaler(blockHandle)




    try
        eai=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();
        blockAutoscaler=eai.getAutoscaler(get_param(blockHandle,'Object'));
        hasAutoscaler=~isa(blockAutoscaler,'SimulinkFixedPoint.EntityAutoscalers.DefaultEntityAutoscaler');
    catch


        hasAutoscaler=false;
    end