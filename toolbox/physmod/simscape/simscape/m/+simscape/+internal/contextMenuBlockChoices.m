function schema=contextMenuBlockChoices(callbackInfo)




    schema=sl_container_schema;
    schema.label=getString(message('physmod:simscape:simscape:menus:BlockChoices'));
    schema.tag='Simscape:BlockChoices';
    schema.state='Hidden';
    schema.autoDisableWhen='Never';
    schema.generateFcn=@lBlockChoiceEntries;
    if(numel(callbackInfo.getSelection)==1)&&...
        strcmpi(callbackInfo.getSelection.Type,'block')
        if simscape.engine.sli.internal.islibraryblock(...
            callbackInfo.getSelection.Handle)
            v=simscape.internal.variantsAndNames(callbackInfo.getSelection.Handle);


            if numel(v)>1
                schema.state='Enabled';
            end
        end
    end
end

function schema=lBlockChoiceEntries(cb)



    variants=simscape.internal.variantsAndNames(cb.getSelection.Handle);
    schema=cell(size(variants));
    for idx=1:numel(variants)
        schema{idx}={@lBlockChoiceEntry,variants{idx}};
    end
end

function s=lBlockChoiceEntry(cb)



    s=sl_toggle_schema;
    sourceFile=cb.userdata;
    blockSchema=feval(sourceFile);


    [variants,names]=simscape.internal.variantsAndNames(cb.getSelection.Handle);



    if~isempty(names)
        s.label=names{strcmp(variants,sourceFile)};
    else
        s.label=blockSchema.descriptor;
    end

    s.tag=strcat('Choice:',sourceFile);



    if strcmp(sourceFile,get_param(cb.getSelection.Handle,'SourceFile'))
        s.checked='checked';
    else
        s.checked='unchecked';
    end


    s.callback=@lUpdateVariantSelection;
    s.userdata=sourceFile;


    s.state=lChoiceEnabled(bdroot(cb.getSelection.Handle));

end

function lUpdateVariantSelection(cb)


    block=cb.getSelection.Handle;
    sourceFile=cb.userdata;
    nesl_setvariant=nesl_private('nesl_setvariant');
    nesl_setvariant(block,sourceFile);

end

function result=lChoiceEnabled(theRoot)


    if bdIsLibrary(theRoot)&&...
        strcmp(get_param(theRoot,'Lock'),'on')
        result='Disabled';
    else
        result='Enabled';
    end
end
