function addFigure(h,f,mfile,fcnname)


    if~ishghandle(f)
        return
    end
    if~isempty(h.Figures)
        h.Figures(~ishghandle([h.Figures.Figure]))=[];
    end

    if isempty(h.Figures)||~any([h.Figures.('Figure')]==f)

        if isempty(f.findprop('LinkPlot'))
            p=addprop(f,'LinkPlot');
            p.Transient=true;
        end
        set(f,'LinkPlot',true);

        figStruct=struct('Figure',f,'Panel',{[]},'VarNames',{{}},'SubsStr',{{}},'LinkedGraphics',{[]},...
        'FigureListeners',{[]},'EventManager',{[]},'DisplayNameListeners',{[]},...
        'CloseListeners',{[]},'SourceDialog',[],'IsEmpty',[],'Dirty',false);
        h.Figures=[h.Figures(:);figStruct];
        ind=length(h.Figures);
    else
        ind=find([h.Figures.('Figure')]==f);
    end
    figStruct=h.updateLinkedGraphics(ind(1));
    h.LinkListener.postRefresh;



    if isempty(figStruct)
        return
    end

    if h.doShowJavaLinkedPlotDialog()






        f.getCanvas();
        h.createlinkpanel(f);
        h.Figures(ind(1)).Panel.open;
    end



    localAddFigCloseListener(f,h,ind(1));

    if h.doShowJavaLinkedPlotDialog()


        pause(0.2);
    end


    h.drawBrushing(ind(1),mfile,fcnname);


    h.installGraphicListeners(f);


    h.setEnabled('on');

    function localAddFigCloseListener(f,h,ind)

        h.Figures(ind).CloseListeners=...
        addlistener(f,'ObjectBeingDestroyed',@(es,ed)rmFigure(h,handle(es)));
