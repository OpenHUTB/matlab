classdef GalleryBrowserFactory<handle





    properties(Access=private)
        DialogTitle;
        Dimensions;
        DeathFunction;
        DebugPort;
        RelativeURL;
    end

    methods(Access=private)
        function obj=GalleryBrowserFactory(channel,varargin)
            p=inputParser;
            p.KeepUnmatched=true;
            p.addParameter('Debug',false,@islogical);
            p.addParameter('DebugPort',[]);
            p.parse(varargin{:});

            obj.DeathFunction=@sltemplate.ui.StartPage.close;
            obj.DebugPort=p.Results.DebugPort;

            obj.RelativeURL=obj.makeRelativeURL(channel,p.Results.Debug);

            obj.setStartPageProperties();

            obj.Dimensions.MinWidth=600;
            obj.Dimensions.MinHeight=400;
        end

        function setStartPageProperties(obj)
            obj.DialogTitle=message('sltemplate:Gallery:StartPageDialogTitle');
            obj.Dimensions.Width=1280;
            obj.Dimensions.Height=822;
        end

        function startPageURL=makeRelativeURL(~,channel,useDebugHTML)

            root='/toolbox/simulink/startpage/web/GalleryView/gallery';
            if useDebugHTML
                root=[root,'_debug'];
            end
            root=[root,'.html'];

            channelParam=['?channel=',channel];
            learnTab='';

            hasLearnTab=learning.simulink.preferences.CourseFeature.hasFeature(learning.simulink.preferences.CourseFeature.StartLearn);

            if hasLearnTab
                learnTab=['&learn=1'];
            end

            startPageURL=[root,channelParam,learnTab];
        end
    end

    methods(Access=public,Static)
        function galleryBrowser=create(varargin)
            factory=sltemplate.internal.GalleryBrowserFactory(varargin{:});

            galleryBrowser=sltemplate.internal.DialogWebBrowser(factory.DialogTitle,...
            factory.RelativeURL,...
            'Dimensions',factory.Dimensions,...
            'DebugPort',factory.DebugPort,...
            'DeathFunction',factory.DeathFunction);
        end

        function url=getURL(varargin)
            factory=sltemplate.internal.GalleryBrowserFactory(varargin{:});
            url=factory.RelativeURL;
        end
    end
end
