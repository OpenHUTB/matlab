classdef ModelCoverageViewExporter<slreportgen.webview.views.OptionalViewExporter



    properties
        HighlightBeforeExport=false;
    end

    properties(Access=private)
        m_cvdata;
        m_cvmap;
        m_removeHighlightAfterExport;
        m_resetCvData;
    end

    methods
        function h=ModelCoverageViewExporter()
            h=h@slreportgen.webview.views.OptionalViewExporter();
            h.Id='coverage';
            h.Name=getString(message('slreportgen_webview:optional_views:Coverage'));
            h.Icon=fullfile(slreportgen.webview.IconsDir,'coverage.png');
            h.ViewerDataExporter=slreportgen.webview.views.ModelCoverageViewerDataExporter();
            h.InformerDataExporter=slreportgen.webview.views.ModelCoverageDataExporter();
        end

        function tf=isWidgetVisible(h)%#ok
            tf=license('test','Simulink_Coverage')&&~isempty(ver('slcoverage'));
        end

        function tf=isWidgetEnabled(h)

            tf=~isempty(license('inuse','Simulink_Coverage'))...
            &&~isempty(cvreportdata(h.Model));
        end

        function preExport(h,varargin)
            preExport@slreportgen.webview.views.OptionalViewExporter(h,varargin{:});


            if isempty(h.m_cvdata)
                setCoverageData(h,h.Model);
                h.m_resetCvData=true;
            else
                h.m_resetCvData=false;
            end


            if isCoverageDataValid(h)

                if h.HighlightBeforeExport
                    showCoverageHighlights(h);
                else
                    removeCoverageHighlights(h);
                end
            else
                warning(['No coverage information for ',get_param(h.Model,'Name')]);
            end
        end

        function postExport(h)
            if(h.m_removeHighlightAfterExport)
                removeCoverageHighlights(h);
            end
            if(h.m_resetCvData)
                setCoverageData(h,[]);
            end
            postExport@slreportgen.webview.views.OptionalViewExporter(h);
        end

        function setCoverageData(h,in)
            if isa(in,'cvdata')||isa(in,'cv.cvdatagroup')
                h.m_cvdata=in;
            elseif isempty(in)
                h.m_cvdata=[];
            else
                model=slreportgen.utils.getModelHandle(in);
                h.m_cvdata=cvreportdata(model);
            end

            if(isempty(h.m_cvmap)&&~isempty(h.m_cvdata))
                tcvs=cvi.CvhtmlSettings;
                tcvs.modelDisplay=0;
                tcvs.generatWebViewReportData=1;
                [h.m_cvmap,~]=cvmodelview(h.m_cvdata,tcvs);
            else
                h.m_cvmap=[];
            end
        end

        function covMap=getCoverageMap(h)
            covMap=h.m_cvmap;
        end

        function tf=isCoverageDataValid(h)
            cvdata=h.m_cvdata;
            tf=~isempty(cvdata)&&valid(cvdata);
        end
    end

    methods(Access=private)
        function showCoverageHighlights(h)
            modelcovId=getModelCoverageId(h);
            if~isempty(modelcovId)

                informer=cvi.Informer.getInstance(modelcovId);
                if~isempty(informer)
                    cvmodelview(h.m_cvdata);
                    h.m_removeHighlightAfterExport=true;
                else
                    h.m_removeHighlightAfterExport=false;
                end
            else
                warning('Cannot highlight');
            end
        end

        function removeCoverageHighlights(h)
            slprivate('remove_hilite',h.Model);


            modelcovId=getModelCoverageId(h);
            if~isempty(modelcovId)
                cvi.Informer.close(modelcovId);
            end
        end

        function modelcovId=getModelCoverageId(h)
            modelcovId=[];
            covId=get_param(h.Model,'CoverageId');
            if(covId~=0)
                modelcovId=covId;
            end
        end
    end
end

