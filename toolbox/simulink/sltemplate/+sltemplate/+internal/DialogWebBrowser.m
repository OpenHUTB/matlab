classdef DialogWebBrowser<sltemplate.internal.Browser





    properties(SetAccess=private,GetAccess=public)
        Title;
        Geometry;
        Dimensions;
        CloseFunction;
        DeathFunction;
        DebugPort;
        AllowResize;
        Webwindow;
        HTMLRelativePath;
    end

    methods(Access=public)

        function obj=DialogWebBrowser(aTitle,htmlRelPath,varargin)











            p=inputParser;
            p.addParameter('Dimensions',[],@sltemplate.internal.DialogWebBrowser.validateDialogDimensions);
            p.addParameter('CloseFunction',@(varargin)obj.hide,@(x)isa(x,'function_handle'));
            p.addParameter('DeathFunction',[],@(x)isa(x,'function_handle'));
            p.addParameter('DebugPort',[],@isnumeric);
            p.addParameter('AllowResize',true,@islogical);
            p.parse(varargin{:});

            obj.Title=aTitle;
            obj.Dimensions=p.Results.Dimensions;
            obj.CloseFunction=p.Results.CloseFunction;
            obj.DeathFunction=p.Results.DeathFunction;
            obj.DebugPort=p.Results.DebugPort;
            obj.AllowResize=p.Results.AllowResize;
            obj.HTMLRelativePath=htmlRelPath;

            if isempty(obj.DebugPort)

                obj.DebugPort=matlab.internal.getDebugPort();
            end

            obj.Geometry=obj.getValidGeometry();
            obj.createWindow;
        end

        function isValid=validateBrowser(obj)
            isValid=isvalid(obj)&&~isempty(obj.Webwindow)&&obj.Webwindow.isWindowValid;
        end

        function visible=isVisible(obj)
            visible=obj.validateBrowser()&&obj.Webwindow.isVisible;
        end

        function show(obj)
            if validateBrowser(obj)
                obj.Webwindow.bringToFront;
            end
        end

        function refresh(obj)
            if validateBrowser(obj)
                obj.Geometry=obj.Webwindow.Position;
                obj.close;
            end
            obj.createWindow;
            obj.show;
        end

        function hide(varargin)
            sltemplate.internal.utils.logDDUX("Hide");
            obj=varargin{1};
            if validateBrowser(obj)
                obj.Webwindow.hide;
            end
        end

        function close(obj)
            sltemplate.internal.utils.logDDUX("Close");
            if validateBrowser(obj)
                obj.Webwindow.close();
            end
        end



        function destroyOnClose(obj)
            obj.CloseFunction=@(varargin)obj.close;
            obj.DeathFunction=@(varargin)obj.close;
            obj.setCallbackFunctions;
        end

        function url=getAbsoluteURL(obj)
            if validateBrowser(obj)
                url=obj.Webwindow.URL;
            else
                url='';
            end
        end

    end

    methods(Access=private)
        function geometry=getValidGeometry(obj)
            if isempty(obj.Dimensions)

                obj.Dimensions.Width=600;
                obj.Dimensions.Height=400;
            end


            ss=get(0,'ScreenSize');
            screen.Width=ss(3);
            screen.Height=ss(4);



            fudgeFactor=150;
            obj.Dimensions.Width=min(screen.Width-fudgeFactor,obj.Dimensions.Width);
            obj.Dimensions.Height=min(screen.Height-fudgeFactor,obj.Dimensions.Height);

            x=(screen.Width-obj.Dimensions.Width)/2;
            y=(screen.Height-obj.Dimensions.Height)/2;

            geometry=[x,y,obj.Dimensions.Width,obj.Dimensions.Height];
        end

        function setCallbackFunctions(obj)
            obj.Webwindow.CustomWindowClosingCallback=obj.CloseFunction;

            if isempty(obj.DeathFunction)

                obj.DeathFunction=obj.CloseFunction;
            end

            obj.Webwindow.MATLABWindowExitedCallback=obj.DeathFunction;



            obj.Webwindow.PageLoadFinishedCallback=...
            @(varargin)obj.doSetSizingOptions();
        end

        function doSetSizingOptions(obj)
            obj.setResizable();
            obj.setMinDimensions();
        end

        function setResizable(obj)
            if obj.AllowResize~=obj.Webwindow.isResizable



                obj.Webwindow.setResizable(obj.AllowResize);
            end
        end

        function setMinDimensions(obj)
            if all(isfield(obj.Dimensions,{'MinWidth','MinHeight'}))
                obj.Webwindow.setMinSize([obj.Dimensions.MinWidth,obj.Dimensions.MinHeight]);
            end
        end

        function setIcon(obj)
            if ismac
                return;
            end

            obj.Webwindow.Icon=sltemplate.internal.Constants.getDialogIcon(ispc);
        end

        function createWindow(obj)
            obj.Webwindow=matlab.internal.webwindow(connector.getUrl(obj.HTMLRelativePath),obj.DebugPort,obj.Geometry);
            obj.Webwindow.Title=obj.Title.getString;
            obj.setCallbackFunctions();
            obj.setIcon();
        end
    end

    methods(Access=public,Static=true,Hidden=true)

        function isValid=validateHtmlPath(htmlPath)
            isValid=false;

            fileFound=exist(fullfile(matlabroot,htmlPath),'file')==2;

            htmlExt='.html';
            hasHtmlExt=strcmp(htmlPath(end-4:end),htmlExt);

            if ischar(htmlPath)&&fileFound&&hasHtmlExt
                isValid=true;
            end
        end

        function isValid=validateDialogDimensions(dimensions)
            isValid=false;
            if isstruct(dimensions)&&isfield(dimensions,'Width')&&isfield(dimensions,'Height')
                isValid=true;
            end
        end

    end

end
