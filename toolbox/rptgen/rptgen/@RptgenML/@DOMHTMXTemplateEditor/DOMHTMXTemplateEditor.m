function this=DOMHTMXTemplateEditor(varargin)







    this=feval(mfilename('class'));

    if~isempty(varargin)
        this.TemplatePath=varargin{1};
    end
