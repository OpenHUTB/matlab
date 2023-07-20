classdef CSCTypeAttributes_FlatStructure<Simulink.CustomStorageClassAttributes




    properties(PropertyType='char')%#ok<ATUNK>
        StructName='';
    end

    properties(PropertyType='logical scalar')%#ok<ATUNK>
        IsStructNameInstanceSpecific=false;
        BitPackBoolean=false;
        IsTypeDef=true;
    end

    properties(PropertyType='char')%#ok<ATUNK>
        TypeName='';
        TypeToken='';
        TypeTag='';
    end

    methods

        function obj=CSCTypeAttributes_FlatStructure()
            mlock;
        end


        function retVal=getIdentifiersForInstance(hObj,hCSCDefn,hData,identifier)


            structName=hObj.getInstanceSpecificStructureName(hCSCDefn,hData);
            retVal=struct('Identifier',[structName,'.',identifier]);
        end


        function retVal=getIdentifiersForGroup(hObj,hCSCDefn,hData)


            structName=hObj.getInstanceSpecificStructureName(hCSCDefn,hData);
            if hObj.IsStructNameInstanceSpecific
                typeName='';
                typeTag='';
                typeToken='';
            else
                typeName=hCSCDefn.CSCTypeAttributes.TypeName;
                typeTag=hCSCDefn.CSCTypeAttributes.TypeTag;
                typeToken=hCSCDefn.CSCTypeAttributes.TypeToken;
            end

            if isempty(typeName)
                typeName=[structName,'_type'];
            end
            if isempty(typeTag)
                typeTag=[structName,'_tag'];
            end
            if isempty(typeToken)
                typeToken=[structName,'_token'];
            end

            retVal=struct('StructName',structName,...
            'TypeName',typeName,...
            'TypeTag',typeTag,...
            'TypeToken',typeToken);
        end


        function retVal=isAddressable(hObj,hCSCDefn,hData)




            if hObj.BitPackBoolean
                retVal=false;
            else
                retVal=isAddressable@Simulink.CustomStorageClassAttributes(hObj,hCSCDefn,hData);
            end
        end


        function props=getInstanceSpecificProps(hObj)



            if hObj.IsStructNameInstanceSpecific
                props=findprop(hObj,'StructName');
            else
                props=[];
            end
        end


        function set.StructName(obj,val)

            val=strtrim(val);


            if isempty(val)||iscvar(val)
                obj.StructName=val;
            else
                DAStudio.error('Simulink:dialog:StructNameMustBeValidCIdent');
            end
        end

    end

    methods(Static,Access=private)

        function structName=getInstanceSpecificStructureName(hCSCDefn,hData)
            if hCSCDefn.CSCTypeAttributes.IsStructNameInstanceSpecific
                structName=hData.CoderInfo.CustomAttributes.StructName;
            else
                structName=hCSCDefn.CSCTypeAttributes.StructName;
            end


            if isempty(structName)
                structName=['rt_',hCSCDefn.OwnerPackage,'_',hCSCDefn.Name];
            end
        end
    end

end
