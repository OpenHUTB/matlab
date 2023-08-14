function mdRows=omitMetadataForTimeCol(~,mdRows)



    if isfield(mdRows,'dataTypeRow')&&~isempty(mdRows.dataTypeRow)
        mdRows.dataTypeRow{end+1}='';
    end
    if isfield(mdRows,'unitsRow')&&~isempty(mdRows.unitsRow)
        mdRows.unitsRow{end+1}='';
    end
    if isfield(mdRows,'interpRow')&&~isempty(mdRows.interpRow)
        mdRows.interpRow{end+1}='';
    end
    if isfield(mdRows,'blockPathRow')&&~isempty(mdRows.blockPathRow)
        mdRows.blockPathRow{end+1}='';
    end
    if isfield(mdRows,'portIndexRow')&&~isempty(mdRows.portIndexRow)
        mdRows.portIndexRow{end+1}='';
    end
end
