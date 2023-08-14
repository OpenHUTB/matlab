function movie(varargin)
































    try
        lmovie(varargin{:});
    catch Me
        if strcmp(Me.identifier,'MATLAB:class:InvalidHandle')



            return;
        else

            rethrow(Me)
        end
    end
end

function lmovie(varargin)













    narginchk(1,6);

    host=[];
    tCallbackFcn=[];
    if nargin>=1
        lastOpt=nargin;
        if(isa(varargin{end},'function_handle'))
            tCallbackFcn=varargin{end};
            lastOpt=nargin-1;
        end


        if(isscalar(varargin{1})...
            &&(isa(varargin{1},'matlab.graphics.axis.Axes')||isa(varargin{1},'matlab.ui.Figure')||ishghandle(varargin{1})))
            host=varargin{1};


            validateParent(host);



            [m,n,frameList,fps,loc]=parseAndValidateInputs(varargin{2:lastOpt});
        else
            [m,n,frameList,fps,loc]=parseAndValidateInputs(varargin{1:lastOpt});
        end
    else

    end



    if isempty(m)
        return;
    end




    if n==0
        warning(message('MATLAB:movie:ZeroRepetitions'));
        return;
    end




    if(isempty(host))
        host=gca;
    end
    import matlab.internal.lang.capability.Capability;
    isRemoteClientThatMirrorsSwingUIs=~Capability.isSupported(Capability.LocalClient)&&Capability.isSupported(Capability.Swing);
    fig_handle=ancestor(host,'figure','node');
    if~feature('LiveEditorRunning')...
        &&isRemoteClientThatMirrorsSwingUIs
        matlab.ui.internal.prepareFigureFor(fig_handle,mfilename('fullpath'));
    end


    parent=getMovieParent(host);



    deleteMoviesFromParent(parent);


    frameSize=[size(m(1).cdata,1),size(m(1).cdata,2)];
    [movieTform,tex]=getMovieTransformAndTexture(frameSize(2),frameSize(1));
    set(movieTform,'Parent',parent);




    adjustCameraParams(parent,frameSize,host,loc);
    drawnow;











    movieQuad=get(movieTform,'Children');




    rate=round(1000/fps)/1000;
    loopFactor=1;
    if n<0





        loopFactor=2;
    end



    t=timer('TimerFcn',@showframe,...
    'ExecutionMode','fixedRate',...
    'Period',rate,...
    'BusyMode','queue',...
    'TasksToExecute',loopFactor*abs(n)*length(frameList));





    try
        start(t);
        wait(t);
        if isvalid(t)
            stop(t);
        else
            cleanupTimer();
            return;
        end
    catch
        cleanupTimer();
        return;
    end
    cleanupTimer();



    function cleanupTimer()

        if isvalid(t)
            stop(t);
            delete(t);
        else
            clear(t);
        end
    end





    function fIdx=getFrameIdx(taskNumber)
        lFrameList=length(frameList);

        if((n>0)&&(taskNumber>lFrameList))
            fIdx=taskNumber-(lFrameList*ceil(-1+taskNumber/lFrameList));
            return;
        end


        if((n<0)&&(taskNumber>lFrameList))
            fIdx=taskNumber-(lFrameList*ceil(-1+taskNumber/lFrameList));










            fSet=ceil(taskNumber/lFrameList);
            if(mod(fSet,2)==0)

                fIdx=lFrameList-fIdx+1;
            end
            return;
        end


        fIdx=taskNumber;
        return;
    end





    rgbFaceA=zeros(4,0,0,'uint8');
    function showframe(varargin)
        try
            t=varargin{1};
            idx=frameList(getFrameIdx(t.TasksExecuted));
            validateFrame(m(idx).cdata,m(idx).colormap);
            if isempty(m(idx).colormap)||(ndims(m(idx).cdata)==3)
                img=uint8(m(idx).cdata);
            else
                img=uint8(ind2rgb(m(idx).cdata,m(idx).colormap)*255);
            end
            dims=size(img);
            fSize=[size(m(idx).cdata,1),size(m(idx).cdata,2)];
            if(any(frameSize~=fSize))

                adjustCameraParams(parent,fSize,host,loc);

                w=fSize(2);
                h=fSize(1);
                vertexData=single([0,0,0
                w,0,0
                w,h,0
                0,h,0]');
                set(movieQuad,'VertexData',vertexData);

                frameSize=fSize;
                rgbFaceA=zeros(4,h,w,'uint8');
            end
            rgbFaceA(1,:,:)=img(1:dims(1),:,1);
            rgbFaceA(2,:,:)=img(1:dims(1),:,2);
            rgbFaceA(3,:,:)=img(1:dims(1),:,3);
            rgbFaceA(4,:,:)=255;
            tex.CData=rgbFaceA;



            set(movieQuad,'Texture',tex);
            drawnow('expose');
            if(~isempty(tCallbackFcn))
                tCallbackFcn(idx,movieQuad);
            end
        catch
            stop(t);
        end
    end
end







function[hMovieTform,tex]=getMovieTransformAndTexture(w,h)




    hMovieTform=matlab.graphics.primitive.Transform('HandleVisibility','off','Serializable','off');




    set(hMovieTform,'Tag','movie');
    hQuad=matlab.graphics.primitive.world.Quadrilateral;
    vertexData=single([0,0,0
    w,0,0
    w,h,0
    0,h,0]');
    tex=matlab.graphics.primitive.world.Texture;
    set(hQuad,'VertexData',vertexData,...
    'Texture',tex,...
    'ColorData',single([1,1,0,0;0,1,1,0]),...
    'ColorType','TextureMapped',...
    'ColorBinding','interpolated');
    hQuad.Parent=hMovieTform;
    drawnow();
end








function[m,n,frameList,fps,loc]=parseAndValidateInputs(varargin)
    narginchk(1,4);
    m=[];
    n=1;
    frameList=[];

    fps=12;
    loc=[];

    if nargin>=1
        m=varargin{1};



        if~isempty(m)
            validateMovieData(m);
        else
            return;
        end
    end


    if nargin>=2
        if(~isempty(varargin{2}))





            [n,frameList]=validateNumLoops(varargin{2},m);
        end
    else
        frameList=1:length(m);
    end


    if nargin>=3
        if(~isempty(varargin{3}))


            fps=varargin{3};
            validateFPS(fps);
        end
    end


    if nargin>=4
        loc=varargin{4};
        validateLocation(loc);
    end
end









function validateFrame(cdata,cmap)













    if(isempty(cdata))
        throw(MException('MATLAB:movie:UninitializedFrames',...
        getString(message('MATLAB:movie:MovieContainsUninitializedFrames'))));
    end

    if(~isa(cdata,'uint8'))
        throw(MException('MATLAB:movie:CDataTypeMustBeUint8Array',...
        getString(message('MATLAB:movie:CdataMustBeOfTypeUint8Array'))));
    end

    if(ndims(cdata)>3)
        throw(MException('MATLAB:movie:CDataMustHave2Or3Dimensions',...
        getString(message('MATLAB:movie:CdataMustHave2Or3Dimensions'))));
    end

    if(ndims(cdata)==3)

        if(size(cdata,3)~=3)
            throw(MException('MATLAB:movie:BadFrameDimensions',...
            getString(message('MATLAB:movie:FrameMustBeAnArrayOfSizeMxNindexedOrMxNx3tr'))));
        end
    end

    if(ismatrix(cdata))

        validateColorMap(cmap);
        [r,~]=size(cmap);


        if(max(cdata(:))>r)
            errString=getString(message('MATLAB:movie:IndexedMovieDataValuesMustBeLegalColormapIndices'));
            throw(MException('MATLAB:movie:BadColormapIndices',...
            errString));
        end
    end
end

function validateColorMap(cmap)








    if(isempty(cmap))
        throw(MException('MATLAB:movie:ColormapMustBeNonEmpty',...
        getString(message('MATLAB:movie:IndexedMovieFrameMustHaveANonemptyColormap'))));
    end

    if~isa(cmap,'double')
        throw(MException('MATLAB:movie:ColormapMustBeDoubleArray',...
        getString(message('MATLAB:movie:MovieColormapsMustBeDoubleArrays'))));
    end

    [r,c]=size(cmap);

    if(r>256)
        throw(MException('MATLAB:movie:ColormapCannotHaveMoreThan256Colors',...
        getString(message('MATLAB:movie:ColormapCanNotHaveMoreThan256Colors'))));
    end

    if(c~=3)
        throw(MException('MATLAB:movie:ColormapMustHave3Columns',...
        getString(message('MATLAB:movie:ColormapsMustHave3Columns'))));
    end

    if(any(isinf(cmap(:))))
        throw(MException('MATLAB:movie:ColormapValuesMustBeFinite',...
        getString(message('MATLAB:movie:ColormapValuesMustBeFinite'))));
    end

    if(min(cmap(:))<0.0||max(cmap(:))>1.0)
        throw(MException('MATLAB:movie:ColormapValuesOutOfRange',...
        getString(message('MATLAB:movie:ColormapValuesMustBeBetween0And1Inclusive'))));
    end
end

function validateMovieData(M)




    if(isa(M,'struct')&&isfield(M,'cdata')&&isfield(M,'colormap'))



        validateFrame(M(1).cdata,M(1).colormap);
        return;
    else
        exception=MException('MATLAB:movie:MustBeValidMovieMatrix',...
        getString(message('MATLAB:movie:ArgumentMustBeAValidMovieMatrixFromGETFRAME')));
        throw(exception);
    end
end

function throwInvalidFrameError(badFrameIndex,numberOfFrames)


    if(~isempty(badFrameIndex)&&~isempty(numberOfFrames))
        error(message('MATLAB:movie:BadFrameOrderIndex1',num2str(badFrameIndex),numberOfFrames));
    end
end

function[repCount,frameList]=validateNumLoops(N,M)







    datatypeShapeException=MException('MATLAB:movie:ExpectedNumericFinite',...
    getString(message('MATLAB:movie:RepetitionCountAndFrameOrderListMustBeFiniteNumeric')));


    if(~isa(N,'double')||any(isinf(N(:)))||any(isnan(N(:))))
        throw(datatypeShapeException);
    end


    if(~isreal(N))
        complexException=MException('MATLAB:movie:BadRepeatCount2',...
        getString(message('MATLAB:movie:InvalidRepeatCountSpecification')));
        throw(complexException);
    end


    if(N(1)~=cast(N(1),'int32'))
        complexException=MException('MATLAB:movie:BadRepeatCount2',...
        getString(message('MATLAB:movie:InvalidRepeatCountSpecification')));
        throw(complexException);
    end




    if(isscalar(N))
        repCount=N;


        frameList=1:length(M);
        return;
    end


    if(~isvector(N))
        throw(datatypeShapeException);
    else




        numFrames=length(M);

        repCount=N(1);
        frameList=N(2:end);


        [r,c]=find(frameList<1,1,'first');
        if~isempty(r)
            throwInvalidFrameError(frameList(r,c),numFrames);
        end

        [r,c]=find(frameList>numFrames,1,'first');
        if~isempty(r)
            throwInvalidFrameError(frameList(r,c),numFrames);
        end

        [r,c]=find(frameList~=cast(frameList,'uint32'),1,'first');
        if~isempty(r)
            throwInvalidFrameError(frameList(r,c),numFrames);
        end
    end
end

function validateFPS(fps)


    if(isnumeric(fps)&&isscalar(fps)&&fps>0)
        return;
    else

        exception=MException('MATLAB:movie:ExpectedNumericScalar',...
        getString(message('MATLAB:movie:FramesPerSecondMustBePositiveDouble')));
        throw(exception);
    end
end

function validateLocation(loc)




    if(numel(loc)~=4)
        exception=MException('MATLAB:movie:BadRECT',...
        getString(message('MATLAB:movie:InvalidRECTSpecification')));
        throw(exception);
    end

    if(~isnumeric(loc))
        exception=MException('MATLAB:hg:dt_conv:Matrix_to_Rect:ExpectedNumeric',...
        getString(message('MATLAB:movie:ValueMustBeNumeric')));
        throw(exception);
    end
end


function validateParent(hParent)




    if((isa(hParent,'matlab.graphics.axis.Axes')||isa(hParent,'matlab.ui.Figure'))&&isvalid(hParent))
        return;
    else

        throwInvalidParentException();
    end
end





function throwInvalidParentException()

    exception=MException('MATLAB:movie:HandleMustBeFigureOrAxes',...
    getString(message('MATLAB:movie:ObjectHandleMustBeAFigureOrAnAxes')));
    throw(exception);
end

function parent=getMovieParent(h)








    parent=[];
    ax=gobjects(0);
    if(isa(h,'matlab.graphics.axis.Axes'))
        ax=h;
        h=ancestor(h,'matlab.ui.internal.mixin.CanvasHostMixin');
    elseif(isa(h,'matlab.ui.Figure'))
        ax=findobj(h,'-depth',1,'type','axes');
        if isempty(ax)
            ax=axes('Parent',h,'Visible','off');
        end
    end




    for i=1:length(ax)
        if~isempty(ax(i).Toolbar)
            ax(i).Toolbar.Visible='off';
        end
        if~isempty(ax(i).Interactions)
            disableDefaultInteractivity(ax(i));
        end
    end

    if(isa(h,'matlab.ui.internal.mixin.CanvasHostMixin'))


        uiChildren=hgGetTrueChildren(h);
        for idx=1:length(uiChildren)
            if(isa(uiChildren(idx),'matlab.graphics.primitive.canvas.Canvas'))
                ch=hgGetTrueChildren(uiChildren(idx));
                for jIdx=1:length(ch)
                    if(isa(ch(jIdx),'matlab.graphics.axis.camera.Camera2D')&&...
                        strcmp(ch(jIdx).Description,'movieContainer'))
                        parent=ch(jIdx);
                        return;
                    end
                end
            end
        end






        if~isempty(ax)
            addlistener(ax,'Cla',@(obj,~)deleteMovieCameraFromParent(obj));
            addlistener(ax,'ObjectBeingDestroyed',@(obj,~)deleteMovieCameraFromParent(obj));
        end


        sv=h.getCanvas;
        hCamera=matlab.graphics.axis.camera.Camera2D;


        hCamera.Description='movieContainer';
        hCamera.Parent=sv;
        parent=hCamera;
    else

        throwInvalidParentException();
    end
end

function deleteMoviesFromParent(hParent)


    ui=ancestor(hParent,'matlab.ui.internal.mixin.CanvasHostMixin');
    movies=findall(ui,'type','hgtransform','Tag','movie');
    delete(movies);
end

function deleteMovieCameraFromParent(hParent)


    ui=ancestor(hParent,'matlab.ui.internal.mixin.CanvasHostMixin');
    if~isempty(ui)


        uiChildren=hgGetTrueChildren(ui);
        for idx=1:length(uiChildren)
            if isa(uiChildren(idx),'matlab.graphics.primitive.canvas.Canvas')
                ch=hgGetTrueChildren(uiChildren(idx));
                for jIdx=1:length(ch)
                    if(isa(ch(jIdx),'matlab.graphics.axis.camera.Camera2D')&&...
                        strcmp(ch(jIdx).Description,'movieContainer'))
                        camera=ch(jIdx);
                        delete(camera);
                        return;
                    end
                end
            end
        end
    end
end

function adjustCameraParams(hCamera,frameSize,host,location)


    if(isa(host,'matlab.graphics.axis.Axes'))







        axPos=host.GetLayoutInformation;
        axesPosition=axPos.PlotBox;


        if isempty(location)
            location=[axesPosition(1),axesPosition(2),0,0];
        else

            location(1)=location(1)+axesPosition(1)-1;
            location(2)=location(2)+axesPosition(2)-1;
        end


    end






    height=frameSize(1);
    width=frameSize(2);

    set(hCamera,'XLim',[0,width],'YLim',[0,height]);
    if(isempty(location))
        startX=1;
        startY=1;
    else
        startX=location(1);
        startY=location(2);
    end


    f=ancestor(host,'figure');
    pos=[startX,startY,100,100];
    pos=matlab.ui.internal.PositionUtils.getPixelRectangleInDevicePixels(pos,f);

    vp=get(hCamera,'ViewPort');
    saveUnits=vp.Units;


    vp.Units='devicepixels';
    vp.Position=[pos(1),pos(2),width,height];
    vp.Units=saveUnits;

    set(hCamera,'Viewport',vp);

    drawnow();
end

