classdef RequirementsViewExporter<slreportgen.webview.views.OptionalViewExporter








    properties
        HighlightBeforeExport=false;
        IncludeReferencedModels;
        IncludeLibraryLinks;
        IsGeneratingNewReport=false;
    end

    properties(Access=private)
        m_removeHighlightAfterExport;
    end

    methods
        function h=RequirementsViewExporter()
            h=h@slreportgen.webview.views.OptionalViewExporter();
            h.Id='requirements';
            h.Name=getString(message('slreportgen_webview:optional_views:Requirements'));
            h.Icon=fullfile(slreportgen.webview.IconsDir,'requirements.png');
            h.InformerDataExporter=slreportgen.webview.views.RequirementsDataExporter();
            h.ViewerDataExporter=slreportgen.webview.views.RequirementsViewerDataExporter();

        end

        function tf=isWidgetVisible(h)%#ok
            [rmiInstalled,rmiLicensed]=rmi.isInstalled();
            tf=rmiInstalled&&rmiLicensed;
        end

        function tf=isWidgetEnabled(h)%#ok




            tf=true;
        end

        function preExport(h,varargin)
            preExport@slreportgen.webview.views.OptionalViewExporter(h,varargin{:});







            cacheDir=rmi.Informer.cache('clearwebview');



            rmi.Informer.cache('clear');




            rmi.Informer.cache(['./',h.BaseUrl]);




            opt.exportDir=cacheDir;




            opt.destDir=h.BaseUrl;



            opt.includeLibraryLinks=h.IncludeLibraryLinks;
            opt.includeReferencedModels=h.IncludeReferencedModels;
            if reqmgt('rmiFeature','EnhancedWebViewReq')&&h.IsGeneratingNewReport
                slreq.report.webview.WebViewReqDataExporter.exportModelLinkData(h.Model,opt);
            else





                rmi.populateInformerData(h.Model,false);

                slreq.report.webview.WebViewReqDataExporter.refreshReqSetReferencedData(h.Model,opt);


                if(h.HighlightBeforeExport)
                    showRequirementHighlights(h);
                else
                    removeRequirementHighlights(h);
                end


                addRequirementDocsToPackage(h);
            end


            addRequirementSupportFilesToPackage(h,cacheDir,h.BaseUrl);


        end

        function postExport(h,varargin)
            if(h.m_removeHighlightAfterExport)
                removeRequirementHighlights(h);
            end
            postExport@slreportgen.webview.views.OptionalViewExporter(h,varargin{:});
        end
    end

    methods(Access=private)
        function showRequirementHighlights(h)
            modelH=h.Model;
            highlightState=get_param(modelH,'ReqHilite');
            if strcmp(highlightState,'off')
                set_param(h.Model,'ReqHilite','on');
                h.m_removeHighlightAfterExport=true;
            else
                h.m_removeHighlightAfterExport=false;
            end
        end

        function removeRequirementHighlights(h)
            modelH=h.Model;
            slprivate('remove_hilite',modelH);
        end

        function addRequirementDocsToPackage(h)
            modelName=get_param(h.Model,'Name');
            reqDocs=rmi.Informer.getDocs(modelName);
            nReqDocs=length(reqDocs);

            for i=1:nReqDocs
                reqDoc=reqDocs{i};

                doesExist=exist(reqDoc,'file');
                if(doesExist==2||doesExist==4)
                    addFile(h,reqDoc);
                end
            end
        end

        function addRequirementSupportFilesToPackage(h,srcDir,url)
            d=dir(srcDir);
            for i=3:length(d)
                dName=d(i).name;
                if(d(i).isdir)
                    if strcmp(dName,'cached')
                        continue;
                    end
                    newSrcDir=fullfile(srcDir,dName);
                    newUrl=[url,'/',dName];
                    addRequirementSupportFilesToPackage(h,newSrcDir,newUrl);
                else
                    [~,fName,fExt]=fileparts(dName);
                    fileName=fullfile(srcDir,[fName,fExt]);
                    fileUrl=[url,'/',fName,fExt];
                    addFile(h,fileName,fileUrl);
                end
            end
        end
    end
end
