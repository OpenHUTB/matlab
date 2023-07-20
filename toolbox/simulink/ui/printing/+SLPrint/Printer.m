classdef Printer<handle






    properties(Constant,Hidden)
        lockMap=containers.Map;
        dirtyMap=containers.Map;
    end

    methods(Static)
        function setUnlockDuringPrint(rootSysHandle)
            rootSysName=get_param(rootSysHandle,'Name');
            p=SLPrint.Printer;
            if~p.lockMap.isKey(rootSysName)


                p.lockMap(rootSysName)=strcmpi(get_param(rootSysName,'Lock'),'on');
                p.dirtyMap(rootSysName)=strcmpi(get_param(rootSysName,'Dirty'),'on');
                p.unlock(rootSysName);
            end
        end

        function tf=wasUnlockDuringPrint(obj)
            rootObj=SLPrint.Resolver.getBlockDiagramUDDObject(obj);
            rootSysName=rootObj.Name;
            p=SLPrint.Printer;
            if p.lockMap.isKey(rootSysName)
                tf=p.lockMap(rootSysName);
            else
                tf=false;
            end
        end

        function lock(obj)
            rootObj=SLPrint.Resolver.getBlockDiagramUDDObject(obj);
            rootObj.Lock='on';
        end

        function unlock(obj)
            rootObj=SLPrint.Resolver.getBlockDiagramUDDObject(obj);
            rootObj.Lock='off';
        end

        function init()
            SLPrint.Printer.lockMap.remove(SLPrint.Printer.lockMap.keys);
            SLPrint.Printer.dirtyMap.remove(SLPrint.Printer.dirtyMap.keys);
        end

        function cleanup()
            for key=SLPrint.Printer.dirtyMap.keys()
                sys=key{1};
                if SLPrint.Printer.dirtyMap(sys)
                    set_param(sys,'Lock','off');
                    set_param(sys,'Dirty','on');
                else
                    set_param(sys,'Lock','off');
                    set_param(sys,'Dirty','off');
                end
            end

            for key=SLPrint.Printer.lockMap.keys()
                sys=key{1};
                if SLPrint.Printer.lockMap(sys)
                    set_param(sys,'Lock','on');
                else
                    set_param(sys,'Lock','off');
                end
            end

            SLPrint.Printer.lockMap.remove(SLPrint.Printer.lockMap.keys);
            SLPrint.Printer.dirtyMap.remove(SLPrint.Printer.dirtyMap.keys);
        end


        function ExecutePrintJob(pj)

            slSfHandle=pj.Handles{1};



            if(is_simulink_handle(slSfHandle)&&pj.Verbose)
                SLM3I.SLDomain.showPrintDialog(slSfHandle);
                return;
            end

            slSfObj=SLPrint.Utils.GetSLSFObject(slSfHandle);

            mode=SLPrint.Utils.GetMode(pj,slSfObj);

            switch lower(mode)
            case{'auto','manual'}
                SLPrint.Printer.PrintAutoOrManual(pj,slSfObj,mode);
            case 'tiled'
                SLPrint.Printer.PrintTiled(pj,slSfObj);
            case 'frame'
                SLPrint.Printer.PrintFrame(pj,slSfObj);
            otherwise
                DAStudio.error('Simulink:Printing:InvalidPrintMode',mode);
            end
        end

        function PrintAutoOrManual(pj,slSfObj,autoOrManual)

            p=SLPrint.Utils.GetPortal(slSfObj);

            p.printOptions=SLPrint.Printer.PrintJob2PrintOptions(p,pj,slSfObj,autoOrManual);


            p.printOptions.backgroundColorMode=get_param(0,'PrintBackgroundColorMode');





            if(isempty(p.printOptions.printerName))
                p.printOptions.printerName=getenv('PRINTER');
            end

            if SLPrint.Printer.wasUnlockDuringPrint(slSfObj)
                SLPrint.Printer.lock(slSfObj);
            end

            if(~isempty(pj.FileName))
                inCurrentView=isfield(pj,'sfCurrentView')&&pj.sfCurrentView;
                if(inCurrentView)
                    canvas=SLPrint.Utils.GetLastActiveSFEditorCanvasFor(slSfObj);
                    sceneRectInView=canvas.SceneRectInView;
                    p.printToFile(p.targetScene,sceneRectInView);
                else
                    p.printToFile;
                end
            else
                p.print;
            end

            if SLPrint.Printer.wasUnlockDuringPrint(slSfObj)
                SLPrint.Printer.unlock(slSfObj);
            end

        end

        function PrintTiled(pj,slSfObj)

            p=SLPrint.Utils.GetPortal(slSfObj);


            printOptions=SLPrint.Printer.PrintJob2PrintOptions(p,pj,slSfObj,'tiled');
            printOptions.centerAndFitToPaper=false;


            printOptions.backgroundColorMode=get_param(0,'PrintBackgroundColorMode');


            toFile=~isempty(printOptions.fileName);


            [oldPaperUnits,bdDirty,bdLock]=SLPrint.Utils.ChangePaperUnits(slSfObj,'Inches');




            tilePageScale=SLPrint.Utils.SLSFGet(slSfObj,'TiledPageScale');
            tilePageMargins=SLPrint.Utils.SLSFGet(slSfObj,'TiledPaperMargins');
            paperSize=SLPrint.Utils.SLSFGet(slSfObj,'PaperSize');


            printOptions.paperMargins=tilePageMargins;


            dpi=double(p.targetScene.DpiX);
            pageWidth=(paperSize(1)-tilePageMargins(1)-tilePageMargins(3))*dpi;
            pageHeight=(paperSize(2)-tilePageMargins(2)-tilePageMargins(4))*dpi;


            tileWidth=pageWidth*tilePageScale;
            tileHeight=pageHeight*tilePageScale;


            targetBounds=p.getTargetBounds;
            srcLeft=targetBounds(1);
            srcTop=targetBounds(2);
            srcWidth=targetBounds(3);
            srcHeight=targetBounds(4);
            numTilesWide=ceil(srcWidth/tileWidth);
            numTilesHigh=ceil(srcHeight/tileHeight);


            p.targetOutputRect=[0,0,pageWidth,pageHeight];


            p.printOptions=printOptions;
            GLUE2.Portal.beginSpooling();


            tileNum=0;
            for yi=0:(numTilesHigh-1)
                for xi=0:(numTilesWide-1)
                    tileNum=tileNum+1;
                    p.targetSceneRect=[srcLeft+xi*tileWidth,srcTop+yi*tileHeight,tileWidth,tileHeight];
                    if(toFile)
                        p.printToFile();
                    else
                        p.print();
                    end
                end
            end


            GLUE2.Portal.endSpooling();


            SLPrint.Utils.RestorePaperUnits(slSfObj,oldPaperUnits,bdDirty,bdLock);

        end

        function PrintFrame(pj,slSfObj)
            f=SLPrint.PrintFrame.Instance();














            p=f.Render(slSfObj);
            p.printOptions.printerName=pj.PrinterName;
            p.printOptions.colorMode=SLPrint.Utils.GetColorMode(pj);

            toFile=false;
            if(~isempty(pj.FileName))
                toFile=true;
                p.printOptions.fileName=pj.FileName;
                p.printOptions.fileFormat=SLPrint.Printer.GetPrintFileFormat(pj);
            end

            if SLPrint.Printer.wasUnlockDuringPrint(slSfObj)
                SLPrint.Printer.lock(slSfObj);
            end

            if(toFile)
                p.printToFile;
            else
                p.print;
            end

            if SLPrint.Printer.wasUnlockDuringPrint(slSfObj)
                SLPrint.Printer.unlock(slSfObj);
            end

        end

        function fileFormat=GetPrintFileFormat(pj)

            fileFormat='PDF';

        end

        function printOptions=PrintJob2PrintOptions(portal,pj,slSfObj,mode)


            printOptions=GLUE2.PortalPrintOptions;


            printOptions.printerName=pj.PrinterName;


            printOptions.fileName=pj.FileName;


            printOptions.colorMode=SLPrint.Utils.GetColorMode(pj);


            printOptions.fileFormat=SLPrint.Printer.GetPrintFileFormat(pj);


            if isfield(pj,'PaperOrientation')
                slSfPaperOrientation=pj.PaperOrientation;
            else
                slSfPaperOrientation=SLPrint.Utils.SLSFGet(slSfObj,'PaperOrientation');
            end
            printOptions.paperOrientation=SLPrint.Printer.SLSFToQtPaperOrientation(slSfPaperOrientation);


            printOptions.paperUnits='Inches';


            if isfield(pj,'PaperType')
                slSfPaperType=pj.PaperType;
            else
                slSfPaperType=SLPrint.Utils.SLSFGet(slSfObj,'PaperType');
            end
            qtPaperTypeOrCustomPaperInfo=SLPrint.Printer.SLSFToQtPaperTypeOrSize(slSfPaperType);


            if isfield(pj,'NumCopies')
                printOptions.numCopies=pj.NumCopies;
            end

            if isfield(pj,'FromPage')
                printOptions.fromPage=pj.FromPage;
            end

            if isfield(pj,'ToPage')
                printOptions.toPage=pj.ToPage;
            end

            if(isa(qtPaperTypeOrCustomPaperInfo,'char'))
                printOptions.paperType=qtPaperTypeOrCustomPaperInfo;
            elseif(isa(qtPaperTypeOrCustomPaperInfo,'struct'))
                printOptions.paperType='Custom';
                customPaperSize=qtPaperTypeOrCustomPaperInfo.paperSize;
                customPaperUnits=qtPaperTypeOrCustomPaperInfo.paperUnits;
                printOptions.setCustomPaperSize(customPaperSize,customPaperUnits);
            end


            if(strcmpi(mode,'auto')||strcmpi(mode,'manual'))


                printOptions.paperMargins=[0.5,0.5,0.5,0.5];
            end

        end


        function qtOrientation=SLSFToQtPaperOrientation(slSfOrientation)

            persistent orientationMap;

            if(isempty(orientationMap))
                orientationMap=containers.Map;
                orientationMap('landscape')='Landscape';
                orientationMap('portrait')='Portrait';
                orientationMap('rotated')='Landscape';
            end

            if strcmpi(slSfOrientation,'rotated')
                warning(message('Simulink:Printing:DeprecatedRotatedOrientation'));
            end

            qtOrientation=orientationMap(slSfOrientation);

        end

        function qtPaperTypeOrCustomPaperInfo=SLSFToQtPaperTypeOrSize(slSfPaperType)

            persistent paperTypeMap;

            if(isempty(paperTypeMap))
                paperTypeMap=containers.Map;


                paperTypeMap('A0')='A0';
                paperTypeMap('A1')='A1';
                paperTypeMap('A2')='A2';
                paperTypeMap('A3')='A3';
                paperTypeMap('A4')='A4';
                paperTypeMap('A5')='A5';

                paperTypeMap('B0')='B0';
                paperTypeMap('B1')='B1';
                paperTypeMap('B2')='B2';
                paperTypeMap('B3')='B3';
                paperTypeMap('B4')='B4';
                paperTypeMap('B5')='B5';

                paperTypeMap('USLETTER')='Letter';
                paperTypeMap('USLEGAL')='Legal';
                paperTypeMap('TABLOID')='Tabloid';








                paperTypeMap('A')='A4';
                paperTypeMap('B')='A3';
                paperTypeMap('C')='A2';
                paperTypeMap('D')='A1';
                paperTypeMap('E')='A0';




                paperTypeMap('ARCH-A')=struct('paperSize',[9,12],'paperUnits','Inches');
                paperTypeMap('ARCH-B')=struct('paperSize',[12,18],'paperUnits','Inches');
                paperTypeMap('ARCH-C')=struct('paperSize',[18,24],'paperUnits','Inches');
                paperTypeMap('ARCH-D')=struct('paperSize',[24,36],'paperUnits','Inches');
                paperTypeMap('ARCH-E')=struct('paperSize',[36,48],'paperUnits','Inches');



                paperTypeMap('A4LETTER')='A4';
            end


            if(strcmpi(slSfPaperType,'a4letter'))
                warning(message('glue2:portal:DeprecatedPaperSize',slSfPaperType,paperTypeMap(upper(slSfPaperType))));
            end

            qtPaperTypeOrCustomPaperInfo=paperTypeMap(upper(slSfPaperType));

        end
    end

end


