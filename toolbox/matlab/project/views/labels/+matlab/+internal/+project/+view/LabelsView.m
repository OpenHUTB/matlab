classdef LabelsView




    properties(GetAccess=public,SetAccess=private)
ViewModel
CacheModel
Url
    end
    methods
        function obj=LabelsView(debug)

            [extensionView,cacheView]=matlab.internal.project.view.createLabelsView();
            if(debug)
                url="/toolbox/matlab/project/views/labels_web/index-debug.html";
            else
                url="/toolbox/matlab/project/views/labels_web/index.html";
            end
            url=url+"?client="+extensionView.ClientChannel...
            +"&server="+extensionView.ServerChannel...
            +"&command="+extensionView.CommandChannel...
            +"&cacheClient="+cacheView.ClientChannel...
            +"&cacheServer="+cacheView.ServerChannel;
            url=connector.getUrl(url);
            obj.ViewModel=extensionView;
            obj.CacheModel=cacheView;
            obj.Url=url;
        end

    end

end
