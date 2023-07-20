function comp=CImportCode(varargin)











    comp=feval(mfilename('class'));
    comp.init(varargin{:});
