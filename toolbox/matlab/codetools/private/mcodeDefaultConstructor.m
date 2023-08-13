function mcodeDefaultConstructor(hObj,hCode)

    if ishghandle(hObj)
        localSetConstructorFunction(hObj,hCode);
    end
    if ishghandle(hObj,'axes')
        localHGAxes_createConstructor(hObj,hCode);
    elseif ishghandle(hObj,'surface')
        localHGSurface_createConstructor(hObj,hCode);
    elseif ishghandle(hObj,'line')
        localHGLine_createConstructor(hObj,hCode);
    elseif ishghandle(hObj,'image')
        localHGImage_createConstructor(hObj,hCode);
    elseif ishghandle(hObj,'figure')
        localHGFigure_createConstructor(hObj,hCode);
    elseif isa(hObj,'matlab.graphics.primitive.Text')
        localHGText_createConstructor(hObj,hCode);
    elseif strncmp(class(hObj),'ui',2)||isa(hObj,'matlab.ui.control.Component')
        localUI_createConstructor(hObj,hCode);
    else

        generateDefaultPropValueSyntax(hCode);
    end



    function localSetConstructorFunction(hObj,hCode)

        Func=localClassToFunction(class(hObj));
        hCode.setConstructorName(Func);




        function Func=localNonGuideClassToFunction(FullClass)





            ContainerClassToFuncMap={...
            'matlab.ui.container.Tab','uitab';...
            'matlab.ui.container.TabGroup','uitabgroup';...
            };

            ContainerClassIndex=find(strcmp(FullClass,ContainerClassToFuncMap(:,1)));
            if~isempty(ContainerClassIndex)
                Func=ContainerClassToFuncMap{ContainerClassIndex,2};
            else
                Func=[];
            end



            function Func=localClassToFunction(FullClass)

                ClassToFuncMap={...
                'matlab.graphics.axis.Axes','axes';...
                'matlab.graphics.primitive.Group','hggroup';...
                'matlab.graphics.primitive.Image','image';...
                'matlab.graphics.primitive.Light','light';...
                'matlab.graphics.primitive.Line','line';...
                'matlab.graphics.primitive.Patch','patch';...
                'matlab.graphics.primitive.Rectangle','rectangle';...
                'matlab.graphics.primitive.Surface','surface';...
                'matlab.graphics.primitive.Text','text';...
                'matlab.ui.Root','root';...
                'matlab.graphics.primitive.Transform','hgtransform';...
                'matlab.ui.Figure','figure';...
                'matlab.ui.container.Menu','uimenu';...
                'matlab.ui.container.ContextMenu','uicontextmenu';...
                'matlab.ui.control.UIControl','uicontrol';...
                'matlab.ui.control.Table','uitable';...
                'matlab.ui.container.internal.UIContainer','uicontainer';...
                'matlab.ui.container.internal.JavaWrapper','hgjavacomponent';...
                'matlab.ui.container.Panel','uipanel';...
                'matlab.ui.container.internal.UIFlowContainer','uiflowcontainer';...
                'matlab.ui.container.internal.UIGridContainer','uigridcontainer';...
                'matlab.ui.container.Toolbar','uitoolbar';...
                'matlab.ui.container.toolbar.PushTool','uipushtool';...
                'matlab.ui.container.toolbar.SplitTool','uisplittool';...
                'matlab.ui.container.toolbar.ToggleSplitTool','uitogglesplittool';...
                'matlab.ui.container.toolbar.ToggleTool','uitoggletool';...
                };

                ClassIndex=find(strcmp(FullClass,ClassToFuncMap(:,1)));

                if~isempty(ClassIndex)
                    Func=ClassToFuncMap{ClassIndex,2};
                else

                    nonGuideClass=localNonGuideClassToFunction(FullClass);
                    if~isempty(nonGuideClass)
                        Func=nonGuideClass;
                    else

                        Func=FullClass;
                    end
                end


                function localHGFigure_createConstructor(hObj,hCode)




                    hRef=get(hCode,'MomentoRef');
                    hProps=get(hRef,'PropertyObject');
                    propIndex=find(strcmpi(get(hProps,'Name'),'Colormap'));
                    if~isempty(propIndex)
                        colormap_name=[];
                        cmap=get(hObj,'Colormap');
                        known_colormaps={'parula','jet','hsv','hot','gray','bone','copper','pink','white','flag','lines','colorcube','prism','cool','autumn','spring','winter','summer'};
                        defaultColorMapSize=size(get(groot,'DefaultFigureColormap'),1);
                        for n=1:length(known_colormaps)
                            if isequal(cmap,feval(known_colormaps{n},defaultColorMapSize))
                                colormap_name=known_colormaps{n};


                                set(hProps(propIndex),'Ignore',true);
                                break;
                            elseif isequal(cmap,feval(known_colormaps{n},length(cmap)))
                                colormap_name=[known_colormaps{n},'(',num2str(length(cmap)),')'];


                                set(hProps(propIndex),'Ignore',true);
                                break;
                            end
                        end
                        if~isempty(colormap_name)
                            hCode.addPostConstructorText('colormap(',colormap_name,');');
                        end
                    end

                    generateDefaultPropValueSyntax(hCode);


                    function localHGText_createConstructor(hObj,hCode)


                        hObj=handle(hObj);
                        hAxes=hObj.Parent;
                        if ishghandle(hAxes,'axes')
                            islabel=true;


                            str=[];
                            if isSameLabelHandle(hObj,hAxes.XLabel_IS)
                                str='xlabel';
                            elseif isSameYLabelHandle(hObj,hAxes)
                                str='ylabel';
                            elseif isSameLabelHandle(hObj,hAxes.ZLabel_IS)
                                str='zlabel';
                            elseif isSameLabelHandle(hObj,hAxes.Title_IS)
                                str='title';
                                islabel=false;
                            end

                            if islabel&&strcmp(hAxes.Visible,'off')


                                addProperty(hCode,'Visible')
                            end

                            if~isempty(str)
                                localAxesLabelMCodeConstructor(hObj,hCode,str)
                            else
                                generateDefaultPropValueSyntax(hCode);
                            end
                        else

                            generateDefaultPropValueSyntax(hCode);
                        end


                        function ret=isSameYLabelHandle(hObj,hAxes)
                            ret=false;
                            for i=1:numel(hAxes.YAxis)
                                if isSameLabelHandle(hObj,hAxes.YAxis(i).Label_IS)
                                    ret=true;
                                    break;
                                end
                            end





                            function ret=isSameLabelHandle(h1,h2)


                                if~isempty(h2)
                                    ret=h1==h2;
                                else
                                    ret=false;
                                end


                                function localAxesLabelMCodeConstructor(hObj,hCode,strname)


                                    val=get(hObj,'String');
                                    hAxes=ancestor(hObj,'axes');
                                    is2Daxes=is2D(hAxes);

                                    if isempty(val)||strcmp(hObj.StringMode,'auto')


                                        hCode.Constructor=[];

                                    else
                                        setConstructorName(hCode,strname);


                                        ignoreProperty(hCode,{'String','Parent','Position'});


                                        switch(lower(strname))
                                        case 'title'
                                            addPropertyIfChanged(hCode,'HorizontalAlignment','center');
                                            addPropertyIfChanged(hCode,'VerticalAlignment','bottom');
                                        case 'xlabel'
                                            if~is2Daxes
                                                addPropertyIfChanged(hCode,'HorizontalAlignment','left');
                                                addPropertyIfChanged(hCode,'VerticalAlignment','top');
                                            else
                                                addPropertyIfChanged(hCode,'HorizontalAlignment','center');
                                                addPropertyIfChanged(hCode,'VerticalAlignment','cap');
                                            end
                                        case 'ylabel'
                                            if~is2Daxes
                                                addPropertyIfChanged(hCode,'HorizontalAlignment','right');
                                                addPropertyIfChanged(hCode,'VerticalAlignment','top');
                                            else
                                                addPropertyIfChanged(hCode,'HorizontalAlignment','center');
                                                addPropertyIfChanged(hCode,'VerticalAlignment','bottom');
                                                addPropertyIfChanged(hCode,'Rotation',90);
                                            end
                                        case 'zlabel'
                                            if~is2Daxes
                                                addPropertyIfChanged(hCode,'HorizontalAlignment','center');
                                                addPropertyIfChanged(hCode,'VerticalAlignment','bottom');
                                                addPropertyIfChanged(hCode,'Rotation',90);
                                            else
                                                addPropertyIfChanged(hCode,'HorizontalAlignment','right');
                                                addPropertyIfChanged(hCode,'VerticalAlignment','middle');
                                            end
                                        end


                                        hArg=codegen.codeargument('Value',val);
                                        set(hArg,'DataTypeDescriptor',codegen.DataTypeDescriptor.CharNoNewLineNoDeblank);
                                        addConstructorArgin(hCode,hArg);


                                        generateDefaultPropValueSyntaxNoOutput(hCode);
                                    end


                                    function localHGImage_createConstructor(hObj,hCode)



                                        ignoreProperty(hCode,{'XData','YData','CData'});


                                        xdata=get(hObj,'XData');
                                        ydata=get(hObj,'YData');
                                        cdata=get(hObj,'CData');
                                        m=size(cdata,1);
                                        n=size(cdata,2);



                                        if~isequal(xdata,[1,n])||~isequal(ydata,[1,m])
                                            hArg=codegen.codeargument('Name','xdata','Value',xdata);
                                            addConstructorArgin(hCode,hArg);
                                            hArg=codegen.codeargument('Name','ydata','Value',ydata);
                                            addConstructorArgin(hCode,hArg);
                                        end


                                        hArg=codegen.codeargument('Name','cdata','Value',cdata,'IsParameter',true);
                                        addConstructorArgin(hCode,hArg);


                                        generateDefaultPropValueSyntax(hCode);


                                        function localHGLine_createConstructor(hObj,hCode)

                                            ignoreProperty(hCode,{'XData','YData','ZData'});

                                            xdata=get(hObj,'XData');
                                            ydata=get(hObj,'YData');
                                            zdata=get(hObj,'ZData');


                                            hArg=codegen.codeargument('Name','XData','Value',xdata,'IsParameter',true);
                                            addConstructorArgin(hCode,hArg);


                                            hArg=codegen.codeargument('Name','YData','Value',ydata,'IsParameter',true);
                                            addConstructorArgin(hCode,hArg);


                                            if~isempty(zdata)
                                                hArg=codegen.codeargument('Name','ZData','Value',zdata,'IsParameter',true);
                                                addConstructorArgin(hCode,hArg);
                                            end


                                            generateDefaultPropValueSyntax(hCode);


                                            function localHGSurface_createConstructor(hObj,hCode)







                                                xdata=get(hObj,'xdata');
                                                ydata=get(hObj,'ydata');
                                                zdata=get(hObj,'zdata');
                                                m=size(zdata,1);
                                                n=size(zdata,2);


                                                if isequal(xdata,1:m)&&isequal(ydata',1:n)
                                                    ignoreProperty(hCode,{'XData','YData','ZData'});


                                                    hArg=codegen.codeargument('Name','ZData','Value',zdata,'IsParameter',true);
                                                    addConstructorArgin(hCode,hArg);
                                                end


                                                if strcmp(get(hObj,'VertexNormalsMode'),'auto')
                                                    ignoreProperty(hCode,{'VertexNormals'});
                                                end


                                                generateDefaultPropValueSyntax(hCode);





                                                function localHGAxes_createConstructor(hObj,hCode)


                                                    isYYaxis=numel(hObj.YAxis)==2;


                                                    if isYYaxis
                                                        local_set_YYaxis_code(hObj,hCode);
                                                    end





                                                    localMoveTextToCodegenEnd(hObj,hCode);



                                                    if strcmpi(get(hObj,'PositionConstraint'),'innerposition')
                                                        ignoreProperty(hCode,{'PositionConstraint','OuterPosition'});
                                                    else
                                                        ignoreProperty(hCode,{'PositionConstraint','Position'});
                                                    end


                                                    ignoreProperty(hCode,'InnerPosition');


                                                    ignoreProperty(hCode,{'xlim','ylim','zlim'});


                                                    ignoreProperty(hCode,{'Layout'});






                                                    hFig=handle(ancestor(hObj,'figure'));
                                                    appdata=handle(getappdata(hFig,'SubplotGrid'));
                                                    if any(hObj==appdata(:))
                                                        ignoreProperty(hCode,{'Position'});

                                                        [row,col]=find(appdata==hObj);

                                                        row=size(appdata,1)-row+1;

                                                        gridRow=size(appdata,1);
                                                        gridCol=size(appdata,2);

                                                        ind=sub2ind([gridCol,gridRow],col,row);

                                                        setConstructorName(hCode,'subplot');
                                                        hRowArg=codegen.codeargument('Value',gridRow);
                                                        hColArg=codegen.codeargument('Value',gridCol);
                                                        hInd=codegen.codeargument('Value',ind);
                                                        addConstructorArgin(hCode,hRowArg);
                                                        addConstructorArgin(hCode,hColArg);
                                                        addConstructorArgin(hCode,hInd);
                                                    end



                                                    if hasProperty(hCode,'View')&&hasProperty(hCode,'CameraPosition')
                                                        ignoreProperty(hCode,'View');
                                                    end



                                                    if strcmp(get(hObj,'XTickMode'),'manual')&&~hasProperty(hCode,'XTick')
                                                        addProperty(hCode,'XTick');
                                                    end
                                                    if strcmp(get(hObj,'YTickMode'),'manual')&&~hasProperty(hCode,'YTick')
                                                        addProperty(hCode,'YTick');
                                                    end
                                                    if~is2D(hObj)&&strcmp(get(hObj,'ZTickMode'),'manual')&&~hasProperty(hCode,'ZTick')
                                                        addProperty(hCode,'ZTick');
                                                    end

                                                    if strcmp(get(hObj,'XTickLabelMode'),'manual')&&~hasProperty(hCode,'XTickLabel')
                                                        addProperty(hCode,'XTickLabel');
                                                    end
                                                    if strcmp(get(hObj,'YTickLabelMode'),'manual')&&~hasProperty(hCode,'YTickLabel')
                                                        addProperty(hCode,'YTickLabel');
                                                    end
                                                    if~is2D(hObj)&&strcmp(get(hObj,'ZTickLabelMode'),'manual')&&~hasProperty(hCode,'ZTickLabel')
                                                        addProperty(hCode,'ZTickLabel');
                                                    end

                                                    if strcmpi(get(hObj,'DataAspectRatioMode'),'manual')&&~hasProperty(hCode,'DataAspectRatio')
                                                        addProperty(hCode,'DataAspectRatio');
                                                    end






                                                    if hasProperty(hCode,'XDir')||hasProperty(hCode,'YDir')||hasProperty(hCode,'ZDir')
                                                        if strcmp(get(hObj,'CameraUpVectorMode'),'manual')
                                                            addProperty(hCode,'CameraUpVector');
                                                        end
                                                        if strcmp(get(hObj,'CameraPositionMode'),'manual')
                                                            addProperty(hCode,'CameraPosition');
                                                        end
                                                    end




                                                    if isappdata(double(hObj),'LegendColorbarExpectedPosition')&&...
                                                        isequal(getappdata(double(hObj),'LegendColorbarExpectedPosition'),get(hObj,'Position'))
                                                        inset=getappdata(hObj,'LegendColorbarOriginalInset');
                                                        if isempty(inset)

                                                            inset=get(get(hObj,'Parent'),'DefaultAxesLooseInset');
                                                        end
                                                        inset=offsetsInUnits(hObj,inset,'normalized',get(hObj,'Units'));
                                                        if strcmpi(get(hObj,'ActivePositionProperty'),'position')
                                                            pos=get(hObj,'Position');
                                                            loose=get(hObj,'LooseInset');
                                                            opos=getOuterFromPosAndLoose(pos,loose,get(hObj,'Units'));
                                                            if strcmp(get(hObj,'Units'),'normalized')
                                                                inset=[opos(3:4),opos(3:4)].*inset;
                                                            end
                                                            pos=[opos(1:2)+inset(1:2),opos(3:4)-inset(1:2)-inset(3:4)];
                                                            if~any(isnan(pos))&&all(pos(3:4)>0)
                                                                posProp=hCode.getProperty('Position');
                                                                set(posProp,'Value',pos);
                                                            end
                                                        end
                                                    end




                                                    ignoreProperty(hCode,{'ColorOrderIndex'});






                                                    if strcmp(get(hObj,'Visible'),'off')




                                                        ignoreProperty(hCode,{'Visible'});
                                                        hCode.addPostConstructorText('axis off');
                                                    end



                                                    localAddAxesHelperFunctions(hObj,hCode);










                                                    propsForAxesConstructor={'Units','Parent','Position','Tag','ColorOrder'};


                                                    hRef=get(hCode,'MomentoRef');
                                                    hProps=get(hRef,'PropertyObject');
                                                    propIndex=find(strcmpi(get(hProps,'Name'),'ColorOrder'));
                                                    validColorMap=false;
                                                    if~isempty(propIndex)
                                                        colormapInput=[];
                                                        cmap=get(hObj,'ColorOrder');
                                                        known_colormaps={'parula','jet','hsv','hot','gray','bone','copper','pink','white','flag','lines','colorcube','prism','cool','autumn','spring','winter','summer'};
                                                        defaultColorMapSize=size(get(groot,'DefaultFigureColormap'),1);

                                                        for n=1:length(known_colormaps)
                                                            if isequal(cmap,feval(known_colormaps{n},defaultColorMapSize))

                                                                colormapInput=known_colormaps{n};
                                                                validColorMap=true;
                                                                break;
                                                            elseif isequal(cmap,feval(known_colormaps{n},length(cmap)))

                                                                colormapInput=[known_colormaps{n},'(',num2str(length(cmap)),')'];
                                                                validColorMap=true;
                                                                break;
                                                            end
                                                        end

                                                        if validColorMap
                                                            hCode.addPostConstructorText('colororder(',colormapInput,');');
                                                        else

                                                            hCode.addPostConstructorText(['colororder(',mat2str(hProps(propIndex).Value),');']);
                                                        end


                                                        set(hProps(propIndex),'Ignore',true);
                                                    end



                                                    props=setdiff(properties(hObj),propsForAxesConstructor);


                                                    if isYYaxis

                                                        yyprops={'YColor','YDir','YMinorTick','YScale','YTick','YTickLabel'};
                                                        props=setdiff(props,yyprops);

                                                    end



                                                    hFunc=local_CreateAxesSetPropertiesFunction(hObj,hCode,props);
                                                    if~isempty(hFunc)


                                                        ignoreProperty(hCode,props);


                                                        hCode.addPostChildFunction(hFunc);
                                                    end


                                                    generateDefaultPropValueSyntax(hCode);


                                                    function localAddAxesHelperFunctions(hObj,hCode)





                                                        ignoreProperty(hCode,{'xlim','ylim','zlim'});


                                                        is_xauto=strcmpi(get(hObj,'XLimMode'),'auto');
                                                        is_yauto=strcmpi(get(hObj,'YLimMode'),'auto');
                                                        is_zauto=strcmpi(get(hObj,'ZLimMode'),'auto');
                                                        xlm=get(hObj,'XLim');
                                                        ylm=get(hObj,'YLim');
                                                        zlm=get(hObj,'ZLim');

                                                        if numel(hObj.YAxis)==2
                                                            is_yauto=1;
                                                        end




                                                        hAxesArg=codegen.codeargument('Value',hObj,'IsParameter',true);
                                                        if isnumeric(xlm)&&~is_xauto
                                                            hCode.addPostChildFunction(codegen.codetext(['% ',getString(...
                                                            message('MATLAB:codetools:private:mcodeDefaultConstructor:UncommentLineToPreserveXlimits'))]));
                                                            hArg=codegen.codeargument('Value',xlm);
                                                            hCode.addPostChildFunction(codegen.codetext('% xlim(',hAxesArg,',',hArg,');'));
                                                        end
                                                        if isnumeric(ylm)&&~is_yauto
                                                            hCode.addPostChildFunction(codegen.codetext(['% ',getString(...
                                                            message('MATLAB:codetools:private:mcodeDefaultConstructor:UncommentLineToPreserveylimits'))]));
                                                            hArg=codegen.codeargument('Value',ylm);
                                                            hCode.addPostChildFunction(codegen.codetext('% ylim(',hAxesArg,',',hArg,');'));
                                                        end
                                                        if isnumeric(zlm)&&~is_zauto
                                                            hCode.addPostChildFunction(codegen.codetext(['% ',getString(...
                                                            message('MATLAB:codetools:private:mcodeDefaultConstructor:UncommentLineToPreservezlimits'))]));
                                                            hArg=codegen.codeargument('Value',zlm);
                                                            hCode.addPostChildFunction(codegen.codetext('% zlim(',hAxesArg,',',hArg,');'));
                                                        end




                                                        if hasProperty(hCode,'View')
                                                            ignoreProperty(hCode,'View');
                                                            hCode.addPostChildFunction(local_CreateAxesHelperFunction(hObj,hCode,'view',get(hObj,'View')));
                                                        end






                                                        if hasProperty(hCode,'Box')
                                                            ignoreProperty(hCode,'Box');
                                                            hCode.addPostChildFunction(local_CreateAxesHelperFunction(hObj,hCode,'box',get(hObj,'Box')));
                                                        end




                                                        is_xgrid=strcmpi(get(hObj,'XGrid'),'on');
                                                        is_ygrid=strcmpi(get(hObj,'YGrid'),'on');
                                                        is_zgrid=strcmpi(get(hObj,'ZGrid'),'on');
                                                        if is_xgrid&&is_ygrid&&is_zgrid
                                                            ignoreProperty(hCode,{'XGrid','YGrid','ZGrid'});
                                                            hCode.addPostChildFunction(local_CreateAxesHelperFunction(hObj,hCode,'grid','on'));
                                                        end




                                                        if is_xauto&&is_yauto&&is_zauto...
                                                            &&strcmp(hObj.XLimSpec,'tight')...
                                                            &&strcmp(hObj.YLimSpec,'tight')...
                                                            &&strcmp(hObj.ZLimSpec,'tight')
                                                            ignoreProperty(hCode,{'XLimSpec','YLimSpec','ZLimSpec','XLimitMethod','YLimitMethod','ZLimitMethod'});
                                                            hCode.addPostChildFunction(local_CreateAxesHelperFunction(hObj,hCode,'axis','tight'));
                                                        end




                                                        if strcmp(hObj.PlotBoxAspectRatioMode,'manual')&&...
                                                            strcmp(hObj.DataAspectRatioMode,'auto')&&...
                                                            isequal(hObj.PlotBoxAspectRatio,[1,1,1])
                                                            ignoreProperty(hCode,{'PlotBoxAspectRatio','PlotBoxAspectRatioMode'});
                                                            hCode.addPostChildFunction(local_CreateAxesHelperFunction(hObj,hCode,'axis','square'));
                                                        end




                                                        if strcmp(hObj.XDir,'normal')&&...
                                                            strcmp(hObj.YDir,'reverse')
                                                            ignoreProperty(hCode,{'XDir','YDir'});
                                                            hCode.addPostChildFunction(local_CreateAxesHelperFunction(hObj,hCode,'axis','ij'));
                                                        end






                                                        if is_xauto&&is_yauto&&is_zauto...
                                                            &&strcmp(hObj.XLimSpec,'padded')...
                                                            &&strcmp(hObj.YLimSpec,'padded')...
                                                            &&strcmp(hObj.ZLimSpec,'padded')
                                                            ignoreProperty(hCode,{'XLimSpec','YLimSpec','ZLimSpec','XLimitMethod','YLimitMethod','ZLimitMethod'});
                                                            hCode.addPostChildFunction(local_CreateAxesHelperFunction(hObj,hCode,'axis','padded'));
                                                        end






                                                        hc=hObj.HintConsumer;
                                                        if strcmp(hc.BubbleSizeLimitsMode,'manual')
                                                            bl=hc.BubbleSizeLimits;
                                                            hCode.addPostChildFunction(codegen.codetext('bubblelim(',hAxesArg,',[',num2str(bl(1)),' ',num2str(bl(2)),']);'));
                                                        end
                                                        if strcmp(hc.BubbleSizeRangeMode,'manual')
                                                            bs=hc.BubbleSizeRange;
                                                            hCode.addPostChildFunction(codegen.codetext('bubblesize(',hAxesArg,',[',num2str(bs(1)),' ',num2str(bs(2)),']);'));
                                                        end



                                                        do_hold_all=true;








                                                        if(do_hold_all&&...
                                                            (strcmpi(get(hObj,'NextPlot'),'add')||~isempty(plotchild(hObj)))...
                                                            )
                                                            hCode.addPostConstructorFunction(local_CreateAxesHelperFunction(hObj,hCode,'hold','on'));
                                                            hCode.addPostChildFunction(local_CreateAxesHelperFunction(hObj,hCode,'hold','off'));
                                                        end

                                                        ignoreProperty(hCode,'NextPlot');


                                                        function hFunc=local_CreateAxesHelperFunction(hObj,hCode,fname,fval)




                                                            hFunc=codegen.codefunction('Name',fname,'CodeRef',hCode);


                                                            hAxesArg=codegen.codeargument('Value',hObj,'IsParameter',true);
                                                            addArgin(hFunc,hAxesArg);
                                                            hArg=codegen.codeargument('Value',fval);
                                                            addArgin(hFunc,hArg);


                                                            function localUI_createConstructor(hObj,hCode)

                                                                hFunc=getConstructor(hCode);
                                                                constructorString=hFunc.Name;
                                                                str=sprintf('%% %s(...)',constructorString);
                                                                set(hFunc,'Name',str);

                                                                comment=['% ',getString(message('MATLAB:codetools:private:mcodeDefaultConstructor:CurrentlyDoesNotSupportCodeGen',constructorString,constructorString))];
                                                                if isempty(localNonGuideClassToFunction(class(hObj)))

                                                                    comment=[comment,sprintf('\n'),...
                                                                    '% ',getString(message('MATLAB:codetools:private:mcodeDefaultConstructor:InOrderToGenerateCodeUseGUIDE',constructorString))];
                                                                end
                                                                set(hFunc,'Comment',comment);




                                                                function out=offsetsInUnits(ax,in,from,to)
                                                                    fig=ancestor(ax,'figure');
                                                                    par=get(ax,'Parent');
                                                                    p1=hgconvertunits(fig,[0,0,in(1:2)],from,to,par);
                                                                    p2=hgconvertunits(fig,[0,0,in(3:4)],from,to,par);
                                                                    out=[p1(3:4),p2(3:4)];





                                                                    function outer=getOuterFromPosAndLoose(pos,loose,units)
                                                                        if strcmp(units,'normalized')

                                                                            w=pos(3)/(1-loose(1)-loose(3));
                                                                            h=pos(4)/(1-loose(2)-loose(4));
                                                                            loose=[w,h,w,h].*loose;
                                                                        end
                                                                        outer=[pos(1:2)-loose(1:2),pos(3:4)+loose(1:2)+loose(3:4)];






                                                                        function localMoveTextToCodegenEnd(ax,hCode)





                                                                            objsToRemove=[ax.XLabel_IS,ax.ZLabel_IS,ax.Title_IS];
                                                                            if numel(ax.YAxis)==1
                                                                                objsToRemove=[objsToRemove,ax.YLabel_IS];
                                                                            end

                                                                            objsCode=[];

                                                                            children=hCode.getChildren();

                                                                            for i=1:numel(children)
                                                                                child=children(i);
                                                                                if~isempty(child.MomentoRef)
                                                                                    childRef=child.MomentoRef.ObjectRef;
                                                                                else
                                                                                    childRef=[];
                                                                                end

                                                                                if~isempty(childRef)
                                                                                    if any(childRef==objsToRemove)



                                                                                        objsCode=[objsCode,child];%#ok<AGROW>
                                                                                        disconnect(child)
                                                                                    end
                                                                                end
                                                                            end


                                                                            if~isempty(objsCode)
                                                                                hCode.addChildren(objsCode);
                                                                            end



                                                                            function hFunc=local_CreateAxesSetPropertiesFunction(hObj,hAxesCode,propName)




                                                                                hFunc=codegen.codefunction('Name','set','CodeRef',hAxesCode,...
                                                                                'Comment',...
                                                                                getString(message('MATLAB:codetools:private:mcodeDefaultConstructor:SetRemainingAxesPropertiesComment')));
                                                                                propsSet=false;


                                                                                hAxesArg=codegen.codeargument('Value',hObj,'IsParameter',true);
                                                                                addArgin(hFunc,hAxesArg);

                                                                                if ischar(propName)
                                                                                    propName={propName};
                                                                                end
                                                                                labelProps={'XTickLabel','YTickLabel','ZTickLabel'};

                                                                                for i=1:length(propName)

                                                                                    if hasProperty(hAxesCode,propName{i})

                                                                                        propArg=codegen.codeargument('Value',propName{i});
                                                                                        addArgin(hFunc,propArg);
                                                                                        val=get(hObj,propName{i});

                                                                                        hArg=codegen.codeargument('Value',val);
                                                                                        if any(ismember(propName{i},labelProps))
                                                                                            hArg.DataTypeDescriptor=codegen.DataTypeDescriptor.CharNoNewLineNoDeblank;
                                                                                        end
                                                                                        addArgin(hFunc,hArg);
                                                                                        propsSet=true;
                                                                                    end
                                                                                end

                                                                                if~propsSet

                                                                                    hFunc=[];
                                                                                end



                                                                                function hFunc=local_createYYaxisSideFnc(hObj,hCode,side)

                                                                                    hFunc=[];
                                                                                    if isempty(side)||side==0||side>2
                                                                                        return
                                                                                    end

                                                                                    if(side==1)
                                                                                        side='left';
                                                                                    else
                                                                                        side='right';
                                                                                    end


                                                                                    comment=sprintf(getString(message('MATLAB:codetools:private:mcodeDefaultConstructor:SetActiveDataSpaceComment',side)));
                                                                                    hFunc=codegen.codefunction('Name','yyaxis','CodeRef',hCode,'Comment',comment);

                                                                                    hAxesArg=codegen.codeargument('Value',hObj,'IsParameter',true);
                                                                                    addArgin(hFunc,hAxesArg);

                                                                                    hAxesArgSide=codegen.codeargument('Value',side);
                                                                                    addArgin(hFunc,hAxesArgSide);


                                                                                    function side=local_getDataSpaceForChild(child)





                                                                                        ax=ancestor(child,'axes');
                                                                                        side=[];

                                                                                        if isempty(ax)||~ishghandle(ax,'axes')||~isa(ax,'matlab.graphics.axis.Axes')
                                                                                            return
                                                                                        end

                                                                                        if isa(child,'matlab.graphics.primitive.Text')
                                                                                            for i=1:length(ax.YAxis)
                                                                                                if child==ax.YAxis(i).Label_IS
                                                                                                    side=i;
                                                                                                    return
                                                                                                end
                                                                                            end
                                                                                        end


                                                                                        for i=1:length(ax.TargetManager.Children)
                                                                                            if any(child==findobj(ax.TargetManager.Children(i).ChildContainer.Children))
                                                                                                side=i;
                                                                                                break;
                                                                                            end
                                                                                        end



                                                                                        function hFunc=local_createYYaxisManualPropsFnc(hObj,hAxesCode,side)


                                                                                            props={'Color','YColor','Direction','YDir','MinorTick','YMinorTick','Scale','YScale','TickValues','YTick','TickLabels','YTickLabel'};

                                                                                            hFunc=codegen.codefunction('Name','set','CodeRef',hAxesCode,...
                                                                                            'Comment',...
                                                                                            getString(message('MATLAB:codetools:private:mcodeDefaultConstructor:SetRemainingAxesPropertiesComment')));
                                                                                            propsSet=false;


                                                                                            hAxesArg=codegen.codeargument('Value',hObj,'IsParameter',true);
                                                                                            addArgin(hFunc,hAxesArg);


                                                                                            for i=1:2:length(props)

                                                                                                if strcmpi(get(hObj.YAxis(side),strcat(props(i),'Mode')),'manual')
                                                                                                    propArg=codegen.codeargument('Value',props{i+1});
                                                                                                    addArgin(hFunc,propArg);
                                                                                                    val=get(hObj.YAxis(side),props{i});
                                                                                                    hArg=codegen.codeargument('Value',val);
                                                                                                    addArgin(hFunc,hArg);
                                                                                                    propsSet=true;
                                                                                                end

                                                                                            end

                                                                                            if~propsSet

                                                                                                hFunc=[];
                                                                                            end


                                                                                            function local_setYLimFncForYYaxis(hObj,hCode,side)

                                                                                                if strcmpi(hObj.YLimMode,'manual')&&strcmpi(hObj.YAxis(side).LimitsMode,'manual')
                                                                                                    ylm=hObj.YAxis(side).Limits;

                                                                                                    hCode.addPostConstructorFunction(codegen.codetext(['% ',getString(...
                                                                                                    message('MATLAB:codetools:private:mcodeDefaultConstructor:UncommentLineToPreserveylimits'))]));
                                                                                                    hAxesArg=codegen.codeargument('Value',hObj,'IsParameter',true);
                                                                                                    hArg=codegen.codeargument('Value',ylm);
                                                                                                    hCode.addPostConstructorFunction(codegen.codetext('% ylim(',hAxesArg,',',hArg,');'));
                                                                                                end















                                                                                                function local_set_YYaxis_code(hObj,hCode)



                                                                                                    ignoreProperty(hCode,{'YAxisLocation'});
                                                                                                    ignoreProperty(hCode,{'LineStyleOrder'});
                                                                                                    ignoreProperty(hCode,{'ClippingStyle'});
                                                                                                    ignoreProperty(hCode,{'ColorOrder'});

                                                                                                    ignoreProperty(hCode,{'YColor'});
                                                                                                    ignoreProperty(hCode,{'YLim'});

                                                                                                    otherKids=[];
                                                                                                    leftKids=[];
                                                                                                    rightKids=[];

                                                                                                    children=hCode.getChildren();




                                                                                                    leftLabel=hObj.YAxis(1).Label_IS;
                                                                                                    rightLabel=hObj.YAxis(2).Label_IS;

                                                                                                    labelLeftCodeBlk=[];
                                                                                                    labelRightCodeBlk=[];

                                                                                                    for i=1:length(children)
                                                                                                        child=children(i);
                                                                                                        side=local_getDataSpaceForChild(child.MomentoRef.ObjectRef);
                                                                                                        if side==1
                                                                                                            if all(child.MomentoRef.ObjectRef~=leftLabel)
                                                                                                                leftKids=[leftKids,child];%#ok<AGROW>
                                                                                                            else
                                                                                                                labelLeftCodeBlk=child;
                                                                                                            end
                                                                                                        elseif side==2
                                                                                                            if all(child.MomentoRef.ObjectRef~=rightLabel)
                                                                                                                rightKids=[rightKids,child];%#ok<AGROW>
                                                                                                            else
                                                                                                                labelRightCodeBlk=child;
                                                                                                            end
                                                                                                        else
                                                                                                            otherKids=[otherKids,child];%#ok<AGROW>
                                                                                                        end
                                                                                                        disconnect(child);
                                                                                                    end



                                                                                                    leftKids=[leftKids,labelLeftCodeBlk];
                                                                                                    rightKids=[rightKids,labelRightCodeBlk];



                                                                                                    local_add_YYaxis_functions(leftKids,hCode,hObj,1);
                                                                                                    local_add_YYaxis_functions(rightKids,hCode,hObj,2);




                                                                                                    hCode.addChildren([leftKids,rightKids,otherKids]);





                                                                                                    function local_add_YYaxis_functions(childrenArray,hCode,hObj,side)

                                                                                                        if isempty(childrenArray)

                                                                                                            hCode.addPostConstructorFunction(local_createYYaxisSideFnc(hObj,hCode,side));
                                                                                                            hCode.addPostConstructorFunction(local_createYYaxisManualPropsFnc(hObj,hCode,side));
                                                                                                            local_setYLimFncForYYaxis(hObj,hCode,side);
                                                                                                        else


                                                                                                            firstChild=childrenArray(1);
                                                                                                            lastChild=childrenArray(end);

                                                                                                            firstChild.addPreConstructorFunction(local_createYYaxisSideFnc(hObj,hCode,side));
                                                                                                            lastChild.addPostChildFunction(local_createYYaxisManualPropsFnc(hObj,hCode,side));
                                                                                                            local_setYLimFncForYYaxis(hObj,lastChild,side);
                                                                                                        end






