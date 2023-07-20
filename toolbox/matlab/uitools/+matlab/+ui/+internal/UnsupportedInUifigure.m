function UnsupportedInUifigure(comps)









    if feature('WebGraphicsRestriction')

        w=warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
        c1=onCleanup(@()warning(w));


        [lastmsg,lastid]=lastwarn;
        c2=onCleanup(@()lastwarn(lastmsg,lastid));


        for i=1:length(comps)
            comp=comps(i);
            if ishghandle(comp)
                fig=ancestor(comp,'figure');
                if matlab.ui.internal.isUIFigure(fig)
                    ex=MException(message('MATLAB:ui:uifigure:UnsupportedAppDesignerFunctionality','uifigure'));
                    throwAsCaller(ex);
                end
            end
        end

    end

end
