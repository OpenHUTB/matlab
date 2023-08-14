classdef powerpoint<handle






















    methods(Static)
        function hApp=start()







            pptc=pptcontroller();
            hApp=start(pptc);
        end

        function hPres=load(fileName)






            pptc=pptcontroller();
            hPres=load(pptc,fileName);
        end

        function hPres=open(fileName)







            pptc=pptcontroller();
            hPres=open(pptc,fileName);
        end

        function tf=close(varargin)






































            pptc=pptcontroller();
            tf=close(pptc,varargin{:});
        end

        function tf=closeAll(varargin)




















            pptc=pptcontroller();
            tf=closeAll(pptc,varargin{:});
        end

        function out=show(varargin)










            pptc=pptcontroller();
            out=show(pptc,varargin{:});
        end

        function out=hide(varargin)











            pptc=pptcontroller();
            out=hide(pptc,varargin{:});
        end

        function out=filenames()






            pptc=pptcontroller();
            out=filenames(pptc);
        end

        function tf=isAvailable()







            pptc=pptcontroller();
            tf=isAvailable(pptc);
        end

        function tf=isStarted()







            pptc=pptcontroller();
            tf=isStarted(pptc);
        end

        function tf=isLoaded(fileName)







            pptc=pptcontroller();
            tf=isLoaded(pptc,fileName);
        end

        function hApp=pptapp()







            pptc=pptcontroller();
            hApp=app(pptc);
        end

        function hPres=pptpres(fileName)







            pptc=pptcontroller();
            hPres=doc(pptc,fileName);
        end
    end

    methods(Hidden,Static)
        function kill()



            processes=System.Diagnostics.Process.GetProcessesByName("powerpnt");
            n=processes.Length;
            for i=1:n
                process=processes.Get(i-1);
                process.Kill();
            end
        end
    end
end

function pptc=pptcontroller()
    pptc=mlreportgen.utils.internal.PPTController.instance();
end

