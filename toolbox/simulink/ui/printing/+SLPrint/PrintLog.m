classdef PrintLog<handle


    methods(Static)


        function portal=Init(srcFileName,printerName)
            portal=GLUE2.Portal;
            portal.pathXStyle=get_param(0,'EditorPathXStyle');
            printOptions=GLUE2.PortalPrintOptions;
            printOptions.paperOrientation='Portrait';
            printOptions.centerAndFitToPaper=false;
            portal.printOptions=printOptions;

            if(strcmp(printerName,'PDF Writer'))
                portal.printOptions.fileFormat='PDF';
                portal.printOptions.fileName=srcFileName;
            else
                portal.printOptions.printerName=printerName;
            end

        end


        function Print(srcFileName,printerName)
            portal=SLPrint.PrintLog.Init(srcFileName,printerName);


            scene=MG2.Scene;


            paper=SLPrint.Paper;
            paper.PaperType=portal.printOptions.paperType;

            if(GLUE2.Portal.spoolPrintableWidth>0&&GLUE2.Portal.spoolPrintableHeight>0)
                paperSize=[GLUE2.Portal.spoolPrintableWidth*double(scene.DpiX),GLUE2.Portal.spoolPrintableHeight*double(scene.DpiY)];
                baseVPos=0;
                hPos=0;
            else
                paperSize=paper.Size.convertTo('points').Value/72*double(scene.DpiX);
                baseVPos=0.5*scene.DpiY;
                hPos=0.5*scene.DpiX;
            end

            font=MG2.Font;
            font.Family=SLPrint.PrintLog.GetPrintLogTextFont;
            font.Size=10;
            font.Weight='Normal';
            font.Style='Normal';

            vPos=baseVPos;
            lineSpacing=10;
            lastVPos=paperSize(2)-hPos-lineSpacing;
            pageNum=1;

            try
                fid=fopen(srcFileName,'r');
                while 1
                    txt=fgetl(fid);
                    if(~ischar(txt))
                        break;
                    end
                    textNode=MG2.TextNode;
                    textNode.Text=txt;
                    textNode.Font=font;
                    textNode.Position=[hPos,vPos];
                    scene.addNode(textNode);
                    vPos=vPos+lineSpacing;

                    if(vPos>lastVPos)

                        SLPrint.PrintLog.PrintPortal(portal,scene);
                        vPos=baseVPos;
                        scene=MG2.Scene;
                        pageNum=pageNum+1;
                    end

                end
                SLPrint.PrintLog.PrintPortal(portal,scene,pageNum);
                fclose(fid);
            catch me
                fclose(fid);
                rethrow(me);
            end

        end


        function PrintPortal(portal,scene,pageNum)
            if(~isempty(portal.printOptions.fileName))
                if(pageNum>1)
                    [pathName,baseName,extName]=fileparts(portal.printOptions.fileName);
                    if~isempty(extName)
                        portal.printOptions.fileName=fullfile(pathName,sprintf('%s-%d.%s',baseName,pageNum,extName));
                    else
                        portal.printOptions.fileName=fullfile(pathName,sprintf('%s-%d',baseName,pageNum));
                    end

                    portal.printToFile(scene,scene.Bounds);
                end
            else
                portal.print(scene,scene.Bounds);
            end
        end

        function fontName=GetPrintLogTextFont



            if(ispc&&strncmpi(get(0,'lang'),'ja',2))
                fontName='MS UI Gothic';
            else
                fontName='Courier';
            end
        end

    end

end


