classdef PrintFrame<handle









    properties(SetAccess=private,GetAccess=private)
        FrameInfo=[];
        IsInitialized=false;
        FigHandle=0;
        Portal=[];
        OverlayRoot=[];
        PixelsPerNormXY=[];
        Margins=[];
        DeviceScale=1;
    end


    methods(Access=private)
        function obj=PrintFrame()
            obj.FrameInfo=[];
            obj.IsInitialized=false;
            obj.FigHandle=0;
            obj.Portal=[];
            obj.OverlayRoot=[];
        end
    end


    methods(Static)
        function obj=Instance()
            persistent singleton;
            if(isempty(singleton))
                singleton=SLPrint.PrintFrame();
            end
            obj=singleton;
        end
    end


    methods

        function Init(self,frameFigFile,numSys)
            assert(~self.IsInitialized);


            try
                propertyOverride.Visible='off';
                self.FigHandle=hgload(frameFigFile,propertyOverride);
            catch me
                DAStudio.error('Simulink:Printing:InvalidFrameFigure',frameFigFile);
            end



            self.FrameInfo=struct('date',datestr(now,1),'time',datestr(now,15),'npages',numSys,'page',0);


            portal=GLUE2.Portal;
            portal.pathXStyle=get_param(0,'EditorPathXStyle');
            self.Portal=portal;
            self.initOverlayScene();

            self.SetPrintOptions(portal.printOptions);


            self.IsInitialized=true;

        end

        function portal=Render(self,sysObject)

            assert(self.IsInitialized);

            portal=self.Portal;
            portal.setTarget(SLPrint.Utils.GetDomain(sysObject),sysObject);

            ppi=GLUE2.Util.getLogicalDPI();
            self.DeviceScale=300/(ppi*GLUE2.Util.getDpiScale());


            self.initOverlayScene();


            self.IncrementPageNum();


            sysTextBoundsHG=self.DrawTexts(sysObject);


            sysOverlayRect=self.DrawFrameRects(sysTextBoundsHG);









            dstBounds=gleeTestInternal.Rect(sysOverlayRect);
            dstBounds.expand(-.25*ppi);


            portal.targetOutputRect=dstBounds.toArray();
            portal.printOptions.centerAndFitToPaper=false;


            targetScale=min(portal.targetScale,self.DeviceScale);
            tightBounds=gleeTestInternal.Rect(portal.getTargetBounds());
            tightBounds.width=targetScale*tightBounds.width;
            tightBounds.height=targetScale*tightBounds.height;









            tightBounds.setCenter(dstBounds.center());
            portal.targetOutputRect=tightBounds.toArray();


            portal.printOptions.forceTargetOverlayRectToFillPaper=false;
            portal.targetOverlayRect=sysOverlayRect;
        end

        function initOverlayScene(self)
            portal=self.Portal;
            portal.clearOverlayScene();
            overlayScene=portal.overlayScene;
            overlayRoot=MG2.ContainerNode;
            overlayScene.addNode(overlayRoot);

            self.OverlayRoot=overlayRoot;
        end

        function Reset(self)

            if(self.IsInitialized)

                close(self.FigHandle);

                self.FigHandle=0;
                self.FrameInfo=[];
                self.IsInitialized=false;
                self.OverlayRoot=[];
                self.Portal.clearOverlayScene;
                self.Portal=[];
                self.PixelsPerNormXY=[];
            end
        end

        function IncrementPageNum(self)
            self.FrameInfo.page=self.FrameInfo.page+1;
        end

        function SetPrintOptions(self,portalPrintOptions)

            f=self.FigHandle;


            set(f,'PaperUnits','Inches');
            paperPosHG=get(f,'PaperPosition');
            paperTypeHG=get(f,'PaperType');
            paperSizeHG=get(f,'PaperSize');
            paperOrientationHG=get(f,'PaperOrientation');

            portalPrintOptions.paperType=self.HGToQtPaperTypeOrSize(paperTypeHG);
            portalPrintOptions.paperOrientation=self.HGToQtPaperOrientation(paperOrientationHG);


            portalPrintOptions.paperMargins=[paperPosHG(1),...
            paperSizeHG(2)-paperPosHG(4)-paperPosHG(2),...
            paperSizeHG(1)-paperPosHG(3)-paperPosHG(1),...
            paperPosHG(2)];

        end

        function framePatchVertices=GetFramePatchVertices(self)
            f=self.FigHandle;
            patches=findall(f,'type','patch');
            framePatchVertices=get(patches,'vertices');
        end

        function bdOverlayRect=DrawFrameRects(self,sysTextBoundsHG)

            overlayRoot=self.OverlayRoot;

            framePatchVertices=self.GetFramePatchVertices;

            sysTextLeft=sysTextBoundsHG(1);
            sysTextBottom=sysTextBoundsHG(2);

            overlayRects={};
            possibleSysRectAreas=[];
            possibleSysRects={};
            j=1;

            for i=1:length(framePatchVertices)

                framePatchVertex=framePatchVertices{i};





                if(any(framePatchVertex(:)<0))
                    continue;
                end

                overlayRects{i}=self.GetPortalRectForPatch(framePatchVertex)*self.DeviceScale;%#ok<AGROW>

                rectNode=MG2.RectNode(overlayRects{i});

                rectNode.Parent=overlayRoot;

                minX=framePatchVertex(1,1);
                maxX=framePatchVertex(4,1);

                minY=framePatchVertex(1,2);
                maxY=framePatchVertex(2,2);


                if((sysTextLeft>minX)&&(sysTextLeft<maxX)&&(sysTextBottom>minY)&&(sysTextBottom<maxY))
                    possibleSysRectAreas(j)=overlayRects{i}(3)*overlayRects{i}(4);%#ok<AGROW>
                    possibleSysRects{j}=overlayRects{i};%#ok<AGROW>
                    j=j+1;
                end

            end



            [~,idx]=sort(possibleSysRectAreas);
            bdOverlayRect=possibleSysRects{idx(1)};

        end

        function blockDiagTextPos=DrawTexts(self,sysObject)

            textHandles=findall(self.FigHandle,'type','text');

            vAlign='V_CENTER_TEXT';

            blockDiagTextPos=[0,0,0,0];

            fontFamily=SLPrint.Utils.GetDefaultFont;

            for i=1:length(textHandles)

                h=textHandles(i);


                textKey=get(h,'string');


                if(isempty(textKey))
                    continue;
                end


                textNode=MG2.TextNode;



                if(strcmpi(textKey,'%<blockdiagram>'))
                    blockDiagTextPos=get(h,'Position');
                    continue;
                end


                fontWeight=get(h,'FontWeight');
                fontAngle=get(h,'FontAngle');
                fontSize=get(h,'FontSize');

                textNode.Font.Family=fontFamily;
                textNode.Font.Weight=fontWeight;
                textNode.Font.Size=fontSize*self.DeviceScale;
                textNode.Font.Style=fontAngle;


                textHAlign=get(h,'HorizontalAlignment');

                if(strcmpi(textHAlign,'left'))
                    hAlign='LEFT_TEXT';
                elseif(strcmpi(textHAlign,'right'))
                    hAlign='RIGHT_TEXT';
                elseif(strcmpi(textHAlign,'center'))
                    hAlign='H_CENTER_TEXT';
                end
                textNode.HorizontalAlignment=hAlign;
                textNode.VerticalAlignment=vAlign;


                interpreter=get(h,'Interpreter');
                if(strcmpi(interpreter,'tex'))
                    interpretMode='INTERPRET_TEX';
                elseif(strcmpi(interpreter,'rich'))
                    interpretMode='INTERPRET_RICH';
                else
                    interpretMode='INTERPRET_OFF';
                end

                textNode.InterpretMode=interpretMode;
                useTex=strcmpi(interpreter,'tex');





                textValue=self.GetValForStr(textKey,sysObject,useTex);
                textNode.Text=textValue;


                textPos=get(h,'Position');
                textTopLeft=self.HGPt2PortalPt(textPos(1:2));
                portalTextTopLeft=textTopLeft.*self.GetPixelsPerNormXY;
                textNode.Position=(portalTextTopLeft+self.Margins(1:2))*self.DeviceScale;


                textNode.Parent=self.OverlayRoot;

            end

        end

        function portalPt=HGPt2PortalPt(~,hgPt)
            portalPt(1)=hgPt(1);
            portalPt(2)=1-hgPt(2);
        end

        function portalRect=GetPortalRectForPatch(self,thisPatchVertex)

            pixelsPerNormXY=self.GetPixelsPerNormXY;

            topLeft=self.HGPt2PortalPt(thisPatchVertex(2,:));
            width=abs(thisPatchVertex(2,1)-thisPatchVertex(3,1));
            height=abs(thisPatchVertex(1,2)-thisPatchVertex(2,2));

            portalRect=[topLeft,width,height].*...
            [pixelsPerNormXY(1),pixelsPerNormXY(2),pixelsPerNormXY(1),pixelsPerNormXY(2)];
            portalRect(1:2)=portalRect(1:2)+self.Margins(1:2);
        end

        function pixelsPerNormXY=GetPixelsPerNormXY(self)
            if(isempty(self.PixelsPerNormXY))
                pixelsPerInch=double(self.Portal.targetScene.DpiX);

                f=self.FigHandle;
                set(f,'PaperUnits','Inches');
                paperPosInches=get(f,'PaperPosition');
                papeSizeInches=get(f,'PaperSize');

                margins=[...
                paperPosInches(1)...
                ,papeSizeInches(2)-paperPosInches(2)-paperPosInches(4)...
                ,papeSizeInches(1)-paperPosInches(1)-paperPosInches(3)...
                ,paperPosInches(2)...
                ];

                if(GLUE2.Portal.spoolPrintableWidth>0&&GLUE2.Portal.spoolPrintableHeight>0)
                    inchesPerNormXY=[GLUE2.Portal.spoolPrintableWidth-margins(1)-margins(3)...
                    ,GLUE2.Portal.spoolPrintableHeight-margins(2)-margins(4)];
                else
                    inchesPerNormXY=paperPosInches(3:4);
                end

                self.PixelsPerNormXY=inchesPerNormXY*pixelsPerInch;
                self.Margins=margins*pixelsPerInch;
            end
            pixelsPerNormXY=self.PixelsPerNormXY;
        end

        function result=GetValForStr(self,str,sysObj,isTex)





            val=cellstr(str);

            frameinfo=self.FrameInfo;

            val=self.EscapeVal(val,'%<page>',num2str(frameinfo.page),isTex);
            val=self.EscapeVal(val,'%<date>',frameinfo.date,isTex);
            val=self.EscapeVal(val,'%<time>',frameinfo.time,isTex);
            val=self.EscapeVal(val,'%<npages>',num2str(frameinfo.npages),isTex);
            val=self.EscapeVal(val,'%<system>',SLPrint.Utils.GetSystemName(sysObj),isTex);
            val=self.EscapeVal(val,'%<fullsystem>',SLPrint.Utils.GetFullSystemName(sysObj),isTex);
            val=self.EscapeVal(val,'%<filename>',SLPrint.Utils.GetFileName(sysObj),isTex);
            val=self.EscapeVal(val,'%<fullfilename>',SLPrint.Utils.GetFullFileName(sysObj),isTex);

            result=val{1};
            for idx=2:numel(val)
                result=sprintf('%s\n%s',result,val{idx});
            end

        end

        function out=EscapeVal(~,in,keyword,val,isTex)

            if isTex

                val=regexprep(val,'([\_\{\}\^\\])','\\$1');
            end

            out=strrep(in,keyword,val);

        end

        function qtPaperTypeOrCustomPaperInfo=HGToQtPaperTypeOrSize(~,hgPaperType)



            qtPaperTypeOrCustomPaperInfo=SLPrint.Printer.SLSFToQtPaperTypeOrSize(hgPaperType);
        end

        function qtOrientation=HGToQtPaperOrientation(~,hgPaperOrientation)



            qtOrientation=SLPrint.Printer.SLSFToQtPaperOrientation(hgPaperOrientation);

        end

    end

end




