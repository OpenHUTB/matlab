function showPromotedModelArgumentDialog()


    [~,~]=uigetpref(...
    'SimulinkControlDesign',...
    'ShowPromotedModelArgumentDialog',...
    DAStudio.message(...
    'Simulink:dialog:ModelRefPromotedModelArgumentDialogTitle'),...
    {...
''
''
    DAStudio.message(...
    'Simulink:dialog:ModelRefPromotedModelArgumentDialogInfo')
    },...
    {DAStudio.message('Simulink:dialog:Ok')},...
    'DefaultButton','Cancel'...
    );
end
