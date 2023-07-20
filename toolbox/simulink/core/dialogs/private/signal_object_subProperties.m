function props=signal_object_subProperties(lineObj,parentProp)



    props={};
    assert(isa(lineObj,'Simulink.Line'));
    if isempty(lineObj.SignalObject)
        storageClass=lineObj.getSourcePort.RTWStorageClass;
        if~isequal(storageClass,'Auto')
            props=cat(2,props,'RTWStorageTypeQualifier');
        end
    end



    if~isempty(lineObj.SignalObject)

        if strcmp(parentProp,DAStudio.message('Simulink:dialog:SigpropTabTwoName'))

            builtInStorageClasses=getPropAllowedValues(lineObj.getSourcePort,'RTWStorageClass');

            storageClass=lineObj.SignalObject.StorageClass;
            if(~ismember(storageClass,[builtInStorageClasses;Simulink.data.getNameForModelDefaultSC]))

                hCoderInfoClass=classhandle(lineObj.SignalObject.CoderInfo);
                csAttribsProp=findprop(hCoderInfoClass,'CustomAttributes');

                grpMoreAttributes=populate_widget_from_object_property(lineObj.SignalObject.CoderInfo,...
                csAttribsProp,lineObj.SignalObject,true);

                if isfield(grpMoreAttributes,'Items')&&~isempty(grpMoreAttributes)
                    props=cat(2,props,DAStudio.message('Simulink:dialog:DataCustomAttributesPrompt'));
                end
            end


            properties=get(classhandle(lineObj.SignalObject.CoderInfo),'Properties');
            propsToSkip={'StorageClass';'CustomStorageClass';'CustomAttributes';
            'CSCPackageName';'ParameterOrSignal';
            'SaveVarsCalledFromDataObject';'TypeQualifier'};


            for i=1:length(properties)
                if ismember(properties(i).Name,propsToSkip)
                    continue;
                end

                wid=populate_widget_from_object_property(lineObj.SignalObject.CoderInfo,properties(i),lineObj.SignalObject,true);
                if(strcmp(wid.Type,'unknown')==1)
                    continue;
                else


                    switch properties(i).Name
                    case{'Alias','Identifier'}
                        propertyFullName=['CoderInfo.',properties(i).Name];
                        if lineObj.SignalObject.isValidProperty(propertyFullName)
                            props=cat(2,props,properties(i).Name);
                        end
                    case 'Alignment'
                        props=cat(2,props,'Alignment');
                    otherwise
                        if~isempty(wid.Name)
                            props=cat(2,props,wid.Name);
                        end
                    end
                end
            end
        elseif strcmp(parentProp,DAStudio.message('Simulink:dialog:DataCustomAttributesPrompt'))
            cusAttribute=lineObj.SignalObject.CoderInfo.CustomAttributes;
            properties=Simulink.data.getPropList(cusAttribute,'GetAccess','public',...
            'Hidden',false);

            assert(~isempty(properties));
            for i=1:length(properties)
                type=get_widget_type_from_property(cusAttribute,properties(i));

                if(strcmp(type,'unknown')==1)
                    continue;
                end
                wid=populate_widget_from_object_property(cusAttribute,properties(i),lineObj.SignalObject,true);
                if~isempty(wid.Name)
                    props=cat(2,props,wid.Name);
                end
            end
        end
    end
end

