function[pj,devices,options]=inputcheck(pj,varargin)













    if pj.UseOriginalHGPrinting
        hg1PJ=pj;
        pj=matlab.graphics.internal.mlprintjob;
        pj.updateFromPrintjob(hg1PJ);
    end
    options=printtables(pj);
    deviceToCheck='';

    [handles,simWindowName]=checkArgsForHandleToPrint(false,varargin{:});
    if~isempty(handles)
        pj.Handles=[pj.Handles,handles];
        pj.ParentFig=ancestor(pj.Handles{1},'figure');
    end

    if pj.UseOriginalHGPrinting
        pj.SimWindowName=simWindowName;
    end

    for i=1:length(varargin)
        cur_arg=varargin{i};

        if isempty(cur_arg)


        elseif~ischar(cur_arg)


        elseif(cur_arg(1)~='-')

            if isempty(pj.FileName)
                pj.FileName=cur_arg;
            else
                error(message('MATLAB:print:MultipleInputFiles',pj.FileName,cur_arg));
            end

        else
            switch(cur_arg(2))

            case 'd'




                if~isempty(deviceToCheck)
                    error(message('MATLAB:print:MultipleInputDeviceNames',deviceToCheck,cur_arg));
                end
                deviceToCheck=cur_arg;

            case 'f'

                if strcmp(cur_arg,'-fillpage')




                    pj.FillPage=true;
                end


            case 'b'
                if strcmp(cur_arg,'-bestfit')




                    pj.BestFit=true;
                end

            case 's'


            case 'P'
                if~matlab.graphics.internal.export.isPrintingSupported()
                    throwAsCaller(MException(message('MATLAB:print:PrintingNotSupported')));
                end

                pj.PrinterName=cur_arg(3:end);


                if(isempty(pj.PrinterName))
                    error(message('MATLAB:print:InvalidPrinterName'));
                end




                if pj.UseOriginalHGPrinting&&...
                    ispc&&...
                    ~isempty(regexp(pj.PrinterName,'^\\\\.*?\\.*$','once'))&&...
                    ~queryPrintServices('validate',pj.PrinterName)
                    warning(message('MATLAB:print:UNCPrinterNotFoundWarning',pj.PrinterName));
                end

            otherwise




                opIndex=LocalCheckOption(cur_arg,options);



                switch options{opIndex}

                case 'loose'
                    pj.PostScriptTightBBox=0;

                case 'tiff'
                    pj.PostScriptPreview=pj.TiffPreview;

                case 'append'
                    pj.PostScriptAppend=1;

                case 'adobecset'
                    pj.PostScriptLatin1=0;
                    if pj.UseOriginalHGPrinting
                        warning(message('MATLAB:print:DeprecatedOptionAdobecset'));
                    else
                        error(message('MATLAB:print:DeprecatedOptionAdobecsetRemoved'));
                    end

                case 'cmyk'
                    pj.PostScriptCMYK=1;
                    pj.PostScriptLatin1=0;

                case 'r'

                    pj.DPI=round(sscanf(cur_arg,'-r%g'));
                    if isempty(pj.DPI)||isnan(pj.DPI)||isinf(pj.DPI)||pj.DPI<0
                        error(message('MATLAB:print:InvalidParamResolution'))
                    end

                case 'noui'
                    pj.PrintUI=0;
                    pj.nouiOption=1;

                case{'painters','vector'}
                    pj.Renderer='painters';
                    pj.rendererOption=1;

                case 'zbuffer'
                    if pj.XTerminalMode
                        warning(message('MATLAB:prnRenderer:zbuffer'))
                    else
                        pj.Renderer='zbuffer';
                        pj.rendererOption=1;
                    end

                case{'opengl','image'}









                    isJSD=feature('webui');
                    if pj.UseOriginalHGPrinting
                        allowOpenGL=~pj.XTerminalMode;
                    else
                        allowOpenGL=opengl('info');
                    end
                    if~allowOpenGL&&~isJSD
                        warning(message('MATLAB:prnRenderer:opengl'))
                    else
                        pj.Renderer='opengl';
                        pj.rendererOption=1;
                    end

                case 'tileall'
                    pj.TiledPrint=1;

                case 'printframes'


                    pj.FramePrint=1;

                case 'numcopies'

                    pj.NumCopies=sscanf(cur_arg,'-numcopies%d');

                case 'pages'
                    [a,count]=sscanf(cur_arg,'-pages[ %d %d ]');
                    if(count~=2)||(a(1)<1)||(a(2)>9999)||(a(1)>a(2))
                        warning(message('MATLAB:print:InvalidParamPages'))
                    else
                        pj.FromPage=a(1);
                        pj.ToPage=a(2);
                    end

                case 'DEBUG'
                    pj.DebugMode=1;

                case 'v'

                    pj.Verbose=1;

                case 'RGBImage'

                    pj.RGBImage=1;
                    pj.DriverClass='IM';
                    pj.DriverColor=1;

                case 'clipboard'

                    pj.ClipboardOption=1;

                otherwise
                    error(message('MATLAB:print:UnrecognizedOption',cur_arg))

                end
            end
        end
    end




    [~,devices,extensions,classes,colorDevs,destinations,~,clipsupport]=printtables(pj);


    if~pj.UseOriginalHGPrinting&&~isempty(deviceToCheck)&&...
        ~matlab.graphics.internal.isSLorSF(pj)
        if length(deviceToCheck)>2
            pj.Driver=deviceToCheck(3:end);

            if any(strcmp(pj.Driver,{'win','prn'}))
                pj.PrinterBW=1;
            end
            LocalCheckForDeprecation(pj);
        end
    end
    [pj,devIndex]=LocalCheckDevice(pj,deviceToCheck,devices);


    if~isempty(deviceToCheck)
        if devIndex==0


            pj.Driver='-d';
            return
        end
        pj.setOutputDeviceInfo(devIndex,extensions,classes,colorDevs,...
        destinations,clipsupport);


        if pj.PostScriptAppend&&~strcmp(pj.DriverClass,'PS')
            error(message('MATLAB:print:AppendNotValid'));
        end





        if~matlab.graphics.internal.isSLorSF(pj)
            LocalCheckForDeprecation(pj);
        end
    end


    if~pj.UseOriginalHGPrinting&&pj.rendererOption&&strcmpi(pj.Renderer,'zbuffer')
        pj.Renderer='opengl';
        warning(message('MATLAB:print:DeprecateZbuffer'));
    end

    if pj.UseOriginalHGPrinting
        pj=pj.tostruct();
        fnames=fieldnames(hg1PJ);
        for idx=1:length(fnames)
            hg1PJ.(fnames{idx})=pj.(fnames{idx});
        end
        pj=hg1PJ;
    end
end






function[pj,devIndex]=LocalCheckDevice(pj,cur_arg,devices)





    if(length(cur_arg)>2)

        dev=cur_arg(3:end);
        devIndex=pj.getOutputDevice(dev,devices);
    else
        devIndex=0;
    end

end




function opIndex=LocalCheckOption(op,options)




    if(size(op,2)>1)

        option=op(2:end);


        opIndex=find(strcmp(option,options));

        if length(opIndex)~=1


            opIndex=find(strcmp(option,options));

            if isempty(opIndex)


                if strcmp(option,'epsi')



                    if pj.UseOriginalHGPrinting
                        warning(message('MATLAB:print:UnsupportedFormatEPSI'))
                    else
                        error(message('MATLAB:print:UnsupportedFormatEPSIError'))
                    end
                    opIndex=find(strcmp('tiff',options));


                elseif option(1)=='r'



                    opIndex=find(strcmp('r',options));

                elseif strncmp(option,'pages[',6)

                    opIndex=find(strcmp('pages',options));


                elseif strncmp(option,'numcopies',9)

                    opIndex=find(strcmp('numcopies',options));

                else
                    error(message('MATLAB:print:UnrecognizedOption',op))
                end

            elseif length(opIndex)>1
                error(message('MATLAB:print:NonUniqueOption',op))
            end
        end
    else
        error(message('MATLAB:print:ExpectedOption'))
    end

end




function LocalCheckForDeprecation(pj)
    msgID='';
    msgText='';
    deviceToCheck=pj.Driver;


    [~,~,~,~,depDevices,depDestinations,~]=getDeprecatedDeviceList();
    depIndex=find(strcmp(depDevices,deviceToCheck));
    if isempty(depIndex)
        return;
    end
    depDest=depDestinations(depIndex);
    if isempty(depDest)
        depDest='';
    end

    if strcmpi(deviceToCheck,'ill')

        msgID='MATLAB:print:Illustrator:DeprecatedDevice';
        if pj.UseOriginalHGPrinting
            msgText=getString(message('MATLAB:uistring:inputcheck:ThedillPrintDeviceWillBeRemovedInAFutureRelease'));
        else
            msgText=getString(message('MATLAB:uistring:inputcheck:ThedillPrintDeviceHasBeenRemoved'));
        end
    elseif strcmpi(deviceToCheck,'mfile')

        msgID='MATLAB:print:DeprecatedMATLABCodeGenerationOption';
        if pj.UseOriginalHGPrinting
            msgText=getString(message('MATLAB:printdmfile:DeprecatedMATLABCodeGenerationOption'));
        else
            msgText=getString(message('MATLAB:print:DeprecatedMATLABCodeGenerationOption'));
        end
    elseif strcmp('P',depDest)

        msgID='MATLAB:Print:Deprecate:PrinterFormat';
        if pj.UseOriginalHGPrinting
            msgText=sprintf('%s',getString(message('MATLAB:uistring:inputcheck:ThePrintDeviceWillBeRemovedInAFutureRelease',...
            deviceToCheck)));
        else
            msgText=sprintf('%s',getString(message('MATLAB:uistring:inputcheck:ThePrintDeviceHasBeenRemoved',...
            deviceToCheck)));
        end
    elseif strcmp('X',depDest)
        msgID='MATLAB:Print:Deprecate:GraphicFormat';
        if pj.UseOriginalHGPrinting
            msgText=sprintf(getString(message('MATLAB:uistring:inputcheck:TheGraphicExportFormatWillBeRemovedInAFutureRelease',...
            deviceToCheck)));
        else
            msgText=sprintf(getString(message('MATLAB:uistring:inputcheck:TheGraphicExportFormatHasBeenRemoved',...
            deviceToCheck)));
        end
    elseif strcmpi('setup',deviceToCheck)
        msgID='MATLAB:Print:DSetupOptionRemoved';
        if pj.UseOriginalHGPrinting
            msgText=sprintf(getString(message('MATLAB:print:DSetupOptionDeprecation')));
        else
            msgText=sprintf(getString(message('MATLAB:print:DSetupOptionRemoved')));
        end
    end

    if~isempty(msgID)
        if pj.UseOriginalHGPrinting
            warning(msgID,msgText);
        else
            error(msgID,msgText);
        end
    end


end



