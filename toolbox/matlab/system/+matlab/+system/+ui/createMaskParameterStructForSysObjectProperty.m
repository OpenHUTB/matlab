function thisParam=createMaskParameterStructForSysObjectProperty(blkH,property,className,...
    sysObj,paramNames,ind,...
    isLibraryBlockOrLinkedBlock)



    [thisParam,thisAttrib]=getDefaultMaskParamStruct(paramNames{ind});
    thisParam.Alias=property.Alias;
    thisParam.Default=property.Default;


    if property.IsNontunable
        thisAttrib.Tunable='off';
    end
    if property.IsReadOnly
        thisAttrib.ReadOnly='on';
        thisAttrib.Tunable='off';
    end
    if property.IsTransient
        thisAttrib.NeverSave='on';
    end
    if property.IsHidden
        thisAttrib.Hidden='on';
    end







    if~property.IsGraphical
        thisAttrib.Tunable='off';
    end



    showPrompt=true;

    propName=property.Name;
    if property.IsLogical

        thisParam.Type='checkbox';
        thisParam.TypeOptions={''};
        thisAttrib.Tunable='off';
        if~property.IsNontunable
            warning(message('SystemBlock:MATLABSystem:ParameterCannotBeTunable',...
            className,getfullname(blkH),propName));
        end
        thisAttrib.Evaluate='off';
        thisAttrib.others='do-dialog-callback';

    elseif property.IsStringSet||property.IsEnumeration||property.IsEditableEnumeration

        thisParam.Type='popup';

        if~isempty(property.WidgetType)
            thisParam.Type=char(property.WidgetType);
        end

        if property.IsEditableEnumeration
            thisParam.Type='combobox';
        end

        if property.IsLocalizedStringSet


            thisParam.TypeOptions=property.StringSetMessageIdentifiers;
        else
            thisParam.TypeOptions=property.StringSetValues;
        end

        thisAttrib.Tunable='off';
        thisAttrib.Evaluate='off';
        thisAttrib.others='do-dialog-callback';

    elseif property.isDataTypeProperty()&&property.IsDataType

        thisParam.Type=matlab.system.ui.getUDTMaskType(sysObj,property,paramNames);
        thisParam.TypeOptions={''};
        thisAttrib.Tunable='off';
        showPrompt=false;

    elseif property.isDataTypeProperty()&&property.IsDesignMin

        thisParam.Type='min';
        thisAttrib.Tunable='off';
        showPrompt=false;

    elseif property.isDataTypeProperty()&&property.IsDesignMax

        thisParam.Type='max';
        thisAttrib.Tunable='off';
        showPrompt=false;


    elseif property.IsSystemObject


        thisParam.Type='sysobject';


        thisParam.TypeOptions={'matlab.system.ui.getSystemObjectParamSchema'};
        thisAttrib.others={'mxarray','do-dialog-callback'};
        thisAttrib.Tunable='off';

    elseif~isempty(property.StaticRange)

        thisParam.Type='dial';


        if~isempty(property.WidgetType)
            thisParam.Type=char(property.WidgetType);
        end
        thisParam.TypeOptions={''};
        thisParam.Range=property.StaticRange;



        thisAttrib.Evaluate='on';

    elseif property.IsStringLiteral

        thisParam.Type='edit';

        if~isempty(property.WidgetType)
            thisParam.Type=char(property.WidgetType);
        end
        thisParam.TypeOptions={''};
        thisAttrib.Evaluate='off';
        thisAttrib.Tunable='off';
        if~property.IsNontunable
            warning(message('SystemBlock:MATLABSystem:ParameterCannotBeTunable',...
            className,getfullname(blkH),propName));
        end

    else

        thisParam.Type='edit';
        thisParam.TypeOptions={''};
        propValue=property.getValue(sysObj);
        switch class(propValue)
        case 'char'
            thisAttrib.Tunable='off';
            if~property.IsNontunable
                warning(message('SystemBlock:MATLABSystem:ParameterCannotBeTunable',...
                className,getfullname(blkH),propName));
            end
            thisAttrib.Evaluate='off';

        case{'double','float','single','int8','uint8','int16','uint16','int32','uint32','int64','uint64','half'}

            if isempty(propValue)&&~isLibraryBlockOrLinkedBlock...
                &&~property.IsRestrictedToBuiltinType...
                &&~isPropertyPortTarget(findprop(sysObj,property.Name),class(sysObj))
                warning(message('SystemBlock:MATLABSystem:ParameterWithUnspecifiedDefaultValueRestrictedToBuiltinDataType',...
                className,getfullname(blkH),propName));
            end

        case 'struct'

            paramValue=thisParam.Default;
            if ischar(paramValue)
                paramValue=eval(paramValue);
            end
            if slInternal('isValidNumericStructScalar',paramValue)
                thisAttrib.others='mxnumstruct';
            else
                thisAttrib.Tunable='off';
                thisAttrib.others='mxarray';
                if~property.IsNontunable&&~isLibraryBlockOrLinkedBlock
                    warning(message('SystemBlock:MATLABSystem:ParameterCannotBeTunable',...
                    className,getfullname(blkH),propName));
                end
            end

        case{'cell','function_handle'}

            thisAttrib.Tunable='off';
            thisAttrib.others='mxarray';
            if~property.IsNontunable&&~isLibraryBlockOrLinkedBlock
                warning(message('SystemBlock:MATLABSystem:ParameterCannotBeTunable',...
                className,getfullname(blkH),propName));
            end

        case 'logical'


        otherwise

            try
                paramValue=eval(thisParam.Default);
                isSimulinkPrmObject=isa(paramValue,'Simulink.Parameter');
                isFiObject=isa(paramValue,'embedded.fi');
            catch


                isSimulinkPrmObject=false;
                isFiObject=false;
                thisAttrib.ReadOnly='on';
            end

            if(~isSimulinkPrmObject&&~isFiObject)


                thisAttrib.others='mxarray';
            end

            if strcmp(thisAttrib.ReadOnly,'off')

                tmpValue=strtok(thisParam.Default,'(');
                isSystemOject=matlab.system.isSystemObjectName(tmpValue);
                isEnumObject=~isempty(enumeration(['',class(paramValue),'']));
                isNumericType=isa(paramValue,'embedded.numerictype');
                mc=meta.class.fromName(tmpValue);
                isNonSysObjMCOS=~isSystemOject&&~isempty(mc);

                if(isSystemOject||(~isEnumObject&&~isSimulinkPrmObject&&~isFiObject&&~isNumericType&&~isNonSysObjMCOS))
                    thisAttrib.ReadOnly='on';
                    if(~isLibraryBlockOrLinkedBlock)
                        warning(message('SystemBlock:MATLABSystem:ParameterOfMATLABObjectTypeMustBeReadOnly',...
                        className,getfullname(blkH),propName));
                    end
                end
            end

            if(strcmp(thisAttrib.ReadOnly,'off')&&~isFiObject)
                thisAttrib.Tunable='off';
                if~property.IsNontunable&&~isLibraryBlockOrLinkedBlock
                    warning(message('SystemBlock:MATLABSystem:ParameterCannotBeTunable',...
                    className,getfullname(blkH),propName));
                end
            elseif(strcmp(thisAttrib.ReadOnly,'on'))



                thisAttrib.Tunable='off';

            end

        end
    end

    if property.IsControllingAnEnumeration


        violations=intersect(paramNames(1:ind),property.ControlledPropertyList);
        for n=1:numel(violations)
            warning(message('SystemBlock:MATLABSystem:DynamicPopupPropertyOrder',violations{n},className,property.Name));
        end
    end


    if showPrompt
        thisParam.Prompt=property.Description;
        if~isempty(thisParam.Prompt)&&...
            (any(strcmp(thisParam.Type,{'edit','popup','sysobject','combobox'}))...
            ||contains(thisParam.Type,"unidt"))&&~matlab.system.ui.isMessageID(thisParam.Prompt)
            thisParam.Prompt=[thisParam.Prompt,':'];
        end
    end


    thisParam.Attributes=thisAttrib;
    if~isempty(property.Row)
        thisParam.Row=char(property.Row);
    else
        thisParam.Row='new';
    end
end

function[thisParam,thisAttrib]=getDefaultMaskParamStruct(paramName)
    thisParam=struct('Name','','Alias','','Type','','Prompt','','TypeOptions',[],'Default','[]','Range',[],'Attributes',[]);
    thisParam.Name=paramName;
    thisParam.TypeOptions={''};
    thisAttrib=struct('Tunable','on','ReadOnly','off','Hidden','off','NeverSave','off','Evaluate','on','others','');
end