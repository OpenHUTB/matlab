function out=createTableHeaderCell(content,varargin)
    import slreq.report.internal.rtmx.*
    out=createCellStr('th',content,varargin{:});
end