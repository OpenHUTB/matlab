classdef ExportOptions<handle




    properties

        Diagrams={};



        SearchScope='CurrentAndBelow';


        IncludeMaskedSubsystems=false;


        IncludeReferencedModels=false;


        IncludeSimulinkLibraryLinks=false;


        IncludeUserLibraryLinks=false;


        FilterCallback=[];
    end

    properties(Hidden)


        WebViewHoleId='slwebview';
    end

    properties(Access=private)
        m_doc slreportgen.webview.WebViewDocument;
    end

    methods
        function h=ExportOptions(d,varargin)
            h.m_doc=d;
            d.ExportOptions=[d.ExportOptions,h];
            for i=1:2:numel(varargin)
                h.(varargin{i})=varargin{i+1};
            end
        end

        function set.Diagrams(h,diagrams)
            if isLocked(h)
                error(message('slreportgen_webview:document:ExportOptionsLocked'));
            end
            h.Diagrams=diagrams;
        end

        function set.SearchScope(h,searchScope)
            if isLocked(h)
                error(message('slreportgen_webview:document:ExportOptionsLocked'));
            end

            switch(lower(char(searchScope)))
            case 'all'
                h.SearchScope='All';
            case 'current'
                h.SearchScope='Current';
            case 'currentandabove'
                h.SearchScope='CurrentAndAbove';
            case 'currentandbelow'
                h.SearchScope='CurrentAndBelow';
            otherwise
                error(message('slreportgen_webview:document:InvalidSearchScope',searchScope));
            end
        end

        function set.IncludeMaskedSubsystems(h,includeMaskedSubsystems)
            if isLocked(h)
                error(message('slreportgen_webview:document:ExportOptionsLocked'));
            end
            h.IncludeMaskedSubsystems=includeMaskedSubsystems;
        end

        function set.IncludeReferencedModels(h,includeReferencedModels)
            if isLocked(h)
                error(message('slreportgen_webview:document:ExportOptionsLocked'));
            end
            h.IncludeReferencedModels=includeReferencedModels;
        end

        function set.IncludeSimulinkLibraryLinks(h,includeSimulinkLibraryLinks)
            if isLocked(h)
                error(message('slreportgen_webview:document:ExportOptionsLocked'));
            end
            h.IncludeSimulinkLibraryLinks=includeSimulinkLibraryLinks;
        end

        function set.IncludeUserLibraryLinks(h,includeUserLibraryLinks)
            if isLocked(h)
                error(message('slreportgen_webview:document:ExportOptionsLocked'));
            end
            h.IncludeUserLibraryLinks=includeUserLibraryLinks;
        end

        function set.FilterCallback(h,filterCallback)
            if isLocked(h)
                error(message('slreportgen_webview:document:ExportOptionsLocked'));
            end
            h.FilterCallback=filterCallback;
        end

        function set.WebViewHoleId(h,webviewHoleId)
            if isLocked(h)
                error(message('slreportgen_webview:document:ExportOptionsLocked'));
            end

            if isstring(webviewHoleId)
                webviewHoleId=char(webviewHoleId);
            end
            h.WebViewHoleId=webviewHoleId;
        end
    end

    methods(Access=private)
        function tf=isLocked(h)
            tf=isOpened(h.m_doc);
        end
    end
end

