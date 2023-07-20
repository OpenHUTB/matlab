function pj=printingGenerateOutput(pj)




    if pj.isPrintDriver()
        pj=LocalGeneratePrintedOutput(pj);
        return;
    end







    pj.DriverExport=true;

    if matlab.graphics.internal.mlprintjob.needCheckForImageSize(pj)







        if~checkImageSizeForPrint(pj.DPI,pj.ScreenDPI,...
            pj.PaperPosition_Width,pj.PaperPosition_Height)

            rgbPJ=pj.copy();
            rgbPJ.Driver='raster@toolbox';
            rgbPJ.PaperPosition_X=0;
            rgbPJ.PaperPosition_Y=0;
            rgbPJ=LocalGenerateRasterOutput(rgbPJ);


            pj.Return=rgbPJ.Return;

            if isempty(pj.Return)
                warning(message('MATLAB:uistring:alternateprintpath:InvalidCData'));
                return;
            elseif ndims(pj.Return)~=3&&pj.wasFigureClosed()



                return;
            end

            if pj.DriverClipboard&&isempty(pj.FileName)
                pj.copyImageToClipboard();
            elseif pj.RGBImage

            else

                pj.writeRaster();
            end
        else
            error(message('MATLAB:print:InvalidRasterOutputSize'));
        end
    else




        pj.temp.oldFileName=pj.FileName;


        if pj.DriverClipboard&&isempty(pj.FileName)
            pj.FileName='';


        elseif pj.temp.isPostscript&&pj.PostScriptAppend&&~exist(pj.FileName,'file')
            pj.PostScriptAppend=false;
        end


        LocalGenerateVectorOutput(pj);

        if~isempty(pj.FileName)&&exist(pj.FileName,'file')&&...
            ~pj.wasFigureClosed()

            fname=pj.FileName;
            pj.FileName=pj.temp.oldFileName;

            LocalPostProcessOutput(pj,fname);
        end
    end


    if~isempty(pj.FileName)&&~exist(pj.FileName,'file')

        if~pj.wasFigureClosed()
            error(message('MATLAB:print:fileNotCreated',pj.FileName));
        end
    end




    if pj.PrintOutput
        send(pj);
    end

end

function LocalGenerateVectorOutput(pj)

    LocalCallgenerateGraphicsOutput(pj);
end

function pj=LocalGenerateRasterOutput(pj)

    if pj.RGBImage


        pj.DriverExt='png';
    end

    pj=LocalCallgenerateGraphicsOutput(pj);
end

function LocalPostProcessOutput(pj,fname)

    if pj.temp.isPostscript&&~isempty(fname)&&exist(fname,'file')



        if(pj.PostScriptPreview==pj.TiffPreview)


            LocalAppendTiffToEPS(pj);
        end
    end
end


function LocalAppendTiffToEPS(origPJ)

    pj=origPJ.copy();



    eventualName=pj.FileName;



    tempEpsFileName=[tempname,'.eps'];
    movefile(pj.FileName,tempEpsFileName,'f');

    fields={'FileName','Driver','DriverExt','DriverClass','DPI'};
    values={[tempname,'.tif'],'tiff','tif','IM',150};




    for i=1:length(fields)
        pj.(fields{i})=values{i};
    end



    origPJ.temp.TempTiffPreview=cell2struct(values,fields,2);



    pj=printingGenerateOutput(pj);



    catpreview(pj,tempEpsFileName,pj.FileName,eventualName);
end

function pj=LocalGeneratePrintedOutput(pj)






    pj.Driver='prn';
    pj.DriverExt=pj.Driver;


    LocalCallgenerateGraphicsOutput(pj);
end

function pj=LocalCallgenerateGraphicsOutput(pj)
    if pj.DebugMode
        disp(pj)
    end


    if pj.wasFigureClosed()
        warning(message('MATLAB:uistring:alternateprintpath:FigureMayHaveBeenClosed'));
        return;
    end


    if matlab.graphics.internal.mlprintjob.usesJava(pj)
        container=pj.getJavaContainer();
        if isempty(container)
            warning(message('MATLAB:uistring:alternateprintpath:FigureMayHaveBeenClosed'));
            return;
        end




        assert(com.mathworks.hg.peer.PaintDisabled.isChildOfPaintDisabledContainer(container))





        drawnow update
    else









        drawnow nocallbacks;
    end


    if strcmpi(pj.CallerFunc,'print')
        matlab.graphics.internal.export.logDDUXInfo(pj);
    end

    try
        s=pj.tostruct();
        s=LocalAddHeaderInfoToPrintJobStruct(pj,s);
        pj.Return=pj.generateOutput('HG',pj.Handles{1},s);

    catch e

        pause(0.5);
        if pj.wasFigureClosed()
            warning(message('MATLAB:uistring:alternateprintpath:FigureMayHaveBeenClosed'));
        else

            ME=MException(message('MATLAB:print:ProblemGeneratingOutput',e.message));
            if pj.DebugMode
                ME=ME.addCause(e);
            end
            throw(ME);
        end
    end
end

function s=LocalAddHeaderInfoToPrintJobStruct(pj,s)

    headerFields={'Header_String','Header_DateString','Header_Font_Name',...
    'Header_Font_Size','Header_Font_Weight','Header_Font_Angle','Header_Margin'};


    if pj.doTransform&&...
        ~localIsPrintHeaderHeaderSpecEmpty(pj)&&...
        (pj.isPrintDriver()||~pj.DriverExport)

        headerS=getappdata(gcf,'PrintHeaderHeaderSpec');
        headerValues={headerS.string,datestr(now,headerS.dateformat,'local'),...
        headerS.fontname,headerS.fontsize,headerS.fontweight,...
        headerS.fontangle,headerS.margin};
    else

        headerValues={'','','',[],'','',[]};
    end

    for i=1:length(headerFields)
        s.(headerFields{i})=headerValues{i};
    end


    pj.temp.TempHeader=cell2struct(headerValues,headerFields,2);

    if strcmpi(s.Header_DateString,'none')
        s.Header_DateString='';
        pj.temp.TempHeader.Header_DateString='';
    end

end




function reallyEmpty=localIsPrintHeaderHeaderSpecEmpty(pj)
    fig=pj.Handles{1};
    reallyEmpty=false;
    hs=getappdata(fig,'PrintHeaderHeaderSpec');
    if isempty(hs)||(~isempty(hs)&&strcmp(hs.dateformat,'none')&&isempty(hs.string))
        reallyEmpty=true;
    end

end