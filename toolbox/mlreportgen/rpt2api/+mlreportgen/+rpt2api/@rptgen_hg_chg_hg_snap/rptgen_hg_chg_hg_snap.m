classdef(Abstract)rptgen_hg_chg_hg_snap<handle










    methods(Access=protected)

        function writeHandleGraphicsSnapshotProperties(this,varName)

            import mlreportgen.rpt2api.exprstr.Parser

            parentName=this.RptFileConverter.VariableNameStack.top;
            if~isempty(this.Component.Caption)
                Parser.writeExprStr(this.FID,...
                this.Component.Caption,'rptSnapshotCaption');
                fprintf(this.FID,'%s.Snapshot.Caption = rptSnapshotCaption;\n',varName);
            end

            if strcmp(this.Component.isResizeFigure,'manual')
                fprintf(this.FID,"%s.Scaling = 'custom';\n",varName);
                fprintf(this.FID,"%s.Width = '%s';\n",varName,strcat(string(this.Component.PrintSize(1)),...
                mlreportgen.rpt2api.utils.getUnitAbbreviation(this.Component.PrintUnits)));
                fprintf(this.FID,"%s.Height = '%s';\n",varName,strcat(string(this.Component.PrintSize(2)),...
                mlreportgen.rpt2api.utils.getUnitAbbreviation(this.Component.PrintUnits)));
            elseif strcmp(this.Component.isResizeFigure,'auto')
                fprintf(this.FID,"%s.Scaling = 'none';\n",varName);
            end


            imgFormat="svg";
            if~strcmpi(this.Component.ImageFormat,"ps")
                figureSnapshotFormat=lower(this.Component.ImageFormat(1:3));
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
            fprintf(this.FID,"%s.SnapshotFormat = '%s';\n",varName,imgFormat);

            if strcmp(this.Component.InvertHardcopy,'off')
                fprintf(this.FID,"%s.PreserveBackgroundColor = true;\n",varName);
            end

            fprintf(this.FID,'append(%s,%s);\n\n',parentName,varName);
        end
    end
end
