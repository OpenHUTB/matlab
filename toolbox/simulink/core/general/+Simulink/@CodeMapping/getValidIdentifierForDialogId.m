function id=getValidIdentifierForDialogId(mapping,functionType,functionId)




    id=functionId;
    if strcmp(functionType,'FcnCallInport')



        id=num2str(get_param(mapping.Block,'SID'));
    end
end
