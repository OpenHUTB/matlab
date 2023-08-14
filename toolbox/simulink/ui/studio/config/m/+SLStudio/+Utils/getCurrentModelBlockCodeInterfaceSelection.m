function selection=getCurrentModelBlockCodeInterfaceSelection(modelBlockHandle)


    codeInterface=get_param(modelBlockHandle,'CodeInterface');

    selection='';

    switch(codeInterface)
    case 'Model reference'
        selection='Simulink:studio:CodeInterfaceModelReferenceToolBar';

    case 'Top model'
        selection='Simulink:studio:CodeInterfaceTopModelToolBar';
    end

    if isempty(selection)
        DAStudio.error('Simulink:General:InternalError',...
        'SLStudio.Utils.getCurrentModelBlockCodeInterfaceSelection');
    end
end
