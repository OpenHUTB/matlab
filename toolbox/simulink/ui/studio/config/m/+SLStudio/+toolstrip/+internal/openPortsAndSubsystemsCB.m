



function openPortsAndSubsystemsCB(~)
    lb=slLibraryBrowser;
    lb=lb.getLBComponents{1};
    lb.selectTreeNodeByName('Simulink/Ports & Subsystems');
end
