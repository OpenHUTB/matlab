classdef ReferencesView




    properties(GetAccess=public,SetAccess=private)
ViewModel
Url
    end
    methods
        function obj=ReferencesView(debug)

            view=matlab.internal.project.view.createReferencesView();
            if(debug)
                url="/toolbox/matlab/project/views/references_web/index-debug.html";
            else
                url="/toolbox/matlab/project/views/references_web/index.html";
            end
            url=url+"?client="+view.ClientChannel...
            +"&server="+view.ServerChannel...
            +"&command="+view.CommandChannel;
            url=connector.getUrl(url);
            obj.ViewModel=view;
            obj.Url=url;
        end

    end

end
