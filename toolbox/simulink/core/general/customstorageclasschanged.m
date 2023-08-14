function customstorageclasschanged(hCoderInfo,correctAttribClassOrObject)

















    if isempty(hCoderInfo.CustomAttributes)
        hThisAttribClass=[];
    else
        hThisAttribClass=hCoderInfo.CustomAttributes.classhandle;
    end



    if isempty(correctAttribClassOrObject)
        local_SetCoderInfoCustomAttributes(hCoderInfo,[]);
    elseif(ischar(correctAttribClassOrObject))


        [correctPackage,correctClass]=strtok(correctAttribClassOrObject,'.');
        if~isempty(correctClass)
            correctClass(1)=[];
        end

        hCorrectPackage=findpackage(correctPackage);
        if isempty(hCorrectPackage)
            MSLDiagnostic('Simulink:util:PackageNotFound',correctPackage).reportAsWarning;
            hCoderInfo.CustomAttributes=[];
        else
            hCorrectClass=findclass(hCorrectPackage,correctClass);
            if isempty(hCorrectClass)
                MSLDiagnostic('Simulink:util:ClassNotFound',correctAttribClassOrObject).reportAsWarning;
                hCoderInfo.CustomAttributes=[];
            else
                if((isempty(hThisAttribClass))||...
                    (~hThisAttribClass.isDerivedFrom(hCorrectClass)))
                    local_SetCoderInfoCustomAttributes(hCoderInfo,eval(correctAttribClassOrObject));
                end
            end
        end
    else


        assert(isa(correctAttribClassOrObject,'Simulink.BuiltinCSCAttributes'));
        local_SetCoderInfoCustomAttributes(hCoderInfo,correctAttribClassOrObject);
    end


    function local_SetCoderInfoCustomAttributes(hCoderInfo,hNewAttributes)



        hOldAttributes=hCoderInfo.CustomAttributes;


        if~isempty(hOldAttributes)&&~isempty(hNewAttributes)&&...
            ~isempty(fieldnames(hOldAttributes))&&...
            ~isempty(fieldnames(hNewAttributes))
            copy_object_properties(hOldAttributes,hNewAttributes);
        end


        hCoderInfo.CustomAttributes=hNewAttributes;


