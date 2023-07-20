function figOut=lobeDiagramSettings(obj,toolStrip,figHandle,arr,propSpeed,steerAng)





    figHandle.Name=...
    getString(message('phased:apps:arrayapp:gratingLobeDiagram'));
    figHandle.Tag='gratingLobeFig';
    figHandle.HandleVisibility='on';

    set(groot,'CurrentFigure',figHandle);
    drawnow();

    isUHA=false;
    isCircPlanar=false;
    if~obj.pFromSimulink
        isUHA=obj.ToolStripDisplay.ArrayGalleryItems{4}.Value;
        isCircPlanar=obj.ToolStripDisplay.ArrayGalleryItems{5}.Value;
    end


    getCurrentFreqGratingCallback(toolStrip);


    [y,~,u]=engunits(toolStrip.FreqGrating);
    fcStr=[num2str(y),' ',u];
    toolStrip.FreqDropDownGrating.Text=fcStr;


    if isa(arr,'phased.ULA')||isa(arr,'phased.URA')
        plotGratingLobeDiagram(arr,toolStrip.FreqGrating,...
        steerAng(:,1),propSpeed);
    elseif(isa(arr,'phased.ConformalArray')&&...
        (isUHA||isCircPlanar))


        ratio=1;
        usingLambda=obj.ParametersPanel.isUsingLambda(obj.ParametersPanel.ArrayDialog.ElementSpacingUnits);

        if usingLambda
            ratio=propSpeed/toolStrip.FreqGrating;
        end

        elemSpacing=...
        obj.ParametersPanel.ArrayDialog.ElementSpacing*ratio;


        if isUHA
            RS=elemSpacing/2*sqrt(3);
            CS=elemSpacing;
            lattice='Triangular';
        elseif isCircPlanar
            RS=elemSpacing;
            CS=elemSpacing;
            templattice=obj.ParametersPanel.ArrayDialog.Lattice;
            if strcmp(templattice,...
                getString(message('phased:apps:arrayapp:Triangular')))
                lattice='Triangular';
            else
                lattice='Rectangular';
            end
        end

        phased.apps.internal.plotGratingLobeDiagramPlanar(RS,CS,...
        lattice,toolStrip.FreqGrating,steerAng(:,1),propSpeed);
    end


    hLegend=findobj(figHandle,'Type','Legend');
    hLegend.UIContextMenu='';
    figHandle.HandleVisibility='off';


    hAxes=figHandle.CurrentAxes;
    title=get(hAxes,'title');
    title_str=get(title,'String');
    [Fval,~,Fletter]=engunits(toolStrip.FreqGrating);
    steeringString=getString(message('phased:apps:arrayapp:NoSteering'));
    if any(any(steerAng~=0))
        steeringString=getString(...
        message('phased:apps:arrayapp:d3titlesteer',...
        num2str(steerAng(1)),num2str(steerAng(2))));
    end

    title_str=[title_str,newline,num2str(Fval),' ',Fletter,[...
    getString(message('phased:apps:arrayapp:Hz')),' '],steeringString];


    set(title,'String',title_str);


    axtoolbar(hAxes,{'export','pan'});

    figOut=figHandle;