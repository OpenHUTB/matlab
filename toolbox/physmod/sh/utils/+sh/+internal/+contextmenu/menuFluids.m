function schema=menuFluids(functionName,callbackInfo)

    fcn=str2func(['l',functionName]);
    schema=fcn(callbackInfo);

end

function schema=lFluids(callbackInfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.label='&Fluids';
    schema.tag='sh:Fluids';
    schema.state='Hidden';
    schema.autoDisableWhen='Busy';
    selection=callbackInfo.getSelection;
    if(numel(selection)==1)&&...
        strcmpi(selection.Type,'block')&&...
        strcmpi(selection.BlockType,'SimscapeBlock')
        componentPath=selection.ComponentPath;
        if sh.internal.mask.isComponentFixedDisplacementPump(componentPath)||...
            sh.internal.mask.isComponentFixedDisplacementMotor(componentPath)
            schema.state='Enabled';
            im=DAStudio.InterfaceManagerHelper(callbackInfo.studio,'Simulink');
            children={im.getAction('sh:PlotPumpMotorCharacteristic')};
            schema.childrenFcns=children;
        end
    end
end

function schema=lPlotPumpMotorCharacteristic(callbackInfo)%#ok<DEFNU>
    schema=sh.internal.contextmenu.menuPlotPumpMotorCharacteristic(callbackInfo);
end

