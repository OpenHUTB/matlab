function props=getCodeGenPropertiesForIO(blockH,perspective,modelMapping,mappingType)




    props={};
    model=bdroot(blockH);
    switch(perspective)
    case 'Simulink:studio:DataViewPerspective_CodeGen'
        if strcmp(mappingType,'CoderDictionary')||strcmp(mappingType,'SimulinkCoderCTarget')
            props{end+1}=DAStudio.message('coderdictionary:mapping:StorageClassColumnName');
            if~isempty(modelMapping)&&strcmp(mappingType,'CoderDictionary')
                modelName=get_param(model,'Name');
                blockName=get_param(blockH,'Name');
                blockName=Simulink.CodeMapping.escapeSimulinkName(blockName);
                if strcmp(get_param(blockH,'BlockType'),'Outport')
                    mappedPort=modelMapping.Outports.findobj('Block',[modelName,'/',blockName]);
                else
                    mappedPort=modelMapping.Inports.findobj('Block',[modelName,'/',blockName]);
                end
                if~isempty(mappedPort.MappedTo)&&~isempty(mappedPort.MappedTo.StorageClass)
                    props{end+1}=DAStudio.message('coderdictionary:mapping:CodeIdentifierColumnName');
                    props=horzcat(props,mappedPort.MappedTo.getCSCAttributeNames(model)');
                    props=setdiff(props,'PreserveDimensions','stable');
                end
            end
        else
            if strcmp(mappingType,'AutosarTargetCPP')
                mc=metaclass(Simulink.AutosarTarget.PortEvent);
            elseif strcmp(mappingType,'AutosarTarget')
                mc=metaclass(Simulink.AutosarTarget.PortElement);
            else
                return;
            end
            for ii=1:numel(mc.PropertyList)
                prop=mc.PropertyList(ii);
                if strcmp(prop.GetAccess,'public')&&~prop.Hidden
                    props{end+1}=prop.Name;%#ok<AGROW>
                end
            end
        end
    case 'RTW:autosar:uiComSpecTitleSpreadsheet'
        props={};
        if strcmp(mappingType,'AutosarTargetCPP')

            return;
        elseif strcmp(mappingType,'AutosarTarget')
            m3iModel=autosar.api.Utils.m3iModel(model,true);
            port=get_param(blockH,'Object');
            props=...
            autosar.ui.comspec.ComSpecPropertyHandler.getValidComSpecPropertiesForPort(...
            model,port.Name,true,m3iModel);
        end
    case 'RTW:autosar:CalibrationParametersTitle'
        props={};
        if strcmp(mappingType,'AutosarTarget')||strcmp(mappingType,'AutosarTargetCPP')
            port=get_param(blockH,'Object');
            props=...
            autosar.ui.utiks.PortCalibrationAttributeHandler.getValidCalibrationAttributesForPort(...
            model,port.Name,true);
        end
    otherwise
        props={};
    end
