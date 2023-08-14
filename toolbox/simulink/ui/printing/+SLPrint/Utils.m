classdef Utils<handle



    methods(Static)

        function ret=IsFormatSupported(pj)

            persistent unsupportedFormats;


            if(isempty(unsupportedFormats))
                unsupportedFormats={'hdf','hpgl','pcx16','pcx24b','pcx256',...
                'ljet2p','ljet3','deskjet','paintjet','cdj550',...
                'ljetplus','laserjet','cdjcolor','cdjmono','pxlmono',...
                'ljet4','pjetx','pjxl','pjxl300','ibmpro',...
                'epsonc','epson','cdj500','bj200','bjc600',...
                'bjc800','bj10e','dnj650c','eps9high','pkm',...
                'pkmraw','ill','tifflzw'};
            end

            ret=~any(strcmpi(pj.Driver,unsupportedFormats));

        end


        function ret=IsPrint(pj)




            ret=false;

            if(pj.Verbose)
                ret=true;
                return;
            end


            if(~isempty(pj.PrinterName))
                ret=true;
                return;
            end


            if(strncmpi(pj.Driver,'win',3)||strncmpi(pj.Driver,'winc',4))
                ret=true;
                return;
            end


            if(strcmpi(pj.Driver,'pdfe'))
                return;
            end


            if(strncmpi(pj.Driver,'pdf',3))
                ret=true;
                return;
            end


            if(isempty(pj.Driver)&&isempty(pj.FileName))
                ret=true;
                return;
            end

        end


        function ret=IsClipboard(pj)

            ret=false;

            if(ispc)
                ret=isempty(pj.FileName)&&...
                (strncmpi(pj.Driver,'meta',4)||strncmpi(pj.Driver,'bitmap',6));
            end

        end


        function mode=GetMode(pj,slSfObj)



            if pj.TiledPrint
                mode='tiled';
            elseif pj.FramePrint
                mode='frame';
            else
                mode='auto';
            end
        end

        function colorMode=GetColorMode(pj)

            colorMode='Color';

        end

        function p=GetPortal(slSfObj)

            p=GLUE2.Portal;
            p.pathXStyle=get_param(0,'EditorPathXStyle');
            domain=SLPrint.Utils.GetDomain(slSfObj);
            p.setTarget(domain,slSfObj);



        end

        function domain=GetDomain(slSfObj)

            if(SLPrint.Utils.IsSimulink(slSfObj))
                domain='Simulink';
            elseif(SLPrint.Utils.IsStateflow(slSfObj))
                domain='Stateflow';
            end

        end

        function bgColor=GetBGColor(slSfObj)

            if(SLPrint.Utils.IsStateflow(slSfObj))
                chart=slSfObj;
                if(~isa(chart,'Stateflow.Chart')&&...
                    ~isa(chart,'Stateflow.StateTransitionTableChart')&&...
                    ~isa(chart,'Stateflow.ReactiveTestingTableChart')&&...
                    ~isa(chart,'Stateflow.TruthTableChart'))
                    chart=slSfObj.Chart;
                end
                bgColor=chart.ChartColor;
            else
                screenColor=slSfObj.ScreenColor;
                if(~isempty(regexp(screenColor,'\d+','once')))
                    bgColor=str2num(screenColor);%#ok<ST2NM>
                else
                    bgColor=SLPrint.Color.getRGB(screenColor);
                end
            end

            bgColor=[bgColor,1];

        end

        function retVal=SLSFGet(slsfObj,propName)






            if(SLPrint.Utils.IsStateflow(slsfObj))
                if(isValidProperty(slsfObj,propName))
                    retVal=get(slsfObj,propName);
                else
                    chartObj=get(slsfObj,'Chart');
                    retVal=get(chartObj,propName);
                end
            else
                retVal=get(slsfObj,propName);
            end

        end

        function SLSFSet(slsfObj,propName,propVal)






            if(SLPrint.Utils.IsStateflow(slsfObj))
                if(isa(slsfObj,'Stateflow.Chart'))
                    chartObj=slsfObj;
                else
                    chartObj=slsfObj.Chart;
                end
                chartSubsysHandle=chartObj.up.Handle;



                set_param(chartSubsysHandle,propName,propVal);
            else

                set_param(slsfObj.Handle,propName,propVal);
            end

        end

        function slBlkDiagObj=GetSLBDObj(slSfObj)




            slBlkDiagObj=slSfObj;
            if(~isa(slSfObj,'Simulink.BlockDiagram'))
                while(true)
                    tmpObj=slSfObj.up;
                    if(isa(tmpObj,'Simulink.BlockDiagram'))
                        slBlkDiagObj=tmpObj;
                        break;
                    else
                        slSfObj=tmpObj;
                    end
                end
            end

        end

        function slSfObj=GetSLSFObject(h)

            if is_simulink_handle(h)

                slSfObj=get_param(h,'Object');
            else

                root=sfroot;
                slSfObj=root.find('id',h);
            end

        end

        function[offset,scale]=GetOffsetAndScaleToFitWithAspectRatio(srcBounds,dstBounds)

            srcAspect=srcBounds(3)/srcBounds(4);
            dstAspect=dstBounds(3)/dstBounds(4);

            if(srcAspect>dstAspect)
                scale=dstBounds(3)/srcBounds(3);
            else
                scale=dstBounds(4)/srcBounds(4);
            end

            offset=[(dstBounds(3)-scale*srcBounds(3))/2,(dstBounds(4)-scale*srcBounds(4))/2];

        end

        function retVal=GetScreenPixelsPerPoint

            retVal=SLPrint.Utils.GetScreenPixelsPerInch/72;


        end

        function retVal=GetScreenPixelsPerInch

            retVal=get(0,'ScreenPixelsPerInch');

        end

        function retVal=GetSLScreenPixelsPerInch

            retVal=72;

        end

        function canvas=GetLastActiveSLEditorCanvasFor(slObj)

            handle=slObj.Handle;
            editor=SLM3I.SLDomain.getLastActiveEditorFor(handle);
            canvas=editor.getCanvas;

        end

        function canvas=GetLastActiveSFEditorCanvasFor(sfObj)

            id=sfObj.Id;
            editor=StateflowDI.SFDomain.getLastActiveEditorFor(id);
            canvas=editor.getCanvas;

        end

        function ret=IsStateflow(slSfObj)

            ret=isa(slSfObj,'Stateflow.Object');

        end

        function ret=IsSimulink(slSfObj)

            ret=isa(slSfObj,'Simulink.Object');

        end

        function[oldPaperUnits,bdDirty,bdLock]=ChangePaperUnits(slSfObj,newUnits)


            bdRootObj=SLPrint.Utils.GetSLBDObj(slSfObj);


            bdDirty=bdRootObj.Dirty;
            bdLock=bdRootObj.Lock;
            oldPaperUnits=SLPrint.Utils.SLSFGet(slSfObj,'PaperUnits');


            bdRootObj.Lock='off';
            SLPrint.Utils.SLSFSet(slSfObj,'PaperUnits',newUnits);

        end

        function RestorePaperUnits(slSfObj,oldPaperUnits,bdDirty,bdLock)

            bdRootObj=SLPrint.Utils.GetSLBDObj(slSfObj);

            SLPrint.Utils.SLSFSet(slSfObj,'PaperUnits',oldPaperUnits);
            bdRootObj.Dirty=bdDirty;
            bdRootObj.Lock=bdLock;

        end

        function name=GetSystemName(slSfObj)


            name=slSfObj.Name;
            name=strrep(name,char(10),' ');

        end

        function name=GetFullSystemName(slSfObj)


            name='';
            if(SLPrint.Utils.IsSimulink(slSfObj))
                name=slSfObj.Path;
                if(~strcmp(slSfObj.Name,slSfObj.Path))
                    name=[slSfObj.Path,'/',slSfObj.Name];
                end
            elseif(SLPrint.Utils.IsStateflow(slSfObj))


                if(isa(slSfObj,'Stateflow.Chart'))
                    name=slSfObj.Path;
                else


                    name=[slSfObj.Path,'.',slSfObj.Name];
                end
            end
            name=strrep(name,char(10),' ');

        end

        function name=GetFileName(slSfObj)


            fullFileName=SLPrint.Utils.GetFullFileName(slSfObj);
            [~,base,ext]=fileparts(fullFileName);
            name=[base,ext];

        end

        function name=GetFullFileName(slSfObj)



            if(isa(slSfObj,'Simulink.BlockDiagram'))
                name=slSfObj.FileName;
            else
                upObj=slSfObj.up;
                bdObj=SLPrint.Utils.GetSLBDObj(upObj);
                name=bdObj.FileName;
            end

        end

        function netBounds=UnionBounds(bounds,anotherBounds)

            netBounds=bounds;

            if(anotherBounds(3)<=0||anotherBounds(4)<=0)
                return;
            end

            left=min(bounds(1),anotherBounds(1));
            top=min(bounds(2),anotherBounds(2));

            right=max(bounds(1)+bounds(3),anotherBounds(1)+anotherBounds(3));
            bottom=max(bounds(2)+bounds(4),anotherBounds(2)+anotherBounds(4));

            netBounds=[left,top,right-left,bottom-top];
        end

        function fontName=GetDefaultFont
            if(strncmpi(get(0,'language'),'ja',2))
                fontName='MS UI Gothic';
            else
                fontName='Helvetica';
            end
        end


        function padding=getDefaultPadding()

            padding=[5,5,5,5];
        end



    end

end


