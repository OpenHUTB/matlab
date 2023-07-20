function exportapp(handle,filespec)



























    import matlab.graphics.internal.export.ExportAppValidator;
    try
        currentPath=pwd;
        ExportAppValidator.isValidHandle(handle);
        [~,format,outputName]=ExportAppValidator.isValidFilespec(filespec,currentPath);
        ExportAppValidator.isCaptureFormatSupported(format);


        matlab.graphics.internal.export.logDDUXInfo('exportapp',handle,format);


        validVectorFormats=ExportAppValidator.getValidVectorFormats();
        validRasterFormats=ExportAppValidator.getValidRasterFormats();
        includeFigureToolbars=true;

        if ismember(format,validVectorFormats)
            if strcmpi(format,'pdf')&&matlab.graphics.internal.export.ExportAppValidator.isLiveEditorFigure(handle)
                error(message('MATLAB:print:LiveScriptFigureNoSupportPDF'));
            end
            matlab.ui.internal.FigureImageCaptureService.exportToPDF(handle,outputName,includeFigureToolbars);

        elseif ismember(format,validRasterFormats)


            drawnow;
            drawnow;
            matlab.graphics.internal.prepareFigureForPrint(handle,false);


            x=matlab.graphics.internal.getframeWithDecorations(handle,includeFigureToolbars,false);
            pj=matlab.graphics.internal.mlprintjob;


            imageData.format=format;
            imageData.filename=outputName;
            imageData.cdata=x.cdata;
            pj=localFillPrintJobForExportApp(pj,imageData);


            pj.writeRaster();

        end

    catch ex
        throw(ex)
    end
end


function pj=localFillPrintJobForExportApp(pj,imageData)
    pj.DriverClass='IM';
    format=lower(imageData.format);
    pj.Driver=format;
    pj.DriverExt=format;
    pj.Return=imageData.cdata;
    pj.FileName=imageData.filename;
end
