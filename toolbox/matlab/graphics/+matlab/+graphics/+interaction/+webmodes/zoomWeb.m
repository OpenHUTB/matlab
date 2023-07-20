function zoomWeb(arg1,arg2)




    if nargin==0
        firstinput=getCurrentFigure();
        secondinput='toggle';
    elseif(nargin==1)
        if isnumeric(arg1)
            fig=getCurrentFigure();
            ax=findall(fig,'Type','axes');
            zoomAxesVectorAroundPoint(ax,arg1);
            return;
        elseif isgraphics(arg1)
            if isgraphics(arg1,'axes')
                error(message('MATLAB:pan:unrecognizedinput'));
            else
                firstinput=arg1;
                secondinput='toggle';
            end
        else
            switch(arg1)
            case{'out','fill'}
                fig=getCurrentFigure();
                resetplotlimits(fig);
                return;
            case 'reset'
                fig=getCurrentFigure();
                ax=findall(fig,'Type','axes');
                matlab.graphics.interaction.internal.saveView(ax);
                matlab.graphics.interaction.internal.initializeView(ax);
                return;
            otherwise
                firstinput=getCurrentFigure();
                secondinput=convertXYOn(arg1);
            end
        end
    elseif nargin==2
        if isnumeric(arg2)
            ax=arg1;
            if isgraphics(arg1,'figure')
                ax=findall(arg1,'Type','axes');
            end
            zoomAxesVectorAroundPoint(ax,arg2);
            return;
        else
            switch(arg2)
            case{'out','fill'}
                if isgraphics(arg1,'figure')
                    resetplotlimits(arg1);
                    return
                elseif isgraphics(arg1,'axes')
                    resetplotview(arg1,'ApplyStoredView');
                    return;
                end
            case 'reset'
                if isgraphics(arg1,'figure')
                    fig=arg1;
                    ax=findall(fig,'Type','axes');
                    matlab.graphics.interaction.internal.saveView(ax);
                    matlab.graphics.interaction.internal.initializeView(ax);
                    return;
                elseif isgraphics(arg1,'axes')
                    ax=arg1;
                    matlab.graphics.interaction.internal.saveView(ax);
                    matlab.graphics.interaction.internal.initializeView(ax);
                    return;
                end
            otherwise
                firstinput=arg1;
                secondinput=convertXYOn(arg2);
            end
        end
    end

    matlab.graphics.interaction.webmodes.modeHelper('zoom',firstinput,secondinput);

    function fig=getCurrentFigure()
        fig=gcf;

        function out=convertXYOn(in)
            out=in;
            switch(in)
            case{'xon','yon','inmode','inmodex','inmodey'}
                out='on';
            case{'outmode','fill'}
                out='noaction';
            end

            function resetplotlimits(fig)
                ax=findall(fig,'Type','axes');
                for i=1:numel(ax)
                    resetplotview(ax(i),'ApplyStoredView');
                end

                function zoomAxesVectorAroundPoint(ax,val)
                    if(val>0)&&isfinite(val)
                        for i=1:numel(ax)
                            zoomAroundPoint(ax(i),val);
                        end
                    end

                    function zoomAroundPoint(obj,val)
                        drawnow nocallbacks

                        matlab.graphics.interaction.internal.initializeView(obj);
                        new_lims=matlab.graphics.interaction.internal.zoom.zoomAxisAroundPoint([0,1],0.5,val);
                        [x,y,z]=matlab.graphics.interaction.internal.UntransformLimits(obj.ActiveDataSpace,new_lims,new_lims,new_lims);
                        bounds=matlab.graphics.interaction.internal.getBounds(obj,true);
                        [new_xlim,new_ylim,new_zlim]=matlab.graphics.interaction.internal.boundLimitsAllAxes([x,y,z],bounds,false);


                        if is2D(obj)
                            matlab.graphics.interaction.validateAndSetLimits(obj,new_xlim,new_ylim);
                        else
                            matlab.graphics.interaction.validateAndSetLimits(obj,new_xlim,new_ylim,new_zlim);
                        end