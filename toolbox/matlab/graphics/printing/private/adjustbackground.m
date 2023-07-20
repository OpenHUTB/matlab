function adjustbackground(state,fig)























    persistent SaveTonerOriginalColors;

    if nargin==0...
        ||~ischar(state)...
        ||~(strcmp(state,'save')||strcmp(state,'restore'))
        error(message('MATLAB:adjustbackground:NeedsMoreInfo'))
    elseif nargin==1
        fig=gcf;
    end

    NONE=[NaN,NaN,0];
    FLAT=[NaN,0,NaN];
    BLACK=[0,0,0];
    WHITE=[1,1,1];

    useLatestHGPrinting=~useOriginalHGPrinting(fig);
    if useLatestHGPrinting
        findobjFcn=@findobjinternal;
    else
        findobjFcn=@findobj;
    end


    AXESCOLOR_IDX=1;
    AXESXCOLOR_IDX=4;
    AXESYCOLOR_IDX=7;
    AXESZCOLOR_IDX=10;
    AXESCORECOLOREND_IDX=12;
    GRIDCOLOR_IDX=13;
    MINORGRIDCOLOR_IDX=16;
    AXESCOLOR_COUNT=18;


    XCOLORMODE_IDX=1;
    YCOLORMODE_IDX=2;
    ZCOLORMODE_IDX=3;
    GRIDCOLORMODE_IDX=4;
    MINORGRIDCOLORMODE_IDX=5;
    AXESMODE_COUNT=5;

    if strcmp(state,'save')


        storage.useLatestHGPrinting=useLatestHGPrinting;
        origFigColor=get(fig,'color');
        saveOrigFigColor=get(fig,'color');

        if isequal(get(fig,'color'),'none')
            saveOrigFigColor=[NaN,NaN,NaN];
        end

        origFigWhite=0;
        if isequal(WHITE,saveOrigFigColor)
            origFigWhite=1;
        end


        count.color=0;
        count.facecolor=0;
        count.edgecolor=0;
        count.markeredgecolor=0;
        count.markerfacecolor=0;

        if~storage.useLatestHGPrinting
            allAxes=findobjFcn(fig,'type','axes','-or','type','polaraxes',...
            '-or','type','legend','-or','type','colorbar');
            storage.colorbars=[];
        else

            allAxes=findobjFcn(fig,'type','axes','-or','type','polaraxes',...
            '-or','type','legend');
            allColorbar=findobjFcn(fig,'type','colorbar');


            [allAxes,allColorbar]=...
            matlab.graphics.chart.internal.removeChartChildren(allAxes,allColorbar);




            ncolorbars=length(allColorbar);
            storage.colorbars=repmat({[],zeros(1,1)},ncolorbars,1);

            for cbidx=1:length(allColorbar)
                cb=allColorbar(cbidx);
                cbcolor=color2matrix(get(cb,'Color'));
                storage.colorbars(cbidx,:)={cb,cbcolor};
                if isequal(cbcolor,origFigColor)
                    setGraphicsProperty(cb,'color',WHITE,...
                    storage.useLatestHGPrinting);
                elseif isequal(cbcolor,WHITE)
                    setGraphicsProperty(cb,'color',BLACK,...
                    storage.useLatestHGPrinting);
                end
            end
        end


        allHeatmaps=findall(fig,'-isa','matlab.graphics.chart.HeatmapChart');
        nHeatmaps=length(allHeatmaps);
        storage.heatmaps=cell(nHeatmaps,2);
        for hidx=1:nHeatmaps
            h=allHeatmaps(hidx);
            fontColor=h.FontColor;
            storage.heatmaps{hidx,1}=h;
            storage.heatmaps{hidx,2}=fontColor;
            if isequal(fontColor,origFigColor)
                h.FontColor=WHITE;
            elseif isequal(fontColor,WHITE)
                h.FontColor=BLACK;
            end
        end


        allSubplotText=findall(fig,'-isa','matlab.graphics.illustration.subplot.Text');
        nSubplotText=length(allSubplotText);
        storage.subplotTexts=cell(nSubplotText,2);
        for stIdx=1:nSubplotText
            t=allSubplotText(stIdx);
            color=t.Color;
            storage.subplotTexts{stIdx,1}=t;
            storage.subplotTexts{stIdx,2}=color;
            if isequal(color,origFigColor)
                t.Color=WHITE;
            elseif isequal(color,WHITE)
                t.Color=BLACK;
            end
        end



        for axnum=length(allAxes):-1:1
            if~isprop(allAxes(axnum),'Color')
                allAxes(axnum)=[];
            end
        end

        naxes=length(allAxes);
        for axnum=1:naxes
            a=allAxes(axnum);
            origAxesColor=get(a,'color');
            if isa(a,'matlab.graphics.illustration.Legend')&&...
                ~isempty(a.Title_I)&&isvalid(a.Title_I)
                chil=a.Title;
            else
                chil=allchild(a);
            end

            axesVisible=strcmp(get(a,'visible'),'on');


            if isempty(chil)||(axesVisible&&isequal(origAxesColor,WHITE))...
                ||((~axesVisible||strcmp(origAxesColor,'none'))&&origFigWhite)


            else


                if~axesVisible||strcmp(origAxesColor,'none')
                    bkgrndColor=origFigColor;
                else
                    bkgrndColor=origAxesColor;
                end

                count.color=count.color+length(findobjFcn(chil,'color',WHITE,'Visible','on'));
                count.facecolor=count.facecolor+length(findobjFcn(chil,'facecolor',WHITE,'Visible','on'));
                count.edgecolor=count.edgecolor+length(findobjFcn(chil,'edgecolor',WHITE,'Visible','on'));
                count.markeredgecolor=count.markeredgecolor+length(findobjFcn(chil,'markeredgecolor',WHITE,'Visible','on'));
                count.markerfacecolor=count.markerfacecolor+length(findobjFcn(chil,'markerfacecolor',WHITE,'Visible','on'));

                count.color=count.color+length(findobjFcn(chil,'color',bkgrndColor,'Visible','on'));
                count.facecolor=count.facecolor+length(findobjFcn(chil,'facecolor',bkgrndColor,'Visible','on'));
                count.edgecolor=count.edgecolor+length(findobjFcn(chil,'edgecolor',bkgrndColor,'Visible','on'));
                count.markeredgecolor=count.markeredgecolor+length(findobjFcn(chil,'markeredgecolor',bkgrndColor,'Visible','on'));
                count.markerfacecolor=count.markerfacecolor+length(findobjFcn(chil,'markerfacecolor',bkgrndColor,'Visible','on'));
            end





            if~origFigWhite&&isprop(a,'XLabel_IS')&&isprop(a,'YLabel_IS')...
                &&isprop(a,'ZLabel_IS')&&isprop(a,'Title_IS')


                count.color=count.color+length(findobjFcn(...
                [get(a,'XLabel_IS'),get(a,'YLabel_IS'),get(a,'ZLabel_IS'),get(a,'Title_IS')],...
                '-depth',0,'color',WHITE,'Visible','on')');


                count.color=count.color+length(findobjFcn(...
                [get(a,'XLabel_IS'),get(a,'YLabel_IS'),get(a,'ZLabel_IS'),get(a,'Title_IS')],...
                '-depth',0,'color',origFigColor,'Visible','on')');
            end

        end



        storage.figure={fig,saveOrigFigColor};




        storage.axes=repmat({[],zeros(1,AXESCOLOR_COUNT)},naxes,1);


        storage.axesModes=repmat({''},naxes,AXESMODE_COUNT);





        storage.color=repmat({[],zeros(1,3)},count.color,1);
        storage.facecolor=repmat({[],zeros(1,3)},count.facecolor,1);
        storage.edgecolor=repmat({[],zeros(1,3)},count.edgecolor,1);
        storage.markeredgecolor=repmat({[],zeros(1,3)},count.markeredgecolor,1);
        storage.markerfacecolor=repmat({[],zeros(1,3)},count.markerfacecolor,1);



        turnMe.color=repmat({[],zeros(1,3)},count.color,1);
        turnMe.facecolor=repmat({[],zeros(1,3)},count.facecolor,1);
        turnMe.edgecolor=repmat({[],zeros(1,3)},count.edgecolor,1);
        turnMe.markeredgecolor=repmat({[],zeros(1,3)},count.markeredgecolor,1);
        turnMe.markerfacecolor=repmat({[],zeros(1,3)},count.markerfacecolor,1);


        idx.color=1;
        idx.facecolor=1;
        idx.edgecolor=1;
        idx.markeredgecolor=1;
        idx.markerfacecolor=1;

        for axnum=1:naxes
            a=allAxes(axnum);
            if isa(a,'matlab.graphics.illustration.Legend')&&...
                ~isempty(a.Title_I)&&isvalid(a.Title_I)
                chil=a.Title;
            else
                chil=allchild(a);
            end
            thisBaselineParent=findall(a,'-property','BaseLine','ShowBaseline','on');
            if~isempty(thisBaselineParent)&&length(thisBaselineParent)>1
                thisBaselineParent=thisBaselineParent(1);
            end
            if~isempty(thisBaselineParent)
                theBaseline=get(thisBaselineParent,'BaseLine');
                if~isempty(theBaseline)
                    chil(end+1,1)=theBaseline;%#ok<AGROW>
                end
            end


            axc=[];
            ayc=[];
            azc=[];
            axesVisible=strcmp(get(a,'visible'),'on');
            origAxesColor=get(a,'color');
            if isprop(a,'XColor')&&isprop(a,'YColor')&&isprop(a,'ZColor')
                axc=get(a,'XColor');
                ayc=get(a,'YColor');
                azc=get(a,'ZColor');
                if storage.useLatestHGPrinting
                    axcm=get(a,'XColorMode');
                    aycm=get(a,'YColorMode');
                    azcm=get(a,'ZColorMode');
                end
            elseif isprop(a,'EdgeColor')&&isprop(a,'TextColor')


                axc=get(a,'Color');
                ayc=get(a,'EdgeColor');
                azc=get(a,'TextColor');
                if storage.useLatestHGPrinting
                    axcm=get(a,'ColorMode');
                    aycm=get(a,'EdgeColorMode');
                    azcm=get(a,'TextColorMode');
                end
            end

            aXYZc=[0,0,0,0,0,0,0,0,0];
            if~isempty([axc,ayc,azc])
                aXYZc=[color2matrix(axc),color2matrix(ayc),color2matrix(azc)];
                if storage.useLatestHGPrinting
                    storage.axesModes(axnum,XCOLORMODE_IDX:ZCOLORMODE_IDX)={axcm,aycm,azcm};
                end
            end
            storage.axes{axnum,1}=a;
            storage.axes{axnum,2}(1:AXESCORECOLOREND_IDX)=[color2matrix(origAxesColor),aXYZc];

            if isa(a,'matlab.graphics.axis.AbstractAxes')

                storage.axes{axnum,2}(GRIDCOLOR_IDX:GRIDCOLOR_IDX+2)=color2matrix(a.GridColor);
                storage.axes{axnum,2}(MINORGRIDCOLOR_IDX:MINORGRIDCOLOR_IDX+2)=color2matrix(a.MinorGridColor);
                storage.axesModes{axnum,GRIDCOLORMODE_IDX}=a.GridColorMode;
                storage.axesModes{axnum,MINORGRIDCOLORMODE_IDX}=a.MinorGridColorMode;
            end


            if~axesVisible||strcmp(origAxesColor,'none')
                bkgrndColor=origFigColor;
            else
                bkgrndColor=origAxesColor;
            end


            if(axesVisible&&isequal(origAxesColor,WHITE))...
                ||((~axesVisible||strcmp(origAxesColor,'none'))&&origFigWhite)


            else



                if(~strcmp(origAxesColor,'none'))
                    setGraphicsProperty(a,'color',WHITE,...
                    storage.useLatestHGPrinting)
                end

                for obj=findobjFcn(chil,'color',WHITE,'Visible','on')'
                    storage.color(idx.color,:)={obj,WHITE};
                    turnMe.color(idx.color,:)={obj,BLACK};
                    idx.color=idx.color+1;
                end

                for obj=findobjFcn(chil,'color',bkgrndColor,'Visible','on')'
                    storage.color(idx.color,:)={obj,bkgrndColor};
                    turnMe.color(idx.color,:)={obj,WHITE};
                    idx.color=idx.color+1;
                end


                for obj=findobjFcn(chil,'type','surface','-or',...
                    'type','patch','-or',...
                    'type','rectangle','-or',...
                    'type','area','-or',...
                    'type','bar','-or',...
                    'type','ellipseshape','-or',...
                    'type','polygon',...
                    'Visible','on')'
                    fc=get(obj,'facecolor');
                    ec=get(obj,'edgecolor');
                    if isequal(fc,bkgrndColor)&&~isequal(fc,'none')
                        if isequal(ec,WHITE)
                            [storage,turnMe,idx]=setfaceedge(obj,WHITE,BLACK,storage,turnMe,idx);
                        elseif isequal(ec,bkgrndColor)&&~isequal(ec,'none')
                            [storage,turnMe,idx]=setfaceedge(obj,WHITE,WHITE,storage,turnMe,idx);
                        else
                            [storage,turnMe,idx]=setfaceedge(obj,WHITE,NaN,storage,turnMe,idx);
                        end

                    elseif isequal(fc,WHITE)
                        if isequal(ec,WHITE)
                            [storage,turnMe,idx]=setfaceedge(obj,BLACK,BLACK,storage,turnMe,idx);
                        elseif isequal(ec,'none')
                            [storage,turnMe,idx]=setfaceedge(obj,BLACK,NaN,storage,turnMe,idx);
                        elseif isequal(ec,bkgrndColor)
                            [storage,turnMe,idx]=setfaceedge(obj,NaN,BLACK,storage,turnMe,idx);
                        end

                    elseif isequal(fc,BLACK)
                        if isequal(ec,WHITE)||(isequal(ec,bkgrndColor)&&~isequal(ec,'none'))
                            [storage,turnMe,idx]=setfaceedge(obj,WHITE,BLACK,storage,turnMe,idx);
                        elseif isequal(ec,'flat')
                            [storage,turnMe,idx]=setfaceedge(obj,WHITE,NaN,storage,turnMe,idx);
                        end

                    elseif isequal(fc,'none')
                        if isequal(ec,WHITE)
                            [storage,turnMe,idx]=setfaceedge(obj,NaN,BLACK,storage,turnMe,idx);
                        elseif isequal(ec,bkgrndColor)&&~isequal(ec,'none')
                            [storage,turnMe,idx]=setfaceedge(obj,NaN,WHITE,storage,turnMe,idx);
                        end

                    else
                        if isequal(ec,WHITE)||(isequal(ec,bkgrndColor)&&~isequal(ec,'none'))
                            [storage,turnMe,idx]=setfaceedge(obj,NaN,BLACK,storage,turnMe,idx);
                        end

                    end
                end


                for obj=findobjFcn(chil,'type','line','-or',...
                    '-isa','hg2sample.ScopeLineAnimator','-or',...
                    '-isa','hg2sample.ScopeStairAnimator','-or',...
                    '-isa','matlab.graphics.animation.ScopeLineAnimator','-or',...
                    '-isa','matlab.graphics.animation.ScopeStairAnimator','-or',...
                    '-isa','matlab.graphics.animation.ScopeStemAnimator','-or',...
                    'type','surface','-or',...
                    'type','patch','-or',...
                    'type','errorbar','-or',...
                    'type','quiver','-or',...
                    'type','scatter','-or',...
                    'type','stair','-or',...
                    'type','stem',...
                    'Visible','on')'
                    fc=get(obj,'markerfacecolor');
                    ec=get(obj,'markeredgecolor');
                    if isequal(fc,bkgrndColor)
                        if isequal(ec,WHITE)
                            [storage,turnMe,idx]=setmfaceedge(obj,WHITE,BLACK,storage,turnMe,idx);
                        elseif isequal(ec,bkgrndColor)
                            [storage,turnMe,idx]=setmfaceedge(obj,WHITE,WHITE,storage,turnMe,idx);
                        else
                            [storage,turnMe,idx]=setmfaceedge(obj,WHITE,NaN,storage,turnMe,idx);
                        end

                    elseif isequal(fc,WHITE)
                        if isequal(ec,WHITE)
                            [storage,turnMe,idx]=setmfaceedge(obj,BLACK,BLACK,storage,turnMe,idx);
                        elseif isequal(ec,'none')
                            [storage,turnMe,idx]=setmfaceedge(obj,BLACK,NaN,storage,turnMe,idx);
                        elseif isequal(ec,bkgrndColor)
                            [storage,turnMe,idx]=setmfaceedge(obj,NaN,BLACK,storage,turnMe,idx);
                        end

                    elseif isequal(fc,BLACK)
                        if isequal(ec,WHITE)
                            [storage,turnMe,idx]=setmfaceedge(obj,WHITE,BLACK,storage,turnMe,idx);
                        elseif isequal(ec,bkgrndColor)
                            [storage,turnMe,idx]=setmfaceedge(obj,WHITE,BLACK,storage,turnMe,idx);
                        end

                    elseif isequal(fc,'none')
                        if isequal(ec,WHITE)
                            [storage,turnMe,idx]=setmfaceedge(obj,NaN,BLACK,storage,turnMe,idx);
                        elseif isequal(ec,bkgrndColor)
                            [storage,turnMe,idx]=setmfaceedge(obj,NaN,WHITE,storage,turnMe,idx);
                        end

                    else
                        if isequal(ec,WHITE)
                            [storage,turnMe,idx]=setmfaceedge(obj,NaN,BLACK,storage,turnMe,idx);
                        elseif isequal(ec,bkgrndColor)
                            [storage,turnMe,idx]=setmfaceedge(obj,NaN,WHITE,storage,turnMe,idx);
                        end

                    end
                end
            end





            if~origFigWhite&&isprop(a,'XLabel_IS')&&isprop(a,'YLabel_IS')...
                &&isprop(a,'ZLabel_IS')&&isprop(a,'Title_IS')


                for obj=findobjFcn([get(a,'XLabel_IS'),get(a,'YLabel_IS'),get(a,'ZLabel_IS'),get(a,'Title_IS')],'-depth',0,'color',WHITE,'Visible','on')'
                    storage.color(idx.color,:)={obj,WHITE};
                    turnMe.color(idx.color,:)={obj,BLACK};
                    idx.color=idx.color+1;
                end




                for obj=findobjFcn([get(a,'XLabel_IS'),get(a,'YLabel_IS'),get(a,'ZLabel_IS'),get(a,'Title_IS')],'-depth',0,'color',origFigColor,'Visible','on')'
                    storage.color(idx.color,:)={obj,origFigColor};
                    turnMe.color(idx.color,:)={obj,WHITE};
                    idx.color=idx.color+1;
                end
            end

        end


        for k=1:count.color
            if~islight(turnMe.color{k,1})
                setGraphicsProperty(turnMe.color{k,1},'color',...
                turnMe.color{k,2,:},storage.useLatestHGPrinting);
            end
        end










        for axnum=1:naxes
            a=allAxes(axnum);
            if isprop(a,'XColor')&&isprop(a,'YColor')&&...
                isprop(a,'ZColor')&&isprop(a,'XLabel_IS')&&...
                isprop(a,'YLabel_IS')&&isprop(a,'ZLabel_IS')
                axc=get(a,'xcolor');
                ayc=get(a,'ycolor');
                azc=get(a,'zcolor');













                oldLabel=LocalLabelColor(a,'store');


                if(isequal(axc,origFigColor))
                    setGraphicsProperty(a,'xcolor',WHITE,...
                    storage.useLatestHGPrinting)
                elseif(isequal(axc,WHITE))
                    setGraphicsProperty(a,'xcolor',BLACK,...
                    storage.useLatestHGPrinting)
                end

                if(isequal(ayc,origFigColor))
                    setGraphicsProperty(a,'ycolor',WHITE,...
                    storage.useLatestHGPrinting)
                elseif(isequal(ayc,WHITE))
                    setGraphicsProperty(a,'ycolor',BLACK,...
                    storage.useLatestHGPrinting)
                end

                if(isequal(azc,origFigColor))
                    setGraphicsProperty(a,'zcolor',WHITE,...
                    storage.useLatestHGPrinting)
                elseif(isequal(azc,WHITE))
                    setGraphicsProperty(a,'zcolor',BLACK,...
                    storage.useLatestHGPrinting)
                end


                LocalLabelColor(oldLabel,'restore');

            elseif isprop(a,'TextColor')&&isprop(a,'EdgeColor')
                textColor=get(a,'TextColor');
                if(isequal(textColor,origFigColor))
                    setGraphicsProperty(a,'TextColor',WHITE,...
                    storage.useLatestHGPrinting)
                elseif(isequal(textColor,WHITE))
                    setGraphicsProperty(a,'TextColor',BLACK,...
                    storage.useLatestHGPrinting)
                end

                edgeColor=get(a,'EdgeColor');
                if(isequal(edgeColor,origFigColor))
                    setGraphicsProperty(a,'EdgeColor',WHITE,...
                    storage.useLatestHGPrinting)
                elseif(isequal(edgeColor,WHITE))
                    setGraphicsProperty(a,'EdgeColor',BLACK,...
                    storage.useLatestHGPrinting)
                end
            end

            if isa(a,'matlab.graphics.axis.AbstractAxes')
                gridc=a.GridColor;
                minorgridc=a.MinorGridColor;
                if(isequal(gridc,bkgrndColor))
                    a.GridColor=WHITE;
                elseif(isequal(gridc,WHITE))
                    a.GridColor=BLACK;
                end
                if(isequal(minorgridc,bkgrndColor))
                    a.MinorGridColor=WHITE;
                elseif(isequal(minorgridc,WHITE))
                    a.MinorGridColor=BLACK;
                end
            end
        end


        used=[];
        if count.facecolor>0
            used=1:count.facecolor;
            used(cellfun('isempty',turnMe.facecolor(:,1)))=[];
        end
        if~isempty(used)
            storage.facecolor(used(end)+1:end,:)=[];
            for k=used
                setGraphicsProperty(turnMe.facecolor{k,1},'facecolor',...
                turnMe.facecolor{k,2},storage.useLatestHGPrinting);
            end
        else
            storage.facecolor={};
        end

        used=[];
        if count.edgecolor>0
            used=1:count.edgecolor;
            used(cellfun('isempty',turnMe.edgecolor(:,1)))=[];
        end
        if~isempty(used)
            storage.edgecolor(used(end)+1:end,:)=[];
            for k=used
                setGraphicsProperty(turnMe.edgecolor{k,1},'edgecolor',...
                turnMe.edgecolor{k,2},storage.useLatestHGPrinting);
            end
        else
            storage.edgecolor={};
        end


        used=[];
        if count.markerfacecolor>0
            used=1:count.markerfacecolor;
            used(cellfun('isempty',turnMe.markerfacecolor(:,1)))=[];
        end
        if~isempty(used)
            storage.markerfacecolor(used(end)+1:end,:)=[];
            for k=used
                setGraphicsProperty(turnMe.markerfacecolor{k,1},...
                'markerfacecolor',turnMe.markerfacecolor{k,2},...
                storage.useLatestHGPrinting);
            end
        else
            storage.markerfacecolor={};
        end

        used=[];
        if count.markeredgecolor>0
            used=1:count.markeredgecolor;
            used(cellfun('isempty',turnMe.markeredgecolor(:,1)))=[];
        end
        if~isempty(used)
            storage.markeredgecolor(used(end)+1:end,:)=[];
            for k=used
                setGraphicsProperty(turnMe.markeredgecolor{k,1},...
                'markeredgecolor',turnMe.markeredgecolor{k,2},...
                storage.useLatestHGPrinting);
            end
        else
            storage.markeredgecolor={};
        end


        setGraphicsProperty(fig,'color',WHITE,storage.useLatestHGPrinting);

        SaveTonerOriginalColors=[storage,SaveTonerOriginalColors];

    else




        storage=SaveTonerOriginalColors(1);
        SaveTonerOriginalColors=SaveTonerOriginalColors(2:end);
        origFig=storage.figure{1};
        if isvalid(origFig)
            if storage.useLatestHGPrinting~=~useOriginalHGPrinting(origFig)
                error(message('MATLAB:adjustbackground:InconsistentClasses'))
            end
            origFigColor=storage.figure{2};
            if(sum(isnan(origFigColor))==3)
                origFigColor='none';
            end
            setGraphicsProperty(origFig,'color',origFigColor,...
            storage.useLatestHGPrinting);
        end

        if~isempty(storage.axes)
            for k=find(isvalid([storage.axes{:,1}]))
                if isempty(storage.axes{k})
                    continue;
                end
                a=storage.axes{k,1};
                setGraphicsProperty(a,'color',matrix2color(storage.axes{k,2}(AXESCOLOR_IDX:AXESCOLOR_IDX+2)),...
                storage.useLatestHGPrinting)

                if isprop(a,'XLabel_IS')&&isprop(a,'YLabel_IS')...
                    &&isprop(a,'ZLabel_IS')













                    oldLabel=LocalLabelColor(a,'store');


                    setGraphicsProperty(a,'xcolor',matrix2color(storage.axes{k,2}(AXESXCOLOR_IDX:AXESXCOLOR_IDX+2)),...
                    storage.useLatestHGPrinting)

                    setGraphicsProperty(a,'ycolor',matrix2color(storage.axes{k,2}(AXESYCOLOR_IDX:AXESYCOLOR_IDX+2)),...
                    storage.useLatestHGPrinting)

                    setGraphicsProperty(a,'zcolor',matrix2color(storage.axes{k,2}(AXESZCOLOR_IDX:AXESZCOLOR_IDX+2)),...
                    storage.useLatestHGPrinting)

                    if storage.useLatestHGPrinting
                        setGraphicsProperty(a,'XColorMode',storage.axesModes{k,XCOLORMODE_IDX},...
                        storage.useLatestHGPrinting)
                        setGraphicsProperty(a,'YColorMode',storage.axesModes{k,YCOLORMODE_IDX},...
                        storage.useLatestHGPrinting)
                        setGraphicsProperty(a,'ZColorMode',storage.axesModes{k,ZCOLORMODE_IDX},...
                        storage.useLatestHGPrinting)
                    end


                    LocalLabelColor(oldLabel,'restore');


                elseif isprop(a,'TextColor')&&isprop(a,'EdgeColor')
                    setGraphicsProperty(a,'Color',matrix2color(storage.axes{k,2}(AXESXCOLOR_IDX:AXESXCOLOR_IDX+2)),...
                    storage.useLatestHGPrinting)
                    setGraphicsProperty(a,'EdgeColor',matrix2color(storage.axes{k,2}(AXESYCOLOR_IDX:AXESYCOLOR_IDX+2)),...
                    storage.useLatestHGPrinting)
                    setGraphicsProperty(a,'TextColor',matrix2color(storage.axes{k,2}(AXESZCOLOR_IDX:AXESZCOLOR_IDX+2)),...
                    storage.useLatestHGPrinting)
                end

                if isa(a,'matlab.graphics.axis.AbstractAxes')
                    a.GridColor=matrix2color(storage.axes{k,2}(GRIDCOLOR_IDX:GRIDCOLOR_IDX+2));
                    a.MinorGridColor=matrix2color(storage.axes{k,2}(MINORGRIDCOLOR_IDX:MINORGRIDCOLOR_IDX+2));
                    a.GridColorMode=storage.axesModes{k,GRIDCOLORMODE_IDX};
                    a.MinorGridColorMode=storage.axesModes{k,MINORGRIDCOLORMODE_IDX};
                end
            end
        end

        if~isempty(storage.color)
            for k=find(isvalid([storage.color{:,1}]))
                obj=storage.color{k,1};
                setGraphicsProperty(obj,'color',...
                matrix2color(storage.color{k,2}),storage.useLatestHGPrinting)
            end
        end

        if~isempty(storage.facecolor)
            for k=find(isvalid([storage.facecolor{:,1}]))
                obj=storage.facecolor{k,1};
                setGraphicsProperty(obj,'facecolor',...
                matrix2color(storage.facecolor{k,2}),...
                storage.useLatestHGPrinting)
            end
        end

        if~isempty(storage.edgecolor)
            for k=find(isvalid([storage.edgecolor{:,1}]))
                obj=storage.edgecolor{k,1};
                setGraphicsProperty(obj,'edgecolor',...
                matrix2color(storage.edgecolor{k,2}),...
                storage.useLatestHGPrinting)
            end
        end

        if~isempty(storage.markeredgecolor)
            for k=find(isvalid([storage.markeredgecolor{:,1}]))
                obj=storage.markeredgecolor{k,1};
                setGraphicsProperty(obj,'markeredgecolor',...
                matrix2color(storage.markeredgecolor{k,2}),...
                storage.useLatestHGPrinting)
            end
        end

        if~isempty(storage.markerfacecolor)
            for k=find(isvalid([storage.markerfacecolor{:,1}]))
                obj=storage.markerfacecolor{k,1};
                setGraphicsProperty(obj,'markerfacecolor',...
                matrix2color(storage.markerfacecolor{k,2}),...
                storage.useLatestHGPrinting)
            end
        end

        if~isempty(storage.colorbars)&&storage.useLatestHGPrinting

            for k=find(isvalid([storage.colorbars{:,1}]))
                obj=storage.colorbars{k,1};
                setGraphicsProperty(obj,'Color',...
                matrix2color(storage.colorbars{k,2}),...
                storage.useLatestHGPrinting);
            end
        end


        if~isempty(storage.heatmaps)
            for hidx=find(isvalid([storage.heatmaps{:,1}]))
                obj=storage.heatmaps{hidx,1};
                obj.FontColor=storage.heatmaps{hidx,2};
            end
        end


        if~isempty(storage.subplotTexts)
            for stIdx=find(isvalid([storage.subplotTexts{:,1}]))
                obj=storage.subplotTexts{stIdx,1};
                obj.Color=storage.subplotTexts{stIdx,2};
            end
        end

    end





    function[storage,turnMe,idx]=setfaceedge(obj,newFace,newEdge,storage,turnMe,idx)


        if~isnan(newFace)
            storage.facecolor(idx.facecolor,:)={obj,color2matrix(get(obj,'facecolor'))};
            turnMe.facecolor(idx.facecolor,:)={obj,newFace};
            idx.facecolor=idx.facecolor+1;
        end

        if~isnan(newEdge)
            storage.edgecolor(idx.edgecolor,:)={obj,color2matrix(get(obj,'edgecolor'))};
            turnMe.edgecolor(idx.edgecolor,:)={obj,newEdge};
            idx.edgecolor=idx.edgecolor+1;
        end
    end


    function[storage,turnMe,idx]=setmfaceedge(obj,newFace,newEdge,storage,turnMe,idx)


        if~isnan(newFace)
            storage.markerfacecolor(idx.markerfacecolor,:)={obj,color2matrix(get(obj,'markerfacecolor'))};
            turnMe.markerfacecolor(idx.markerfacecolor,:)={obj,newFace};
            idx.markerfacecolor=idx.markerfacecolor+1;
        end

        if~isnan(newEdge)
            storage.markeredgecolor(idx.markeredgecolor,:)={obj,color2matrix(get(obj,'markeredgecolor'))};
            turnMe.markeredgecolor(idx.markeredgecolor,:)={obj,newEdge};
            idx.markeredgecolor=idx.markeredgecolor+1;
        end
    end


    function color=color2matrix(color)


        if isequal(color,'none')
            color=NONE;

        elseif isequal(color,'flat')
            color=FLAT;

        end
    end


    function color=matrix2color(color)


        if isequal(isnan(color),isnan(NONE))
            color='none';

        elseif isequal(isnan(color),isnan(FLAT))
            color='flat';

        end
    end


    function outObj=LocalLabelColor(inObj,state)


        switch state
        case 'store'


            labelProp={'XLabel_IS','YLabel_IS','ZLabel_IS'};
            axes=cell(1,length(labelProp));
            axes(:)={inObj};
            outObj.labelObj={};
            outObj.labelColor={};

            outObj.labelObj=cellfun(@(x,y)get(x,y),axes,labelProp,'UniformOutput',false);

            for i=1:length(labelProp)
                if~isempty(outObj.labelObj{i})
                    outObj.labelColor{i}=get(outObj.labelObj{i},'Color');
                end
            end

        case 'restore'


            for i=1:length(inObj.labelObj)
                if~isempty(inObj.labelObj{i})
                    setGraphicsProperty(inObj.labelObj{i},'color',inObj.labelColor{i},...
                    storage.useLatestHGPrinting);
                end
            end
        end

    end


end


function yesno=islight(obj)
    yesno=false;

    if isa(obj,'matlab.graphics.primitive.world.LightSource')||...
        (isprop(obj,'Type')&&strcmp('light',get(obj,'type')))
        yesno=true;
    end
end




