

function addExcelSpecification(srcID,srcObj,sheet,range)

    if isempty(sheet)
        error(message('stm:general:NoSheetSpecifiedAPI'));
    end


    if isempty(srcObj.ExcelSpecifications)
        error(message('stm:general:InvalidExcelSource'));
    end


    if~isempty(range)
        if isempty(sheet)
            error(message('stm:general:NoSheetSpecifiedAPI'));
        end
    end


    srcSheets=srcObj.ExcelSpecifications.Sheet;
    if~isempty(find(strcmp(srcSheets,sheet),1))
        error(message('stm:general:SheetAlreadyExists'));
    end

    if(isa(srcObj,'sltest.testmanager.TestInput'))
        type=stm.internal.SourceSelectionTypes.Input;
    else
        assert(isa(srcObj,'sltest.testmanager.BaselineCriteria'));
        type=stm.internal.SourceSelectionTypes.Baseline;
    end


    exlOpt=struct(...
    'Type',int32(type),...
    'Sheets',string(sheet),...
    'Ranges',string(range),...
    'Path',srcObj.FilePath);

    stm.internal.addExcelOptions(srcID,exlOpt);
end