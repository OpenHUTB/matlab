classdef exportAPIArgumentParser




    properties

        Target;
        SpecifiedHandle;
        FileSpec;

        VectorizeContent;
        Resolution;
        BackgroundColor;

        DestinationType;

        Colorspace;

        Append;
    end


    methods

        function obj=exportAPIArgumentParser
            obj.FileSpec='';
            obj.DestinationType='';
            obj.Target=gobjects(1,1);
            obj.SpecifiedHandle=gobjects(1,1);
            obj.VectorizeContent='auto';
            obj.Resolution=150;
            obj.BackgroundColor=[1,1,1];
            obj.Colorspace='RGB';
            obj.Append=false;
        end

        function obj=parseArgs(obj,outputType,varargin)
            if~ismember(outputType,{'file','clipboard'})
                error(message('MATLAB:print:InvalidDestinationType'));
            end
            obj.DestinationType=outputType;
            varargin=matlab.graphics.internal.convertStringToCharArgs(varargin);



            invalidFormats={'bmp','ps','psc','svg'};
            if~ispc

                invalidFormats{end+1}='meta';
            end

            idx=1;
            numArgs=length(varargin);
            if numArgs<1
                error(message('MATLAB:print:GraphicsHandleMustBeFirst'))
            end

            if isgraphics(varargin{idx})
                h=varargin{idx};

                obj.SpecifiedHandle=h;
                if ishghandle(h,'figure')
                    if matlab.ui.internal.isUIFigure(h)&&~feature('GraphicsUsesJava')
                        canvas=findobj(h.NodeChildren,'-depth',0,'-class','matlab.graphics.primitive.canvas.HTMLCanvas');
                        if isempty(canvas)

                            error(message('MATLAB:print:EmptyFigureNotSupported'));
                        end
                    end
                    h=h.getCanvas;
                end
                obj.Target=h;
            else
                error(message('MATLAB:print:GraphicsHandleMustBeFirst'));
            end

            idx=idx+1;
            while idx<=numArgs


                arg=varargin{idx};


                if strcmpi(obj.DestinationType,'file')&&isempty(obj.FileSpec)
                    if idx>2
                        error(message('MATLAB:print:ProvideOutputFileBeforeOptionalArguments'));
                    end
                    if matlab.graphics.internal.isCharOrString(arg)
                        [~,fn,fext]=fileparts(arg);
                        if isempty(fn)||length(fext)<2
                            error(message('MATLAB:print:OutputFileNeedsNameAndExtension'));
                        end

                        fext=fext(2:end);
                        fmt=matlab.graphics.internal.export.ExporterValidator.getFormatForExtension(fext);
                        if isempty(fmt)||startsWith(fmt,invalidFormats,'IgnoreCase',true)
                            error(message('MATLAB:print:InvalidFileFormatForExport',fext));
                        end
                        obj.FileSpec=arg;
                        idx=idx+1;
                        continue;
                    end
                end

                if matlab.graphics.internal.isCharOrString(arg)
                    arg=lower(arg);
                    switch(arg)
                    case 'contenttype'




                        if idx>=numArgs
                            error(message('MATLAB:print:OptionRequiresAValue',arg));
                        end
                        idx=idx+1;
                        forceVector=varargin{idx};
                        if matlab.graphics.internal.isCharOrString(forceVector)
                            forceVector=lower(forceVector);
                            if~ismember(forceVector,obj.getValidContentTypeValues())
                                error(message('MATLAB:print:InvalidContentTypeValue'));
                            end
                        else
                            error(message('MATLAB:print:InvalidContentTypeValue'));
                        end
                        obj.VectorizeContent=forceVector;

                    case 'resolution'

                        if idx>=numArgs
                            error(message('MATLAB:print:OptionRequiresAValue',arg));
                        end
                        idx=idx+1;
                        res=varargin{idx};
                        if strcmpi(res,'display')
                            res=0;
                        end
                        if matlab.graphics.internal.isCharOrString(res)
                            res=str2double(res);
                        end
                        obj.Resolution=res;

                    case 'backgroundcolor'

                        if idx>=numArgs
                            error(message('MATLAB:print:OptionRequiresAValue',arg));
                        end
                        idx=idx+1;
                        bkg=varargin{idx};
                        if strcmpi(bkg,'current')
                            bkg='';
                        end
                        obj.BackgroundColor=bkg;

                    case 'colorspace'




                        if idx>=numArgs
                            error(message('MATLAB:print:OptionRequiresAValue',arg));
                        end
                        idx=idx+1;
                        colorspace=varargin{idx};
                        if matlab.graphics.internal.isCharOrString(colorspace)
                            colorspace=lower(colorspace);
                            if~ismember(colorspace,obj.getValidColorspaceValues())
                                error(message('MATLAB:print:UnrecognizedColorspace'));
                            end
                        else
                            error(message('MATLAB:print:UnrecognizedColorspace'));
                        end
                        obj.Colorspace=colorspace;

                    case 'append'



                        if idx>=numArgs
                            error(message('MATLAB:print:OptionRequiresAValue',arg));
                        end
                        idx=idx+1;
                        append=varargin{idx};

                        if(~islogical(append))
                            error(message('MATLAB:print:UnrecognizedAppendValue'));
                        end

                        obj.Append=append;
                    otherwise
                        error(message('MATLAB:print:UnrecognizedOption',arg));
                    end

                    idx=idx+1;
                else
                    error(message('MATLAB:print:ExtraInputs'));
                end

            end




            if isa(obj.Target,'matlab.graphics.GraphicsPlaceholder')
                error(message('MATLAB:print:NoCurrentGraphics'));
            end

            if strcmp(obj.DestinationType,'file')
                if isempty(obj.FileSpec)
                    error(message('MATLAB:print:OutputFileNeedsNameAndExtension'));
                end
            else
                if~isempty(obj.FileSpec)
                    error(message('MATLAB:print:OutputFileNotNeeded'));
                end
            end

        end
        function arguments=convertToInternalAPI(obj)
















            theArgs={'handle',obj.Target,'target',obj.DestinationType};
            destArgs={};
            switch obj.DestinationType
            case 'file'
                destArgs={'destination',obj.FileSpec};
            case 'clipboard'
                destArgs={'format',obj.VectorizeContent};
            case 'array'
                destArgs={'format','image'};
            end

            vectorFlag=obj.mapExternalContentTypeToInternalVector(obj.VectorizeContent);
            vectorizeContentArg={'vector',vectorFlag};

            resArg={'resolution',obj.Resolution};

            bkgArg={'background',obj.BackgroundColor};

            colorspaceArg={'colorspace',obj.Colorspace};

            appendArg={'append',obj.Append};
            arguments=[theArgs(:)',destArgs(:)',vectorizeContentArg(:)'...
            ,resArg(:)',bkgArg(:)',colorspaceArg(:)',appendArg(:)'];
        end

        function warnIfNeeded(obj)
            obj.warnIfUI();
        end

    end
    methods(Access=private)
        function val=mapExternalContentTypeToInternalVector(obj,fmt)
            internalVector={'true','false','auto'};
            externalVector=obj.getValidContentTypeValues();
            if ismember(fmt,externalVector)
                val=internalVector{strcmp(fmt,externalVector)};
            else
                val=[];
            end
        end
        function validValues=getValidContentTypeValues(~)
            validValues={'vector','image','auto'};
        end

        function validValues=getValidColorspaceValues(~)

            validValues=...
            matlab.graphics.internal.export.ExporterValidator.getValidColorspaces();
        end

        function warnIfUI(obj)
            h=obj.SpecifiedHandle;
            if matlab.graphics.internal.mlprintjob.containsUIElements(h)
                f=ancestor(h,'figure');

                if matlab.ui.internal.isUIFigure(f)

                    warning(message('MATLAB:print:ExportappForUIFigureWithUIControl'));
                else

                    warning(message('MATLAB:print:ExportExcludesUI'));
                end
            end
        end
    end
end
