function exportToPreviousRelease(this,matFileName,varName,varargin)%#ok<INUSL>













    assert(...
    ~strcmp(varName,'this')&&...
    ~strcmp(varName,'matFileName')&&...
    ~strcmp(varName,'varName'));

    eval(sprintf('%s = this;',varName));
    eval(sprintf('%s.ExportToPrev_ = true;',varName));
    save(matFileName,varargin{:},varName);
end