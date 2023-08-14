function valOut=getMATLABValueFromConnectorData(valIn)




    if~iscell(valIn)

        if any(ischar(valIn))
            valIn={valIn};
        else

            valIn=num2cell(valIn);
        end

    end

    isChar=cellfun(@ischar,valIn);


    if any(isChar)


        idxOfChar=find(isChar==1);


        for k=1:length(idxOfChar)


            switch valIn{idxOfChar(k)}


            case 'Inf'

                valIn{idxOfChar(k)}=Inf;


            case 'inf'

                valIn{idxOfChar(k)}=Inf;


            case '-Inf'

                valIn{idxOfChar(k)}=-Inf;


            case '-inf'

                valIn{idxOfChar(k)}=-Inf;


            case 'NaN'
                valIn{idxOfChar(k)}=NaN;


            otherwise

                if ischar(valIn{idxOfChar(k)})||isStringScalar(valIn{idxOfChar(k)})
                    valIn{idxOfChar(k)}=datacreation.internal.resolveMinMaxStr2Num(valIn{idxOfChar(k)},'double');


                end
            end

        end


    end

    valOut=valIn;
