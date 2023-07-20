function schema=menuElectrical(functionName,callbackInfo)




    fcn=str2func(['l',functionName]);
    schema=fcn(callbackInfo);

end

function schema=lElectrical(callbackInfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.label='&Electrical';
    schema.tag='ee:Electrical';
    schema.state='Hidden';
    schema.autoDisableWhen='Busy';
    selection=callbackInfo.getSelection;
    if(numel(selection)==1)&&...
        strcmpi(selection.Type,'block')&&...
        strcmpi(selection.BlockType,'SimscapeBlock')
        componentPath=selection.ComponentPath;
        children=cell.empty;
        if ee.internal.mask.isComponentCharacteristicViewerSupported(componentPath)...
            ||ee.internal.mask.isComponentQuickPlotSupported(componentPath)
            schema.state='Enabled';
            im=DAStudio.InterfaceManagerHelper(callbackInfo.studio,'Simulink');
            if ee.internal.mask.isComponentCharacteristicViewerSupported(componentPath)
                children(end+1)={im.getAction('ee:CharacteristicVisualizer')};
            end
            if ee.internal.mask.isComponentQuickPlotSupported(componentPath)
                children(end+1)={im.getAction('ee:QuickPlot')};
            end
            schema.childrenFcns=children;
        end
    end
end

function schema=lCharacteristicVisualizer(callbackInfo)%#ok<DEFNU>
    schema=ee.internal.contextmenu.menuCharacteristicVisualizer(callbackInfo);
end

function schema=lQuickPlot(callbackInfo)%#ok<DEFNU>
    schema=ee.internal.contextmenu.menuQuickPlot(callbackInfo);
end
