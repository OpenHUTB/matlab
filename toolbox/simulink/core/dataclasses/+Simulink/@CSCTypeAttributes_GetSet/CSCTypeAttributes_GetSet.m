classdef CSCTypeAttributes_GetSet<Simulink.CustomStorageClassAttributes




    properties(PropertyType='char')
        GetFunction='get_$N';
    end

    properties(PropertyType='logical scalar')
        IsGetFunctionInstanceSpecific=true;
    end

    properties(PropertyType='char')
        SetFunction='set_$N';
    end

    properties(PropertyType='logical scalar')
        IsSetFunctionInstanceSpecific=true;
    end

    properties(PropertyType='logical scalar')
        AccessDataThroughMacro=false;
    end

    properties(Hidden,PropertyType='char')
        GetElementFunction='get_el_$N';
        SetElementFunction='set_el_$N';
    end

    properties(Hidden,PropertyType='logical scalar')



        SupportsArrayAccess=false;
    end

    methods

        function obj=CSCTypeAttributes_GetSet()
            mlock;
        end


        function retVal=getIdentifiersForInstance(hCSCAttrib,hCSCDefn,hData,identifier)%#ok


            mf0mdl=mf.zero.Model;
            sfsConfig=coder.identifiers.SFSConfig(mf0mdl);
            idGenerator=coder.identifiers.IdentifierGenerator(mf0mdl);
            sfsConfig.dN=identifier;



            sfsConfig.ruleString=getGetFunctionName(hCSCDefn,hData);
            retVal.GetFunction=idGenerator.getIdentifier(sfsConfig);

            sfsConfig.ruleString=getSetFunctionName(hCSCDefn,hData);
            retVal.SetFunction=idGenerator.getIdentifier(sfsConfig);

            if(supportsArrayAccess(hCSCDefn,hData))
                sfsConfig.ruleString=getGetElementFunctionName(hCSCDefn,hData);
                retVal.GetElementFunction=idGenerator.getIdentifier(sfsConfig);
                sfsConfig.ruleString=getSetElementFunctionName(hCSCDefn,hData);
                retVal.SetElementFunction=idGenerator.getIdentifier(sfsConfig);
            end
        end


        function retVal=isAddressable(hObj,hCSCDefn,hData)%#ok



            if hCSCDefn.IsDataAccessInstanceSpecific
                dataAccess=hData.CoderInfo.CustomAttributes.DataAccess;
            else
                dataAccess=hCSCDefn.DataAccess;
            end
            retVal=strcmp(dataAccess,'Pointer');
        end


        function props=getInstanceSpecificProps(hObj)


            props=[];
            if(hObj.IsGetFunctionInstanceSpecific)
                props=[props;findprop(hObj,'GetFunction')];
            end
            if(hObj.IsSetFunctionInstanceSpecific)
                props=[props;findprop(hObj,'SetFunction')];
            end
        end

    end
end



