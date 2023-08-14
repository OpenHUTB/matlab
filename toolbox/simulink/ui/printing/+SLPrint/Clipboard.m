classdef Clipboard<handle

    methods(Static)

        function ExecutePrintJob(pj)

            slSfHandle=pj.Handles{1};
            slSfObj=SLPrint.Utils.GetSLSFObject(slSfHandle);

            p=SLPrint.Utils.GetPortal(slSfObj);
            p.clipboardOptions=SLPrint.Clipboard.PrintJob2ClipboardOptions(pj);
            p.targetScene.Background.Color=SLPrint.Utils.GetBGColor(slSfObj);

            if(SLPrint.Utils.IsSimulink(slSfObj))
                p.toClipboard();
            else
                inSFCurrentView=isfield(pj,'sfCurrentView')&&pj.sfCurrentView;
                if(inSFCurrentView)
                    canvas=SLPrint.Utils.GetLastActiveSFEditorCanvasFor(slSfObj);
                    p.toClipboard(canvas);
                else
                    p.toClipboard();
                end
            end

        end


        function clipboardOptions=PrintJob2ClipboardOptions(pj)

            clipboardOptions=GLUE2.PortalClipboardOptions;

            if(strncmpi(pj.Driver,'meta',4))
                clipboardOptions.format='META';

                clipboardOptions.EMFGenType=4;
            elseif(strncmpi(pj.Driver,'bitmap',6))
                clipboardOptions.format='BITMAP';
            end

        end
    end

end


