classdef PrintJobGateway<handle

    methods(Static)

        function ExecutePrintJob(pj)

            backtrace=warning('query','backtrace');
            warning('backtrace','off');

            try

                if(~SLPrint.Utils.IsFormatSupported(pj))
                    DAStudio.error('Simulink:Printing:UnsupportedFormat',pj.Driver);
                end

                if(SLPrint.Utils.IsPrint(pj))
                    SLPrint.Printer.ExecutePrintJob(pj);
                elseif(SLPrint.Utils.IsClipboard(pj))
                    SLPrint.Clipboard.ExecutePrintJob(pj);
                else
                    SLPrint.Exporter.ExecutePrintJob(pj);
                end

            catch me
                warning(backtrace.state,'backtrace');
                f=SLPrint.PrintFrame.Instance();
                f.Reset();

                switch me.identifier

                case{'Simulink:Printing:InvalidFormatForFramePrinting',...
                    'Simulink:Printing:InvalidFormatForTiledPrinting',...
                    'Simulink:Printing:InvalidExportMode'}
                    disp(me.message);
                otherwise
                    rethrow(me);
                end
            end

            warning(backtrace.state,'backtrace');

        end
    end

end

