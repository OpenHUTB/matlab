function schema=internalGetSlimDialogSchema(hThis,type)





    if strcmp(type,'Simscape:Description')
        buildFunc=nesl_private('nesl_buildslimdialogschema');
        schema=buildFunc(hThis);
    else
        error('NetworkEngine:DynNeDlgSource:internalGetSlimDialogSchema',...
        'Invalid schema type when generating slim dialog schema');
    end

end
