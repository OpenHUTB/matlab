function retVal=getIdentifiersForInstance(hCSCDefn,hData,identifier,context)




    assert(isa(hData,'Simulink.Data'));

    taObj=hCSCDefn.CSCTypeAttributes;
    if isempty(taObj)
        retVal={identifier};



        if hCSCDefn.isGrouped
            DAStudio.error('Simulink:dialog:NoTypeAttributesClassForGroupedCSC',...
            hCSCDefn.Name,hCSCDefn.OwnerPackage);
        end
    else
        retStruct=taObj.getIdentifiersForInstance(hCSCDefn,hData,identifier);
        if~isscalar(retStruct)||~isstruct(retStruct)
            DAStudio.error('Simulink:dialog:CSCInstanceIdentifiersMustBeValidStruct',...
            hCSCDefn.CSCTypeAttributesClassName);
        end


        retVal=struct2cell(retStruct);
        if isempty(retVal)||~iscellstr(retVal)
            DAStudio.error('Simulink:dialog:CSCInstanceIdentifiersMustBeValidStruct',...
            hCSCDefn.CSCTypeAttributesClassName);
        end


        retVal=retVal(~strcmp(retVal,''));


        if isempty(retVal)

            retVal={''};
        elseif(length(unique(retVal))~=length(retVal))
            details='';
            fields=fieldnames(retStruct);
            for idx=1:length(fields)
                details=sprintf('%s\n- %s: ''%s''',details,fields{idx},retVal{idx});
            end

            if isvarname(context)

                DAStudio.error('Simulink:dialog:CSCInstanceIdentifiersMustBeUnique1',...
                context,details);
            else

                DAStudio.error('Simulink:dialog:CSCInstanceIdentifiersMustBeUnique2',...
                context,details);
            end
        end
    end


