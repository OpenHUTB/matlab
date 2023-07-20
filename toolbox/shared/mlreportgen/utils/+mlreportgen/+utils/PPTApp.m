classdef PPTApp<mlreportgen.utils.internal.OfficeApp























    properties(Constant,Hidden)
        Name="Microsoft Powerpoint";
    end

    methods(Static)
        function hApp=instance()







            pptc=mlreportgen.utils.internal.PPTController.instance();
            start(pptc);
            hApp=app(pptc);
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

            pptc=mlreportgen.utils.internal.PPTController.instance();

            tf=false;
            closeFlag=isempty(varargin)||logical(varargin{1});

            hNETObj=netobj(this);
            hPPTs=executeRPC(@()hNETObj.Presentations);

            if~closeFlag
                pptFileNames=filenames(pptc);
                for pptFileName=pptFileNames
                    close(pptc,pptFileName,closeFlag);
                end
            end

            if(~closeFlag||(executeRPC(@()hPPTs.Count==0)))
                executeRPC(@()hNETObj.Quit());

                reset(this,[]);
                hPPTs=[];%#ok
                hNETObj=[];%#ok
                System.GC.Collect();
                System.GC.WaitForPendingFinalizers();
                System.GC.Collect();
                System.GC.WaitForPendingFinalizers();

                tf=mlreportgen.utils.internal.waitFor(...
                @()(double(System.Diagnostics.Process.GetProcessesByName('powerpnt').Length)==0));
            end
        end

        function tf=isVisible(this)




            hNETObj=netobj(this);
            tf=mlreportgen.utils.internal.executeRPC(@()isVisibleNETObj(hNETObj));
        end
    end

    methods(Access=?mlreportgen.utils.internal.PPTController)
        function this=PPTApp()
            this=this@mlreportgen.utils.internal.OfficeApp();

            NET.addAssembly('microsoft.office.interop.PowerPoint');
            NET.addAssembly("system");




            reset(this,Microsoft.Office.Interop.PowerPoint.ApplicationClass());
        end
    end
end


function tf=isVisibleNETObj(hNETObj)
    if(hNETObj.Visible==Microsoft.Office.Core.MsoTriState.msoTrue)

        tf=(hNETObj.WindowState~=Microsoft.Office.Interop.PowerPoint.PpWindowState.ppWindowMinimized);
    else
        tf=false;
    end
end
function showNETObj(hNETObj)
    hNETObj.Visible=Microsoft.Office.Core.MsoTriState.msoTrue;
    hNETObj.Activate()
end

function hideNETObj(hNETObj)
    hNETObj.WindowState=Microsoft.Office.Interop.PowerPoint.PpWindowState.ppWindowMinimized;
end