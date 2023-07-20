function onModelClose(~,~)




    listeners=Simulink.CodeMapping.setGetListeners;
    listeners{1}=[];
    listeners{2}=[];
    listeners{3}={};
    listeners{4}=[];
    Simulink.CodeMapping.setGetListeners(listeners);
end
