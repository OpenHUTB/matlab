function h=FMU2CSTargetCC(varargin)








    if nargin>0
        h=[];
        DAStudio.error('Simulink:utility:ConstructorInputMismatch','Simulink.FMU2CSTargetCC');
    end

    h=Simulink.FMU2CSTargetCC;

    set(h,'GRTInterface','off');
    set(h,'UseToolchainInfoCompliant','on');
    set(h,'MatFileLogging','off');
    set(h,'SaveDirectory',pwd);

    registerPropList(h,'NoDuplicate','All',[]);

