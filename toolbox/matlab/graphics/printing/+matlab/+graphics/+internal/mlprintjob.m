






classdef mlprintjob<dynamicprops&matlab.mixin.SetGet&matlab.mixin.Copyable
    properties
        Handles=[];
        ParentFig=[];
        Driver='';
        FileName='';
        PageNumber=0;
        Active=0;
        Return=0;

        AllFigures=[];
        AllPointers=[];

        PrinterName='';
        PrinterBW=0;
        Renderer='';
        rendererOption=0;
        PrintOutput=0;
        Verbose=0;
        Orientation='';

        PrintUI=1;
        nouiOption=0;

        DPI=-1;

        DriverExt='';
        DriverClass='';
        DriverExport=0;

        DriverColor=0;
        DriverColorSet=0;

        DriverClipboard=0;
        ClipboardOption=0;

        PostScriptAppend=0;
        PostScriptLatin1=1;
        PostScriptCMYK=0;
        PostScriptTightBBox=1;
        PostScriptPreview=0;
        TiffPreview=1;


        ScreenDPI;
        ScaledDPI;
        CanvasDPI;


        PrintCmd;
        DefaultDevice;

        Error=0;
        Exception=[];
        DebugMode=0;

        Validated=0;


        PaperPosition_X=0;
        PaperPosition_Y=0;
        PaperPosition_Width=0;
        PaperPosition_Height=0;
        PaperType='';
        PaperUnits='';
        PaperSize_Width=0;
        PaperSize_Height=0;


        Original_Width;
        Original_Height;


        XTerminalMode;


        UseOriginalHGPrinting;

        RGBImage=false;
        viewer=[];
        doTransform=true;


        temp;
        donePrinting=false;
        PixelOutputPosition;

        ContainsTex=0;


        TransparentBackground=0;





        Desired_Width;
        Desired_Height;


        EnhanceTextures=0;

        Options=[];

        FillPage=0;
        BestFit=0;


        Tag='';


        BackgroundColor=[1,1,1];


        CallerFunc='';


        Colorspace;


        Append;









        TempFileName='';
    end

    properties(Hidden=true)



        generateOutput=[];
    end

    methods

        function obj=mlprintjob

            if matlab.graphics.internal.export.isPrintingSupported
                [obj.PrintCmd,obj.DefaultDevice]=printopt(groot);
            else

                obj.PrintCmd='';
                obj.DefaultDevice='-dpdf';
            end

            defPos=get(0,'DefaultFigurePosition');
            obj.Original_Width=defPos(3);
            obj.Original_Height=defPos(4);

            obj.resetTemp();


            if matlab.ui.internal.isFigureShowEnabled
                obj.XTerminalMode=false;
                obj.temp.isFigureShowEnabled=true;
            else
                obj.XTerminalMode=true;
                obj.PrintUI=false;
                obj.temp.isFigureShowEnabled=false;
            end

            obj.PaperType=get(0,'DefaultFigurePaperType');
            obj.PaperUnits=get(0,'DefaultFigurePaperUnits');

            obj.UseOriginalHGPrinting=0;
            obj.ScreenDPI=get(groot,'ScreenPixelsPerInch');
            obj.ScaledDPI=obj.ScreenDPI;

            obj.Tag='printjob';
            obj.generateOutput=@matlab.graphics.internal.mlprintjob.generateGfxOutput;
            obj.Colorspace='rgb';
            obj.Append=false;
        end

        function obj=updateFromPrintjob(obj,userSuppliedPJ)



            if isstruct(userSuppliedPJ)
                obj=obj.copyProps(userSuppliedPJ);
                return;
            elseif isa(userSuppliedPJ,class(obj))
                obj=userSuppliedPJ.copy();
                return;
            else
                error(message('MATLAB:printjob:InvalidUpdateSource',class(userSuppliedPJ)));
            end
        end

        function s=tostruct(obj)


            s=[];
            props=properties(obj);
            for idx=1:length(props)
                s.(props{idx})=obj.(props{idx});
            end
        end

        function obj=resetTemp(obj)

            obj.temp=[];
            obj.temp.oldProps=[];

            if matlab.ui.internal.isFigureShowEnabled
                obj.temp.isFigureShowEnabled=true;
            else
                obj.temp.isFigureShowEnabled=false;
            end
        end

        function isprint=isPrintDriver(obj)


            if~isfield(obj.temp,'isPrinting')
                obj.temp.isPrinting=isempty(obj.DriverClass)||...
                strncmpi(obj.Driver,'win',3)||...
                strcmp(obj.DriverClass,'PR')||...
                (strcmp(obj.DriverClass,'MW')&&~obj.DriverExport);
            end
            isprint=obj.temp.isPrinting;
        end

        function isauto=isPaperPositionModeAuto(obj)
            parentFig=ancestor(obj.Handles{1},'figure');
            if isfield(obj.temp,'PaperPositionModeAuto')
                isauto=obj.temp.PaperPositionModeAuto;
            else
                if isfield(obj.Options,'PaperPositionMode')
                    pposMode=obj.Options.PaperPositionMode;
                else
                    pposMode=get(parentFig,'PaperPositionMode');
                end
                isauto=strcmpi(pposMode,'auto');

                obj.temp.PaperPositionModeAuto=isauto;
            end
        end

        function getCopyOptionsPreferences(obj)
            obj.temp.HonorCOPrefs=javaMethod('getIntegerPref','com.mathworks.services.Prefs',...
            'CopyOptions.HonorCOPrefs')~=0;
            if obj.temp.HonorCOPrefs





                obj.temp.COFigureBackground=javaMethod('getIntegerPref','com.mathworks.services.Prefs','CopyOptions.FigureBackground');
            end
        end

        function figClosed=wasFigureClosed(obj)


            figClosed=false;

            ishgh=ishghandle(obj.ParentFig,'figure');
            beingDeleted=ishgh&&strcmpi(obj.ParentFig.BeingDeleted,'on');

            if~ishgh||beingDeleted
                figClosed=true;
            end
        end

        function[container,javaFrame]=getJavaContainer(obj)
            if isfield(obj.temp,'JavaFrame')
                javaFrame=obj.temp.JavaFrame;
                container=obj.temp.JavaContainer;
            else
                parentFig=ancestor(obj.Handles{1},'figure');
                javaFrame=matlab.graphics.internal.getFigureJavaFrame(parentFig);

                if isempty(javaFrame)
                    container=[];
                else
                    container=javaObjectEDT(javaFrame.getFigurePanelContainer());
                end

                obj.temp.JavaFrame=javaFrame;
                obj.temp.JavaContainer=container;
            end
        end

        function setPaintDisabled(obj,disable)
            if(~obj.temp.PaintDisabled&&~disable)||~matlab.graphics.internal.mlprintjob.usesJava(obj)

                return
            end
            obj.temp.PaintDisabled=disable;


            drawnow update
            container=obj.getJavaContainer();
            container.setPaintDisabled(disable)
        end

        function writeRaster(obj)






            if strcmp(obj.DriverClass,'IM')

                dims=size(obj.Return);
                if ndims(obj.Return)~=3||dims(3)~=3
                    ex=MException('MATLAB:writeRaster',getString(message('MATLAB:uistring:writeraster:InvalidCData')));
                    throw(ex);
                end


                imwriteArgs=obj.imwriteArgsForRaster();

                if obj.DebugMode
                    fprintf(getString(message('MATLAB:uistring:writeraster:PassingInputArgsToIMWRITE')))
                    sArgs=cell2struct(imwriteArgs.varargs(2:2:end),imwriteArgs.varargs(1:2:end),2);
                    if isempty(sArgs)
                        sArgs=getString(message('MATLAB:uistring:writeraster:NoAdditionalArgs'));
                    end
                    disp(sArgs)
                end


                if isempty(imwriteArgs.indexedData)
                    imwrite(obj.Return,obj.FileName,obj.DriverExt,imwriteArgs.varargs{:});
                else

                    imwrite(imwriteArgs.indexedData,imwriteArgs.map,...
                    obj.FileName,obj.DriverExt,imwriteArgs.varargs{:});
                end
            end
        end

        function imwriteArgs=imwriteArgsForRaster(obj)











            imwriteArgs.map=[];
            imwriteArgs.indexedData=[];

            imwriteArgs.varargs={};


            if strcmp(obj.DriverClass,'IM')
                if strncmp(obj.Driver,'tiff',4)
                    imwriteArgs.varargs{end+1}='Compression';
                    if strcmp(obj.Driver,'tiffnocompression')
                        imwriteArgs.varargs{end+1}='none';
                    else
                        imwriteArgs.varargs{end+1}='packbits';
                    end

                    imwriteArgs.varargs{end+1}='Description';
                    imwriteArgs.varargs{end+1}='MATLAB Handle Graphics';

                    imwriteArgs.varargs{end+1}='Resolution';
                    dpi=LocalGetDPI(obj);
                    imwriteArgs.varargs{end+1}=dpi;

                elseif strncmp(obj.Driver,'jpeg',4)

                    imwriteArgs.varargs{end+1}='Quality';
                    imwriteArgs.varargs{end+1}=sscanf(obj.Driver,'jpeg%d');
                    if isempty(imwriteArgs.varargs{end})

                        imwriteArgs.varargs{end}=90;
                    end

                    imwriteArgs.varargs{end+1}='Comment';
                    imwriteArgs.varargs{end+1}={'MATLAB Handle Graphics';...
                    'MATLAB, The MathWorks, Inc.'};

                elseif strncmp(obj.Driver,'png',3)
                    imwriteArgs.varargs{end+1}='CreationTime';
                    imwriteArgs.varargs{end+1}=datestr(clock,0);

                    imwriteArgs.varargs{end+1}='ResolutionUnit';
                    imwriteArgs.varargs{end+1}='meter';


                    dpi=LocalGetDPI(obj);
                    dpi=fix(dpi*100.0/2.54+0.5);

                    imwriteArgs.varargs{end+1}='XResolution';
                    imwriteArgs.varargs{end+1}=dpi;

                    imwriteArgs.varargs{end+1}='YResolution';
                    imwriteArgs.varargs{end+1}=dpi;

                    imwriteArgs.varargs{end+1}='Software';
                    imwriteArgs.varargs{end+1}='MATLAB, The MathWorks, Inc.';

                    if~(any(strcmp(obj.Driver,{'png','png16m'})))
                        switch obj.Driver(4:end)
                        case 'mono'
                            numBits=1;
                            numColors=2;
                        case 'gray'
                            numBits=8;
                            numColors=7;
                        case '256'
                            numBits=8;
                            numColors=256;
                        end

                        [imwriteArgs.indexedData,imwriteArgs.map]=rgb2ind(obj.Return,colorcube(numColors));
                        imwriteArgs.varargs{end+1}='bitdepth';
                        imwriteArgs.varargs{end+1}=numBits;
                    end

                elseif strncmp(obj.Driver,'pcx',3)


                    if strcmp(obj.Driver,'pcx')
                        numColors=256;
                    else
                        switch obj.Driver(4:end)
                        case '16'
                            numColors=16;
                        case '256'
                            numColors=256;
                        case '24b'
                            numColors=256;
                        case 'mono'
                            numColors=2;
                        case 'gray'
                            numColors=7;
                        end
                    end

                    [imwriteArgs.indexedData,imwriteArgs.map]=rgb2ind(obj.Return,colorcube(numColors));

                elseif strncmp(obj.Driver,'pbm',3)
                    imwriteArgs.varargs{end+1}='Encoding';
                    if strcmp(obj.Driver,'pbmraw')
                        imwriteArgs.varargs{end+1}='rawbits';
                    else
                        imwriteArgs.varargs{end+1}='ascii';
                    end


                    numColors=2;
                    [imwriteArgs.indexedData,imwriteArgs.map]=rgb2ind(obj.Return,colorcube(numColors));

                elseif strncmp(obj.Driver,'pgm',3)
                    imwriteArgs.varargs{end+1}='Encoding';
                    if strcmp(obj.Driver,'pgmraw')
                        imwriteArgs.varargs{end+1}='rawbits';
                    else
                        imwriteArgs.varargs{end+1}='ascii';
                    end

                elseif strncmp(obj.Driver,'ppm',3)
                    imwriteArgs.varargs{end+1}='Encoding';
                    if strcmp(obj.Driver,'ppmraw')
                        imwriteArgs.varargs{end+1}='rawbits';
                    else
                        imwriteArgs.varargs{end+1}='ascii';
                    end

                elseif strncmp(obj.Driver,'bmp',3)
                    if any(strcmp(obj.Driver,{'bmp','bmp16m'}))
                        numColors=0;
                    else
                        switch obj.Driver(4:end)
                        case 'mono'
                            numColors=2;
                        case '256'
                            numColors=256;
                        end
                    end
                    if numColors>0
                        [imwriteArgs.indexedData,imwriteArgs.map]=rgb2ind(obj.Return,colorcube(numColors));


                        if strcmp(obj.Driver,'bmpmono')
                            imwriteArgs.indexedData=logical(imwriteArgs.indexedData);
                        end
                    end
                elseif(strncmp(obj.Driver,'gif',3))
                    [imwriteArgs.indexedData,imwriteArgs.map]=rgb2ind(obj.Return,256);



                    imwriteArgs.varargs{end+1}='DelayTime';
                    imwriteArgs.varargs{end+1}=0.083;
                    imwriteArgs.varargs{end+1}='DisposalMethod';
                    imwriteArgs.varargs{end+1}='restoreBG';

                    if(obj.Append&&isfile(obj.FileName))
                        imwriteArgs.varargs{end+1}='WriteMode';
                        imwriteArgs.varargs{end+1}='append';
                    else


                        imwriteArgs.varargs{end+1}='LoopCount';
                        imwriteArgs.varargs{end+1}=Inf;
                    end
                end
            end
        end

        function devIndex=getOutputDevice(obj,dev,validDevices)

            devIndex=find(strcmp(dev,validDevices));
            if length(devIndex)==1
                obj.Driver=dev;
            else


                devIndex=find(startsWith(validDevices,dev));
                if length(devIndex)==1

                    obj.Driver=validDevices{devIndex};

                elseif length(devIndex)>1
                    error(message('MATLAB:print:NonUniqueDeviceOption',dev))

                else

                    if startsWith(dev,'jpeg')
                        if isempty(str2num(dev(5:end)))%#ok
                            error(message('MATLAB:print:JPEGQualityLevel'));
                        end

                        obj.Driver=dev;
                        devIndex=find(strcmp('jpeg',validDevices));
                    else
                        error(message('MATLAB:print:InvalidDeviceOption',dev));
                    end
                end
            end
        end

        function setOutputDeviceInfo(obj,devIndex,extensions,classes,colorDevs,destinations,clipsupport)

            obj.DriverExt=extensions{devIndex};
            obj.DriverClass=classes{devIndex};
            obj.DriverColor=strcmp('C',colorDevs{devIndex});
            obj.DriverColorSet=1;
            obj.DriverExport=strcmp('X',destinations{devIndex});
            obj.DriverClipboard=clipsupport{devIndex};

        end

        function copyImageToClipboard(obj)



            if~matlab.graphics.internal.mlprintjob.usesJava(obj)
                return;
            end

            im=matlab.graphics.internal.im2java(obj.Return);

            cb=matlab.graphics.internal.ClipboardFlavorEnhancer;
            cbrestore=onCleanup(@()delete(cb));
            clippy=javaObjectEDT(...
            'com.mathworks.hg.uij.ExportClipboardHelper','image',im);
            clippy.copyToClipboard;
        end
    end
    methods(Static)














        function filename=fixTilde(fileName)
            persistent homeDir;
            filename=fileName;
            if(isunix&&(length(fileName)>1))
                if(fileName(1)=='~'&&fileName(2)==filesep)
                    if isempty(homeDir)



                        currDir=pwd;
                        cd('~');
                        homeDir=pwd;
                        cd(currDir);
                    end
                    if~isempty(homeDir)



                        filename=[homeDir,fileName(2:end)];
                    end
                end
            end
        end

        function isJava=usesJava(pj)





            if isempty(pj.ParentFig)
                pj.ParentFig=ancestor(pj.Handles{1},'figure');
            end
            isJava=~isempty(get(pj.ParentFig,'JavaFrame_I'));
            if~isJava
                isJava=feature('GraphicsUsesJava');
            end
        end

        function objUnitsModified=modifyUnitsForPrint(modifyRevertFlag,varargin)

















            narginchk(2,3)


            unitsToModify={'centimeters','inches','characters','pixels','points'};

            if strcmp(modifyRevertFlag,'modify')
                narginchk(3,3)
                h=varargin{1};


                if ishghandle(h,'figure')
                    h=findall(h);
                end
                dpiAdjustment=varargin{2};




                hUnits=findall(h,'-property','units','-depth',0);

                objUnitsModified=getObjWithUnits(hUnits,...
                'Units',unitsToModify);

                unitsModified=structfun(@(x)~isempty(x),objUnitsModified);
                if any(unitsModified)

                    unitsToChange=unitsToModify(unitsModified);
                    for idx=1:length(unitsToChange)
                        cellfun(@(ph)set(ph,'Units','normalized'),objUnitsModified.(unitsToChange{idx}).handles,...
                        'UniformOutput',false);
                    end
                end


                hPixelFontUnits=findall(h,'-property','fontunits','fontunits','pixels','-depth',0);
                objUnitsModified.fontunitsPixels=updatePixelFontUnits(hPixelFontUnits);


                selfScalingObjects=findall(h,'-isa','matlab.graphics.chart.Chart','visible','on','-method','scaleForPrinting','-depth',0);



                selfScalingObjects=[selfScalingObjects;unique(findall(h,'-isa','matlab.graphics.illustration.internal.AbstractChartIllustration'))];
                objUnitsModified.selfScalingObjects=selfScalingObjects;
                for sObj=1:numel(selfScalingObjects)
                    selfScalingObjects(sObj).scaleForPrinting('modify',dpiAdjustment);
                end






                if dpiAdjustment~=1

                    scale=1.0/dpiAdjustment;

                    fontUnitsSelector={'fontunits','inches','-or','fontunits','points','-or',...
                    'fontunits','centimeters'};
                    hMeasuredFontUnits=findall(h,'-property','fontunits',fontUnitsSelector,'-depth',0);
                    assumedPointsFontUnits=findall(h,'-not','-property','fontunits','-property','fontsize','-depth',0);
                    hMeasuredFontUnits=[hMeasuredFontUnits;assumedPointsFontUnits];


                    cbLabels=getColorbarLabelArray(hMeasuredFontUnits);




                    objUnitsModified.miscFontunitsMeasured=getObjectSizes(cbLabels,'FontSize');
                    objUnitsModified.fontunitsMeasured=getObjectSizes(hMeasuredFontUnits,'FontSize');

                    scaleObjectSizes(objUnitsModified.fontunitsMeasured,scale,'FontSize');
                    scaleObjectSizes(objUnitsModified.miscFontunitsMeasured,scale,'FontSize');


                    lw=findall(h,'visible','on','-property','LineWidth','-depth',0);
                    objUnitsModified.lineobjects=getObjectSizes(lw,'LineWidth');
                    scaleObjectSizes(objUnitsModified.lineobjects,scale,'LineWidth');


                    ms=findall(h,{'visible','on','-property','MarkerSize','-property','Marker','-not','Marker','none'},'-depth',0);
                    objUnitsModified.markerobjects=getObjectSizes(ms,'MarkerSize');
                    scaleObjectSizes(objUnitsModified.markerobjects,scale,'MarkerSize');


                    sd=findall(h,{'visible','on','-property','SizeData','-property','Marker','-not','Marker','none'},'-depth',0);
                    objUnitsModified.sizeDataObjects=getObjectSizes(sd,'SizeData');
                    scaleObjectSizes(objUnitsModified.sizeDataObjects,scale,'SizeData');
                else
                    objUnitsModified.fontunitsMeasured=[];
                    objUnitsModified.miscFontunitsMeasured=[];
                    objUnitsModified.lineobjects=[];
                    objUnitsModified.markerobjects=[];
                    objUnitsModified.sizeDataObjects=[];
                end
            elseif strcmp(modifyRevertFlag,'revert')
                narginchk(2,2)
                objUnitsModified=varargin{1};

                if isempty(objUnitsModified)
                    return
                end




                if~isempty(objUnitsModified.fontunitsMeasured)
                    cellfun(@(ph,sz)setProp(ph,'FontSize',sz),...
                    objUnitsModified.fontunitsMeasured.handles,objUnitsModified.fontunitsMeasured.FontSize,'UniformOutput',false);

                    cellfun(@(ph,modeValue)setPropMode(ph,'FontSizeMode',modeValue),...
                    objUnitsModified.fontunitsMeasured.handles,objUnitsModified.fontunitsMeasured.FontSizeMode,'UniformOutput',false);
                end


                if~isempty(objUnitsModified.miscFontunitsMeasured)
                    cellfun(@(ph,sz)setProp(ph,'FontSize',sz),...
                    objUnitsModified.miscFontunitsMeasured.handles,objUnitsModified.miscFontunitsMeasured.FontSize,'UniformOutput',false);

                    cellfun(@(ph,modeValue)setPropMode(ph,'FontSizeMode',modeValue),...
                    objUnitsModified.miscFontunitsMeasured.handles,objUnitsModified.miscFontunitsMeasured.FontSizeMode,'UniformOutput',false);
                end

                if~isempty(objUnitsModified.fontunitsPixels)
                    cellfun(@(ph,fSize)setProp(ph,'FontUnits','pixels','FontSize',fSize),...
                    objUnitsModified.fontunitsPixels.handles,objUnitsModified.fontunitsPixels.FontSize,'UniformOutput',false);


                    cellfun(@(ph,modeValue)setPropMode(ph,'FontSizeMode',modeValue),...
                    objUnitsModified.fontunitsPixels.handles,objUnitsModified.fontunitsPixels.FontSizeMode,'UniformOutput',false);
                    cellfun(@(ph,modeValue)setPropMode(ph,'FontUnitsMode',modeValue),...
                    objUnitsModified.fontunitsPixels.handles,objUnitsModified.fontunitsPixels.FontUnitsMode,'UniformOutput',false);
                end

                if~isempty(objUnitsModified.lineobjects)
                    cellfun(@(ph,sz)setProp(ph,'LineWidth',sz),...
                    objUnitsModified.lineobjects.handles,objUnitsModified.lineobjects.LineWidth,'UniformOutput',false);

                    cellfun(@(ph,modeValue)setPropMode(ph,'LineWidthMode',modeValue),...
                    objUnitsModified.lineobjects.handles,objUnitsModified.lineobjects.LineWidthMode,'UniformOutput',false);
                end

                if~isempty(objUnitsModified.markerobjects)
                    cellfun(@(ph,sz)setProp(ph,'MarkerSize',sz),...
                    objUnitsModified.markerobjects.handles,objUnitsModified.markerobjects.MarkerSize,'UniformOutput',false);

                    cellfun(@(ph,modeValue)setPropMode(ph,'MarkerSizeMode',modeValue),...
                    objUnitsModified.markerobjects.handles,objUnitsModified.markerobjects.MarkerSizeMode,'UniformOutput',false);
                end


                if~isempty(objUnitsModified.sizeDataObjects)
                    cellfun(@(ph,sz)setProp(ph,'SizeData',sz),...
                    objUnitsModified.sizeDataObjects.handles,objUnitsModified.sizeDataObjects.SizeData,'UniformOutput',false);

                    cellfun(@(ph,modeValue)setPropMode(ph,'SizeDataMode',modeValue),...
                    objUnitsModified.sizeDataObjects.handles,objUnitsModified.sizeDataObjects.SizeDataMode,'UniformOutput',false);
                end

                selfScalingObjects=objUnitsModified.selfScalingObjects;
                for sObj=1:numel(selfScalingObjects)
                    if isvalid(selfScalingObjects(sObj))
                        selfScalingObjects(sObj).scaleForPrinting('revert');
                    end
                end




                for idx=1:length(unitsToModify)
                    units=unitsToModify{idx};
                    if~isempty(objUnitsModified.(units))
                        cellfun(@(ph,pos)resetWithDrawnow(ph,'Units',units,'Position',pos),...
                        objUnitsModified.(units).handles,objUnitsModified.(units).positions,'UniformOutput',false);

                        cellfun(@(ph,modeValue)setPropMode(ph,'PositionMode',modeValue),...
                        objUnitsModified.(units).handles,objUnitsModified.(units).positionmode,'UniformOutput',false);
                        cellfun(@(ph,modeValue)setPropMode(ph,'UnitsMode',modeValue),...
                        objUnitsModified.(units).handles,objUnitsModified.(units).unitsmode,'UniformOutput',false);
                    end
                end
            else
                error(message('MATLAB:modifyunitsforprint:invalidFirstArgument'))
            end



            function resetWithDrawnow(h,varargin)
                if~isvalid(h)
                    return;
                end
                if isa(h,'matlab.graphics.axis.AbstractAxes')&&h.isInLayout



                    for vIdx=1:2:length(varargin)
                        if strcmpi(varargin{vIdx},'units')
                            set(h,varargin{vIdx},varargin{vIdx+1});
                            break;
                        end
                    end
                elseif isa(h,'matlab.graphics.axis.AbstractAxes')&&...
                    isprop(h,'LayoutManager')&&isscalar(h.LayoutManager)&&...
                    isvalid(h.LayoutManager)









                    for vIdx=1:2:length(varargin)
                        if strcmpi(varargin{vIdx},'Position')
                            set(h,'Position_I',varargin{vIdx+1});
                        else
                            set(h,varargin{vIdx},varargin{vIdx+1});
                        end
                    end
                else
                    set(h,varargin{:});
                end
                drawnow;
            end

            function objUnitsModified=getObjWithUnits(h,unitsProp,units)



                saveProp=lower(unitsProp);
                for unitsIdx=1:length(units)
                    objWithUnits=findall(h,'flat',unitsProp,units{unitsIdx},'-property','Position');


                    handles=objWithUnits(~ishghandle(objWithUnits,'figure'));
                    objUnitsModified.(units{unitsIdx}).handles=num2cell(handles);




                    objUnitsModified.(units{unitsIdx}).positions=cellfun(@(ph)get(ph,'Position'),...
                    objUnitsModified.(units{unitsIdx}).handles,'UniformOutput',false);

                    objUnitsModified.(units{unitsIdx}).positionmode=...
                    cellfun(@(ph)getPropMode(ph,'Position'),objUnitsModified.(units{unitsIdx}).handles,'UniformOutput',false);
                    objUnitsModified.(units{unitsIdx}).([saveProp,'mode'])=...
                    cellfun(@(ph)getPropMode(ph,unitsProp),objUnitsModified.(units{unitsIdx}).handles,'UniformOutput',false);
                end

            end

            function fontunitsPixels=updatePixelFontUnits(hFontUnits)

                fontunitsPixels={};
                hFontUnits=num2cell(hFontUnits);
                if~isempty(hFontUnits)
                    fontunitsPixels.handles=hFontUnits;
                    fontunitsPixels.FontSize=cellfun(@(ph)get(ph,'FontSize'),hFontUnits,'UniformOutput',false);

                    fontunitsPixels.FontSizeMode=...
                    cellfun(@(ph)getPropMode(ph,'FontSize'),hFontUnits,'UniformOutput',false);

                    fontunitsPixels.FontUnitsMode=...
                    cellfun(@(ph)getPropMode(ph,'FontUnits'),hFontUnits,'UniformOutput',false);

                    cellfun(@(ph)set(ph,'FontUnits','points'),fontunitsPixels.handles,...
                    'UniformOutput',false);
                end

            end

            function objects=getObjectSizes(objs,prop)

                objects=[];
                objs=num2cell(objs);
                if~isempty(objs)
                    objects.handles=objs;
                    objects.(prop)=cellfun(@(ph)get(ph,prop),objs,'UniformOutput',false);

                    objects.([prop,'Mode'])=...
                    cellfun(@(ph)getPropMode(ph,prop),objs,'UniformOutput',false);
                end
            end

            function scaleObjectSizes(objs,scale,prop)

                if~isempty(objs)

                    cellfun(@(ph,sz)set(ph,prop,sz*scale),...
                    objs.handles,objs.(prop),'UniformOutput',false);
                end

            end

            function mode=getPropMode(obj,prop)

                mode=[];
                if isprop(obj,[prop,'Mode'])
                    mode=obj.([prop,'Mode']);
                end

            end

            function setProp(obj,varargin)

                if isvalid(obj)
                    set(obj,varargin{:});
                end

            end

            function setPropMode(obj,modeProp,modeValue)

                if isvalid(obj)&&isprop(obj,modeProp)
                    obj.(modeProp)=modeValue;
                end

            end


            function result=getColorbarLabelArray(fontArray)

                result=[];
                cb=findall(fontArray,'type','colorbar');
                if~isempty(cb)
                    index=arrayfun(@(x)~isempty(x.Label.String),cb);
                    if any(index)
                        result=[cb(index).Label];
                    end
                end
            end
        end

        function output=generateGfxOutput(varargin)




            genMethod=varargin{1};
            cleanupData=struct('Canvas',[],...
            'CanvasOpenGL',[],...
            'FileName','');

            pj=varargin{3};
            if~matlab.graphics.internal.mlprintjob.usesJava(pj)
                genMethod='JT';
                if ishghandle(varargin{2},'figure')




                    canvas=varargin{2}.getCanvas;
                    cleanupData.Canvas=canvas;
                    cleanupData.CanvasOpenGL=canvas.OpenGL;
                    varargin{2}=canvas;
                end
            end

            if strcmpi(genMethod,'JT')
                if~isfield(pj,'TextAsShapes')
                    pj.TextAsShapes='auto';
                end



                if isempty(pj.FileName)&&pj.DriverClipboard
                    pj.ClipboardOption=1;
                end
                if strcmpi(pj.Driver,'raster@toolbox')
                    if pj.ClipboardOption
                        pj.Driver='pf_clip_raster';
                    else
                        pj.Driver='raster';
                        if pj.RGBImage
                            pj.FileName=tempname;
                            cleanupData.FileName=pj.FileName;
                        end
                    end
                else
                    if pj.ClipboardOption&&strcmp(pj.DriverExt,'pdf')
                        pj.Driver='pf_clip_vector';
                    else
                        switch pj.DriverExt
                        case 'pdf'
                            pj.Driver='pf_pdf';
                        case 'svg'



                            if pj.ContainsTex&&strcmp(pj.TextAsShapes,'auto')
                                pj.TextAsShapes='always';
                            end
                            pj.Driver='pf_svg';
                        case 'emf'
                            pj.Driver='meta';
                        case{'eps','ps'}
                            pj.Driver='ps';
                        case 'prn'
                            pj.Driver='prn';
                        case 'bbox'
                            pj.Driver='BB_NoOp';
                        end
                    end
                end
            end
            if isfield(pj.temp,'TightCroppedSizeRequested')&&pj.temp.TightCroppedSizeRequested
                pj.TightCroppedSizeRequested=true;
            else
                pj.TightCroppedSizeRequested=false;
            end




            if(pj.Append&&isfile(pj.FileName)&&strcmpi(pj.DriverExt,'pdf'))



                filePath=fileparts(pj.FileName);
                pj.TempFileName=[tempname(filePath),'.pdf'];
            end

            cleaner=onCleanup(...
            @()matlab.graphics.internal.mlprintjob.doCleanup(cleanupData));

            if matlab.graphics.internal.mlprintjob.needCheckForImageSize(pj)&&matlab.graphics.internal.mlprintjob.checkImageSizeForPrint(...
                pj.DPI,pj.PaperPosition_Width,pj.PaperPosition_Height)

                error(message('MATLAB:print:InvalidRasterOutputSize'));
            end

            try
                output=generateGraphicsOutput(genMethod,varargin{2},pj);
            catch e

                matlab.graphics.internal.processPrintingError(e,pj);
                throw(e);
            end
        end

        function doCleanup(data)
            if exist(data.FileName,'file')
                delete(data.FileName);
            end
            if~isempty(data.Canvas)
                data.Canvas.OpenGL=data.CanvasOpenGL;
            end
        end

        function yes=needCheckForImageSize(pj)




            yes=strcmpi(pj.DriverClass,'IM');
        end

        function tooBig=checkImageSizeForPrint(dpi,width,height)










            tooBig=false;

            expectedWidth=width*dpi;
            expectedHeight=height*dpi;

            maxInt32=double(intmax('int32'));










            if expectedWidth>maxInt32||expectedHeight>maxInt32
                tooBig=true;
            elseif((expectedWidth*expectedHeight*4)>maxInt32)
                tooBig=true;
            end
        end
        function uihtml=hasUIHTML(h)


            uihtml=false;
            if(isgraphics(h,'figure')&&matlab.ui.internal.isUIFigure(h)&&~isempty(findall(h,'Type','uihtml')))
                uihtml=true;
            end
        end

        function hasUI=containsUIElements(h)

            hasUI=false;


            noUIChildren={'-isa',...
            'matlab.graphics.axis.AbstractAxes','-or','-isa',...
            'matlab.graphics.primitive.canvas.HTMLCanvas','-or','-isa',...
            'matlab.graphics.primitive.canvas.JavaCanvas','-or','-isa',...
            'matlab.graphics.chart.Chart','-or','-isa',...
            'matlab.graphics.layout.Layout'};
            if~isempty(findobj(h,noUIChildren,'-depth',0))
                return;
            end







            if~isprop(h,'NodeChildren')
                hasUI=true;
            else
                ignoreChildren=[{'-not'},{'-isa'},{'matlab.ui.container.Menu'},...
                {'-and'},{'-not'},{'-isa'},{'matlab.ui.container.Toolbar'},...
                {'-and'},{'-not'},{'-isa'},{'matlab.ui.container.ContextMenu'},...
                {'-and'},{'-not'},{'-isa'},{'matlab.graphics.primitive.canvas.Canvas'},...
                ];
                kids=findobj(h.NodeChildren,ignoreChildren,'-depth',0);
                if~isempty(kids)
                    kids=findobj(kids,'-not',noUIChildren,'-depth',0);
                end
                hasUI=~isempty(kids);
            end
        end
    end

    methods(Access=private)
        function obj=copyProps(obj,propertySource)


            if isstruct(propertySource)
                propNames=fieldnames(propertySource);
            else
                propNames=properties(propertySource);
            end
            for idx=1:length(propNames)
                if~isprop(obj,propNames{idx})||...
                    ~isequal(obj.(propNames{idx}),propertySource.(propNames{idx}))

                    if~isprop(obj,propNames{idx})
                        if ismethod(obj,propNames{idx})
                            error(message('MATLAB:printjob:InvalidPropertyName',propNames{idx},class(obj)));
                        end
                        addprop(obj,propNames{idx});
                    end

                    obj.(propNames{idx})=propertySource.(propNames{idx});
                end
            end

        end

        function dpi=LocalGetDPI(obj)



            if obj.DPI==-1
                dpi=150;
            elseif obj.DPI==0
                dpi=get(groot,'screenpixelsperinch');
            else
                dpi=obj.DPI;
            end
        end
    end
end


