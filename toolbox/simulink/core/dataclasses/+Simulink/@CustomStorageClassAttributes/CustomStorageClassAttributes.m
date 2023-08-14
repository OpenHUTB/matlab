classdef CustomStorageClassAttributes<matlab.mixin.Copyable&imported.Simulink.BaseCSCAttributes&hgsetget&Simulink.data.HasPropertyType




    methods

        function retVal=getIdentifiersForInstance(hObj,hCSCDefn,hData,identifier)






            assert(isa(hData,'Simulink.Data'));
            assert(logical(iscvar(identifier)));


            if(hCSCDefn.isGrouped)
                DAStudio.error('Simulink:dialog:NoInstanceIdentifiersForGroupedCSC',...
                class(hObj),hCSCDefn.Name,hCSCDefn.OwnerPackage);
            end


            retVal=struct('Identifier',identifier);
        end


        function retVal=getIdentifiersForGroup(hObj,hCSCDefn,hData)








            assert(hCSCDefn.isGrouped);
            assert(isa(hData,'Simulink.Data'));


            DAStudio.error('Simulink:dialog:NoGroupIdentifiersForGroupedCSC',...
            class(hObj),hCSCDefn.Name,hCSCDefn.OwnerPackage);
        end


        function retVal=isAddressable(hObj,hCSCDefn,hData)%#ok



            assert(isa(hData,'Simulink.Data'));



            retVal=true;
        end


        function hProps=getInstanceSpecificProps(hObj)






            hProps=hObj.getPossibleProperties;
        end
    end

    methods(Sealed)

        function retVal=isequal(obj1,obj2)

            retVal=builtin('isequal',obj1,obj2);
        end


        function retVal=isequaln(obj1,obj2)

            retVal=builtin('isequaln',obj1,obj2);
        end
    end

    methods(Hidden,Sealed)

        function hProps=getPossibleProperties(hObj)







            hClass=metaclass(hObj);
            hProps=findobj(hClass.PropertyList,...
            'Hidden',false,...
            'SetAccess','public',...
            'GetAccess','public');
        end


        function retVal=getPropDataType(hObj,propName)





            hProp=findprop(hObj,propName);

            if isempty(hProp)
                DAStudio.error('Simulink:dialog:InvalidPropertyName',propName);
            end


            assert(hProp.DefiningClass~=?Simulink.CustomStorageClassAttributes);
            assert(hProp.DefiningClass~=?imported.Simulink.BaseCSCAttributes);


            if(hProp.DefiningClass==?imported.Simulink.BaseCSCAttributes)

                hClass=findclass(findpackage('Simulink'),'BaseCSCAttributes');
                hProp=find(hClass.Properties,'Name',propName);
                retVal=hProp.DataType;


                hType=findtype(retVal);
                if isa(hType,'schema.EnumType')
                    retVal='enum';
                end
            else
                retVal=Simulink.data.getPropDataTypeFromProperty(hObj,propName);
            end
        end


        function retVal=getPropAllowedValues(hObj,propName)

            retVal={};

            hProp=findprop(hObj,propName);


            if(hProp.DefiningClass==?imported.Simulink.BaseCSCAttributes)
                if strcmp(getPropDataType(hObj,propName),'enum')

                    hType=findtype(hProp.DataType);
                    retVal=hType.Strings;
                end
            else

                retVal=hProp.AllowedValues;
            end
        end


        function panel=getDialogContainer(hObj,dlgName,isWidgetEnabled,hUI,hCSCDefn)



            panel=[];
            panel.Type='panel';
            panel.Items={};


            hProps=hObj.getPossibleProperties;


            colGrid=2;


            rowIdx=0;
            colIdx=0;
            for i=1:length(hProps)
                propName=hProps(i).Name;
                propType=hObj.getPropDataType(propName);
                allowedVals={};

                widget=[];
                widget.Name=propName;
                widget.Tag=[propName,'_Tag'];

                switch(propType)
                case 'bool'
                    widget.Type='checkbox';
                case{'string','double','int32'}
                    widget.Type='edit';
                case 'on/off'
                    widget.Type='combobox';
                    widget.Entries={'on','off'};
                case 'enum'
                    allowedVals=hObj.getPropAllowedValues(propName);
                    widget.Type='combobox';
                    widget.Entries=allowedVals;
                otherwise
                    MSLDiagnostic('Simulink:dialog:SkipUnknownPropertyType',...
                    propName,propType,dlgName).reportAsWarning;
                    continue;
                end


                widget.Enabled=isWidgetEnabled;


                widget.Value=hObj.(propName);
                if isWidgetEnabled
                    widget.Source=hUI;



                    widget.ObjectMethod='setCSCTypeAttributesPropAndDirty';
                    widget.MethodArgs={hCSCDefn,propName,'%value',allowedVals};
                    widget.ArgDataTypes={'mxArray','mxArray','mxArray','mxArray'};
                end
                widget.Mode=1;
                widget.DialogRefresh=1;

                widget.RowSpan=[rowIdx+1,rowIdx+1];
                widget.ColSpan=[colIdx+1,colIdx+1];

                panel.Items=[panel.Items,{widget}];

                colIdx=mod(colIdx+1,colGrid);
                if(colIdx==0)
                    rowIdx=rowIdx+1;
                end
            end

            panel.LayoutGrid=[rowIdx+1,colGrid];
        end

        function retVal=hasPropertyActions(obj,propName,contextObj)
            retVal=hasPropertyActions@Simulink.data.HasPropertyType(obj,propName,contextObj);
        end

        function retVal=getPropertyActions(obj,propName,propVal)
            retVal=getPropertyActions@Simulink.data.HasPropertyType(obj,propName,propVal);
        end
    end

    methods(Hidden)

        function result=getStructValueViaReturnArgument(obj)






            assert(isa(obj,'Simulink.CSCTypeAttributes_GetSet'));

            result=false;
        end
    end
end


