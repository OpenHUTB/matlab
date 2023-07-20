function modeFunctionHelper(varargin)

    modename=varargin{1};
    if nargin==1
        firstinput=getCurrentFigure();
        secondinput='toggle';
    elseif(nargin==2)
        if isgraphics(varargin{2})
            if isgraphics(varargin{2},'axes')
                error(message('MATLAB:graphics:interaction:IncorrectNumberArguments'));
            else
                firstinput=varargin{2};
                secondinput='toggle';
            end
        else
            firstinput=getCurrentFigure();
            secondinput=varargin{2};
        end
    elseif(nargin==3)
        firstinput=varargin{2};
        secondinput=varargin{3};
    else
        error(message('MATLAB:graphics:interaction:IncorrectNumberArguments'));
    end

    matlab.graphics.interaction.webmodes.modeHelper(modename,firstinput,secondinput);

    function fig=getCurrentFigure()
        fig=gcf;
