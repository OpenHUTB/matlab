function logDDUXInfo(varargin)





    try
        logDDUXInfoHelper(varargin{:});
    catch ex

    end
end

function logDDUXInfoHelper(varargin)


    narginchk(1,inf);

    persistent product;
    persistent appComponent;
    persistent eventKey;
    persistent dataId;
mlock
    persistent previousUploadedData;
    if isempty(product)
        product="ML";
        appComponent="ML_GRAPHICS";
        eventKey="ML_GRAPHICS_EXPORT";
        dataId=matlab.ddux.internal.DataIdentification(product,appComponent,eventKey);
    end








    if ischar(varargin{1})||isstring(varargin{1})

        callerFunc=varargin{1};
        toUpload=struct();
        switch callerFunc
        case 'getframe'
            toUpload=populateForGetframe(toUpload,varargin{2:end});
        case 'exportapp'
            toUpload=populateForExportapp(toUpload,varargin{2:end});
        otherwise



            return
        end
        compareAndDoLogData(toUpload);
        return;
    end




    if~isa(varargin{1},'matlab.graphics.internal.mlprintjob')


        return
    end



    pj=varargin{1};
    callerFunc=pj.CallerFunc;
    toUpload=struct();

    switch callerFunc
    case 'exportgraphics'
        argParserResults=varargin{2};
        toUpload=populateForExporter(callerFunc,toUpload,pj,argParserResults);
    case 'copygraphics'
        argParserResults=varargin{2};
        toUpload=populateForExporter(callerFunc,toUpload,pj,argParserResults);
    case 'print'
        toUpload=populateForalternatePrintPath(toUpload,pj);
    end
    compareAndDoLogData(toUpload);

    function compareAndDoLogData(toUpload)
        doUpload=true;
        if isempty(previousUploadedData)
            previousUploadedData=toUpload;
        else
            doUpload=~isequaln(previousUploadedData,toUpload);
        end
        if doUpload
            previousUploadedData=toUpload;
            matlab.ddux.internal.logData(dataId,toUpload);
        end
    end

end

function toUpload=populateForExportapp(toUpload,varargin)
    if length(varargin)<2
        return;
    end
    hFig=varargin{1};
    format=varargin{2};
    toUpload.class="uifigure";
    toUpload.outputFormat=convertCharsToStrings(format);
    toUpload.outputResolution=int64(hFig.ScreenPixelsPerInch);
    toUpload.outputRenderer=convertCharsToStrings(hFig.Renderer);
    figPos=hFig.Position;
    figUnits=hFig.Units;
    if~strcmp(figUnits,'pixels')
        figPos=hgconvertunits(hFig,figPos,figUnits,'pixels',groot);
    end
    toUpload.outputWidth=int64(figPos(3));
    toUpload.outputHeight=int64(figPos(4));
    toUpload.function="exportapp";
    toUpload.outputDestination="file";
    toUpload.isApp=localCheckHasUI(hFig);
    toUpload.isManualSize=false;
end

function toUpload=populateForGetframe(toUpload,varargin)
    if length(varargin)<4
        return;
    end
    originalH=varargin{1};
    parentFig=ancestor(originalH,'figure');
    width=varargin{2};
    height=varargin{3};
    toUpload.class=convertCharsToStrings(originalH.Type);
    toUpload.outputFormat="cdata";
    toUpload.outputResolution=int64(parentFig.ScreenPixelsPerInch);
    toUpload.outputRenderer=convertCharsToStrings(parentFig.Renderer);
    toUpload.outputWidth=int64(width);
    toUpload.outputHeight=int64(height);
    toUpload.function="getframe";
    toUpload.outputDestination="array";
    toUpload.isApp=localCheckHasUI(parentFig);
    toUpload.isManualSize=varargin{4};
end



function toUpload=populateForalternatePrintPath(toUpload,pj)
    toUpload.class='figure';
    toUpload.outputFormat=convertCharsToStrings(pj.DriverExt);


    parentFig=ancestor(pj.Handles{1},'figure');
    if pj.DPI<=0
        resolution=parentFig.ScreenPixelsPerInch;
    else
        resolution=pj.DPI;
    end
    toUpload.outputResolution=int64(resolution);
    toUpload.function=pj.CallerFunc;
    toUpload.outputRenderer=convertCharsToStrings(pj.Renderer);
    [w,h]=getWidthAndHeightFromPJ(pj);
    toUpload.outputWidth=w;
    toUpload.outputHeight=h;

    if pj.RGBImage
        toUpload.outputDestination="array";
    elseif pj.DriverClipboard
        toUpload.outputDestination="clipboard";
    elseif pj.isPrintDriver()
        toUpload.outputDestination="printer";
    else
        toUpload.outputDestination="file";
    end

    toUpload.isApp=localCheckHasUI(parentFig);
    toUpload.isManualSize=strcmpi(parentFig.PaperPositionMode,'manual');
end


function toUpload=populateForExporter(callerFunc,toUpload,pj,argParserResults)
    if isprop(argParserResults.handle,"Type")
        outputClass=convertCharsToStrings(argParserResults.handle.Type);
    else


        outputClass="figure";
    end
    toUpload.class=outputClass;
    toUpload.outputFormat=convertCharsToStrings(pj.DriverExt);
    toUpload.outputResolution=int64(pj.DPI);
    toUpload.function=convertCharsToStrings(callerFunc);
    parentFig=ancestor(argParserResults.handle,'figure');
    toUpload.outputRenderer=convertCharsToStrings(pj.Renderer);
    [w,h]=getWidthAndHeightFromPJ(pj);
    toUpload.outputWidth=w;
    toUpload.outputHeight=h;
    toUpload.outputDestination=convertCharsToStrings(argParserResults.target);
    toUpload.isApp=localCheckHasUI(parentFig);
    toUpload.isManualSize=strcmpi(parentFig.PaperPositionMode,'manual');
end

function[w,h]=getWidthAndHeightFromPJ(pj)
    dims=size(pj.Return);
    if length(dims)==3
        w=dims(2);
        h=dims(1);
    elseif strcmpi(pj.DriverClass,"IM")
        w=round(pj.PaperPosition_Width*pj.DPI);
        h=round(pj.PaperPosition_Height*pj.DPI);
    else
        w=round(pj.PaperPosition_Width*pj.ScreenDPI);
        h=round(pj.PaperPosition_Height*pj.ScreenDPI);
    end
    w=int64(w);
    h=int64(h);
end

function hasUI=localCheckHasUI(h)
    hasUI=matlab.graphics.internal.mlprintjob.containsUIElements(h);
end