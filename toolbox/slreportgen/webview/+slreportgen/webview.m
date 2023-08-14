classdef webview

    properties(Constant)
        ResourcesDir=fullfile(matlabroot,'toolbox','slreportgen','webview','resources');
        IconsDir=fullfile(slreportgen.webview.ResourcesDir,'icons');
        TemplatesDir=fullfile(slreportgen.webview.ResourcesDir,'templates');
        JavaScriptLibDir=fullfile(slreportgen.webview.ResourcesDir,'lib');
    end

    methods(Static)
    end
end