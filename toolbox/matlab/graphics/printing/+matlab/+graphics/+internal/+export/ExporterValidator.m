classdef ExporterValidator<handle





    methods(Static)

        function isvalid=validateHandle(h)



            if isa(h,'matlab.graphics.primitive.canvas.JavaCanvas')||...
                isa(h,'matlab.graphics.primitive.canvas.HTMLCanvas')||...
                isa(h,'matlab.graphics.axis.AbstractAxes')||...
                isa(h,'matlab.graphics.chart.Chart')||...
                isa(h,'matlab.graphics.internal.export.GraphicsExportable')||...
                isa(h,'matlab.ui.internal.mixin.CanvasHostMixin')
                isvalid=true;
            else
                error(message('MATLAB:print:ExportHandleNotValid'));
            end
        end

        function isvalid=validateDestination(dest)
            import matlab.graphics.internal.export.ExporterValidator
            try
                [isvalid,~,errMsg]=ExporterValidator.canWriteToFile(dest);
            catch ex
                isvalid=false;
                errMsg=ex.message;
            end
            if~isvalid
                error(message('MATLAB:print:CannotCreateOutputFile',dest,errMsg));
            end
        end

        function isvalid=validateTarget(target)

            isvalid=ismember(lower(target),{'file','array','clipboard'});
            if~isvalid
                error(message('MATLAB:print:InvalidTargetValueForExport',target));
            end

        end

        function isvalid=validateFormat(fmt)
            import matlab.graphics.internal.export.ExporterValidator

            isvalid=ismember(lower(fmt),ExporterValidator.getValidFormats());
            if~isvalid
                error(message('MATLAB:print:InvalidOutputFormat'));
            end
        end

        function isvalid=validateResolution(resolution)

            isvalid=~(isempty(resolution)||isnan(resolution)||...
            isinf(resolution)||resolution<=0||...
            (int32(resolution)~=resolution));
            if~isvalid
                error(message('MATLAB:print:InvalidExportResolution'));
            end
        end

        function isvalid=validateMargins(margins)

            import matlab.graphics.internal.export.ExporterValidator

            ExporterValidator.getMarginValue(margins);
            isvalid=true;

        end

        function isvalid=validateBackground(background)



            matlab.graphics.internal.export.ExporterValidator.getColorFromSpec(background);
            isvalid=true;
        end

        function isvalid=validateVectorFlag(flag)


            if flag==false
                flag='false';
            elseif flag==true
                flag='true';
            end

            if ismember(lower(flag),matlab.graphics.internal.export.ExporterValidator.getValidVectorValues())
                isvalid=true;
            else
                isvalid=false;
            end
            if~isvalid
                error(message('MATLAB:print:InvalidInternalVectorFlag'));
            end
        end

        function validateColorspace(colorspace)

            import matlab.graphics.internal.export.ExporterValidator

            isvalid=ismember(lower(colorspace),ExporterValidator.getValidColorspaces());
            if~isvalid
                error(message('MATLAB:print:UnrecognizedColorspace'));
            end

        end

        function validateAppendValue(append)
            if~islogical(append)
                error(message('MATLAB:print:UnrecognizedAppendValue'));
            end
        end

        function isvalid=validateSize(outputSize)
            isvalid=true;
            if ischar(outputSize)
                if~strcmpi(outputSize,"auto")
                    isvalid=false;
                end
            else
                if~isnumeric(outputSize)||~isvector(outputSize)...
                    ||length(outputSize)~=2||any(outputSize<=0)||any(isinf(outputSize))
                    isvalid=false;
                end
            end
            if~isvalid
                error(message('MATLAB:print:InvalidExportSize'));
            end
        end

        function isvalid=validateUnits(units)
            isvalid=ismember(lower(units),{'auto','centimeters','inches','pixels','points'});
            if~isvalid
                error(message('MATLAB:print:InvalidExportUnits'));
            end
        end

        function results=crossValidateInputs(results)


            import matlab.graphics.internal.export.ExporterValidator
            import matlab.graphics.internal.export.Exporter
            if strcmp(results.target,'file')
                if isempty(results.destination)
                    results.destination='output';
                end
            end


            if~isempty(results.destination)&&~strcmp(results.target,'file')
                error(message('MATLAB:print:ExportDestinationOnlyAllowedforFile'));
            end


            if strcmp(results.target,'file')&&isempty(results.format)
                [~,~,ext]=fileparts(results.destination);
                if isempty(ext)
                    ext='.png';
                end


                fmt=ExporterValidator.getFormatForExtension(ext(2:end));
                results.format=fmt;
            end


            fileExt='';
            if~isempty(results.format)&&strcmp(results.target,'file')
                results.destination=ExporterValidator.addExtensionIfNeeded(results.format,results.destination);
                [isvalid,outputName,errMsg]=ExporterValidator.canWriteToFile(results.destination);
                if~isvalid
                    error(message('MATLAB:print:CannotCreateOutputFile',results.destination,errMsg));
                else
                    results.destination=outputName;
                end
                [~,~,fileExt]=fileparts(results.destination);
            end


            if strcmp(results.target,'array')&&...
                ~any(strcmp(results.format,ExporterValidator.getValidArrayFormats()))
                error(message('MATLAB:print:InvalidOutputFormatForTarget',results.format,results.target));
            end



            if strcmp(results.target,'file')&&...
                ~any(strcmp(results.format,ExporterValidator.getOutputFileFormats()))
                error(message('MATLAB:print:InvalidOutputFormatForTarget',results.format,results.target));
            end







            if strcmp(results.target,'clipboard')
                if isempty(results.format)
                    results.format='auto';
                end
                if~any(strcmp(results.format,ExporterValidator.getClipboardFormats()))
                    error(message('MATLAB:print:InvalidOutputFormatForTarget',results.format,results.target));
                end
                results.format=ExporterValidator.getFormatForClipboard(results);
            end


            if ischar(results.resolution)
                results.resolution=str2double(results.resolution);
            end




            switch results.resolution
            case 0
                h=Exporter.getExportableHandle(results.handle);
                results.resolution=h.ScreenPixelsPerInch;
            case-1
                results.resolution=ExporterValidator.getDefault('resolution');
            end
            results.resolution=double(results.resolution);


            results.margins=ExporterValidator.getMarginValue(results.margins);


            results.background=ExporterValidator.getColorFromSpec(results.background);



            if islogical(results.vector)
                if results.vector
                    results.vector='true';
                else
                    results.vector='false';
                end
            end
            results.vector=lower(results.vector);





            if strcmp(results.colorspace,'cmyk')
                if strcmp(results.target,'clipboard')
                    error(message('MATLAB:print:CMYKUnsupportedForClipboard'));
                elseif~(strcmp(results.target,'file')&&...
                    ExporterValidator.isCMYKSupported(fileExt))
                    error(message('MATLAB:print:UnsupportedColorspace',results.colorspace,results.format));
                end
            end




            if islogical(results.append)
                if(results.append)
                    if strcmp(results.target,'clipboard')
                        error(message('MATLAB:print:AppendUnsupportedForClipboard'));
                    elseif~(strcmp(results.target,'file')&&...
                        ExporterValidator.isAppendSupported(fileExt))
                        error(message('MATLAB:print:UnsupportedAppendValue',results.format));
                    end
                end
            else
                error(message('MATLAB:print:UnrecognizedAppendValue'));
            end



            if~isempty(results.handle)
                parentFig=ancestor(results.handle,'figure');
                if~matlab.ui.internal.isUIFigure(parentFig)&&...
                    (~strcmp(results.size,"auto")||~strcmp(results.units,"auto"))


                    error(message('MATLAB:print:JavaHandleNotValid'))
                end
            end


            if~isnumeric(results.size)&&strcmpi(results.size,'auto')&&~strcmpi(results.units,'auto')
                error(message('MATLAB:print:SizeUnitsBothAuto','Units','Size'));
            end

            if isnumeric(results.size)&&strcmpi(results.units,'auto')
                error(message('MATLAB:print:SizeUnitsBothAuto','Size','Units'));
            end

            if strcmpi(results.units,'pixels')&&...
                ~(ismember(lower(results.format),ExporterValidator.getValidRasterFormats())||...
                strcmpi(results.target,'array'))
                error(message('MATLAB:print:PixelsOnlyWithImage'));
            end
        end

        function result=getMarginValue(margins)




            result=[];
            if ischar(margins)
                switch margins
                case 'loose'
                    result=-1;
                case 'tight'
                    result=0;
                end
            elseif isnumeric(margins)
                isvalid=~isinf(margins)&&~isnan(margins)&&...
                (margins>=0&&margins<=10);
                if isvalid
                    result=margins;
                end
            end
            if isempty(result)
                error(message('MATLAB:print:InvalidMarginValueForExport'));
            else

                result=floor(result);
            end
        end

        function result=getColorFromSpec(bkgColor)




            if isempty(bkgColor)
                result=bkgColor;
            elseif ischar(bkgColor)
                bkgColor=lower(char(bkgColor));
                switch(bkgColor)
                case 'none'
                    result='none';
                otherwise
                    try
                        result=hgcastvalue('matlab.graphics.datatype.RGBColor',bkgColor);
                    catch
                        error(message('MATLAB:datatypes:RGBColor:ParseError'));
                    end
                end
            elseif isreal(bkgColor)&&isvector(bkgColor)&&size(bkgColor,2)==3
                if any(isnan(bkgColor))||any(bkgColor<0)||any(bkgColor>1)
                    error(message('MATLAB:hg:ColorBase:BadColorValue'));
                end
                result=bkgColor;
            else
                error(message('MATLAB:datatypes:RGBColor:ValueMustBe3ElementVector'));
            end
        end
        function s=getFormatForExtension(ext)



            import matlab.graphics.internal.export.ExporterValidator
            [fmts,exts]=ExporterValidator.getOutputFileFormats();
            [isvalid,idx]=ismember(lower(ext),exts);
            if isvalid
                s=fmts{idx};
            else
                s='';
            end
        end

    end
    methods(Static,Access={?ExporterValidator,?tExporterValidator})
        function rasterFormats=getValidRasterFormats()
            rasterFormats={'bmp','png','jpeg','tiff'}';
        end

        function vectorFormats=getValidVectorFormats()
            vectorFormats={'pdf','psc','epsc','svg'};
        end
    end
    methods(Static,Access=protected)

        function[fmts,exts]=getOutputFileFormats()


            fmts={'png','jpeg','jpeg','bmp','tiff','tiff','pdf','psc','epsc','svg','gif'};

            fmtExts={'png','jpeg','jpg','bmp','tif','tiff','pdf','ps','eps','svg','gif'};

            if ispc

                fmts(end+1)={'meta'};
                fmtExts(end+1)={'emf'};
            end

            if nargout==2
                exts=fmtExts;
            end
        end

        function supported=isCMYKSupported(fmt)

            supported=contains(fmt,'ps','IgnoreCase',true);
        end

        function supported=isAppendSupported(fmt)

            pattern=["pdf","gif"];
            supported=contains(fmt,pattern,'IgnoreCase',true);
        end

        function validValues=getValidFormats()
            import matlab.graphics.internal.export.ExporterValidator
            validArrayFormats=ExporterValidator.getValidArrayFormats();
            validFileFormats=ExporterValidator.getOutputFileFormats();
            validClipboardFormats=ExporterValidator.getClipboardFormats();
            validValues=unique([validArrayFormats,validFileFormats,validClipboardFormats]);
        end

        function validValues=getValidArrayFormats()
            validValues={'image'};
        end

        function extension=getExtensionForFormat(fmt)
            import matlab.graphics.internal.export.ExporterValidator
            [fmts,exts]=ExporterValidator.getOutputFileFormats();
            [isvalid,idx]=ismember(lower(fmt),fmts);
            if isvalid
                extension=exts{idx};
            else
                extension='';
            end
        end

        function fname=addExtensionIfNeeded(format,fname)



            import matlab.graphics.internal.export.ExporterValidator
            if~isempty(format)&&~isempty(fname)
                [p,n,e]=fileparts(fname);
                if isempty(e)
                    ext=ExporterValidator.getExtensionForFormat(format);
                    if~isempty(ext)
                        fname=fullfile(p,[n,'.',ext]);
                    end
                end
            end
        end

        function[isvalid,outputName,errMsg]=canWriteToFile(filename)
            import matlab.graphics.internal.export.ExporterValidator

            isvalid=false;
            errMsg='';

            if~isempty(filename)

                filename=replace(filename,{'\','/'},filesep);


                filename=matlab.graphics.internal.mlprintjob.fixTilde(filename);


                [fpath,fname,ext]=fileparts(filename);
                if isempty(fpath)
                    fpath='.';
                end
                str=fullfile(fpath,[fname,ext]);
                outputName=str;


                fidRead=fopen(str,'r');
                didNotExist=(fidRead==-1);
                if~didNotExist
                    fclose(fidRead);
                end

                [fidAppend,errMsg]=fopen(str,'a');
                if fidAppend~=-1
                    fclose(fidAppend);

                    if didNotExist



                        delete(str);
                    end

                    isvalid=true;
                else

                    isvalid=false;
                end
            end
        end

        function defValue=getDefault(param)

            defValue=matlab.graphics.internal.export.ExporterArgumentParser.getDefault(param);
        end

        function validValues=getClipboardFormats()
            validValues={'image','vector','auto'};
        end

        function clipFormat=getFormatForClipboard(results)
            switch results.format
            case 'image'
                clipFormat='bmp';

            case 'vector'
                if ispc
                    clipFormat='meta';
                else
                    clipFormat='pdf';
                end

            case 'auto'


                clipFormat=results.format;
            end
        end

        function validValues=getValidVectorValues()


            validValues={'true','false','auto'};
        end
    end

    methods(Static,Access=?matlab.graphics.internal.export.exportAPIArgumentParser)
        function validValues=getValidColorspaces()


            validValues={'rgb','cmyk','gray'};
        end
    end
end