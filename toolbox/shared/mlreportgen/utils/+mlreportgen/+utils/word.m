classdef word<handle






















    methods(Static)
        function hApp=start()







            wc=wordcontroller();
            hApp=start(wc);
        end

        function hDoc=load(fileName)






            wc=wordcontroller();
            hDoc=load(wc,fileName);
        end

        function hDoc=open(fileName)







            wc=wordcontroller();
            hDoc=open(wc,fileName);
        end

        function tf=close(varargin)




































            wc=wordcontroller();
            tf=close(wc,varargin{:});
        end

        function tf=closeAll(varargin)



















            wc=wordcontroller();
            tf=closeAll(wc,varargin{:});
        end

        function out=show(varargin)









            wc=wordcontroller();
            out=show(wc,varargin{:});
        end

        function out=hide(varargin)









            wc=wordcontroller();
            out=hide(wc,varargin{:});
        end

        function out=filenames()






            wc=wordcontroller();
            out=filenames(wc);
        end

        function tf=isAvailable()







            wc=wordcontroller();
            tf=isAvailable(wc);
        end

        function tf=isStarted()






            wc=wordcontroller();
            tf=isStarted(wc);
        end

        function tf=isLoaded(fileName)







            wc=wordcontroller();
            tf=isLoaded(wc,fileName);
        end

        function hApp=wordapp()






            wc=wordcontroller();
            hApp=app(wc);
        end

        function hDoc=worddoc(fileName)







            wc=wordcontroller();
            hDoc=doc(wc,fileName);
        end
    end

    methods(Hidden,Static)
        function kill()



            processes=System.Diagnostics.Process.GetProcessesByName("winword");
            n=processes.Length;
            for i=1:n
                process=processes.Get(i-1);
                process.Kill();
            end
        end
    end
end

function wc=wordcontroller()
    wc=mlreportgen.utils.internal.WordController.instance();
end

