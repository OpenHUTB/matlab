function schema=menuPowerSystems(functionName,callbackInfo)




    fcn=str2func(['l',functionName]);
    schema=fcn(callbackInfo);

end

function schema=lPowerSystems(callbackInfo)
    schema=sl_container_schema;
    schema.label='&Electrical';
    schema.tag='ee:PowerSystems';
    schema.state='Hidden';
    schema.autoDisableWhen='Busy';
    selection=callbackInfo.getSelection;
    if(numel(selection)==1)&&...
        strcmpi(selection.Type,'block')&&...
        strcmpi(selection.BlockType,'SimscapeBlock')
        componentPath=selection.ComponentPath;
        if ee.internal.mask.isComponentAsynchronousMachine(componentPath)||...
            ee.internal.mask.isComponentMachineInertia(componentPath)||...
            ee.internal.mask.isComponentSimplifiedSynchronousMachine(componentPath)||...
            ee.internal.mask.isComponentSynchronousMachineModel2p1(componentPath)||...
            ee.internal.mask.isComponentSinglePhaseAsynchronousMachine(componentPath)||...
            ee.internal.mask.isComponentSynchronousMachine(componentPath)||...
            ee.internal.mask.isComponentTransformer(componentPath)||...
            ee.internal.mask.isComponentMotorDrive(componentPath)
            schema.state='Enabled';
            im=DAStudio.InterfaceManagerHelper(callbackInfo.studio,'Simulink');
            children={...
            im.getAction('ee:MachineDisplayBase'),...
            im.getAction('ee:SinglePhaseMachineDisplayBase'),...
            im.getAction('ee:AsynchronousMachinePlotSaturation'),...
            im.getAction('ee:AsynchronousMachinePlotSaturationFactor'),...
            im.getAction('ee:AsynchronousMachinePlotSaturationInductance'),...
            im.getAction('ee:AsynchronousMachinePlotTorqueSpeedSi'),...
            im.getAction('ee:AsynchronousMachinePlotTorqueSpeedPu'),...
            im.getAction('ee:MachineInertiaDisplayParameters'),...
            im.getAction('ee:SynchronousMachineDisplayAssociatedBaseValues'),...
            im.getAction('ee:SynchronousMachineDisplayAssociatedInitialConditions'),...
            im.getAction('ee:SynchronousMachinePlotSaturationPu'),...
            im.getAction('ee:SynchronousMachinePlotSaturationFactorPu'),...
            im.getAction('ee:TransformerDisplayBase'),...
            im.getAction('ee:MotorDrivePlotEfficiencyMap')};
            schema.childrenFcns=children;
        end
    end
end

function schema=lMachineDisplayBase(callbackInfo)
    schema=ee.internal.contextmenu.menuMachineDisplayBase(callbackInfo);
end

function schema=lSinglePhaseMachineDisplayBase(callbackInfo)
    schema=ee.internal.contextmenu.menuSinglePhaseMachineDisplayBase(callbackInfo);
end

function schema=lAsynchronousMachinePlotSaturation(callbackInfo)
    schema=ee.internal.contextmenu.menuAsynchronousMachinePlotSaturation(callbackInfo);
end

function schema=lAsynchronousMachinePlotSaturationFactor(callbackInfo)
    schema=ee.internal.contextmenu.menuAsynchronousMachinePlotSaturationFactor(callbackInfo);
end

function schema=lAsynchronousMachinePlotSaturationInductance(callbackInfo)
    schema=ee.internal.contextmenu.menuAsynchronousMachinePlotSaturationInductance(callbackInfo);
end

function schema=lAsynchronousMachinePlotTorqueSpeedSi(callbackInfo)
    schema=ee.internal.contextmenu.menuAsynchronousMachinePlotTorqueSpeedSi(callbackInfo);
end

function schema=lAsynchronousMachinePlotTorqueSpeedPu(callbackInfo)
    schema=ee.internal.contextmenu.menuAsynchronousMachinePlotTorqueSpeedPu(callbackInfo);
end

function schema=lMachineInertiaDisplayParameters(callbackInfo)
    schema=ee.internal.contextmenu.menuMachineInertiaDisplayParameters(callbackInfo);
end

function schema=lSynchronousMachineDisplayAssociatedBaseValues(callbackInfo)
    schema=ee.internal.contextmenu.menuSynchronousMachineDisplayAssociatedBaseValues(callbackInfo);
end

function schema=lSynchronousMachineDisplayAssociatedInitialConditions(callbackInfo)
    schema=ee.internal.contextmenu.menuSynchronousMachineDisplayAssociatedInitialConditions(callbackInfo);
end

function schema=lSynchronousMachinePlotSaturationPu(callbackInfo)
    schema=ee.internal.contextmenu.menuSynchronousMachinePlotSaturationPu(callbackInfo);
end

function schema=lSynchronousMachinePlotSaturationFactorPu(callbackInfo)
    schema=ee.internal.contextmenu.menuSynchronousMachinePlotSaturationFactorPu(callbackInfo);
end

function schema=lTransformerDisplayBase(callbackInfo)
    schema=ee.internal.contextmenu.menuTransformerDisplayBase(callbackInfo);
end

function schema=lMotorDrivePlotEfficiencyMap(callbackInfo)
    schema=ee.internal.contextmenu.menuMotorDrivePlotEfficiencyMap(callbackInfo);
end
