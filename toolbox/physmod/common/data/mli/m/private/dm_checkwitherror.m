function val=dm_checkwitherror(fcn,a,b,bUnit,parameterName,parameterDescription)








    if ischar(fcn)
        fcnInfo=dm_stringtocompfcn(fcn,'-message');
    else
        fcnInfo={fcn,'???'};
    end

    hFunc=fcnInfo{1};
    if~isa(hFunc,'function_handle')
        pm_error('physmod:common:data:mli:dm_checkwitherror:InvalidInputType');
    end

    val=a;
    if~all(hFunc(a,b))

        bStr=lParamValueToString(b);

        description=parameterDescription;
        if isempty(description)
            description=parameterName;
            if isempty(description)
                msgObj=message('physmod:common:data:mli:dm_checkwitherror:InternalValue');
                description=msgObj.getString;
            end
        end

        if strcmp(bUnit,'1')
            unitStr='';
        else
            unitStr=[' : ',bUnit];
        end

        pm_error('physmod:common:data:mli:dm_checkwitherror:InvalidParameterValue',...
        description,...
        fcnInfo{2},...
        bStr,...
        unitStr);
    end
end

function str=lParamValueToString(v)

    if isscalar(v)
        str=sprintf('%g',v);
    else
        str=mat2str(v);
    end

end


