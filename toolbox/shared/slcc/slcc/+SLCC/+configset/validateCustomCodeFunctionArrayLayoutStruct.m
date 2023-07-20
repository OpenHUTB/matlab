function out=validateCustomCodeFunctionArrayLayoutStruct(in)


    out=in;
    try
        loc_checkBasicFormat(out);
        if isempty(out)
            return;
        end
        [allFcnNames,allArrLayouts]=loc_preprocessing(out);
        loc_checkInvalidCharsAndDuplicates(allFcnNames);
        loc_checkValidArrayLayoutSetting(allArrLayouts);
    catch e
        e.throwAsCaller();
    end

    out=struct('FunctionName',allFcnNames,'ArrayLayout',allArrLayouts);
end

function loc_checkBasicFormat(in)
    throwErr=false;
    if isstruct(in)
        fn=fieldnames(in);
        if(numel(fn)~=2)
            throwErr=true;
        elseif~isfield(in,'FunctionName')||~isfield(in,'ArrayLayout')
            throwErr=true;
        elseif~isrow(in)
            throwErr=true;
        end
    elseif~isempty(in)
        throwErr=true;
    end

    if throwErr
        e=MException(message('Simulink:CustomCode:FunctionArrayLayoutWrongFormat'));
        e.throw();
    end
end

function[allFcnNames,allArrLayouts]=loc_preprocessing(in)
    allFcnNames=deblank(cellstr({in.FunctionName}));
    allArrLayouts=deblank(cellstr({in.ArrayLayout}));
end

function loc_checkInvalidCharsAndDuplicates(allFcnNames)

    if any(cellfun(@isempty,allFcnNames))
        e=MException(message('Simulink:CustomCode:FunctionArrayLayoutEmptyNames'));
        e.throwAsCaller();
    end


    wspaceLogicalIdx=cellfun(@any,isstrprop(allFcnNames,'wspace'));
    if any(wspaceLogicalIdx)
        wspaceFcnNames=unique(allFcnNames(wspaceLogicalIdx));
        namesToReport=sprintf('''%s'', ',wspaceFcnNames{:});
        namesToReport(end-1:end)=[];
        e=MException(message('Simulink:CustomCode:FunctionArrayLayoutNamesWithWhitespace',namesToReport));
        e.throw();
    end


    [~,iIn,iU]=unique(allFcnNames);
    [fcnCounts,~,bins]=histcounts(iU,numel(iIn));
    nonUniqueLogicalIdx=fcnCounts(bins)>1;
    if any(nonUniqueLogicalIdx)
        nonUniqueFcnNames=unique(allFcnNames(nonUniqueLogicalIdx));
        namesToReport=sprintf('''%s'', ',nonUniqueFcnNames{:});
        namesToReport(end-1:end)=[];
        e=MException(message('Simulink:CustomCode:FunctionArrayLayoutDuplicateNames',namesToReport));
        e.throw();
    end
end

function loc_checkValidArrayLayoutSetting(allArrayLayouts)
    import SLCC.configset.functionmajority.utils.*;
    validOptions=getFunctionArrayLayoutOptsEnglish();
    numValidOptions=numel(validOptions);
    assert(numValidOptions>0);
    validEntriesLoglicalIdx=ismember(allArrayLayouts,validOptions);
    if~all(validEntriesLoglicalIdx)
        e=MException(message('Simulink:CustomCode:FunctionArrayLayoutInvalidSetting'));
        e.throw();
    end
end