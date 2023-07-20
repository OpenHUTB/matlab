




classdef Exporter<handle




    methods(Static)

        function ExecutePrintJob(pj)

            slSfHandle=pj.Handles{1};
            slSfObj=SLPrint.Utils.GetSLSFObject(slSfHandle);

            mode=SLPrint.Utils.GetMode(pj,slSfObj);

            switch lower(mode)
            case{'auto','manual'}
                SLPrint.Exporter.ExportDefault(pj,slSfObj);
            case 'frame'
                DAStudio.error('Simulink:Printing:InvalidFormatForFramePrinting');
            case 'tiled'
                DAStudio.error('Simulink:Printing:InvalidFormatForTiledPrinting');
            otherwise
                DAStudio.error('Simulink:Printing:InvalidExportMode',mode);
            end

        end

        function ExportDefault(pj,slSfObj)

            p=SLPrint.Utils.GetPortal(slSfObj);
            p.exportOptions=SLPrint.Exporter.PrintJob2ExportOptions(pj);













            inCurrentView=isfield(pj,'sfCurrentView')&&pj.sfCurrentView;


            p.targetScene.Background.Color=SLPrint.Utils.GetBGColor(slSfObj);


            p.exportOptions.backgroundColorMode=get_param(0,'ExportBackgroundColorMode');

            if(inCurrentView)
                canvas=SLPrint.Utils.GetLastActiveSFEditorCanvasFor(slSfObj);
                p.exportCanvasView(canvas);
            else
                p.export;
            end

        end

        function exportOptions=PrintJob2ExportOptions(pj)

            exportOptions=GLUE2.PortalExportOptions;





            exportOptions.EMFGenType=4;

            [format,quality]=SLPrint.Exporter.GetExportFormat(pj);
            exportOptions.format=format;
            exportOptions.quality=quality;
            exportOptions.fileName=pj.FileName;
            exportOptions.resolution=pj.DPI;
            exportOptions.colorMode='Color';

        end

        function[found,isSubstitute,format]=GetExportFormatHelper(inFormat)

            found=false;
            isSubstitute=false;
            format='';

            persistent formatMap;
            persistent substituteFormatMap;


            if(isempty(formatMap))
                formatMap=containers.Map;
                formatMap('png')='PNG';
                formatMap('jpeg')='JPEG';
                formatMap('jpg')='JPEG';
                formatMap('bmp')='BMP';
                formatMap('bitmap')='BMP';
                formatMap('tiff')='TIFF';
                formatMap('pbm')='PBM';
                formatMap('pgm')='PGM';
                formatMap('ppm')='PPM';
                formatMap('meta')='EMF';
                formatMap('svg')='SVG';
                formatMap('pdf')='PDF';
                formatMap('pdfe')='PDF';
            end


            if(isempty(substituteFormatMap))
                substituteFormatMap=containers.Map;
                substituteFormatMap('bmp256')='BMP';
                substituteFormatMap('tiffnocompression')='TIFF';
                substituteFormatMap('bmpmono')='BMP';
                substituteFormatMap('ppmraw')='PPM';
                substituteFormatMap('pgmraw')='PGM';
                substituteFormatMap('pbmraw')='PBM';
            end

            if(formatMap.isKey(inFormat))
                found=true;
                format=formatMap(inFormat);
            elseif(substituteFormatMap.isKey(inFormat))
                found=true;
                isSubstitute=true;
                format=substituteFormatMap(inFormat);
            end

        end

        function[outFormat,quality]=GetExportFormat(pj)

            quality=-1;
            inFormat=pj.Driver;


            if(strncmpi(inFormat,'jpeg',4))
                inFormat='jpeg';
                regPat='jpeg(\d+)';
                tokens=regexp(pj.Driver,regPat,'tokens');
                if(~isempty(tokens))
                    match=tokens{1}{1};
                    match=match(1:2);
                    quality=str2double(match);
                    if(~isfinite(quality)||quality<=0)
                        quality=-1;
                    end
                end
            end

            [found,isSubstitute,outFormat]=SLPrint.Exporter.GetExportFormatHelper(inFormat);

            if(~found)
                DAStudio.error('Simulink:Printing:UnsupportedFormat',inFormat);
            end

            if(isSubstitute)
                MSLDiagnostic('Simulink:Printing:SubstitutingForUnsupportedFormat',inFormat,outFormat).reportAsWarning;
            end

        end

    end
end



