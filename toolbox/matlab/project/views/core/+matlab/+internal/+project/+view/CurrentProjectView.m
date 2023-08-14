classdef CurrentProjectView




    properties(GetAccess=public,SetAccess=private)
ViewModel
Url
    end
    methods
        function obj=CurrentProjectView(debug)

            view=matlab.internal.project.view.createCurrentProjectView();
            if(debug)
                url="/toolbox/matlab/project/views/core_web/index-debug.html";
            else
                url="/toolbox/matlab/project/views/core_web/index.html";

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
