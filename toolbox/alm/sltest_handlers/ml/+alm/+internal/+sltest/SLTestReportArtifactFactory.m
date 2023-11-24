classdef SLTestReportArtifactFactory<alm.internal.AbstractArtifactFactory

    methods

        function h=SLTestReportArtifactFactory(metaData,storage,g)
            h=h@alm.internal.AbstractArtifactFactory(metaData,storage,g);
        end

        function type=getSelfContainedType(h,address)
            type="";
            [~,~,ext]=fileparts(address);
            switch ext
            case{'.pdf','.docx','.zip'}
                opaqueFileCache=...
                alm.internal.OpaqueFileCache.getInstance();
                opaqueFileContents=opaqueFileCache.get(address);
                if~isempty(opaqueFileContents)
                    type="sl_test_report_file";
                end
            end
        end
    end

end
