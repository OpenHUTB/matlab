












classdef ExternalToolInfoAdapter<handle

    properties(Constant,Access=private)
        MetaClass2PropsMap=containers.Map(...
        {...
        'CompuMethod',...
        'Integer',...
        'FixedPoint',...
        'FloatingPoint',...
        'Enumeration',...
        'Boolean',...
        'ServiceRequiredPort',...
        'ServiceProvidedPort',...
        'SystemConst',...
        },...
        {...
        {{'SlDataTypes',''},{'CellOfEnums',''},{'IntValues',''}},...
        {{'SlDataTypes',''}},...
        {{'SlDataTypes',''}},...
        {{'SlDataTypes',''}},...
        {{'SlDataTypes',''}},...
        {{'SlDataTypes',''}},...
        {{'InstanceSpecifier',''},{'ServiceDiscoveryMode',''}},...
        {{'InstanceSpecifier',''}},...
        {{'RteSysConstNumericValue',''}}...
        });
    end

    methods(Static)



        function propValue=get(m3iObj,propName)
            import autosar.mm.util.ExternalToolInfoAdapter;
            propValue=[];
            if(ExternalToolInfoAdapter.MetaClass2PropsMap.isKey(m3iObj.getMetaClass().name))
                toolId=['ARXML_',propName];
                if ExternalToolInfoAdapter.isNumericProperty(propName)
                    extraInfo=autosar.mm.Model.getExtraExternalToolInfo(...
                    m3iObj,toolId,{'Value'},{'%f'});
                    propValue=extraInfo.Value;
                else
                    propValue=m3iObj.getExternalToolInfo(toolId).externalId;
                end

                switch propName
                case 'SlDataTypes'
                    if~isempty(propValue)
                        propValue=regexp(propValue,'#','split');
                    end
                case 'CellOfEnums'
                    [literalNames,~,result]=autosar.mm.util.getLiteralsFromTextTableCompuMethods(m3iObj);
                    if result
                        propValue=literalNames;
                    else
                        propValue=[];
                    end
                case 'IntValues'
                    [~,literalValues,result]=autosar.mm.util.getLiteralsFromTextTableCompuMethods(m3iObj);
                    if result
                        propValue=literalValues;
                    else
                        propValue=[];
                    end
                case 'CellOfBitfieldTables'
                    [shortLabels,masks,literalNames,literalValues,result]=...
                    ExternalToolInfoAdapter.getBitfieldInfoFromTextTableCompuMethods(m3iObj);
                    if result
                        propValue=struct(...
                        'shortLabels',{shortLabels},...
                        'masks',masks,...
                        'names',{literalNames},...
                        'values',literalValues);
                    else
                        propValue=[];
                    end
                case 'InstanceSpecifier'
                    if slfeature('AdaptiveAutogenInstanceSpecifier')
                        DAStudio.error('autosarstandard:api:ObsoleteInstanceSpecifier');
                    end

                    if isempty(propValue)
                        propValue=m3iObj.Name;
                    else
                        propValue=regexp(propValue,'#','split');
                        propValue=propValue{1};
                    end
                case 'ServiceDiscoveryMode'
                    if isempty(propValue)
                        propValue=autosar.mm.util.ServiceDiscoveryEnum.OneTime.char();
                    else
                        propValue=regexp(propValue,'#','split');
                        propValue=propValue{1};
                    end
                otherwise
                end
            end
        end




        function set(modelName,m3iObj,propName,propValue)
            import autosar.mm.util.ExternalToolInfoAdapter;
            import autosar.mm.Model;
            import autosar.api.Utils;

            if(ExternalToolInfoAdapter.MetaClass2PropsMap.isKey(m3iObj.getMetaClass().name))
                toolId=['ARXML_',propName];
                ExternalToolInfoAdapter.checkPropertyValue(propName,propValue);

                switch propName
                case 'IsReference'
                    propValue=num2str(propValue);
                case 'SlDataTypes'
                    errorCodes=autosar.mm.util.mapSLDataTypes(modelName,m3iObj,propValue,'OK',false);
                    if numel(errorCodes)>0
                        DAStudio.error(errorCodes{1:numel(errorCodes)})
                    end
                    return;
                case{'CellOfEnums','IntValues'}
                    DAStudio.error('autosarstandard:api:readOnlyProperty',propName,'CompuMethod');
                case 'InstanceSpecifier'
                    if slfeature('AdaptiveAutogenInstanceSpecifier')
                        DAStudio.error('autosarstandard:api:ObsoleteInstanceSpecifier');
                    end

                    if strcmp(propValue,m3iObj.Name)
                        return;
                    end
                    apiObj=autosar.api.getAUTOSARProperties(modelName);
                    if strcmp(apiObj.get('XmlOptions','IdentifyServiceInstance'),'InstanceSpecifier')
                        [error,serviceInstance]=autosar.internal.adaptive.manifest.ManifestUtilities.validateServiceInstance(propValue,'InstanceSpecifier');
                        if error
                            DAStudio.error('autosarstandard:validation:errorIdentifyServiceInstance',...
                            modelName,'InstanceSpecifier');
                        else
                            propValue=serviceInstance;
                        end
                    end
                case 'RteSysConstNumericValue'
                    propValue=Simulink.metamodel.arplatform.getRealStringCompact(propValue);
                otherwise
                end
                Model.setExtraExternalToolInfo(m3iObj,...
                toolId,...
                {'%s'},...
                {propValue});
            end
        end






        function etiOptions=getValidProperties(m3iObj)
            etiOptions={};
            metaClassName=m3iObj.getMetaClass().name;
            if autosar.mm.util.ExternalToolInfoAdapter.MetaClass2PropsMap.isKey(metaClassName)
                valuePair=autosar.mm.util.ExternalToolInfoAdapter.MetaClass2PropsMap(metaClassName);
                etiOptions=cellfun(@(x)x{1},valuePair,'UniformOutput',false);
            end
        end




        function result=isProperty(m3iObj,propName)
            import autosar.mm.util.ExternalToolInfoAdapter;

            result=false;
            metaClassName=m3iObj.getMetaClass().name;
            if ExternalToolInfoAdapter.MetaClass2PropsMap.isKey(metaClassName)
                valuePair=ExternalToolInfoAdapter.MetaClass2PropsMap(metaClassName);
                values=cellfun(@(x)x{1},valuePair,'UniformOutput',false);
                result=any(strcmp(values,propName));
            end
        end

        function result=getEnumPropertyValues(propName)
            import autosar.mm.util.ExternalToolInfoAdapter;
            result=[];
            if ExternalToolInfoAdapter.isEnumProperty(propName)
                valuePair=ExternalToolInfoAdapter.MetaClass2PropsMap(propName);
                result=valuePair{1};
            end
        end

    end

    methods(Static,Access=private)




        function result=isEnumProperty(~)
            result=false;
        end




        function result=isNumericProperty(propName)
            switch propName
            case 'IsReference'
                result=true;
            case 'RteSysConstNumericValue'
                result=true;
            otherwise
                result=false;
            end
        end





        function checkPropertyValue(propName,propValue)
            if strcmp(propName,'IsReference')
                if~isnumeric(propValue)||isnan(propValue)||...
                    isinf(propValue)||propValue<0
                    DAStudio.error('RTW:autosar:apiInvalidPropertyValue',...
                    num2str(propValue),propName,...
                    '[0, 1]');
                end
            elseif strcmp(propName,'ServiceDiscoveryMode')
                autosar.mm.util.ServiceDiscoveryUtils.validateServiceDiscoveryMode(propValue);
            end
        end

        function str=cell2str(cellArray)

            str='';
            sep='';
            for ii=1:length(cellArray)
                str=sprintf('%s%s''%s''',str,sep,cellArray{ii});
                sep=', ';
            end
            str=sprintf('%s',str);
        end

        function[shortLabels,masks,literalNames,literalValues,result]=getBitfieldInfoFromTextTableCompuMethods(m3iObj)





            toolId='ARXML_CompuMethodInfo';
            tok=regexp(m3iObj.getExternalToolInfo(toolId).externalId,'#','split');
            shortLabels={};
            masks=[];
            literalNames={};
            literalValues=[];
            result=false;
            for jj=2:numel(tok)
                if strcmp(tok(jj),'LiteralValue')
                    literalValues=[literalValues,str2double(tok(jj+1))];%#ok<AGROW>
                    result=true;
                elseif strcmp(tok(jj),'LiteralText')
                    literalNames=[literalNames,tok(jj+1)];%#ok<AGROW>
                elseif strcmp(tok(jj),'ShortLabel')
                    shortLabels=[shortLabels,tok(jj+1)];%#ok<AGROW>
                elseif strcmp(tok(jj),'Mask')
                    str=tok(jj+1);
                    if strncmp('0b',str,2)

                        maskValue=bin2dec(strrep(str,'0b',''));
                    else
                        maskValue=str2double(str);
                    end
                    masks=[masks,maskValue];%#ok<AGROW>
                end
                jj=jj+1;%#ok<FXSET>
            end

            cellData=[shortLabels;num2cell(literalValues)]';
            [~,order]=sortrows(cellData);
            shortLabels=shortLabels(order);
            masks=masks(order);
            literalNames=literalNames(order);
            literalValues=literalValues(order);
        end

    end
end



