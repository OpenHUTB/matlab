function err=checkFieldsOfStructVector(array,fieldNamesToCheck,fieldTypeCheckFuncHandle)




    err=[];
    if isempty(array)
        return;
    end
    if~slvariants.internal.config.utils.is1DArray(array)||~isstruct(array(1))
        err=MException(message('Simulink:Variants:ArgNotVectorOfStructs'));
        return;
    end
    array=transpose(array(:));
    names=fieldnames(array)';
    has=all(ismember(fieldNamesToCheck,names));
    if~has
        err=MException(message('Simulink:Variants:RequiredFieldsNotFound'));
        return;
    end
    numFields=length(fieldNamesToCheck);
    for i=1:numFields
        nameOfField=fieldNamesToCheck{i};
        checkFun=fieldTypeCheckFuncHandle{i};
        fieldVals={array(:).(nameOfField)};

        terrs=cellfun(checkFun,fieldVals,'UniformOutput',false);

        erridxes=find(~cellfun('isempty',terrs));
        if~isempty(erridxes)
            err=MException(message('Simulink:Variants:InvalidFieldValues',nameOfField));
            terrs=terrs(erridxes);
            numerrs=length(erridxes);
            for j=1:numerrs
                idx=erridxes(j);
                tterr=terrs{j};
                terrid='Simulink:Variants:InvalidElement';
                terr=MException(message(terrid,idx));
                terr=terr.addCause(tterr);
                err=err.addCause(terr);
            end
            break;
        end
    end
end
