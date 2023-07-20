classdef FileTypeHandler<handle




    properties(Hidden,GetAccess=public,SetAccess=private)
CloseElementVisitor
CreateWebViewVisitor
    end

    methods
        function set.CloseElementVisitor(obj,visitor)
            validateattributes(visitor,...
            {'evolutions.internal.filetypehandler.CloseElementVisitor'},{'nonempty'});
            obj.CloseElementVisitor=visitor;
        end

        function set.CreateWebViewVisitor(obj,visitor)
            validateattributes(visitor,...
            {'evolutions.internal.filetypehandler.CreateWebViewVisitor'},{'nonempty'});
            obj.CreateWebViewVisitor=visitor;
        end
    end

    methods
        function closeElements(obj,fileData)
            fileType=...
            evolutions.internal.filetypehandler.FileTypeFactory.getFileType(fileData);
            obj.CloseElementVisitor=evolutions.internal.filetypehandler.CloseElementVisitor;
            fileType.accept(obj.CloseElementVisitor);
        end

        function webViewPath=createWebView(obj,fileData,webviewPath)
            fileType=...
            evolutions.internal.filetypehandler.FileTypeFactory.getFileType(fileData);
            obj.CreateWebViewVisitor=evolutions.internal.filetypehandler.CreateWebViewVisitor(webviewPath);
            fileType.accept(obj.CreateWebViewVisitor);
            webViewPath=obj.CreateWebViewVisitor.HtmlPath;
        end

    end
end




