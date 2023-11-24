classdef(CompatibleInexactProperties=true)Animation<Aero.animation.internal.VideoAnimation
    properties(Dependent,SetAccess=protected,Transient,SetObservable,Hidden)
        MLAnimTimer;
    end

    methods
        function set.MLAnimTimer(h,value)
            h.AnimationTimer=value;
        end
        function value=get.MLAnimTimer(h)
            value=h.AnimationTimer;
        end
    end

    properties(Transient,SetObservable)
        Name='';
        Figure=[];
        FigureCustomizationFcn=[];
        Bodies={};
        Camera=[];
        TCurrent{validateattributes(TCurrent,{'numeric'},{'scalar'},'','TCurrent')}=0;
    end


    methods
        function h=Animation(varargin)


            if~builtin('license','test','Aerospace_Toolbox')
                error(message('aero:licensing:noLicenseAnim'));
            end

            if~builtin('license','checkout','Aerospace_Toolbox')
                return;
            end

        end

    end

    methods

        function delete(h)





            h.legacyDelete();

        end

    end

    methods
        function set.Name(obj,value)


            obj.Name=value;
        end

        function set.Camera(obj,value)

            validateattributes(value,{'handle'},{'scalar'},'','Camera')
            obj.Camera=value;
        end

        function set.TCurrent(obj,value)

            value=double(value);
            obj.TCurrent=value;
        end
    end

    methods


        function idx=addBody(h,b)

            h.initIfNeeded;



            if isempty(b.Geometry.FaceVertexColorData)
                error(message('aero:Animation:CantAddEmptyBody'));
            else
                b.generatePatches(get(h.Figure,'CurrentAxes'));
                h.Bodies{end+1}=b;
            end

            idx=numel(h.Bodies);

        end


        function idx=createBody(h,bodyDataSrc,varargin)

            h.initIfNeeded;



            b=Aero.Body;
            if nargin==3
                srcType=varargin{1};
                b.load(bodyDataSrc,srcType);
            else
                b.load(bodyDataSrc);
            end
            b.generatePatches(get(h.Figure,'CurrentAxes'));
            h.Bodies{end+1}=b;

            idx=numel(h.Bodies);

        end


        function hide(h)

            if~isempty(h.Figure)&&ishghandle(h.Figure,'figure')
                set(h.Figure,'Visible','off');
            end

        end


        function initIfNeeded(h)

            if isempty(h.Figure)||~ishghandle(h.Figure,'figure')
                h.initialize;






                if~isempty(h.Bodies)&&~isempty(h.TCurrent)&&~isempty(h.TStart)
                    emptyVector=zeros(size(h.Bodies));
                    for k=1:length(h.Bodies)
                        emptyVector(k)=~isempty(h.Bodies{k}.TimeSeriesSource);
                    end
                    if h.TCurrent>=h.TStart&&all(emptyVector)
                        t=h.TCurrent;
                        h.updateBodies(t);
                        h.updateCamera(t);
                    end
                end
            end

        end


        function initialize(h)

            skyColor=[0.8,0.8,0.9];

            if ishghandle(h.Figure,'figure')

                delete(h.Figure);


                for k=1:numel(h.Bodies)
                    b=h.Bodies{k};
                    b.PatchHandles=[];
                    b.ViewingTransform=[];
                end
            end

            if numel(h.Name)>0
                figTitle=h.Name;
            else
                figTitle='Aero.Animation';
            end

            h.Figure=figure(...
            'Color',skyColor,...
            'Name',figTitle,...
            'Renderer','OpenGL',...
            'UserData',h,...
            'Visible','off',...
            'NumberTitle','off',...
            'MenuBar','none',...
            'PaperPositionMode','auto',...
            'IntegerHandle','off',...
            'HandleVisibility','on');



            if~isa(h.Camera,'Aero.Camera')
                h.Camera=Aero.Camera;
            end

            ax=axes;
            set(ax,...
            'xlim',h.Camera.xlim,'ylim',h.Camera.ylim,'zlim',h.Camera.zlim,...
            'Visible','off',...
            'Projection','perspective',...
            'units','normal',...
            'PlotBoxAspectRatioMode','manual',...
            'PlotBoxAspectRatio',[1,1,1],...
            'DataAspectRatioMode','manual',...
            'DataAspectRatio',[1,1,1],...
            'CameraViewAngleMode','manual',...
            'CameraViewAngle',h.Camera.ViewAngle,...
            'CameraTarget',h.Camera.AimPoint);



            for k=1:numel(h.Bodies)
                h.Bodies{k}.generatePatches(ax);
            end



            if isa(h.FigureCustomizationFcn,'function_handle')
                h.FigureCustomizationFcn(h.Figure);
            end

        end


        function h=moveBody(h,idx,trans,rot)


            h.Bodies{idx}.move(trans,rot);

        end



        function play(h,varargin)


            if isempty(h.Bodies)
                warning(message('aero:Animation:NoBodies'));
                return;
            end
            for i=1:size(h.Bodies,2)

                if strcmpi(h.Bodies{i}.TimeSeriesSourceType,'timeseries')
                    if h.Bodies{i}.TimeSeriesSource.Length==0
                        warning(message('aero:Animation:NoTimeseriesSource'));
                        return;
                    end
                else
                    if isempty(h.Bodies{i}.TimeSeriesSource)
                        warning(message('aero:Animation:NoTimeseriesSource'));
                        return;
                    end
                end
            end


            oldTimer=timerfind;

            if~isempty(oldTimer)
                try
                    oldTimer=oldTimer(strcmp(oldTimer.Name,'MLAnimTimer'));
                    while any(isvalid(oldTimer))

                    end
                catch invalidMLAnimTimer %#ok<NASGU>




                end
            end

            if isempty(h.Figure)||~ishghandle(h.Figure,'figure')
                warning(message('aero:Animation:NothingToAnimate'));
                h.initialize;
            end

            if~isfinite(h.TStart)||~isfinite(h.TFinal)
                locStartStopTimeHeuristic(h);
            else
                locStartStopTimeValidate(h);
            end

            if h.VideoRecord=="scheduled"
                setNonFiniteVideoTime(h);
                validateVideoStartStopTime(h);
            end



            h.show;



            timePace=ceil(1000/h.FramesPerSecond)/1000;

            timeAdvance=h.TimeScaling*timePace;


            if(abs((h.TimeScaling/h.FramesPerSecond)-timeAdvance)/timeAdvance>0.15)
                warning(message('aero:Animation:timePace',sprintf('%5.3f',timePace),...
                sprintf('%d',1/timePace)));
            end


            h.MLAnimTimer=timer('Name','MLAnimTimer');




            h.MLAnimTimer.BusyMode='drop';






            h.MLAnimTimer.ErrorFcn={@timerCallbackFcn,h};



            h.MLAnimTimer.ExecutionMode='fixedRate';
            h.MLAnimTimer.Period=timePace;
            h.MLAnimTimer.StartFcn={@timerCallbackFcn,h,h.TStart};
            h.MLAnimTimer.StopFcn={@timerCallbackFcn,h,h.TFinal};










            h.MLAnimTimer.TasksToExecute=ceil((h.TFinal-h.TStart)/(h.TimeScaling*timePace))+1;
            h.MLAnimTimer.TimerFcn={@timerCallbackFcn,h,timeAdvance};


            videoObj=[];


            h.MLAnimTimer.UserData={h.TStart;videoObj};




            start(h.MLAnimTimer);

        end


        function h=removeBody(h,idx)



            if ishghandle(h.Bodies{idx}.ViewingTransform,'hgtransform')
                delete(h.Bodies{idx}.ViewingTransform);
            end



            h.Bodies(idx)=[];


        end


        function show(h)

            h.initIfNeeded;

            set(h.Figure,'Visible','on');
            figure(h.Figure);

        end


        function h=updateBodies(h,t)

            if ishghandle(h.Figure,'figure')

                for k=1:numel(h.Bodies)
                    h.Bodies{k}.update(t);
                end
            end

        end



        function updateCamera(h,t)



            cam=h.Camera;
            cam.update(t,h.Bodies);

            xform=h.Camera.CoordTransformFcn;


            h.TCurrent=t;

            if isa(xform,'function_handle')




                upVector=xform(-cam.UpVector([1,3,2]),[0,0,0]);
                pos=xform(-cam.Position([1,3,2]),[0,0,0]);
                aimPt=xform(-cam.AimPoint([1,3,2]),[0,0,0]);

                minxyz=[cam.xlim(1),cam.ylim(1),cam.zlim(1)];
                maxxyz=[cam.xlim(2),cam.ylim(2),cam.zlim(2)];

                hgmin=xform(-minxyz([1,3,2]),[0,0,0]);
                hgmax=xform(-maxxyz([1,3,2]),[0,0,0]);



                if ishghandle(h.Figure,'figure')
                    ax=get(h.Figure,'CurrentAxes');
                    set(ax,...
                    'xlim',sort([hgmin(1),hgmax(1)]),...
                    'ylim',sort([hgmin(2),hgmax(2)]),...
                    'zlim',sort([hgmin(3),hgmax(3)]),...
                    'DataAspectRatio',[1,1,1],...
                    'CameraUpVector',upVector,...
                    'CameraPosition',pos,...
                    'CameraTarget',aimPt,...
                    'CameraViewAngle',cam.ViewAngle);


drawnow

                end

            else
                warning(message('aero:Animation:CorruptCamera'));
            end


        end

    end

    methods(Hidden)


        function legacyDelete(h)






            if~isempty(h.Figure)&&ishghandle(h.Figure,'figure')
                delete(h.Figure)
            end

            if(~isempty(h.MLAnimTimer)&&isvalid(h.MLAnimTimer))
                try
                    stop(h.MLAnimTimer)
                catch invalidMLAnimTimer %#ok<NASGU>




                end
            end
            h.MLAnimTimer=[];

        end

    end

end



function timerCallbackFcn(timerObj,event,h,timeAdvance)


    switch event.Type
    case 'StartFcn'

        if~strcmpi(h.VideoRecord,'off')
            userData=get(timerObj,'UserData');

            videoObj=VideoWriter(h.VideoFileName,h.VideoCompression);

            videoObj.FrameRate=h.FramesPerSecond;
            if any(strncmp(h.VideoCompression,{'Motion JPEG AVI','MPEG-4'},length(h.VideoCompression)))

                videoObj.Quality=h.VideoQuality;
            end
            timerObj.UserData={userData{1},videoObj};
        end
    case 'TimerFcn'
        userData=get(timerObj,'UserData');


        t=userData{1};


        videoObj=userData{2};

        if((t==h.TStart)&&strcmpi(h.VideoRecord,'on'))||...
            ((t<=h.VideoTStart)&&strcmpi(h.VideoRecord,'scheduled'))

            open(videoObj);
        end

        if(t<h.TFinal)

            h.updateBodies(t);
            h.updateCamera(t);


            timerObj.UserData={h.TStart+timerObj.TasksExecuted*timeAdvance;...
            videoObj};

            if ishghandle(h.Figure,'figure')&&(strcmpi(h.VideoRecord,'on')||...
                (((t>=h.VideoTStart)&&(t<=h.VideoTFinal))&&strcmpi(h.VideoRecord,'scheduled')))
                try

                    frame=getframe(h.figure);
                    writeVideo(videoObj,frame);
                catch ME %#ok<NASGU>

                end
            end
        else

            h.updateBodies(h.TFinal);
            h.updateCamera(h.TFinal);


            if ishghandle(h.Figure,'figure')&&(strcmpi(h.VideoRecord,'on')||...
                ((t<=h.VideoTFinal)&&strcmpi(h.VideoRecord,'scheduled')))
                try

                    frame=getframe(h.figure);
                    writeVideo(videoObj,frame);
                catch ME %#ok<NASGU>

                end
            end
        end
    case 'StopFcn'

        if~strcmpi(h.VideoRecord,'off')
            userData=get(timerObj,'UserData');
            videoObj=userData{2};
            close(videoObj);
        end

        delete(timerObj)
    case 'ErrorFcn'

        if~strcmpi(h.VideoRecord,'off')
            userData=get(timerObj,'UserData');
            videoObj=userData{2};
            close(videoObj);
        end
    end
end

function locStartStopTimeHeuristic(h)






    for i=1:length(h.Bodies)
        [tempStart(i),tempFinal(i)]=h.Bodies{i}.findstartstoptimes;%#ok<AGROW>
    end
    h.TStart=max(tempStart(isfinite(tempStart)));
    h.TFinal=min(tempFinal(isfinite(tempFinal)));

end

function locStartStopTimeValidate(h)





    validateStartTimeLessThanFinalTime(h)



    for i=1:length(h.Bodies)
        [tempStart(i),tempFinal(i)]=h.Bodies{i}.findstartstoptimes;%#ok<AGROW>
    end


    minStart=max(tempStart(isfinite(tempStart)));
    maxFinal=min(tempFinal(isfinite(tempFinal)));

    validateTimeBounds(h,minStart,maxFinal)

end

