function[v,returnValue]=validateEnumParamValue(value,param,legalValues,defaultValue)






    if nargin<4
        defaultValue=legalValues{1};
    end

    err=0;
    errmsg=message('hdlcoder:validate:nomsg');

    if~isempty(value)
        if~isa(value,'char')
            returnValue=defaultValue;
            err=1;
            errmsg=message('hdlcoder:validate:noncharenumvalue',param);
        else

            match=strcmpi(value,legalValues);


            if sum(match)==0
                match=strncmpi(value,legalValues,length(value));
            end

            if sum(match)==1

                returnValue=legalValues{match};
            else

                returnValue=defaultValue;

                err=1;
                errmsg=message('hdlcoder:validate:nonenumvalue',...
                value,...
                param,...
                enum2str(legalValues));
            end
        end
    else
        returnValue=defaultValue;
    end

    v=hdlvalidatestruct(err,errmsg);

end

