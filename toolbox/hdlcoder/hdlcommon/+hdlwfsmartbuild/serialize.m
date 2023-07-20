function str=serialize(objIn)






    if isnumeric(objIn)||islogical(objIn)||ischar(objIn)
        str=serializeMatrix(objIn);
    elseif isa(objIn,'containers.Map')
        str=serializeMap(objIn);
    elseif isstruct(objIn)
        str=serializeStruct(objIn);
    elseif iscell(objIn)
        str=serializeCell(objIn);
    else
        error('The input class is not supported in the serialize function\n');
    end

    function str=serializeMatrix(objIn)
        str='';

        if isnumeric(objIn)||islogical(objIn)
            objInVec=objIn(:);
            vecSize=length(objInVec);
            for i=1:vecSize
                ele=objInVec(i);
                if isnumeric(ele)
                    elestr=num2str(ele,'%16.15g');
                elseif islogical(ele)
                    if ele
                        elestr='1';
                    else
                        elestr='0';
                    end
                end
                str=[str,',',elestr];%#ok<AGROW>
            end
        else
            str=[str,objIn];
        end
        str=[str,';'];
    end

    function str=serializeMap(objIn)
        str='';
        eleNum=objIn.Count;
        allKeys=keys(objIn);
        for eleindex=1:eleNum
            thisKey=allKeys{eleindex};
            thisValue=objIn(thisKey);
            str=[str,',',thisKey,'.',hdlwfsmartbuild.serialize(thisValue)];%#ok<AGROW>
        end
        str=[str,';'];
    end

    function str=serializeStruct(objIn)
        str='';
        objInVec=objIn(:);
        vecSize=length(objInVec);
        for i=1:vecSize
            ele=objInVec(i);
            fieldNames=fieldnames(ele);
            fieldNum=numel(fieldNames);
            for fieldindex=1:fieldNum;
                fieldName=fieldNames{fieldindex};
                fieldValue=ele.(fieldName);
                str=[str,',',fieldName,'.',hdlwfsmartbuild.serialize(fieldValue)];%#ok<AGROW>
            end
            str=[str,';'];%#ok<AGROW>
        end
    end

    function str=serializeCell(objIn)
        str='';
        eleNum=numel(objIn);
        for eleindex=1:eleNum
            ele=objIn{eleindex};
            str=[str,',',hdlwfsmartbuild.serialize(ele)];%#ok<AGROW>
        end
        str=[str,';'];
    end

end

