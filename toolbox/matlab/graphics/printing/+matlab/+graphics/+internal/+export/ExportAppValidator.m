classdef ExportAppValidator<handle





    methods(Static)
        function isvalid=isValidHandle(h)

            if length(h)~=1||~ishghandle(h,'figure')
                error(message('MATLAB:print:ExportHandleNotValid'))
            end





            if matlab.graphics.internal.export.ExportAppValidator.isLiveEditorFigure(h)
                return;
            end

            if~matlab.ui.internal.isUIFigure(h)
                error(message('MATLAB:print:ExportHandleNotValid'))
            end

            if~matlab.ui.internal.isFigureShowEnabled()
                error(message('MATLAB:print:HeadlessFigureUnsupported'));
            end
            isvalid=true;
        end

        function[isvalidFileName,format,outputName]=isValidFilespec(filespec,baseDir)
            import matlab.graphics.internal.export.ExportAppValidator;
            exporterHelper=matlab.graphics.internal.export.ExporterValidator;





            if~ischar(filespec)&&~isstring(filespec)
                error(message('MATLAB:print:InvalidFilename'));
            end

            filespec=convertStringsToChars(filespec);
            filespec=replace(filespec,{'\','/'},filesep);
            [fpath,fname,fext]=fileparts(filespec);

            if isempty(fname)||length(fext)<2
                error(message('MATLAB:print:OutputFileNeedsNameAndExtension'));
            end

            format=ExportAppValidator.validateFormat(fext);


            try
                outputDir=builtin('_canonicalizepath',fpath);
                outputName=fullfile(outputDir,[fname,fext]);
            catch ex
                error(message('MATLAB:print:CannotCreateOutputFile',filespec,ex.message));
            end

            isvalidFileName=exporterHelper.validateDestination(outputName);

        end

        function isvalid=isCaptureFormatSupported(~)








            if~matlab.graphics.internal.export.isAppCaptureSupported()
                error(message('MATLAB:print:AppCaptureAndExportNotSupported'));
            end
            isvalid=true;
        end

        function formats=getValidVectorFormats()
            formats={'pdf'}';
        end

        function formats=getValidRasterFormats()
            formats={'png','jpeg','tiff','jpg','tif'}';
        end

        function format=validateFormat(fext)
            import matlab.graphics.internal.export.ExportAppValidator;


            if fext(1)=='.'
                format=lower(fext(2:end));
            else
                format=lower(fext);
            end

            validVectorFormats=ExportAppValidator.getValidVectorFormats();
            validRasterFormats=ExportAppValidator.getValidRasterFormats();
            validFormats=[validVectorFormats;validRasterFormats];

            if~ismember(format,validFormats)
                error(message('MATLAB:print:InvalidFileFormatForExport',format));
            end
        end

        function tf=isLiveEditorFigure(fig)
            tf=isprop(fig,'LiveEditorRunTimeFigure');
        end

    end
end
