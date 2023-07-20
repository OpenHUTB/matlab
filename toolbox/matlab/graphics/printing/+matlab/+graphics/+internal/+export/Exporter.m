classdef Exporter<handle




    properties
        argParser;
        state;
        warningBacktrace;
    end

    methods
        function obj=Exporter(argParser)
            obj.argParser=argParser;
        end

        function varargout=process(obj,varargin)
            import matlab.graphics.internal.export.ExporterValidator
            obj.warningBacktrace=obj.disableWarningBacktrace();
            results=obj.argParser.processArguments(varargin{:});
            results=ExporterValidator.crossValidateInputs(results);


            pj=obj.determineWhatToExport(results);


            pj=obj.fillInPrintjob(pj,results);


            pj=obj.preExportSetup(pj);


            cleanupHandler=onCleanup(@()obj.postExportCleanup(pj));
            try
                val=obj.generateExportedOutput(results,pj);
            catch ex
                ex.throwAsCaller();
            end

            matlab.graphics.internal.export.logDDUXInfo(pj,results);

            if nargout
                varargout{1}=val;
            end
        end
    end
    methods(Static,Access={?tExportTo})
        function enabled=getDrawnowSyncEnabled(h)
            if isa(h,'matlab.graphics.primitive.canvas.HTMLCanvas')
                enabled=h.LiveEditorDrawnowSyncReady;
            else
                enabled='';
            end
        end
        function setDrawnowSyncEnabled(h,val)
            if isa(h,'matlab.graphics.primitive.canvas.HTMLCanvas')
                h.LiveEditorDrawnowSyncReady=val;
            end
        end
    end
    methods(Access=protected)
        function output=generateExportedOutput(obj,results,pj)
            exportable=pj.Handles{1};


            pj.CanvasDPI=get(exportable,'ScreenPixelsPerInch');

            if~strcmpi(results.size,'auto')
                pj=matlab.graphics.internal.export.resizeToFitUserRequestedSize(pj,results);
            end

            pjstruct=pj.tostruct;


            if obj.enableFontEmbedding(pj)
                pjstruct.EmbedFonts=true;
            end


            pjstruct.TextAsShapes='auto';





            if matlab.graphics.internal.export.needsTextAsShapes(exportable)
                pjstruct.ContainsTex=1;
            end

            pj.Return=pj.generateOutput('HG',exportable,pjstruct);


            if strcmp(pj.DriverClass,'IM')
                if results.margins>=0
                    pj.Return=matlab.graphics.internal.export.cropImage(...
                    pj.Return,[],results.margins);
                end
                if~strcmpi(results.size,'auto')
                    if~strcmp(results.units,'pixels')
                        requestedSize=hgconvertunits(pj.ParentFig,...
                        [0,0,results.size],results.units,...
                        'inches',groot);
                        requestedWidth=requestedSize(3)*results.resolution;
                        requestedHeight=requestedSize(4)*results.resolution;
                    else
                        requestedWidth=results.size(1);
                        requestedHeight=results.size(2);
                    end
                    generatedWidth=size(pj.Return,2);
                    generatedHeight=size(pj.Return,1);
                    if(requestedWidth~=generatedWidth)||(requestedHeight~=generatedHeight)
                        pj.Return=imresize(pj.Return,[requestedHeight,...
                        requestedWidth]);
                    end
                end
                if strcmp(results.target,'file')
                    pj=obj.getDriverForImwrite(pj,results);
                    pj.writeRaster();
                elseif strcmp(results.target,'clipboard')
                    pj.copyImageToClipboard();
                end
            end
            output=pj.Return;

        end
    end

    methods(Access=private)
        function pj=preExportSetup(obj,pj)

            pj=matlab.graphics.internal.export.exportPreparation(pj,'prepare');
            setWarningState(obj);
            pj=drawnowSyncPreparation(obj,pj,'prepare');
        end

        function postExportCleanup(obj,pj)

            pj=drawnowSyncPreparation(obj,pj,'restore');
            resetWarningState(obj);
            matlab.graphics.internal.export.exportPreparation(pj,'restore');
        end

        function setWarningState(obj)


            obj.state.layoutWarning=warning('off','MATLAB:graphics:axeslayoutmanager:InconsistentState');

            [obj.state.lastWarnMsg,obj.state.lastWarnID]=lastwarn();
        end

        function resetWarningState(obj)

            warning(obj.state.layoutWarning);

            [~,LastId]=lastwarn;
            if strcmp(LastId,'MATLAB:graphics:axeslayoutmanager:InconsistentState')
                lastwarn(obj.state.lastWarnMsg,obj.state.lastWarnID);
            end
        end

        function enable=enableFontEmbedding(~,pj)

            enable=strcmpi(pj.Driver,'pdfwrite');
        end

        function pj=drawnowSyncPreparation(obj,pj,mode)

            if strcmp(mode,'prepare')

                pj.temp.htmlCanvasDrawnowSync='';



                if isa(pj.Handles{1},'matlab.graphics.primitive.canvas.HTMLCanvas')


                    if~obj.blacklistedToSync(pj)




                        pj.temp.htmlCanvasDrawnowSync=pj.Handles{1}.LiveEditorDrawnowSyncReady;
                        pj.Handles{1}.LiveEditorDrawnowSyncReady='on';
                        drawnow;
                    end
                end
            else

                if~isempty(pj.temp.htmlCanvasDrawnowSync)&&...
                    isa(pj.Handles{1},'matlab.graphics.primitive.canvas.HTMLCanvas')
                    pj.Handles{1}.LiveEditorDrawnowSyncReady=pj.temp.htmlCanvasDrawnowSync;
                end
            end
        end






        function isBlackListed=blacklistedToSync(~,pj)


            isLiveEditorFig=isprop(pj.ParentFig,'LiveEditorRunTimeFigure');


            isNoDisplayMode=~pj.temp.isFigureShowEnabled;





            isBlackListed=isLiveEditorFig|isNoDisplayMode;



            if(isBlackListed)
                pj.Handles{1}.ServerSideRendering='on';
            end
        end
    end

    methods(Static)
        function pj=determineWhatToExport(results)
            import matlab.graphics.internal.export.Exporter

            pj=printjob;
            hndl=results.handle;


            pj.ParentFig=ancestor(hndl,'figure');
            content=Exporter.findExportableAndRelatedObjects(hndl);


            if~isa(content.Handle,'matlab.graphics.internal.Exportable')
                error(message('MATLAB:hghardcopy:generateGraphicsOutput:MustBeExportableHandle'));
            end
            pj.Handles{1}=content.Handle;
            pj.temp.exportInclude=content.exportInclude;
            pj.temp.exportExclude=content.exportExclude;
            pj.temp.exportKeepVisible=content.keepVisible;
        end

        function pj=fillInPrintjob(pj,results)
            import matlab.graphics.internal.export.Exporter

            [results,pj]=...
            matlab.graphics.internal.export.Exporter.determineRendererAndBackground(results,pj);
            hndl=pj.Handles{1};

            if strcmp(results.format,'image')&&strcmp(results.target,'array')
                pj.RGBImage=1;
                pj.Driver='png';
            else
                pj.Driver=results.format;
            end
            [~,devices,extensions,classes,colorDevs,...
            destinations,~,clipsupport]=printtables(pj);


            additionalFmts={'gif','gif','IM','C','X','Graphics Interchange Format file',0};

            devices=[devices;additionalFmts(:,1)];
            extensions=[extensions;additionalFmts(:,2)];
            classes=[classes;additionalFmts(:,3)];
            colorDevs=[colorDevs;additionalFmts(:,4)];
            destinations=[destinations;additionalFmts(:,5)];
            clipsupport=[clipsupport;additionalFmts(:,7)];

            devIndex=pj.getOutputDevice(pj.Driver,devices);
            pj.setOutputDeviceInfo(devIndex,extensions,classes,colorDevs,...
            destinations,clipsupport);
            if strcmp(classes{devIndex},'IM')


                pj.Driver='raster@toolbox';
            end

            screenDPI=get(groot,'ScreenPixelsPerInch');
            outputResolution=results.resolution;
            pj.FileName=results.destination;
            pj.DPI=outputResolution;
            pj.ScreenDPI=screenDPI;
            pj.ScaledDPI=pj.DPI;
            pj.temp.DeviceDPI=pj.ParentFig.ScreenPixelsPerInch;


            scSize=hgconvertunits(pj.ParentFig,get(groot,'ScreenSize'),get(groot,'Units'),'pixels',groot);
            pj.temp.ScreenSizeInPixels=scSize(3:4);
            pj.DebugMode=0;
            pj.Validated=1;
            pj.PaperPosition_X=0;
            pj.PaperPosition_Y=0;

            pj.PostScriptCMYK=strcmp(results.colorspace,'cmyk');
            pj.Colorspace=results.colorspace;

            pj.Append=results.append;


            viewportW=double(hndl.Viewport(3));
            viewportH=double(hndl.Viewport(4));



            if ismac&&strcmpi(pj.Renderer,'painters')&&matlab.graphics.internal.mlprintjob.usesJava(pj)
                paperPosScale=1/pj.ScreenDPI;
            else
                paperPosScale=1/double(hndl.ScreenPixelsPerInch);
            end

            pj.PaperPosition_Width=viewportW*paperPosScale;
            pj.PaperPosition_Height=viewportH*paperPosScale;

            pj.Original_Width=viewportW;
            pj.Original_Height=viewportH;
            pj.donePrinting=1;
            pj.PixelOutputPosition=[0,0,viewportW,viewportH];



            desiredSizeScale=1.0;
            if ismac&&(strcmpi(pj.Renderer,'opengl')||strcmpi(pj.Driver,'raster@toolbox'))
                desiredSizeScale=pj.ScreenDPI/double(hndl.ScreenPixelsPerInch);
            end

            pj.Desired_Width=viewportW*desiredSizeScale;
            pj.Desired_Height=viewportH*desiredSizeScale;
            pj.EnhanceTextures=0;
            pj.Tag='printjob';







            pj.doTransform=0;
            pj.ContainsTex=0;




            pj.Verbose=0;
            pj.Orientation='portrait';
            pj.PrintUI=0;
            pj.PaperType='<custom>';
            pj.PaperUnits='inches';
            pj.PaperSize_Width=pj.PaperPosition_Width;
            pj.PaperSize_Height=pj.PaperPosition_Height;

            pj.BackgroundColor=results.background;
            if results.margins<0
                pj.PostScriptTightBBox=0;
            end

            if isempty(pj.CallerFunc)
                if strcmpi(results.target,'clipboard')
                    pj.CallerFunc='copygraphics';
                else
                    pj.CallerFunc='exportgraphics';
                end
            end

            if~strcmp(results.size,'auto')&&~strcmp(results.units,'auto')
                pj.temp.TightCroppedSizeRequested=true;
            end
        end

        function result=isVectorFormat(driver)
            driver=string(driver);
            result=driver.startsWith({'ps','eps','met','pdf','svg'});
        end
        function pj=getDriverForImwrite(pj,results)
            if strcmp(pj.DriverClass,'IM')
                pj.Driver=results.format;
            end
        end

        function exportable=getExportableHandle(hndl)
            exportable=[];
            if isa(hndl,'matlab.graphics.internal.Exportable')
                if ishghandle(hndl,'figure')
                    exportable=hndl.getCanvas;
                else
                    exportable=hndl;
                end
            else
                canvasContainer=ancestor(hndl,'matlab.ui.internal.mixin.CanvasHostMixin');
                if~isempty(canvasContainer)
                    exportable=canvasContainer.getCanvas();
                end
            end
            if length(exportable)>1
                exportable=exportable(1);
            end
        end

        function results=findExportableAndRelatedObjects(hndl)






            import matlab.graphics.internal.export.GraphicsExportable;
            exportableHandle=matlab.graphics.internal.export.Exporter.getExportableHandle(hndl);
            hndlInclude=GraphicsExportable.getObjectsToExport(hndl);





            parent=hndl.NodeParent;
            parents=matlab.graphics.GraphicsPlaceholder;
            idx=1;
            while parent~=groot
                parents(idx)=parent;
                idx=idx+1;
                parent=parent.NodeParent;
            end
            results.keepVisible=parents;
            results.Handle=exportableHandle;

            results.exportInclude=unique([exportableHandle,hndlInclude]);
            if exportableHandle~=hndl



                otherContent=GraphicsExportable.getObjectsToExport(exportableHandle);
                results.exportExclude=setdiff(otherContent,results.exportInclude);
            else
                results.exportExclude=GraphicsExportable.getObjectsToExclude(hndl);
            end

        end

        function[results,pj]=determineRendererAndBackground(results,pj)




            hndl=pj.Handles{1};
            clipboardAuto=false;
            if strcmp(results.target,'clipboard')
                pj.DriverClipboard=1;
                pj.ClipboardOption=1;
                if strcmp(results.format,'auto')
                    clipboardAuto=true;
                    if ispc
                        format='meta';
                    else
                        format='pdf';
                    end
                else
                    format=results.format;
                end
            else
                pj.DriverClipboard=0;
                pj.ClipboardOption=0;
                format=results.format;
            end
            pj.Driver=format;

            isVectorFormat=matlab.graphics.internal.export.Exporter.isVectorFormat(pj.Driver);

            usePainters=false;
            if isVectorFormat
                [paintersSwitchOK,heuristicNotApplied]=...
                matlab.graphics.internal.autoSwitchToPaintersForPrint(pj);
                switch results.vector
                case 'auto'

                    usePainters=paintersSwitchOK;
                case 'true'


                    if~heuristicNotApplied&&~paintersSwitchOK
                        warning(message('MATLAB:print:ContentTypeImageSuggested'))
                    end
                    usePainters=true;
                case 'false'
                    usePainters=false;
                end
            else

                if strcmp(results.vector,'true')
                    warning(message('MATLAB:print:ImageOutputIgnoresVectorContentType'))
                end
            end
            if usePainters
                results.format=format;
                pj.Renderer='painters';
            else
                if clipboardAuto
                    results.format='bmp';
                end

                if ishghandle(hndl,'figure')
                    usingOpenGL=strcmp(hndl.Renderer,'opengl');
                else
                    usingOpenGL=strcmp(hndl.OpenGL,'on');
                end



                if usingOpenGL
                    pj.Renderer='opengl';
                else
                    pj.Renderer='painters';
                end
            end


            pj.rendererOption=1;




            if strcmp(results.background,'none')||...
                isempty(results.background)&&strcmp(hndl.Color,'none')

                if isVectorFormat&&usePainters
                    pj.TransparentBackground=1;
                else


                    warning(message('MATLAB:print:WhiteReplacingTransparentBackground'));
                    results.background=[1,1,1];
                end
            end
        end
        function restoreState=disableWarningBacktrace()
            state=warning('off','backtrace');
            restoreState=onCleanup(@()warning(state));
        end
    end
end
