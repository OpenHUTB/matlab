















classdef EngineInterfaceVal
    methods(Static)
        function ret=byFiat
            persistent sd;
            ret=1001;
            [st,~]=dbstack('-completenames',1);






            if isempty(st)
                if isempty(sd)
                    rng('shuffle');
                    sd=1;
                end
                ret=2000+round(rand*30000);
                return
            end


            insideMatlabRoot=false;
            for i=1:numel(st)
                if exist('polyspaceroot','file')
                    productroot={matlabroot,polyspaceroot};
                else
                    productroot=matlabroot;
                end
                if contains(st(i).file,productroot)
                    insideMatlabRoot=true;
                    break
                end
            end
            if~insideMatlabRoot
                if isempty(sd)
                    rng('shuffle');
                    sd=1;
                end
                ret=2000+round(rand*30000);
            end
        end



        function ret=fixedPoint
            ret=1;
        end
        function ret=sldo
            ret=2;
        end
        function ret=slvv
            ret=3;
        end
        function ret=hdl
            ret=4;
        end
        function ret=plc
            ret=5;
        end
        function ret=sldv
            ret=6;
        end
        function ret=slrt
            ret=7;
        end
        function ret=simulinkTest
            ret=8;
        end
        function ret=embeddedCoder
            ret=9;
        end
        function ret=simulinkCoder
            ret=10;
        end



        function ret=slci
            ret=12;
        end

        function ret=slcheck
            ret=13;
        end
    end
end
