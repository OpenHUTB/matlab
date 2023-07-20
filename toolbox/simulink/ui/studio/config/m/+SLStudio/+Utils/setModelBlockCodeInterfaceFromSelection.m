function setModelBlockCodeInterfaceFromSelection(modelBlockHandle,newSelection)


    newCodeInterface='';

    switch(newSelection)
    case 'Simulink:studio:CodeInterfaceModelReferenceToolBar'
        newCodeInterface='Model reference';

    case 'Simulink:studio:CodeInterfaceTopModelToolBar'
        newCodeInterface='Top model';
    end

    if isempty(newCodeInterface)
        DAStudio.error('Simulink:General:InternalError',...
        'SLStudio.Utils.setModelBlockCodeInterfaceFromSelection');
    end

    set_param(modelBlockHandle,'CodeInterface',newCodeInterface);
end