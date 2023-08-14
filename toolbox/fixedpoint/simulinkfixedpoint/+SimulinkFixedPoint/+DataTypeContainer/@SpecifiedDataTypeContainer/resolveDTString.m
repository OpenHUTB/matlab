function resolvedObject=resolveDTString(this,unevaledDTStr,contextObj)





    try
        resolvedObject=slResolve(unevaledDTStr,contextObj.Handle,...
        'expression','startUnderMask');


    catch e %#ok




        if strncmp(unevaledDTStr,'slDataTypeAndScale(',19)
            resolvedObject=unevaledDTStr;
        else
            resolvedObject=[];
        end
    end

    if isstruct(resolvedObject)
        try
            strct2nt=fixdtUpdate(resolvedObject,[],true);
            resolvedObject=strct2nt;
        catch e %#ok<NASGU>
            resolvedObject=[];
        end
    end

    if ischar(resolvedObject)


        if~this.identifyDTStrings(resolvedObject)
            this.identifyStringWithResolve(resolvedObject,contextObj);
        end

        resolvedObject=this.evaluatedNumericType;
    end

end


