function retStr=cleanmaskvalue(matVal)


















    pm_assert(ndims(matVal)<=2);




    pm_assert(isnumeric(matVal)||islogical(matVal));


    if isempty(matVal)
        retStr='[]';
    elseif numel(matVal)==1
        retStr=lNum2Str(matVal);
    else
        dimInfo=size(matVal);


        nRows=dimInfo(1);
        nCols=dimInfo(2);

        rowDelimStr=';';

        retStr='[';
        for iRow=1:nRows
            for iCol=1:nCols
                strVal=lNum2Str(matVal(iRow,iCol));
                retStr=[retStr,' ',strVal];%#ok<AGROW>
            end



            if iRow~=nRows
                retStr=[retStr,rowDelimStr];%#ok<AGROW>
            end
        end
        retStr=[retStr,' ]'];
    end

    if~isa(matVal,'double')
        retStr=[class(matVal),'(',retStr,')'];
    end

end

function retStr=lNum2Str(numVal)








    if~isfloat(numVal)
        retStr=num2str(numVal);
    elseif isnan(numVal)||isinf(numVal);
        retStr=num2str(numVal);
    else
        testVal=abs(numVal);
        if testVal>1000||(testVal<1e-3&&testVal>eps)


            retStr=sprintf('%.15e',numVal);


            numStr=regexp(retStr,'[-]{0,1}\d\.\d*','match');
            numStr=numStr{1};



            strLen=length(numStr);
            for idx=strLen:-1:2
                if strcmp(numStr(idx),'0')||strcmp(numStr(idx),'.')
                    numStr(idx)=[];
                else
                    break;
                end
            end








            expStr=regexpi(retStr,'e.*$','match');
            expStr=expStr{1};
            expStr=regexprep(expStr,'(e[+-]{0,1})0*([^0].*)','$1$2');

            retStr=[numStr,expStr];


            retStrDouble=str2double(retStr);
            if(abs(numVal-retStrDouble)>eps(max(abs(numVal),abs(retStrDouble))))
                retStr=sprintf('%.16g',numVal);
            end
        else
            retStr=sprintf('%.16g',numVal);
        end
    end
end

