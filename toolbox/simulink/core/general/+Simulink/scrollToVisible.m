function scrollToVisible(obj,varargin)































































    if nargin==0
        obj=[];
    elseif nargin==2

        ensureFit=varargin{1};
        panMode='center';
    else

        parseObj=inputParser;
        parseObj.addParameter('ensureFit','on');
        parseObj.addParameter('panMode','center');

        parseObj.parse(varargin{:});
        ensureFit=~strcmpi(parseObj.Results.ensureFit,'off');
        panMode=parseObj.Results.panMode;
    end


    persistent parentToScrollOpDeferred
    if(isempty(parentToScrollOpDeferred))
        parentToScrollOpDeferred=containers.Map('KeyType','double','ValueType','any');
    end
    parentToScrollOp=containers.Map('KeyType','double','ValueType','any');

    if~isempty(obj)
        h=SLPrint.Resolver.resolveToHandle(obj);
        for i=1:length(h)
            if isempty(h{i})
                continue;
            end


            parentH=locGetParentAsHandle(h{i});

            if parentToScrollOp.isKey(parentH)
                record=parentToScrollOp(parentH);
                record.objs=[record.objs,h{i}];
                parentToScrollOp(parentH)=record;
            else
                parentToScrollOp(parentH)=struct('objs',h{i},'ensureFit',ensureFit,'panMode',panMode);
            end
        end
    end




    keys=parentToScrollOp.keys;
    for i=1:length(keys)
        key=keys{i};
        parentToScrollOpDeferred(key)=parentToScrollOp(key);
    end


    keys=parentToScrollOpDeferred.keys;
    for i=1:length(keys)
        parentH=keys{i};

        resolveToSF=true;
        h=SLPrint.Resolver.resolveToDoubleHandleOrId(parentH,resolveToSF);

        if isempty(h)
            parentToScrollOpDeferred.remove(parentH);
            continue;
        end

        editor=[];
        if SLPrint.Resolver.isSimulink(h)
            editor=SLM3I.SLDomain.getLastActiveEditorFor(h);
        else
            isSubviewer=false;
            type=sf('get',h,'.isa');
            if type==1
                isSubviewer=true;
            elseif type==4
                isSubviewer=sf('get',h,'.superState')==2;
            end

            if isSubviewer
                editor=feval('StateflowDI.SFDomain.getLastActiveEditorFor',h);%#ok<FVAL> 

            else
                parentToScrollOpDeferred.remove(parentH);
            end
        end

        if~isempty(editor)&&editor.getOpeningSizeFinalized
            record=parentToScrollOpDeferred(parentH);
            parentToScrollOpDeferred.remove(parentH);
            locScrollOneEditor(editor,record);
        end
    end

    function locScrollOneEditor(editor,record)
        handles=record.objs;
        if isempty(handles)
            return;
        end

        boundingRect=[0,0,-1,-1];
        for i=1:length(handles)
            h=handles(i);
            diagramElements=SLPrint.Resolver.resolveToDiagramElements(h);




            de=[];
            if~isempty(diagramElements)
                de=diagramElements{1};
            end
            if~isempty(de)
                if boundingRect(3)==-1
                    boundingRect=locGetBound(editor,de);
                else
                    boundingRect=Simulink.RectUtil.union(boundingRect,locGetBound(editor,de));
                end
            end
        end

        if boundingRect(3)==-1
            return;
        end


        boundingRect=Simulink.RectUtil.expand(boundingRect,[12,12,12,12]);

        canvas=editor.getCanvas();


        startScale=canvas.Scale;
        fitScale=min([canvas.ViewExtents(1)/boundingRect(3),...
        canvas.ViewExtents(2)/boundingRect(4)]);



        scale=min([startScale,fitScale]);


        if scale<1
            if~record.ensureFit
                scale=1;
            else
                scale=min([1,fitScale]);
            end
        end

        canvas.Scale=scale;


        if strcmp(record.panMode,'minimal')
            locPanRectMinimallyToVisible(canvas,boundingRect);
        else
            locCenterRect(canvas,boundingRect);
        end


        function locPanRectMinimallyToVisible(canvas,rect)
            import Simulink.RectUtil
            canvasRect=canvas.SceneRectInView;
            offset=RectUtil.minMoveForMaxOverlap(canvasRect,rect);
            canvasRect=RectUtil.offset(canvasRect,offset);
            canvas.showSceneRect(canvasRect);


            function locCenterRect(canvas,rect)
                import Simulink.RectUtil

                canvasRect=canvas.SceneRectInView;
                canvasRect=RectUtil.centerAt(canvasRect,RectUtil.center(rect));


                diagramRect=canvas.Scene.Bounds;
                scale=canvas.Scale;
                margins=canvas.Margins/scale;
                diagramRect=RectUtil.expand(diagramRect,margins);

                offset=RectUtil.minMoveForMaxOverlap(canvasRect,diagramRect);
                canvasRect=RectUtil.offset(canvasRect,offset);
                canvas.showSceneRect(canvasRect);







                function l=locFindLine(sys,lineHandle,lines)

                    l=[];
                    if isempty(lines)
                        return;
                    end

                    lineIdx=find([lines(:).Handle]==lineHandle);
                    if~isempty(lineIdx)
                        l=lines(lineIdx);
                        return;
                    end

                    for i=1:size(lines,1)
                        l=locFindLine(sys,lineHandle,lines(i).Branch);
                        if~isempty(l)
                            return;
                        end
                    end








                    function pos=locLinePosition(l)

                        pos=Simulink.rect;
                        for i=1:size(l.Points,1)-1
                            pos=pos+Simulink.rect(l.Points(i,:),l.Points(i+1,:));
                        end

                        for i=1:size(l.Branch,1)
                            pos=pos+locLinePosition(l.Branch(i));
                        end



                        function parentH=locGetParentAsHandle(h)

                            if SLPrint.Resolver.isSimulink(h)
                                parent=get_param(get_param(h,'Parent'),'Handle');
                            else
                                if isa(h,'Stateflow.Chart')
                                    parent=h;
                                else
                                    parent=sf('get',h.Id,'.subviewer');
                                end
                            end
                            parentH=SLPrint.Resolver.resolveToHandle(parent);
                            parentH=parentH{1};

                            if isa(parentH,'Stateflow.Object')
                                parentH=parentH.Id;
                            end


                            function bounds=locGetBound(editor,de)
                                import Simulink.RectUtil
                                isUsingFallbackMethod=true;
                                if isa(de,'StateflowDI.Transition')
                                    bounds=RectUtil.fromCornerPoints(de.srcPosAbs,de.dstPosAbs);
                                    isUsingFallbackMethod=false;

                                elseif isa(de,'SLM3I.Segment')
                                    bounds=RectUtil.fromCornerPoints(de.fullPath(1,:),de.fullPath(2,:));
                                    for i=3:size(de.fullPath,1)
                                        bounds=RectUtil.unionPoint(bounds,de.fullPath(i,:));
                                    end
                                    isUsingFallbackMethod=false;

                                elseif isa(de,'SLM3I.Line')
                                    segments=de.segment;
                                    if(segments.size()>0)
                                        bounds=locGetBound(editor,segments.at(1));
                                    end
                                    for i=2:segments.size()
                                        bounds=RectUtil.union(bounds,locGetBound(editor,segments.at(i)));
                                    end
                                    isUsingFallbackMethod=false;

                                elseif isa(de,'SLM3I.Block')

                                    glyphRoot=editor.getGlyphRootForElement(de);
                                    if(~isempty(glyphRoot))
                                        bounds=glyphRoot.SceneBoundingRect;
                                        blockName=glyphRoot.childrenWithTag('BlockName');
                                        if(~isempty(blockName)&&blockName.Visible)
                                            bounds=RectUtil.union(bounds,round(blockName.SceneBoundingRect));
                                        end
                                        isUsingFallbackMethod=false;
                                    end
                                end

                                if isUsingFallbackMethod
                                    bounds=RectUtil.fromPointAndSize(de.absPosition,de.size);
                                end
