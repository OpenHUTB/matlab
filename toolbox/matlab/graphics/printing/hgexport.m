function varargout=hgexport(H,filename,options,varargin)






























































































































    narginchk(1,inf);


    H=convertStringsToChars(H);

    if nargin>1
        filename=convertStringsToChars(filename);
    end

    if nargin>2
        options=convertStringsToChars(options);
    end

    if nargin>3
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if ischar(H)
        switch char(H)
        case 'readstyle'
            varargout{1}=LocalReadStyle(filename);
            return;
        case 'writestyle'
            LocalWriteStyle(filename,options);
            return;
        case 'factorystyle'
            varargout{1}=LocalFactoryStyle;
            return;
        end
    end



    drawnow;

    if~(isscalar(H)&&ishghandle(H,'figure'))
        error(message('MATLAB:hgexport:FirstInputMustBeFigHandle'));
    end
    if~ischar(filename)
        error(message('MATLAB:hgexport:SecondInputMustBeString'));
    end
    isClipboard=strcmp(filename,'-clipboard');
    if~ispc&&isClipboard
        error(message('MATLAB:hgexport:CopyToClipboardNotSupported'));
    end

    matlab.graphics.internal.prepareFigureForPrint(H);
    matlab.ui.internal.UnsupportedInUifigure(H);

    auto=LocalFactoryStyle;

    if nargin<3




        template=getappdata(H,'Exportsetup');
        if isempty(template)
            try
                template=LocalReadStyle('Default');
            catch %#ok<CTCH>
                template=LocalFactoryStyle;
            end
        end
        paramPairs=LocalToCell(template,auto);
    else
        paramPairs=LocalToCell(options,auto);
    end

    if~isempty(varargin)
        paramPairs=[paramPairs,varargin];
    end

    opts=auto;


    args={};
    for k=1:2:length(paramPairs)
        param=lower(paramPairs{k});
        if~ischar(param)
            error(message('MATLAB:hgexport:ParameterMustBeString'));
        end
        value=paramPairs{k+1};

        switch(param)
        case 'format'
            opts.Format=LocalCheckAuto(lower(value),auto.Format);
        case 'preview'
            opts.Preview=LocalCheckAuto(lower(value),auto.Preview);
            if~strcmp(opts.Preview,{'none','tiff'})
                error(message('MATLAB:hgexport:InvalidPreviewAction'));
            end
        case 'width'
            opts.Width=LocalToNum(value,auto.Width);
            if~ischar(value)||~strcmp(value,'auto')
                if~LocalIsPositiveScalar(opts.Width)
                    error(message('MATLAB:hgexport:WidthMustBePositiveScalar'));
                end
            end
        case 'height'
            opts.Height=LocalToNum(value,auto.Height);
            if~ischar(value)||~strcmp(value,'auto')
                if(~LocalIsPositiveScalar(opts.Height))
                    error(message('MATLAB:hgexport:HeightMustBePositiveScalar'));
                end
            end
        case 'units'
            opts.Units=LocalCheckAuto(lower(value),auto.Units);
        case 'color'
            opts.Color=LocalCheckAuto(lower(value),auto.Color);
            if~strcmp(opts.Color,{'bw','gray','rgb','cmyk'})
                error(message('MATLAB:hgexport:InvalidColor'));
            end
        case 'background'
            opts.Background=LocalCheckAuto(lower(value),auto.Background);
        case 'fontmode'
            opts.FontMode=LocalCheckAuto(lower(value),auto.FontMode);
            if~strcmp(opts.FontMode,{'scaled','fixed','none'})
                error(message('MATLAB:hgexport:InvalidFontMode'));
            end
        case 'scaledfontsize'
            opts.ScaledFontSize=LocalToNum(value,auto.ScaledFontSize);
            if~ischar(value)||~strcmp(value,'auto')
                if~LocalIsPositiveScalar(opts.ScaledFontSize)
                    error(message('MATLAB:hgexport:InvalidScaledFontSize'));
                end
            end
        case 'fixedfontsize'
            opts.FixedFontSize=LocalToNum(value,auto.FixedFontSize);
            if~ischar(value)||~strcmp(value,'auto')
                if~LocalIsPositiveScalar(opts.FixedFontSize)
                    error(message('MATLAB:hgexport:InvalidFixedFontSize'));
                end
            end
        case 'fontsizemin'
            opts.FontSizeMin=LocalToNum(value,auto.FontSizeMin);
            if~ischar(value)||~strcmp(value,'auto')
                if~LocalIsPositiveScalar(opts.FontSizeMin)
                    error(message('MATLAB:hgexport:InvalidFontSizeMin'));
                end
            end
        case 'fontname'
            opts.FontName=LocalCheckAuto(lower(value),auto.FontName);
            if~isempty(opts.FontName)&&~ischar(opts.FontName)
                error(message('MATLAB:hgexport:InvalidFontNameInput'));
            end
        case 'fontweight'
            opts.FontWeight=LocalCheckAuto(lower(value),auto.FontWeight);
            if~isempty(opts.FontWeight)&&~ischar(opts.FontWeight)
                error(message('MATLAB:hgexport:InvalidFontWeightInput'));
            end
        case 'fontangle'
            opts.FontAngle=LocalCheckAuto(lower(value),auto.FontAngle);
            if~isempty(opts.FontAngle)&&~ischar(opts.FontAngle)
                error(message('MATLAB:hgexport:InvalidFontAngleInput'));
            end
        case 'fontencoding'
            opts.FontEncoding=LocalCheckAuto(lower(value),auto.FontEncoding);
            if~strcmp(opts.FontEncoding,{'latin1','adobe'})
                error(message('MATLAB:hgexport:InvalidFontEncodingType'));
            end
        case 'pslevel'
            opts.PSLevel=LocalToNum(value,auto.PSLevel);
            if~ischar(value)||~strcmp(value,'auto')
                if((opts.PSLevel~=2)&&(opts.PSLevel~=3))
                    error(message('MATLAB:hgexport:InvalidPSLevelInput'));
                end
            end
        case 'linemode'
            opts.LineMode=LocalCheckAuto(lower(value),auto.LineMode);
            if~strcmp(opts.LineMode,{'scaled','fixed','none'})
                error(message('MATLAB:hgexport:InvalidLineModeInput'));
            end
        case 'scaledlinewidth'
            opts.ScaledLineWidth=LocalToNum(value,auto.ScaledLineWidth);
            if~ischar(value)||~strcmp(value,'auto')
                if~LocalIsPositiveScalar(opts.ScaledLineWidth)
                    error(message('MATLAB:hgexport:InvalidScaleLineWidth'));
                end
            end
        case 'fixedlinewidth'
            opts.FixedLineWidth=LocalToNum(value,auto.FixedLineWidth);
            if~ischar(value)||~strcmp(value,'auto')
                if~LocalIsPositiveScalar(opts.FixedLineWidth)
                    error(message('MATLAB:hgexport:InvalidFixedLineWidth'));
                end
            end
        case 'linewidthmin'
            opts.LineWidthMin=LocalToNum(value,auto.LineWidthMin);
            if~ischar(value)||~strcmp(value,'auto')
                if~LocalIsPositiveScalar(opts.LineWidthMin)
                    error(message('MATLAB:hgexport:InvalidLinWidthMinInput'));
                end
            end
        case 'linestylemap'
            opts.LineStyleMap=LocalCheckAuto(value,auto.LineStyleMap);
        case 'renderer'
            opts.Renderer=LocalCheckAuto(lower(value),auto.Renderer);
            if~ischar(value)||~strcmp(value,'auto')
                if~strcmp(opts.Renderer,{'painters','zbuffer','opengl','image','vector'})
                    error(message('MATLAB:hgexport:InvalidRendererInput'));
                end
            end
        case 'resolution'
            opts.Resolution=LocalToNum(value,auto.Resolution);
            if~ischar(value)||~strcmp(value,'auto')
                if~(isnumeric(opts.Resolution)&&(numel(opts.Resolution)==1)&&...
                    (opts.Resolution>=0))
                    error(message('MATLAB:hgexport:InvalidResolution'));
                end
            end
        case 'applystyle'
            opts.ApplyStyle=LocalToNum(value,auto.ApplyStyle);
        case 'bounds'
            opts.Bounds=LocalCheckAuto(lower(value),auto.Bounds);
            if~strcmp(opts.Bounds,{'tight','loose'})
                error(message('MATLAB:hgexport:InvalidBounds'));
            end
        case 'lockaxes'
            opts.LockAxes=LocalCheckAuto(lower(value),auto.LockAxes);
            if~strcmp(opts.LockAxes,{'on','off'})
                error(message('MATLAB:hgexport:InvalidLockAxesInput'));
            end
        case 'lockaxesticks'
            opts.LockAxesTicks=LocalCheckAuto(lower(value),auto.LockAxesTicks);
            if~strcmp(opts.LockAxesTicks,{'on','off'})
                error(message('MATLAB:hgexport:InvalidLockAxesTicksInput'));
            end
        case 'showui'
            opts.ShowUI=LocalCheckAuto(lower(value),auto.ShowUI);
            if~strcmp(opts.ShowUI,{'on','off'})
                error(message('MATLAB:hgexport:InvalidShowUIInput'));
            end
        case 'separatetext'
            opts.SeparateText=LocalCheckAuto(lower(value),auto.SeparateText);
            if~strcmp(opts.SeparateText,{'on','off'})
                error(message('MATLAB:hgexport:InvalidSeparateTextInput'));
            end
        case 'version'

        case 'xmargin'
            opts.XMargin=value;
        case 'ymargin'
            opts.YMargin=value;
        otherwise
            error(message('MATLAB:hgexport:UnknownOption',param));
        end
    end

    alreadyApplied=isappdata(H,'ExportsetupApplied')&&...
    (getappdata(H,'ExportsetupApplied')==true);

    H=handle(H);
    printUtility=matlab.graphics.internal.printUtility;



    objCollections=printingObjectCollection(H);

    allAxes=objCollections.allAxes;
    allCartesian=objCollections.allCartesian;
    allPolar=objCollections.allPolar;
    allAxesRulers=objCollections.allAxesRulers;
    allLegends=objCollections.allLegends;
    allColorbars=objCollections.allColorbars;
    allScribeText=objCollections.allScribeText;
    allScribeEdge=objCollections.allScribeEdge;
    allScribe1DirArrow=objCollections.allScribe1DirArrow;
    allScatterhistograms=objCollections.allScatterhistograms;
    allParallelplots=objCollections.allParallelplots;





    allScribe2DirArrow=objCollections.allScribe2DirArrow;
    allContour=objCollections.allContour;
    allWordclouds=objCollections.allWordclouds;
    allLines=objCollections.allLines;
    allText=objCollections.allText;
    allLights=objCollections.allLights;
    allFont=objCollections.allFont;
    allMarker=objCollections.allMarker;
    allEdge=objCollections.allEdge;
    allFace=objCollections.allFace;
    allCData=objCollections.allCData;
    allNode=objCollections.allNode;
    line=objCollections.line;
    allLineColor=objCollections.allLineColor;


    get(allAxes,'TightInset');



    old.objs={};
    old.prop={};
    old.values={};


    if strncmp(opts.Format,'eps',3)&&~strcmp(opts.Preview,'none')
        args=[args,{['-',opts.Preview]}];
    end

    hadError=0;
    oldwarn=warning;
    setappdata(H,'BusyPrinting','export');
    try

        if~alreadyApplied


            old=printingAxesTickLabelUpdate(H,opts,old);


            old=printUtility.pushOldData(old,H,'PaperPositionMode',...
            get(H,'PaperPositionMode'));
            old=printUtility.pushOldData(old,H,'PaperPosition',...
            get(H,'PaperPosition'));
            old=printUtility.pushOldData(old,H,'PaperUnits',...
            get(H,'PaperUnits'));
            oldFigureUnits=get(H,'Units');
            oldFigPos=get(H,'Position');
            printUtility.setValues(H,'Units',opts.Units);
            figPos=get(H,'Position');
            refsize=figPos(3:4);
            aspectRatio=refsize(1)/refsize(2);
            doAuto=false;
            if strcmp(opts.Width,'auto')&&strcmp(opts.Height,'auto')
                doAuto=true;
                opts.Width=refsize(1);
                opts.Height=refsize(2);
            elseif strcmp(opts.Width,'auto')
                opts.Width=opts.Height*aspectRatio;
            elseif strcmp(opts.Height,'auto')
                opts.Height=opts.Width/aspectRatio;
            end
            wscale=opts.Width/refsize(1);
            hscale=opts.Height/refsize(2);
            opts.sizescale=min(wscale,hscale);
            if doAuto

                printUtility.setValues(H,'PaperPositionMode','auto');
            else
                H.PaperUnits=opts.Units;
                xmargin=(H.PaperSize(1)-opts.Width)/2;
                ymargin=(H.PaperSize(2)-opts.Height)/2;
                if isfield(opts,'XMargin')
                    xmargin=LocalCheckAuto(opts.XMargin,xmargin);
                end
                if isfield(opts,'YMargin')
                    ymargin=LocalCheckAuto(opts.YMargin,ymargin);
                end
                paperPos=[xmargin,ymargin,opts.Width,opts.Height];
                printUtility.setValues(H,'PaperPosition',paperPos);
            end
            if opts.ApplyStyle





                printUtility.setValues(H,'PaperPositionMode','auto');
                newPos=[figPos(1),figPos(2)+figPos(4)*(1-hscale)...
                ,wscale*figPos(3),hscale*figPos(4)];
                old=printUtility.pushOldData(old,H,'Units',oldFigureUnits);
                if~strcmp(get(H,'WindowStyle'),'docked')
                    old=printUtility.pushOldData(old,H,'Position',oldFigPos);
                    old=printUtility.pushOldData(old,H,'WindowState',H.WindowState);
                    printUtility.setValues(H,'WindowState','normal');
                    printUtility.setValues(H,'Position',newPos);
                end
            end
            printUtility.setValues(H,'Units',oldFigureUnits);

            old=printUtility.pushOldData(old,H,'Color',get(H,'Color'));
            old=printUtility.pushOldData(old,H,'InvertHardcopy',...
            get(H,'InvertHardcopy'));



            if strcmp(get(H,'InvertHardcopy'),'on')
                printUtility.setValues(H,'InvertHardcopy','off');
                if~isempty(opts.Background)
                    if ischar(opts.Background)&&(opts.Background(1)=='[')
                        opts.Background=eval(opts.Background);
                    end
                    printUtility.setValues(H,'Color',opts.Background);
                end
            end



            if LocalIsImageFormat(opts.Format)
                old=printUtility.pushOldData(old,H,'PaperOrientation',get(H,'PaperOrientation'));
                printUtility.setValues(H,'PaperOrientation','portrait');
            end


            old=printingFontUpdate(allFont,opts,old);

            old=printingLineUpdate(line,opts,old);
        end


        if(opts.PSLevel==2)&&strncmp(opts.Format,'eps',3)&&...
            isempty(strfind(opts.Format,'2'))
            opts.Format=[opts.Format,'2'];
        end
        switch(opts.Color)
        case{'bw','gray'}
            if~strcmp(opts.Color,'bw')&&strncmp(opts.Format,'eps',3)&&...
                isempty(strfind(opts.Format,'c'))
                opts.Format=[opts.Format,'c'];
            end
            args=[args,{['-d',opts.Format]}];

            if~alreadyApplied


                old=printingGrayscaleUpdate(objCollections,old);

                if strcmp(opts.Color,'bw')




                    tiny=100*eps;
                    loopProps={allLines,'Color',allText,'Color',allCartesian,'XColor',allCartesian,'YColor',...
                    allCartesian,'ZColor',allPolar,'ThetaColor',allPolar,'RColor',allMarker,'MarkerEdgeColor',...
                    allEdge,'EdgeColor',allNode,'NodeColor',allAxes,'GridColor',allAxes,'MinorGridColor',...
                    allLegends,'TextColor',allColorbars,'Color',allAxesRulers,'Color',allLineColor,'LineColor',...
                    allWordclouds,'Color',allWordclouds,'HighlightColor',allScatterhistograms,'Color',...
                    allParallelplots,'Color'};
                    N=length(loopProps)/2;
                    for pr=1:N
                        objs=loopProps{2*pr-1};
                        lcolor=printUtility.getValuesAsCell(objs,loopProps{2*pr});
                        n=length(lcolor);
                        for k=1:n

                            if isempty(lcolor{k})
                                continue;
                            end

                            if isnumeric(lcolor{k})
                                if(lcolor{k}(1)<1-tiny)
                                    printUtility.setValues(objs(k),loopProps{2*pr},[0,0,0]);
                                end
                            elseif ischar(lcolor{k})&&~strcmp(lcolor{k},'none')
                                printUtility.setValues(objs(k),loopProps{2*pr},[0,0,0]);
                            end
                        end
                    end
                end
            end
        case{'rgb','cmyk'}
            if strncmp(opts.Format,'eps',3)
                if isempty(strfind(opts.Format,'c'))
                    opts.Format=[opts.Format,'c'];
                end
                args=[args,{['-d',opts.Format]}];
                if strcmp(opts.Color,'cmyk')
                    args=[args,{'-cmyk'}];
                end
            else
                args=[args,{['-d',opts.Format]}];
            end
        otherwise
            error(message('MATLAB:hgexport:InvalidColorParam'));
        end
        if~alreadyApplied
            if~isempty(opts.Renderer)&&~strcmp(opts.Renderer,'auto')
                old=printUtility.pushOldData(old,H,'RendererMode',...
                get(H,'RendererMode'));
                old=printUtility.pushOldData(old,H,'Renderer',...
                get(H,'Renderer'));


                if strcmp(opts.Renderer,"image")
                    opts.Renderer="opengl";

                elseif strcmp(opts.Renderer,"vector")
                    opts.Renderer="painters";
                end
                printUtility.setValues(H,'Renderer',opts.Renderer);
            end
            if(~isempty(opts.ShowUI)&&strcmp(opts.ShowUI,'off'))
                uicontrols=findobjinternal(H,'Type','uicontrol','Visible','on');
                old=printUtility.pushOldData(old,uicontrols,'Visible','on');
                printUtility.setValues(uicontrols,'Visible','off');
            end
        end
        if~strcmp(opts.Resolution,'auto')||~strncmp(opts.Format,'eps',3)
            if strcmp(opts.Resolution,'auto')
                opts.Resolution=0;
            end
            args=[args,{['-r',int2str(opts.Resolution)]}];
        end


        if~isempty(allCartesian)
            args=[args,{'-loose'}];
            if strcmp(opts.Bounds,'tight')&&~alreadyApplied
                ok=true(1,length(allCartesian));
                for k=1:length(allCartesian)
                    if isappdata(allCartesian(k),'NonDataObject')
                        ok(k)=false;
                    end
                end
                allDataAxes=allCartesian(ok);
                warpModes=printUtility.getValuesAsCell(allDataAxes,'WarpToFillMode');
                old=printUtility.pushOldData(old,allDataAxes,{'WarpToFillMode'},warpModes);
                warpModes=printUtility.getValuesAsCell(allDataAxes,'WarpToFill');
                old=printUtility.pushOldData(old,allDataAxes,{'WarpToFill'},warpModes);
                printUtility.setValues(allDataAxes,'WarpToFill','on')

                posModes=printUtility.getValuesAsCell(allDataAxes,'ActivePositionProperty');
                ax=allDataAxes(strcmp(posModes,'outerposition'));
                inset=printUtility.getValuesAsCell(ax,'LooseInset');
                outpos=printUtility.getValuesAsCell(ax,'OuterPosition');
                old=printUtility.pushOldData(old,ax,{'OuterPosition'},outpos);
                old=printUtility.pushOldData(old,ax,{'LooseInset'},inset);
                old=printUtility.pushOldData(old,ax,{'Units'},printUtility.getValuesAsCell(ax,'Units'));
                printUtility.setValues(ax,'Units','normalized');
                if length(ax)==1
                    printUtility.setValues(ax,'OuterPosition',[0,0,1,1]);
                    printUtility.setValues(ax,'LooseInset',[0,0,0,0]);
                elseif length(ax)>1
                    slop=[inf,inf,inf,inf];
                    voutpos=vertcat(outpos{:});
                    edge=[min(voutpos(:,1:2)),max(voutpos(:,1:2)+voutpos(:,3:4))];
                    for k=1:length(ax)
                        op=outpos{k};
                        loose=inset{k};
                        tight=get(ax(k),'TightInset');

                        if abs(edge(1)-op(1))<100*eps
                            slop(1)=max(0,min(slop(1),(loose(1)*op(3))-tight(1)));
                        end
                        if abs(edge(2)-op(2))<100*eps
                            slop(2)=max(0,min(slop(2),(loose(2)*op(4))-tight(2)));
                        end
                        if abs(edge(3)-op(1)-op(3))<100*eps
                            slop(3)=max(0,min(slop(3),(loose(3)*op(3))-tight(3)));
                        end
                        if abs(edge(4)-op(2)-op(4))<100*eps
                            slop(4)=max(0,min(slop(4),(loose(4)*op(4))-tight(4)));
                        end
                    end
                    if all(isfinite(slop))
                        h=1+slop(1)+slop(3);
                        v=1+slop(2)+slop(4);
                        for k=1:length(ax)
                            op=outpos{k};


                            op(1:2)=op(1:2)-slop(1:2);
                            op=op.*[h,v,h,v];



                            loose=inset{k}.*[op(3:4),op(3:4)];

                            if op(1)<0

                                loose(1)=loose(1)+op(1);
                                op(3)=op(3)+op(1);
                                op(1)=0;
                            end
                            if op(2)<0

                                loose(2)=loose(2)+op(2);
                                op(4)=op(4)+op(2);
                                op(2)=0;
                            end
                            if op(1)+op(3)>1

                                loose(3)=loose(3)-(op(1)+op(3)-1);
                                op(3)=1-op(1);
                            end
                            if op(2)+op(4)>1

                                loose(4)=loose(4)-(op(2)+op(4)-1);
                                op(4)=1-op(2);
                            end

                            inset{k}=loose./[op(3:4),op(3:4)];

                            outpos{k}=op;
                        end
                        printUtility.setValues(ax,'OuterPosition',outpos);
                        printUtility.setValues(ax,'LooseInset',inset);
                    end
                end
            end
        end


        if~isequal(opts.ApplyStyle,1)
            if strcmp(opts.SeparateText,'on')&&~isClipboard

                oldtvis=printUtility.getValuesAsCell(allText,'visible');
                printUtility.setValues(allText,'Visible','off');
                oldax=printUtility.getValuesAsCell(allCartesian,'XTickLabel',1);
                olday=printUtility.getValuesAsCell(allCartesian,'YTickLabel',1);
                oldaz=printUtility.getValuesAsCell(allCartesian,'ZTickLabel',1);
                null=cell(length(oldax),1);
                [null{:}]=deal([]);
                printUtility.setValues(allCartesian,'XTickLabel',null);
                printUtility.setValues(allCartesian,'YTickLabel',null);
                printUtility.setValues(allCartesian,'ZTickLabel',null);
                oldScribeText=printUtility.getValuesAsCell(allScribeText,'String');
                printUtility.setValues(allScribeText,'String','');

                print(H,filename,args{:});

                printUtility.setValues(allText,'Visible',oldtvis);
                printUtility.setValues(allCartesian,'XTickLabel',oldax);
                printUtility.setValues(allCartesian,'YTickLabel',olday);
                printUtility.setValues(allCartesian,'ZTickLabel',oldaz);
                printUtility.setValues(allScribeText,'String',oldScribeText);

                [path,name]=fileparts(filename);
                textFile=fullfile(path,[name,'_t.eps']);
                foundRenderer=0;
                for k=1:length(args)
                    if strncmp('-d',args{k},2)
                        args{k}='-deps';
                    elseif strncmp('-zbuffer',args{k},8)||...
                        strncmp('-opengl',args{k},6)
                        args{k}='-vector';
                        foundRenderer=1;
                    end
                end
                if~foundRenderer
                    args=[args{:},{'-vector'}];
                end
                allNonText=[allLines;allLights;allFace;allCData];

                oldBox=printUtility.getValuesAsCell(allCartesian,'Box');
                printUtility.setValues(allCartesian,'Box','off');
                allAxXRulers=printUtility.getValuesAsCell(allCartesian,'XRuler');
                allAxYRulers=printUtility.getValuesAsCell(allCartesian,'YRuler');
                allAxZRulers=printUtility.getValuesAsCell(allCartesian,'ZRuler');
                allAxRulers=[allAxXRulers{:},allAxYRulers{:},allAxZRulers{:}];
                allAxAxles=printUtility.getValuesAsCell(allAxRulers,'Axle');
                allAxAxles=[allAxAxles{:}];
                oldAxleVis=printUtility.getValuesAsCell(allAxAxles,'Visible');

                allAxMajorTicks=printUtility.getValuesAsCell(allAxRulers,'MajorTicks');
                allAxMajorTicks=[allAxMajorTicks{:}];
                oldMajorTickVis=printUtility.getValuesAsCell(allAxMajorTicks,'Visible');
                allAxMinorTicks=get(allAxRulers,'MinorTicks');
                allAxMinorTicks=[allAxMinorTicks{:}];
                oldMinorTickVis=printUtility.getValuesAsCell(allAxMinorTicks,'Visible');
                printUtility.setValues(allAxAxles,'Visible','off');
                printUtility.setValues(allAxMajorTicks,'Visible','off');
                printUtility.setValues(allAxMinorTicks,'Visible','off');

                oldContourFill=printUtility.getValuesAsCell(allContour,'Fill');
                oldContourLineStyle=printUtility.getValuesAsCell(allContour,'LineStyle');
                oldContourText=printUtility.getValuesAsCell(allContour,'ShowText');
                printUtility.setValues(allContour,'Fill','off');
                printUtility.setValues(allContour,'LineStyle','none');
                printUtility.setValues(allContour,'ShowText','off');

                oldvis=printUtility.getValuesAsCell(allNonText,'Visible');
                oldc=printUtility.getValuesAsCell(allCartesian,'Color');
                oldaxg=printUtility.getValuesAsCell(allCartesian,'XGrid');
                oldayg=printUtility.getValuesAsCell(allCartesian,'YGrid');
                oldazg=printUtility.getValuesAsCell(allCartesian,'ZGrid');
                [null{:}]=deal('off');
                printUtility.setValues(allCartesian,'XGrid',null);
                printUtility.setValues(allCartesian,'YGrid',null);
                printUtility.setValues(allCartesian,'ZGrid',null);
                printUtility.setValues(allNonText,'Visible','off');
                printUtility.setValues(allCartesian,'Color','none');

                oldScribeEdge=printUtility.getValuesAsCell(allScribeEdge,'EdgeColor');
                oldScribe1DirArrowHead=printUtility.getValuesAsCell(allScribe1DirArrow,'HeadStyle');
                oldScribe1DirArrowLine=printUtility.getValuesAsCell(allScribe1DirArrow,'LineStyle');
                oldScribe2DirArrowHead1=printUtility.getValuesAsCell(allScribe2DirArrow,'Head1Style');
                oldScribe2DirArrowHead2=printUtility.getValuesAsCell(allScribe2DirArrow,'Head2Style');
                oldScribe2DirArrowLine=printUtility.getValuesAsCell(allScribe2DirArrow,'LineStyle');
                printUtility.setValues(allScribeEdge,'EdgeColor','none');
                printUtility.setValues(allScribe1DirArrow,'HeadStyle','none');
                printUtility.setValues(allScribe1DirArrow,'LineStyle','none');
                printUtility.setValues(allScribe2DirArrow,'Head1Style','none');
                printUtility.setValues(allScribe2DirArrow,'Head2Style','none');
                printUtility.setValues(allScribe2DirArrow,'LineStyle','none');

                print(H,textFile,args{:});

                printUtility.setValues(allNonText,'Visible',oldvis);
                printUtility.setValues(allCartesian,'Color',oldc);
                printUtility.setValues(allCartesian,'XGrid',oldaxg);
                printUtility.setValues(allCartesian,'YGrid',oldayg);
                printUtility.setValues(allCartesian,'ZGrid',oldazg);
                printUtility.setValues(allCartesian,'Box',oldBox);
                printUtility.setValues(allAxAxles,'Visible',oldAxleVis);
                printUtility.setValues(allAxMajorTicks,'Visible',oldMajorTickVis);
                printUtility.setValues(allAxMinorTicks,'Visible',oldMinorTickVis);
                printUtility.setValues(allContour,'Fill',oldContourFill);
                printUtility.setValues(allContour,'LineStyle',oldContourLineStyle);
                printUtility.setValues(allContour,'ShowText',oldContourText);


                printUtility.setValues(allScribeEdge,'EdgeColor',oldScribeEdge);
                printUtility.setValues(allScribe1DirArrow,'HeadStyle',oldScribe1DirArrowHead);
                printUtility.setValues(allScribe1DirArrow,'LineStyle',oldScribe1DirArrowLine);
                printUtility.setValues(allScribe2DirArrow,'Head1Style',oldScribe2DirArrowHead1);
                printUtility.setValues(allScribe2DirArrow,'Head2Style',oldScribe2DirArrowHead2);
                printUtility.setValues(allScribe2DirArrow,'LineStyle',oldScribe2DirArrowLine);
            elseif~isClipboard
                if(strcmp(opts.Format,'fig'))
                    saveas(H,filename);
                else
                    print(H,filename,args{:});
                end

            else
                driver=find(strncmp(args,'-d',2));
                if strcmp(get(H,'renderer'),'painters')
                    args{driver}='-dmeta';
                else
                    args{driver}='-dbitmap';
                end
                print(H,args{:});
            end
        end
        warning(oldwarn);

    catch ex
        warning(oldwarn);
        hadError=1;
    end




    if ishghandle(H,'figure')&&isappdata(H,'BusyPrinting')
        rmappdata(H,'BusyPrinting');
    end

    if isequal(opts.ApplyStyle,1)
        drawnow;
        varargout{1}=old;
    else
        restoreExport(old);
    end

    if hadError
        error(deblank(ex.getReport('basic','hyperlinks','off')));
    end




    function bool=LocalIsPositiveScalar(value)
        bool=isnumeric(value)&&...
        numel(value)==1&&...
        value>0;
    end




    function value=LocalToNum(value,auto)
        if ischar(value)
            if strcmp(value,'auto')
                value=auto;
            else
                value=str2double(value);
            end
        end
    end



    function val=LocalCheckAuto(val,auto)
        if ischar(val)&&strcmp(val,'auto')
            val=auto;
        end
    end



    function auto=LocalFactoryStyle
        auto.Version=1;
        auto.Format='eps';
        auto.Preview='none';
        auto.Width='auto';
        auto.Height='auto';
        auto.Units=get(0,'DefaultFigurePaperUnits');
        auto.Color='rgb';
        auto.Background='w';
        auto.FixedFontSize=10;
        auto.ScaledFontSize='auto';
        auto.FontMode='scaled';
        auto.FontSizeMin=8;
        auto.FixedLineWidth=1.0;
        auto.ScaledLineWidth='auto';
        auto.LineMode='none';
        auto.LineWidthMin=0.5;
        auto.FontName='auto';
        auto.FontWeight='auto';
        auto.FontAngle='auto';
        auto.FontEncoding='latin1';
        auto.PSLevel=3;
        auto.Renderer='auto';
        auto.Resolution='auto';
        auto.LineStyleMap='none';
        auto.ApplyStyle=0;
        auto.Bounds='loose';
        auto.LockAxes='on';

        auto.LockAxesTicks='off';
        auto.ShowUI='on';
        auto.SeparateText='off';
    end








    function c=LocalToCell(s,auto)
        f=fieldnames(s);
        v=struct2cell(s);
        dup=false(length(f),1);
        for my_k=1:length(f)
            try
                if isequal(auto.(f{my_k}),s.(f{my_k}))
                    dup(my_k)=true;
                end
            catch ex
            end
        end
        f(dup)=[];
        v(dup)=[];
        opts=cell(2,length(f));
        opts(1,:)=f;
        opts(2,:)=v;
        c=opts(:)';
    end





    function h=LocalReadStyle(stylename)
        stylefile=fullfile(prefdir(0),'ExportSetup',[stylename,'.txt']);
        if~exist(stylefile,'file')
            error(message('MATLAB:hgexport:StyleNotFound',stylename));
        end
        fid=fopen(stylefile,'r');
        cleanupHandler=onCleanup(@()closeFile(fid));
        C=textscan(fid,'%s%[^\n]');
        p=strtrim(C{1});
        v=strtrim(C{2});
        h=hgexport('factorystyle');
        for my_k=1:length(p)
            h.(p{my_k})=v{my_k};
        end
    end


    function closeFile(fid)
        if fid>0
            fclose(fid);
        end
    end













    function LocalWriteStyle(h,stylename)
        stylefile=fullfile(prefdir(0),'ExportSetup',[stylename,'.txt']);
        fid=fopen(stylefile,'wt');
        props=fieldnames(h);
        for my_k=1:length(props)
            prop=props{my_k};
            val=h.(props{my_k});
            if isempty(val)
                if ischar(val)
                    fprintf(fid,'%s \n',prop);
                else
                    fprintf(fid,'%s []\n',prop);
                end
            elseif ischar(val)
                fprintf(fid,'%s %s\n',prop,val);
            else
                fprintf(fid,'%s %g\n',prop,val);
            end
        end
        fclose(fid);
    end
end


function isImageFormat=LocalIsImageFormat(device)


    persistent imageFormats;


    if strncmpi(device,'jpeg',4)||strcmpi(device,'meta')||strcmpi(device,'svg')
        isImageFormat=true;
        return;
    end

    if isempty(imageFormats)

        [~,devices,~,classes]=printtables;
        imidx=strcmp(classes,'IM');
        epidx=strcmp(classes,'EP');
        imageFormats=devices(imidx|epidx);
    end

    matches=find(strncmpi(device,imageFormats,length(device)));
    if length(matches)>1
        matches=find(strcmpi(device,imageFormats));
    end


    if~isempty(matches)
        isImageFormat=true;
    else
        isImageFormat=false;
    end
end
