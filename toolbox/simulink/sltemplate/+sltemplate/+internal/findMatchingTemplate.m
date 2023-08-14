function[template,info]=findMatchingTemplate(name,varargin)










    [template,info]=Simulink.findTemplates(name,varargin{:});
    if isempty(template)

        if nargin>1

            template=Simulink.findTemplates(name);
            if~isempty(template)

                DAStudio.error('sltemplate:Registry:NoMatchingTemplate');
            end
        end

        DAStudio.error('sltemplate:Registry:NoMatchingTemplateName',name);
    else
        template=template{1};
        info=info{1};
    end

