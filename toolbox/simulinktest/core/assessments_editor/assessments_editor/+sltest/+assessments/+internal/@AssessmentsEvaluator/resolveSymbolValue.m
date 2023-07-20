function value=resolveSymbolValue(symbolName,symbolValue,fieldElement)
    import sltest.assessments.internal.AssessmentsEvaluator.*;

    fieldElement=strip(fieldElement);
    if isempty(fieldElement)
        value=symbolValue;
        checkValueIsValidScalar(symbolName,value);
        return;
    end

    assert(~isempty(symbolName),'Empty symbol name');
    exprMtree=mtree([symbolName,fieldElement]);
    if strcmp(exprMtree.root.kind,'ERR')
        error(message('sltest:assessments:ParseErrorFieldElementExpression',fieldElement,symbolName));
    end

    subsArray=mtreeToSubsref(symbolName,fieldElement,exprMtree);
    assert(length(subsArray)>=1);

    try
        if strcmp(subsArray(end).type,'()')


            arrayIndex=subsArray(end);
            subsArray(end)=[];


            if~isempty(subsArray)
                value=subsref(symbolValue,subsArray);
            else

                value=symbolValue;
            end


            value=resolveArrayIndex(value,arrayIndex);
        else
            value=subsref(symbolValue,subsArray);
        end
    catch ME
        if strcmp(ME.identifier,'MATLAB:badsubscript')

            error(message('sltest:assessments:ArrayBoundsErrorSubref',fieldElement,symbolName));
        else

            error(message('sltest:assessments:InvalidSubref',fieldElement,symbolName,ME.message));
        end
    end

    checkValueIsValidScalar(symbolName,value);
end

function result=resolveArrayIndex(value,arrayIndex)
    if isa(value,'timeseries')

        if ndims(value.Data)>2 %#ok<ISMAT>
            arrayIndex.subs{end+1}=':';
        else
            arrayIndex.subs=[{':'},arrayIndex.subs{:}];
        end
        data=squeeze(subsref(value.Data,arrayIndex));
        interpMethod=value.getinterpmethod;
        result=timeseries(data,value.Time);
        result=result.setinterpmethod(interpMethod);
    else
        result=subsref(value,arrayIndex);
    end
end
