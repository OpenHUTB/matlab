classdef ReportDocument<mlreportgen.dom.LockedDocument


    methods

        function rpt=ReportDocument(base)
            template=fullfile(matlabroot,'toolbox/shared/sdi/resources/templates/sdi.html');
            reportPath=fullfile(base.OutputFolder,base.OutputFile);
            rpt@mlreportgen.dom.LockedDocument(reportPath,'html-file',template);
            base.DocumentNode=rpt;
            open(rpt,getKey(rpt));
        end


    end

    methods(Access=private,Hidden=true)

        function key=getKey(~)








            key='E2CJpMz0QRVPjMCeSy35MVOrsOCwPXhMer4doICCaEId5K0fHl/KtorUbvsxwyi9ZoQyZXSbTe5GTiI2wNELovC+Th4KofJAj5mDO8QDFT/+6MCTZhtOet19YU5bbYnb/NhSULICTwtUE1XO7KwRviE/4gJTcEtamlFX1R0UwDH64WOz5mcEWjEmtvY34bUpsmgTTIXsAOh9vUMahEk=';
        end

    end

end

