classdef WordApp<mlreportgen.utils.internal.OfficeApp























    properties(Constant,Hidden)
        Name="Microsoft Word";
    end

    methods(Static)
        function hApp=instance()







            wc=mlreportgen.utils.internal.WordController.instance();
            start(wc);
            hApp=app(wc);
        end
    end

    methods
        function show(this)



            hNETObj=netobj(this);
            mlreportgen.utils.internal.executeRPC(@()showNETObj(hNETObj));
        end

        function hide(this)



            hNETObj=netobj(this);
            mlreportgen.utils.internal.executeRPC(@()hideNETObj(hNETObj));
        end

        function tf=close(this,varargin)















            import mlreportgen.utils.internal.executeRPC

            wc=mlreportgen.utils.internal.WordController.instance();

            tf=false;
            closeFlag=isempty(varargin)||logical(varargin{1});

            hNETObj=netobj(this);
            hDocs=executeRPC(@()hNETObj.Documents);

            if~closeFlag
                docFileNames=filenames(wc);
                for docFileName=docFileNames
                    close(wc,docFileName,closeFlag);
                end
            end

            if(~closeFlag||executeRPC(@()(hDocs.Count==0)))
                executeRPC(@()quitNETObj(hNETObj));
                reset(this,[]);
                hNETObj=[];%#ok
                hDocs=[];%#ok
                System.GC.Collect();
                System.GC.WaitForPendingFinalizers();
                System.GC.Collect();
                System.GC.WaitForPendingFinalizers();

                tf=mlreportgen.utils.internal.waitFor(...
                @()(double(System.Diagnostics.Process.GetProcessesByName('winword').Length)==0));
            end
        end

        function tf=isVisible(this)




            hNetObj=netobj(this);
            tf=mlreportgen.utils.internal.executeRPC(@()hNetObj.Visible);
        end
    end

    methods(Access=?mlreportgen.utils.internal.WordController)
        function this=WordApp()
            this=this@mlreportgen.utils.internal.OfficeApp();

            NET.addAssembly("microsoft.office.interop.word");
            NET.addAssembly("system");

            hNETObj=[];

            wordProcesses=System.Diagnostics.Process.GetProcessesByName('winword');
            n=wordProcesses.Length;
            if(n>0)
                wordProcess=wordProcesses(1);
                matlabProcess=System.Diagnostics.Process.GetCurrentProcess;
                matlabHWND=matlabProcess.MainWindowHandle.ToInt64;

                tries=0;
                maxTries=10;
                while(tries<maxTries)

                    try
                        tries=tries+1;
                        hNETObj=System.Runtime.InteropServices.Marshal.GetActiveObject('Word.Application');
                        break;
                    catch
                        wordHWND=wordProcess.MainWindowHandle.ToInt64;
                        mlreportgen.utils.internal.bringWindowToFront(wordHWND);
                        pause(1);
                        mlreportgen.utils.internal.bringWindowToFront(matlabHWND);
                    end
                end
            end

            if isempty(hNETObj)

                hNETObj=Microsoft.Office.Interop.Word.ApplicationClass();
            elseif~isa(hNETObj,'Microsoft.Office.Interop.Word.ApplicationClass')

                hNETObj=Microsoft.Office.Interop.Word.Application(hNETObj);
            end
            reset(this,hNETObj);
        end
    end
end

function quitNETObj(hNETObj)
    mlreportgen.utils.internal.waitFor(...
    @()(~hNETObj.BackgroundSavingStatus&&~hNETObj.BackgroundPrintingStatus));
    hNETObj.Quit();
end

function showNETObj(hNETObj)
    hNETObj.Visible=true;
    hNETObj.Activate();
end

function hideNETObj(hNETObj)
    hNETObj.Visible=false;
end

