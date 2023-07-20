classdef Color



    properties(SetAccess=immutable)
        R;
        G;
        B;
    end

    enumeration
        red(.9,0,0)
        green(0,.82,0)
        blue(0,0,.8)
        cyan(0,.82,.82)
        magenta(1,.26,.82)
        yellow(.91,.82,.32)
        black(0,0,0)
        white(1,1,1)
        gray(.5,.5,.5)
        orange(1,.5,0)
        lightblue(.38,.74,.99)
        darkgreen(.42,.59,.24)
        automatic(1,1,1)
        brown(.65,.17,.17)
        purple(.5,0,.5)
        darkblue(0,0,.4)
    end

    methods
        function this=Color(r,g,b)
            this.R=r;
            this.G=g;
            this.B=b;
        end
    end

    methods(Static)
        function rgb=getRGB(definedColor)
            out=SLPrint.Color.(lower(definedColor));
            rgb=[out.R,out.G,out.B];
        end
    end
end


