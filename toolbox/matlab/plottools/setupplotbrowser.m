function setupplotbrowser(fig,plotbrowser,varargin)
    if isjava(plotbrowser)
        javaMethodEDT('clearAll',plotbrowser);
    end


    if nargin>=3&&strcmp(varargin{1},'-postUpdate')
        fig.PlotBrowserListener=[];
        localPostUpdate(fig,plotbrowser)
        return
    end


    addSceneViewerListeners(fig,plotbrowser);



    repopulatePlotBrowser(plotbrowser,fig)




    addlistener(fig,'ObjectChildAdded',@(es,ed)addSceneViewerListeners(ed.Child,plotbrowser));


    function addSceneViewerListeners(container,pb)





        if~isvalid(container)
            return
        end


        if ishghandle(container,'figure')



            if~isprop(container,'PlotBrowserListener')
                p=addprop(container,'PlotBrowserListener');
                p.Transient=true;
                p.Hidden=true;
            end
            container.PlotBrowserListener.Listener=event.listener(container.getCanvas(),'PostUpdate',...
            createPostUpdateListener(container,pb));
        elseif isa(container,'matlab.ui.internal.mixin.CanvasHostMixin')
            if~isprop(container,'ChildPlotBrowserSceneViewerListener')
                p=addprop(container,'ChildPlotBrowserSceneViewerListener');
                p.Transient=true;
                p.Hidden=true;
            end
            if isempty(container.ChildPlotBrowserSceneViewerListener)



                container.ChildPlotBrowserSceneViewerListener=event.listener(container.getCanvas(),'PostUpdate',...
                createFigurePostUpdateListener(pb));

            end
        end



        children=setdiff(findobj(container,'-isa','matlab.ui.internal.mixin.CanvasHostMixin'),container);
        for i=length(children):-1:1
            child=children(i);

            if~isprop(child,'ChildPlotBrowserSceneViewerListener')
                p=addprop(child,'ChildPlotBrowserSceneViewerListener');
                p.Transient=true;
                p.Hidden=true;
            end

            if isempty(child.ChildPlotBrowserSceneViewerListener)




                child.ChildPlotBrowserSceneViewerListener=event.listener(child.getCanvas(),'PostUpdate',...
                createFigurePostUpdateListener(pb));
            end
        end


        function removeSceneViewerListeners(container)


            if ishghandle(container,'figure')&&isprop(container,'PlotBrowserListener')&&...
                ~isempty(container.PlotBrowserListener)&&isvalid(container.PlotBrowserListener.Listener)
                delete(container.PlotBrowserListener.Listener);
                container.PlotBrowserListener=[];
            end



            children=setdiff(findobj(container,'-isa','matlab.ui.internal.mixin.CanvasHostMixin'),container);
            for i=length(children):-1:1
                child=children(i);
                if~isprop(child,'ChildPlotBrowserSceneViewerListener')||isempty(child.ChildPlotBrowserSceneViewerListener)
                    continue;
                end
                delete(child.ChildPlotBrowserSceneViewerListener);
                child.ChildPlotBrowserSceneViewerListener=[];
            end

            function repopulatePlotBrowser(pb,fig)





                selObjects=pb.getSelectedMatlabObjects();


                if isjava(pb)






                    javaMethodEDT('clearAll',pb,true);
                    javaMethodEDT('repaint',pb);
                end

                children=findobj(get(fig,'children'),'HandleVisibility','on','-regexp','Type','.*axes');



                removeSceneViewerListeners(fig);
                for k=length(children):-1:1
                    child=children(k);
                    if isa(child,'matlab.graphics.axis.AbstractAxes')
                        childContainers={};


                        thisChild=child;
                        while~isempty(thisChild.Parent)&&...
                            (isa(thisChild.Parent,'matlab.ui.internal.mixin.CanvasHostMixin')||isa(thisChild.Parent,'matlab.graphics.layout.Layout'))&&...
                            ~ishghandle(thisChild.Parent,'figure')
                            childContainers{end+1}=thisChild.Parent;%#ok<AGROW>
                            thisChild=thisChild.Parent;
                        end



                        if~isempty(childContainers)
                            for j=length(childContainers):-1:2
                                pb.addContainerProxy(java(childContainers{j}),java(childContainers{j-1}));
                            end
                            pb.addContainerProxy(java(childContainers{1}),java(fig));
                        end

                        pb.addAxesProxy(java(child),java(get(child,'parent')),...
                        java(get(child,'Title')));
                        updatePropertiesForObject(child,pb);
                        refreshAxes(child,pb);
                    end
                end


                localCache(fig,localGetAllGraphicChildren(fig,pb),pb);


                addSceneViewerListeners(fig,pb);


                if~isempty(selObjects)
                    validSelObjects=[];
                    for k=1:length(selObjects)
                        if selObjects(k).isValid
                            validSelObjects=[validSelObjects;selObjects(k)];%#ok<AGROW>
                        end
                    end
                    if isjava(pb)
                        javaMethodEDT('restoreSelectedObjects',pb,validSelObjects);
                    end
                end

                function objs=localGetAllGraphicChildren(h,pb)


                    allAxes=findobj(get(h,'Children'),...
                    {'Type','axes','-or','Type','polaraxes','-or','Type','geoaxes','-or','Type','mapaxes'},...
                    'HandleVisibility','on');
                    objs=allAxes;
                    for k=1:length(allAxes)
                        axChildren=localGetAxesChildren(allAxes(k),pb);
                        objs=[objs;axChildren(:)];%#ok<AGROW>
                    end

                    function[axesChildren,parentClasses,overCount]=localGetAxesChildren(ax,pb)


                        allChildren=matlab.graphics.illustration.internal.getLegendableChildren(ax);
                        allChildren=[allChildren;getLegendableImages(ax)];
                        axesChildren=matlab.graphics.GraphicsPlaceholder.empty;
                        parentClasses={};
                        maxChildCount=pb.getMaxChildCount;
                        if length(allChildren)>maxChildCount+1
                            overCount=length(allChildren)-maxChildCount;
                            numChildren=maxChildCount;
                        else
                            numChildren=length(allChildren);
                            overCount=0;
                        end
                        for j=1:numChildren
                            axesChild=allChildren(j);






                            if isequal(axesChild.Parent,ax)
                                axesChildren(end+1)=axesChild;%#ok<AGROW>
                                parentClasses{end+1}=getNearestKnownParentClass(axesChild);%#ok<AGROW>
                            end

                        end



                        function axesChildren=refreshAxes(ax,pb)

                            [axesChildren,parentClasses,overCount]=localGetAxesChildren(ax,pb);
                            if isempty(axesChildren)
                                return
                            end


                            len=length(axesChildren);
                            ja=javaArray('com.mathworks.page.plottool.plotbrowser.PlotBrowserEntry',len);


                            for n=1:len
                                hAxesChild=handle(axesChildren(n));
                                hParent=handle(get(hAxesChild,'Parent'));
                                nearestClass=parentClasses{n};
                                ja(n)=com.mathworks.page.plottool.plotbrowser.PlotBrowserEntry(hAxesChild,hParent,nearestClass);
                            end
                            if overCount>0
                                pb.addSeriesProxyArray_MatlabThread(ja,getString(message('MATLAB:plottools:BrowserOverflow',overCount)));
                            else
                                pb.addSeriesProxyArray_MatlabThread(ja,[]);
                            end
                            updatePropertiesForObjects(axesChildren,pb);





                            deferredInstantiationAxesProps={'Title'};
                            for k=1:length(deferredInstantiationAxesProps)
                                get(ax,deferredInstantiationAxesProps{k});
                            end
                            drawnow update;

                            function updatePropertiesForObject(obj,pb)





                                if isempty(obj)||~ishandle(obj)
                                    return;
                                end
                                objType=class(obj);
                                propNames=[];
                                allPropNames=localGetAllPropNames;
                                for i=1:length(allPropNames)
                                    entry=allPropNames{i};
                                    if(strcmpi(objType,entry{1})==1)
                                        propNames=entry{2};
                                        break;
                                    end
                                end

                                for i=1:length(propNames)
                                    propVals=localGetPropVals(obj,propNames{i});
                                    for j=1:numel(propVals)
                                        if isa(propVals{j},'matlab.lang.OnOffSwitchState')
                                            propVals{j}=char(propVals{j});
                                        end
                                    end
                                    pb.setProperty(java(obj),propNames{i},propVals{1});
                                end

                                function updatePropertiesForObjects(objs,pb)



                                    allPropNames=localGetAllPropNames;


                                    [types,Itypes]=localGetUniqueClassNames(objs);

                                    plotBrowserPropValues={};
                                    plotBrowserProps={};
                                    plotBrowserObjects={};

                                    for k=1:length(types)
                                        propNames={};
                                        objs_uniformType=objs(Itypes==k);
                                        for i=1:length(allPropNames)
                                            if strcmpi(types{k},allPropNames{i}{1})==1
                                                propNames=allPropNames{i}{2};
                                                break;
                                            end
                                        end







                                        for i=1:length(propNames)
                                            propVals=localGetPropVals(objs_uniformType,propNames{i});
                                            plotBrowserPropValues=[plotBrowserPropValues;propVals(:)];
                                            plotBrowserProps=[plotBrowserProps;repmat({propNames{i}},length(objs_uniformType),1)];
                                            plotBrowserObjects=[plotBrowserObjects;num2cell(objs_uniformType(:))];
                                        end
                                    end

                                    pb.setProperties(plotBrowserObjects,plotBrowserProps,localConvertOnOffState(plotBrowserPropValues));

                                    function objType=getNearestKnownParentClass(obj)

                                        knownClasses={'matlab.ui.Figure','ui.Axes','matlab.graphics.chart.primitive.Line','matlab.graphics.chart.primitive.tall.Line',...
                                        'matlab.graphics.chart.primitive.Bar','matlab.graphics.chart.primitive.Stem',...
                                        'matlab.graphics.chart.primitive.Stair',...
                                        'matlab.graphics.chart.primitive.ConstantLine',...
                                        'matlab.graphics.chart.primitive.FunctionLine',...
                                        'matlab.graphics.chart.primitive.Area','matlab.graphics.chart.primitive.ErrorBar',...
                                        'matlab.graphics.chart.primitive.Scatter','matlab.graphics.chart.primitive.tall.Scatter','matlab.graphics.chart.primitive.Contour',...
                                        'matlab.graphics.chart.primitive.Quiver',...
                                        'matlab.graphics.function.ParameterizedFunctionLine','matlab.graphics.function.FunctionLine',...
                                        'matlab.graphics.function.ParameterizedFunctionSurface','matlab.graphics.function.FunctionSurface',...
                                        'matlab.graphics.funcion.ImplicitFunctionLine','matlab.graphics.function.ImplicitFunctionSurface',...
                                        'matlab.graphics.primitive.Surface',...
                                        'matlab.graphics.primitive.Image','matlab.ui.internal.mixin.CanvasHostMixin','matlab.ui.control.UIControl'...
                                        ,'matlab.graphics.shape.Line','matlab.graphics.shape.Arrow','matlab.graphics.shape.DoubleEndArrow',...
                                        'matlab.graphics.shape.TextArrow','matlab.graphics.shape.TextBox','matlab.graphics.shape.Rectangle',...
                                        'matlab.graphics.shape.Ellipse','matlab.graphics.illustration.Legend','matlab.graphics.illustration.ColorBar',...
                                        'matlab.graphics.primitive.Line','matlab.graphics.primitive.Text','matlab.graphics.primitive.Rectangle','matlab.graphics.primitive.Patch'};

                                        objType=class(handle(obj));
                                        for i=1:length(knownClasses)
                                            if isa(handle(obj),knownClasses{i})
                                                objType=knownClasses{i};
                                                return;
                                            end
                                        end


                                        function localPostUpdate(h,pb)

                                            plotBrowserListener=h.PlotBrowserListener;




                                            if~isempty(plotBrowserListener)&&isfield(plotBrowserListener,'Listener')&&...
                                                ~plotBrowserListener.Listener.Enabled||strcmp(h.BeingDeleted,'on')
                                                return
                                            end


                                            objs=localGetAllGraphicChildren(h,pb);




                                            rebuildPlotBrowser=true;
                                            if~isempty(plotBrowserListener)&&isfield(plotBrowserListener,'ObjectArray')
                                                cachedobjs=plotBrowserListener.ObjectArray;
                                                if isequal(objs,cachedobjs)
                                                    rebuildPlotBrowser=false;
                                                elseif isempty(objs)||(~isempty(cachedobjs)&&isempty(setdiff(objs,cachedobjs)))





                                                    if numel(objs)~=numel(cachedobjs)

                                                        if isjava(pb)
                                                            javaMethodEDT('removeInvalidProxies',pb);
                                                        end
                                                        plotBrowserListener.ObjectArray=objs;


                                                        I=false(length(plotBrowserListener.ObjectProps),1);
                                                        invalidObjectExists=false;
                                                        for k=1:length(plotBrowserListener.ObjectProps)
                                                            I(k)=isvalid(plotBrowserListener.ObjectProps(k).Object);
                                                            invalidObjectExists=true;
                                                        end





                                                        if length(plotBrowserListener.ObjectProps)<=pb.getMaxChildCount||...
                                                            ~invalidObjectExists
                                                            plotBrowserListener.ObjectProps=plotBrowserListener.ObjectProps(I);
                                                            rebuildPlotBrowser=false;
                                                        end
                                                    end
                                                end
                                            end


                                            if isempty(objs)
                                                if rebuildPlotBrowser&&isjava(pb)






                                                    javaMethodEDT('clearAll',pb,true);
                                                    javaMethodEDT('repaint',pb);
                                                end
                                                return
                                            end



                                            if~rebuildPlotBrowser
                                                plotBrowserObjects={};
                                                plotBrowserProps={};
                                                plotBrowserPropValues={};


                                                objs=[plotBrowserListener.ObjectProps.Object];
                                                [types,Itypes]=localGetUniqueClassNames(objs);



                                                for k=1:length(types)
                                                    I=find(Itypes==k);



                                                    objectArray=objs(I);
                                                    objPropArray=plotBrowserListener.ObjectProps(I);


                                                    propNames=objPropArray(1).PropertyNames;

                                                    for j=1:length(propNames)
                                                        newPropVals=localGetPropVals(objectArray,propNames{j});
                                                        for i=1:length(objectArray)


                                                            if~isequal(objPropArray(i).PropertyValues{j},newPropVals{i})
                                                                plotBrowserObjects{end+1}=java(objectArray(i));%#ok<AGROW>
                                                                plotBrowserProps{end+1}=propNames{j};%#ok<AGROW>
                                                                plotBrowserPropValues{end+1}=newPropVals{i};%#ok<AGROW>



                                                                plotBrowserListener.ObjectProps(I(i)).PropertyValues{j}=newPropVals{i};

                                                            end
                                                        end
                                                    end
                                                end

                                                if~isempty(plotBrowserObjects)
                                                    pb.setProperties(plotBrowserObjects,plotBrowserProps,localConvertOnOffState(plotBrowserPropValues));
                                                end
                                                h.PlotBrowserListener=plotBrowserListener;
                                                return
                                            end

                                            h.PlotBrowserListener=plotBrowserListener;


                                            repopulatePlotBrowser(pb,h);


                                            function localCache(h,objs,pb)



                                                h.PlotBrowserListener.ObjectArray=objs;
                                                h.PlotBrowserListener.ObjectProps=...
                                                repmat(struct('Object',[],'PropertyNames',[],'PropertyValues',[],'DisplayNameListener',[]),...
                                                [length(objs),1]);

                                                objectProps=h.PlotBrowserListener.ObjectProps;
                                                objectArray=h.PlotBrowserListener.ObjectArray;


                                                objClasses=cell(length(objs),1);
                                                for k=1:length(objs)
                                                    objClasses{k}=class(objs(k));
                                                end
                                                [types,~,Itypes]=unique(objClasses);



                                                for k=1:length(types)

                                                    objectArray_uniformType=objectArray(Itypes==k);







                                                    propNames=getInterestPropertyNamesForObject(objectArray_uniformType(1));
                                                    propNamesArray=repmat(propNames,length(objectArray_uniformType),1);
                                                    propValuesArray=cell(size(propNamesArray));
                                                    for i=1:length(propNames)
                                                        propValuesArray(:,i)=localGetPropVals(objectArray_uniformType,propNames{i});
                                                    end


                                                    displayNameListenerArray=cell(size(objectArray_uniformType));
                                                    if isa(objectArray_uniformType(1),'matlab.graphics.mixin.Legendable')
                                                        displayNameProp=objectArray_uniformType(1).findprop('DisplayName');
                                                        displayNameCallback=createPostUpdateListener(h,pb);
                                                        for i=1:length(objectArray_uniformType)
                                                            displayNameListenerArray{i}=...
                                                            event.proplistener(objectArray_uniformType(i),displayNameProp,...
                                                            'PostSet',displayNameCallback);
                                                        end
                                                    end








                                                    objectProps(Itypes==k)=cell2struct(...
                                                    [num2cell(objectArray_uniformType),...
                                                    localCombineCellArrayColumns(propNamesArray),...
                                                    localCombineCellArrayColumns(propValuesArray),...
                                                    displayNameListenerArray(:)]',...
                                                    {'Object','PropertyNames','PropertyValues','DisplayNameListener'},1);
                                                end
                                                h.PlotBrowserListener.ObjectProps=objectProps;

                                                function[str]=getInterestPropertyNamesForObject(obj)

                                                    str=[];





                                                    if isempty(obj)||~ishandle(obj)
                                                        return;
                                                    end
                                                    propNames={};
                                                    if isprop(obj,'Visible')
                                                        propNames{end+1}='Visible';
                                                    end
                                                    if isprop(obj,'HandleVisibility')
                                                        propNames{end+1}='HandleVisibility';
                                                    end



                                                    objType=class(obj);
                                                    allPropNames=localGetAllPropNames;
                                                    for i=1:length(allPropNames)
                                                        entry=allPropNames{i};
                                                        if(strcmpi(objType,entry{1})==1)
                                                            propNames=entry{2};
                                                            break;
                                                        end
                                                    end
                                                    str=propNames;

                                                    function allPropNames=localGetAllPropNames

                                                        persistent allPropNamesCache;

                                                        if isempty(allPropNamesCache)
                                                            allPropNamesCache=getplotbrowserproptable;
                                                        end
                                                        allPropNames=allPropNamesCache;

                                                        function propVals=localGetPropVals(objs,propName)


                                                            propVals=get(objs,{propName});

                                                            if strcmpi(propName,'title')
                                                                for k=1:length(objs)
                                                                    if isa(objs(k),'matlab.graphics.axis.AbstractAxes')


                                                                        th=get(objs(k),'Title');
                                                                        if~isempty(th)
                                                                            propVals{k}=get(th,'string');
                                                                        end
                                                                    end
                                                                end
                                                            elseif strcmpi('color',propName)


                                                                I=cellfun('isclass',propVals,'char');
                                                                charValues=repmat({''},size(I));
                                                                charValues(I)=propVals(I);
                                                                flatIndex=strcmp(charValues,'flat');
                                                                noneIndex=strcmp(charValues,'none');
                                                                propVals(I)={[1,1,1,0]};
                                                                propVals(flatIndex)={[16/255,16/255,255/255]};
                                                                propVals(noneIndex)={[]};
                                                            elseif strcmpi('linecolor',propName)

                                                                I=cellfun('isclass',propVals,'char');
                                                                propVals(I)={[]};
                                                            elseif strcmpi('markeredgecolor',propName)
                                                                I=cellfun('isclass',propVals,'char');



                                                                charValues=repmat({''},size(I));
                                                                charValues(I)=propVals(I);



                                                                autoIndex=find(strcmp(charValues,'auto'));
                                                                flatIndex=find(strcmp(charValues,'flat'));

                                                                if~isempty(autoIndex)
                                                                    propVals(autoIndex)={[1,1,1,0]};


                                                                    Isubstitute=false(size(propVals));
                                                                    if isprop(objs(autoIndex(1)),'Color')
                                                                        colorPropVals=get(objs(autoIndex),{'Color'});
                                                                        InumericColors=cellfun('isclass',colorPropVals,'double')&cellfun('length',colorPropVals)>=3;
                                                                        Isubstitute(autoIndex(InumericColors))=true;
                                                                        propVals(Isubstitute)=colorPropVals(InumericColors);
                                                                    end



                                                                    if isprop(objs(autoIndex(1)),'MarkerFaceColor')
                                                                        markerFaceColorPropVals=get(objs(autoIndex),{'MarkerFaceColor'});
                                                                        InumericColors=~Isubstitute(autoIndex)&cellfun('isclass',markerFaceColorPropVals,'double')&cellfun('length',markerFaceColorPropVals)>=3;
                                                                        propVals(autoIndex(InumericColors))=markerFaceColorPropVals(InumericColors);
                                                                    end
                                                                end
                                                                if~isempty(flatIndex)
                                                                    propVals(flatIndex)=localGetFlatValue(objs(flatIndex));
                                                                end
                                                            elseif strcmpi('markerfacecolor',propName)
                                                                I=cellfun('isclass',propVals,'char');




                                                                charValues=repmat({''},size(I));
                                                                charValues(I)=propVals(I);
                                                                flatIndex=strcmp(charValues,'flat');
                                                                noneIndex=strcmp(charValues,'none');
                                                                autoIndex=strcmp(charValues,'auto');
                                                                propVals(I)={[16/255,16/255,255/255]};
                                                                propVals(flatIndex)=localGetFlatValue(objs(flatIndex));
                                                                propVals(autoIndex)=localGetAutoValueMarkerFaceColor(objs(autoIndex));

                                                                propVals(noneIndex)={[]};
                                                            elseif strcmpi('edgecolor',propName)||strcmpi('facecolor',propName)

                                                                for k=1:length(objs)
                                                                    propVals{k}=localGetFaceEdgePropVal(objs(k),propName);
                                                                end
                                                            end

                                                            function colorVals=localGetAutoValueMarkerFaceColor(objs)


                                                                if isempty(objs)
                                                                    colorVals={};
                                                                    return
                                                                end

                                                                colorVals=cell(numel(objs),1);


                                                                ax=ancestor(objs,'axes');
                                                                if~iscell(ax)
                                                                    axesColors=get(ax,{'Color'});
                                                                else
                                                                    axesColors=cellfun(@(h)h.Color,ax,'UniformOutput',false);
                                                                end



                                                                axesColorNone=cellfun('isclass',axesColors,'char');
                                                                colorVals(~axesColorNone)=axesColors(~axesColorNone);
                                                                colorVals(axesColorNone)={[1,1,1]};

                                                                function colorVals=localGetFlatValue(objs)




                                                                    defaultMarkerColor=[16/255,16/255,255/255];

                                                                    if isempty(objs)
                                                                        colorVals=[];
                                                                        return
                                                                    end


                                                                    aCData=get(objs,{'CData'});
                                                                    cDataDims=cell2mat(cellfun(@size,aCData,'UniformOutput',false));

                                                                    colorVals=cell(numel(objs),1);


                                                                    tripletsInd=(cDataDims(:,1)==1&cDataDims(:,2)==3);
                                                                    colorVals(tripletsInd)=aCData(tripletsInd);




                                                                    matrixCDataInd=(cDataDims(:,1)>1&cDataDims(:,2)>1);
                                                                    uniformMatrixColor=cellfun(@localGetUniformMatrixCdataColor,aCData(matrixCDataInd),'UniformOutput',false);

                                                                    if isempty(uniformMatrixColor)
                                                                        uniformMatrixColor={defaultMarkerColor};
                                                                    end
                                                                    colorVals(matrixCDataInd)=uniformMatrixColor;



                                                                    vectorCDataInd=(cDataDims(:,1)==1&cDataDims(:,2)~=3)|(cDataDims(:,2)==1&cDataDims(:,1)~=3);
                                                                    uniformVectorColor=cellfun(@localGetUniformVectorCdataColor,aCData(vectorCDataInd),'UniformOutput',false);

                                                                    if isempty(uniformVectorColor)
                                                                        uniformVectorColor={defaultMarkerColor};
                                                                    end
                                                                    colorVals(vectorCDataInd)=uniformVectorColor;


                                                                    function val=localGetUniformVectorCdataColor(x)
                                                                        val=[16/255,16/255,255/255];
                                                                        if~any(diff(x))
                                                                            c=colormap;
                                                                            val=c(floor(length(c)/2),:);
                                                                        end


                                                                        function val=localGetUniformMatrixCdataColor(x)
                                                                            val=[16/255,16/255,255/255];
                                                                            if~any(diff(x))
                                                                                val=x(1,:);
                                                                            end



                                                                            function propVal=localGetFaceEdgePropVal(obj,propName)





















                                                                                propVal=obj.(propName);

                                                                                if strcmpi('facecolor',propName)&&ischar(propVal)
                                                                                    if ishghandle(obj,'bar')||ishghandle(obj,'area')
                                                                                        propVal=plottoolfunc('getBarAreaColor',obj);
                                                                                    elseif ishghandle(obj,'histogram')||ishghandle(obj,'histogram2')||ishghandle(obj,'categoricalhistogram')
                                                                                        propVal=plottoolfunc('getHistogramColor',obj,propName);
                                                                                    elseif ishghandle(obj,'patch')||ishghandle(obj,'surface')
                                                                                        if strcmp('none',propVal)
                                                                                            propVal=[1,1,1];
                                                                                        elseif ishghandle(obj,'patch')
                                                                                            propVal=plottoolfunc('getPatchColor',obj);
                                                                                        elseif ishghandle(obj,'surface')
                                                                                            propVal=plottoolfunc('getSurfaceColor',obj);
                                                                                        end
                                                                                    else
                                                                                        propVal=[1,1,1];
                                                                                    end
                                                                                elseif strcmpi('edgecolor',propName)&&ischar(propVal)
                                                                                    if ishghandle(obj,'bar')||ishghandle(obj,'area')
                                                                                        propVal=localGetFaceEdgePropVal(obj,'FaceColor');
                                                                                    elseif ishghandle(obj,'histogram')||ishghandle(obj,'histogram2')
                                                                                        propVal=plottoolfunc('getHistogramColor',obj,propName);
                                                                                    elseif ishghandle(obj,'patch')
                                                                                        propVal=plottoolfunc('getPatchColor',obj);
                                                                                    else
                                                                                        propVal=[1,1,1];
                                                                                    end
                                                                                end

                                                                                function fcn=createPostUpdateListener(container,pb)



                                                                                    fcn=@(es,~)localPostUpdate(container,pb);

                                                                                    function fcn=createFigurePostUpdateListener(pb)



                                                                                        fcn=@(es,~)localPostUpdate(ancestor(es,'figure'),pb);

                                                                                        function out=localCombineCellArrayColumns(x)




                                                                                            nrows=size(x,1);
                                                                                            out=cell(size(x,1),1);
                                                                                            x=x';
                                                                                            for k=1:nrows
                                                                                                out{k}=x(:,k)';
                                                                                            end


                                                                                            function[classNames,indices]=localGetUniqueClassNames(objs)


                                                                                                objClasses=cell(length(objs),1);
                                                                                                for k=1:length(objs)
                                                                                                    objClasses{k}=class(objs(k));
                                                                                                end
                                                                                                [classNames,~,indices]=unique(objClasses);

                                                                                                function propVals=localConvertOnOffState(propVals)

                                                                                                    I=cellfun('isclass',propVals,'matlab.lang.OnOffSwitchState');
                                                                                                    propVals(I)=cellfun(@(x)char(x),propVals(I),'UniformOutput',false);
