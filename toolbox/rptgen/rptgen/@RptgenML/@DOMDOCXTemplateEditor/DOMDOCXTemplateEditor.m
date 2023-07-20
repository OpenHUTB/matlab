function this=DOMDOCXTemplateEditor(varargin)







    this=feval(mfilename('class'));

    if~isempty(varargin)
        this.TemplatePath=varargin{1};
    end


