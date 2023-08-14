function copy_object_properties(hSrc,hDst)












    if isempty(hSrc)||isempty(hDst)||isequal(hSrc,hDst)
        return;
    end

    isStrictCopy=false;






    hSrcClass=hSrc.classhandle;
    hDstClass=hDst.classhandle;



    if~hDstClass.isDerivedFrom(hSrcClass)&&isStrictCopy

        DAStudio.error('Simulink:utility:invSrcDestUDDClassType');
    end





    hSrcProps=hSrcClass.Properties;
    hDstProps=hDstClass.Properties;

    for p=1:length(hSrcProps)
        pName=hSrcProps(p).Name;
        spType=hSrcProps(p).DataType;



        spFlags=hSrcProps(p).AccessFlags(1);
        if(strcmp(spFlags.PublicGet,'off')||...
            strcmp(spFlags.Copy,'off'))
            continue;
        end
        try
            spVal=get(hSrc,pName);
        catch err
            if isStrictCopy
                rethrow(err);%#ok
            else
                continue;
            end
        end



        dp=find(hDstProps,'Name',pName);
        if isempty(dp)
            if isStrictCopy
                DAStudio.message('Simulink:dialog:CannotFindPropInDestObj',pName);%#ok
            else
                continue;
            end
        end
        dpType=dp.DataType;



        if~strcmp(spType,dpType)&&isStrictCopy
            DAStudio.error('Simulink:utility:invSrcDestClassType',pName);
        end



        if~strcmp(spType,'handle')
            try
                set(hDst,pName,spVal);
            catch err
                if isStrictCopy
                    rethrow(err);%#ok
                else
                    continue;
                end
            end



        else
            if~strcmp(dpType,'handle')

                continue;
            end



            dpFlags=dp.AccessFlags(1);
            if strcmp(dpFlags.PublicGet,'off')
                if isStrictCopy
                    DAStudio.error('Simulink:dialog:DestObjDoesNotAllowPublicGet',pName);%#ok
                else
                    continue;
                end
            end
            try
                dpVal=get(hDst,pName);
            catch err
                if isStrictCopy
                    rethrow(err);%#ok
                else
                    continue;
                end
            end



            copy_object_properties(spVal,dpVal);
        end

    end





