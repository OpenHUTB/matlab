function panWeb(arg1,arg2)




    if nargin==0
        firstinput=getCurrentFigure();
        secondinput='toggle';
    elseif(nargin==1)
        if isgraphics(arg1)
            if isgraphics(arg1,'axes')
                error(message('MATLAB:pan:unrecognizedinput'));
            else
                firstinput=arg1;
                secondinput='toggle';
            end
        else
            firstinput=getCurrentFigure();
            secondinput=convertXYOn(arg1);
        end
    else
        firstinput=arg1;
        secondinput=convertXYOn(arg2);
    end

    matlab.graphics.interaction.webmodes.modeHelper('pan',firstinput,secondinput);

    function fig=getCurrentFigure()
        fig=gcf;

        function out=convertXYOn(in)
            out=in;
            switch(in)
            case{'xon','yon','onkeepstyle'}
                out='on';
            case{'xy','x','y','unconstrained'}
                out='noaction';
            end

