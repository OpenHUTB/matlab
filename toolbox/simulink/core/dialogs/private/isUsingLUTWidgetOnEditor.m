function usingLUTWidget=isUsingLUTWidgetOnEditor(h)

    if((~isempty(findprop(h,'DialogData')))&&isfield(h.DialogData,'BreakpointsSpecification'))
        usingLUTWidget=(isequal(h.DialogData.BreakpointsSpecification,'Explicit values'))&&...
        isValidDataTypeToDisplayLUTWidgetInEditor(h);
    else
        usingLUTWidget=(isfield(h,'BreakpointsSpecification')&&...
        (isequal(h.BreakpointsSpecification,'Explicit values')))&&...
        isValidDataTypeToDisplayLUTWidgetInEditor(h);
    end
end

function isValidDataType=isValidDataTypeToDisplayLUTWidgetInEditor(h)
    if((~isempty(findprop(h,'DialogData')))&&isfield(h.DialogData,'Breakpoints'))
        for bpIndex=1:numel(h.DialogData.Breakpoints)
            isValidDataType=isValidDT(h.DialogData.Breakpoints(bpIndex).Value);
            if~isValidDataType
                return;
            end
        end
    else
        for bpIndex=1:numel(h.Breakpoints)
            isValidDataType=isValidDT(h.Breakpoints(bpIndex).Value);
            if~isValidDataType
                return;
            end
        end
    end
    if((~isempty(findprop(h,'DialogData')))&&isfield(h.DialogData,'Table'))
        isValidDataType=isValidDT(h.DialogData.Table.Value);
    else
        isValidDataType=isValidDT(h.DTable.Value);
    end
end

function isValidDTForValue=isValidDT(val)
    isValidDTForValue=~isenum(val)&&isreal(val);
end
