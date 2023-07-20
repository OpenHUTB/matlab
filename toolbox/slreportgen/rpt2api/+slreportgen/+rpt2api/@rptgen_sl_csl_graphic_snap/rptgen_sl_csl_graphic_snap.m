classdef(Abstract)rptgen_sl_csl_graphic_snap<handle










    methods(Access=protected)

        function writeGraphicsSnapshotProperties(this,varName,imageFormat)

            if strcmpi(this.Component.ViewportType,'fixed')||strcmpi(this.Component.ViewportType,'zoom')
                fprintf(this.FID,'%s.Snapshot.Width = "%s";\n',varName,strcat(string(this.Component.ViewportSize(1)),...
                mlreportgen.rpt2api.utils.getUnitAbbreviation(this.Component.ViewportUnits)));
                fprintf(this.FID,'%s.Snapshot.Height = "%s";\n',varName,strcat(string(this.Component.ViewportSize(2)),...
                mlreportgen.rpt2api.utils.getUnitAbbreviation(this.Component.ViewportUnits)));
            end


            imgFormat="svg";
            if~strcmpi(imageFormat,"ps")
                figureSnapshotFormat=lower(imageFormat(1:3));
                switch figureSnapshotFormat
                case 'jpe'
                    imgFormat="jpeg";
                case 'bmp'
                    imgFormat="bmp";
                case 'png'
                    imgFormat="png";
                case 'emf'
                    imgFormat="emf";
                case 'tif'
                    imgFormat="tiff";
                case 'pdf'
                    imgFormat="pdf";
                end
            end
            fprintf(this.FID,'%s.SnapshotFormat = "%s";\n',varName,imgFormat);
        end
    end
end
