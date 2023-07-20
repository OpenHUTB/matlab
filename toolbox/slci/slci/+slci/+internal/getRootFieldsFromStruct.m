
function[root,fields,indices]=getRootFieldsFromStruct(expression)





    root=expression;
    fields=[];
    indices=[];
    if~isempty(expression)
        [sRoot,sFields,sIndices,~]=slci.internal.parseStructureParam(expression);

        if~isempty(sFields)&&~Simulink.data.isSupportedEnumClass(sRoot)

            root=sRoot;
            fields=sFields;
            indices=sIndices;
        end
    end


