function out=getLibraryDialogCustomization()







    out=['<configset_customization>',...
    '<custom id="Simulink.ConfigSet" visible="off">',...
    '<custom id="SimulationTarget" visible="on" disp="',...
    message('RTW:configSet:LibSimTargetPaneName').getString,...
    '"/>',...
    '<custom id="CGCustomCode" visible="on" disp="',...
    message('RTW:configSet:LibRTWCustomCodePaneName').getString,...
    '"/>',...
    '<custom id="Model Advisor" visible="on"/>',...
    '</custom>',...
    '<custom id="Simulink.SFSimCC_adv" visible="off"/>',...
    '</configset_customization>'];
