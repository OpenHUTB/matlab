function fullClassName=createCustomAttribClass(hThisCSCDefn,inModel)




    try
        thisCSCName=hThisCSCDefn.Name;
        thisCSCPkgName=hThisCSCDefn.OwnerPackage;
        nameDeriveFromPackage='Simulink';
        nameDeriveFromClass='BuiltinCSCAttributes';

        if inModel
            scope='Model';
        else
            scope='';
        end

        pkgName='SimulinkCSC';
        className=[scope,'AttribClass_',thisCSCPkgName,'_',thisCSCName];
        fullClassName=[pkgName,'.',className];

        hCreateInPackage=findpackage(pkgName);
        if isempty(hCreateInPackage)
            hCreateInPackage=schema.package(pkgName);
            if isempty(hCreateInPackage)
                DAStudio.error('Simulink:dialog:CSCDefnCustomAttribClassCreatePackage',pkgName);
            end
        end

        hC=findclass(hCreateInPackage,className);




        if isempty(hC)
            hDeriveFromPackage=findpackage(nameDeriveFromPackage);
            if isempty(hDeriveFromPackage)
                DAStudio.error('Simulink:dialog:CSCDefnCustomAttribClassFindPackage',nameDeriveFromPackage);
            end

            hDeriveFromClass=findclass(hDeriveFromPackage,nameDeriveFromClass);
            if isempty(hDeriveFromClass)
                DAStudio.error('Simulink:dialog:CSCDefnCustomAttribClassFindClass',nameDeriveFromPackage,...
                nameDeriveFromClass);
            end

            hC=schema.class(hCreateInPackage,className,hDeriveFromClass);





            cscdefn_enumtypes;





            if hThisCSCDefn.IsMemorySectionInstanceSpecific
                baseName=['CSC_Enum_',thisCSCPkgName,'_MemorySection'];
                msEnumList=processcsc('GetMemorySectionNames',thisCSCPkgName);
                msEnumTypeName=l_CreateEnumType(baseName,msEnumList);

                hProp=findprop(hThisCSCDefn,'MemorySection');

                hWrapperProp=schema.prop(hC,'MemorySection',msEnumTypeName);
                hWrapperProp.FactoryValue=hThisCSCDefn.MemorySection;
                l_AddWrapperPropertyGetSetFunctions(hWrapperProp,hProp,inModel);
            end

            if hThisCSCDefn.IsDataScopeInstanceSpecific
                l_AddWrapperProperty(hC,hThisCSCDefn,'DataScope',inModel);
            end

            if hThisCSCDefn.IsDataInitInstanceSpecific
                l_AddWrapperProperty(hC,hThisCSCDefn,'DataInit',inModel);
            end

            if hThisCSCDefn.IsDataAccessInstanceSpecific
                l_AddWrapperProperty(hC,hThisCSCDefn,'DataAccess',inModel);
            end

            if hThisCSCDefn.IsHeaderFileInstanceSpecific
                l_AddWrapperProperty(hC,hThisCSCDefn,'HeaderFile',inModel);
            end

            if hThisCSCDefn.IsDefinitionFileInstanceSpecific
                l_AddWrapperProperty(hC,hThisCSCDefn,'DefinitionFile',inModel);
            end

            if hThisCSCDefn.IsOwnerInstanceSpecific
                l_AddWrapperProperty(hC,hThisCSCDefn,'Owner',inModel);
            end

            if hThisCSCDefn.IsLatchingInstanceSpecific
                l_AddWrapperProperty(hC,hThisCSCDefn,'Latching',inModel);
            end

            if hThisCSCDefn.IsReusableInstanceSpecific
                l_AddWrapperProperty(hC,hThisCSCDefn,'IsReusable',inModel);
            end



            assert(hThisCSCDefn.IsConcurrentAccessInstanceSpecific);
            if hThisCSCDefn.IsConcurrentAccessInstanceSpecific
                l_AddWrapperProperty(hC,hThisCSCDefn,'ConcurrentAccess',inModel);
                hProp=findprop(hC,'ConcurrentAccess');
                hProp.AccessFlags.Serialize='off';
                hProp.AccessFlags.Copy='off';
                hProp.Visible='off';
                hProp.GetFunction=@l_GetConcurrentAccess;
                hProp.SetFunction=@l_SetConcurrentAccess;
            end

            if hThisCSCDefn.PreserveDimensionsInstanceSpecific
                l_AddWrapperProperty(hC,hThisCSCDefn,'PreserveDimensions',inModel);
            end

            if~isempty(hThisCSCDefn.CSCTypeAttributes)


                instanceSpecificProps=hThisCSCDefn.CSCTypeAttributes.getInstanceSpecificProps;


                needInternalObject=false;

                for i=1:length(instanceSpecificProps)
                    propName=instanceSpecificProps(i).Name;


                    if ismember(propName,{'Owner','DefinitionFile'})
                        continue;
                    end


                    propVal=hThisCSCDefn.CSCTypeAttributes.(propName);

                    switch Simulink.data.getScalarObjectLevel(hThisCSCDefn.CSCTypeAttributes)
                    case 1
                        propType=instanceSpecificProps(i).DataType;
                    case 2
                        propType=getPropDataType(hThisCSCDefn.CSCTypeAttributes,propName);

                        if strcmp(propType,'bool')

                            if ischar(propVal)
                                propType='on/off';
                            end

                        elseif strcmp(propType,'enum')

                            baseName=strrep(hThisCSCDefn.CSCTypeAttributesClassName,'.','_');
                            baseName=[baseName,'_',propName,'_EnumType'];%#ok
                            enumStrings=getPropAllowedValues(hThisCSCDefn.CSCTypeAttributes,propName);
                            propType=l_CreateEnumType(baseName,enumStrings);
                        end
                    otherwise
                        assert(false);
                    end


                    hProp=schema.prop(hC,propName,propType);
                    hProp.FactoryValue=propVal;


                    if inModel

                        hProp.SetFunction=l_CreateModelMappingPropertySetFunction(propName);
                        hProp.GetFunction=l_CreateModelMappingPropertyGetFunction(propName);


                        needInternalObject=true;

                    elseif(~isempty(instanceSpecificProps(i).GetMethod)||...
                        ~isempty(instanceSpecificProps(i).SetMethod))








                        hProp.SetFunction=l_CreateUserPropertySetFunction(propName);
                        needInternalObject=true;
                    end
                end



                if(needInternalObject)
                    hProp=schema.prop(hC,'InternalCustomAttributesObject','mxArray');
                    hProp.AccessFlags.Serialize='off';
                    hProp.AccessFlags.AbortSet='off';
                    hProp.AccessFlags.Copy='off';
                    hProp.Visible='off';








                    hProp.FactoryValue=feval(hThisCSCDefn.CSCTypeAttributesClassName);
                end
            end
        end

    catch err
        DAStudio.error('Simulink:dialog:CSCDefnCustomAttribClassCreateCustomClass',...
        thisCSCPkgName,thisCSCName,err.message);

    end
end


function l_AddWrapperProperty(hClass,hThisCSCDefn,propName,inModel)
    hProp=findprop(hThisCSCDefn,propName);
    hWrapperProp=schema.prop(hClass,propName,hProp.DataType);
    hWrapperProp.FactoryValue=hThisCSCDefn.(propName);
    l_AddWrapperPropertyGetSetFunctions(hWrapperProp,hProp,inModel)
end

function l_AddWrapperPropertyGetSetFunctions(hWrapperProp,hProp,inModel)
    if inModel
        classicSetFunction=hProp.SetFunction;
        hWrapperProp.SetFunction=l_CreateModelMappingPropertySetFunction(hProp.Name,classicSetFunction);
        hWrapperProp.GetFunction=l_CreateModelMappingPropertyGetFunction(hProp.Name);
    else
        hWrapperProp.SetFunction=hProp.SetFunction;
    end
end





function retVal=l_CreateUserPropertySetFunction(propName)
    retVal=@(objArg,propValArg)l_setUserPropInInternalObject(objArg,propValArg,propName);
end

function retVal=l_setUserPropInInternalObject(hObj,propVal,propName)




    hProp=findprop(hObj,propName);
    if strcmp(hProp.DataType,'int32')
        propVal=int32(propVal);
    end


    hObj.InternalCustomAttributesObject.(propName)=propVal;


    retVal=hObj.InternalCustomAttributesObject.(propName);
end


function retVal=l_CreateModelMappingPropertySetFunction(propName,classicSetFunction)
    if(nargin==2)
        retVal=@(objArg,propValArg)l_setCSCPropInModelMapping(objArg,propValArg,propName,classicSetFunction);
    else
        retVal=@(objArg,propValArg)l_setUserPropInModelMapping(objArg,propValArg,propName);
    end
end

function retVal=l_CreateModelMappingPropertyGetFunction(propName)
    retVal=@(objArg,propValArg)l_getAnyPropFromModelMapping(objArg,propValArg,propName);
end

function retVal=l_setCSCPropInModelMapping(hObj,propValArg,propName,classicSetFunction)



    if isempty(classicSetFunction)
        retVal=propValArg;
    else
        retVal=classicSetFunction(hObj,propValArg);
    end
    hObj.setPropertyValue(propName,retVal);
end

function retVal=l_setUserPropInModelMapping(hObj,propVal,propName)



    hProp=findprop(hObj,propName);
    if strcmp(hProp.DataType,'int32')
        propVal=int32(propVal);
    end


    hObj.InternalCustomAttributesObject.(propName)=propVal;
    retVal=hObj.InternalCustomAttributesObject.(propName);

    hObj.setPropertyValue(propName,propVal);
end

function retVal=l_getAnyPropFromModelMapping(hObj,propValArg,propName)%#ok


    if hObj.CoderDictContextAvailable
        retVal=hObj.getPropertyValue(propName);
    else

        hProp=findprop(hObj,propName);
        retVal=hProp.FactoryValue;
    end
end


function typeName=l_CreateEnumType(baseName,enumStrings,suffix)








    assert(nargout==1);

    assert(iscellstr(enumStrings));
    enumStrings=enumStrings(:);

    if nargin==2
        suffix=0;
        typeName=baseName;
    else
        suffix=suffix+1;
        typeName=[baseName,num2str(suffix)];
    end

    hType=findtype(typeName);

    if isempty(hType)

        schema.EnumType(typeName,enumStrings);
    else

        if(isa(hType,'schema.EnumType')&&...
            isequal(hType.Strings,enumStrings))

        else

            typeName=l_CreateEnumType(baseName,enumStrings,suffix);
        end
    end
end

function oldValue=l_GetConcurrentAccess(hObj,oldValue)%#ok

    assert((oldValue==false)||(slfeature('BackFoldSafeCSC')==3));
end

function newValue=l_SetConcurrentAccess(hObj,newValue)%#ok

    assert((newValue==false)||(slfeature('BackFoldSafeCSC')==3));
end







