







classdef snapshotanim<Simulink.SnapshotInterface
    properties
data




sixDofData
    end

    methods
        function out=snapshotanim(data)
            out.data=data.handle;
            out.sixDofData=data.sixDofData;
        end
    end

    methods
        function captureSnapshot(obj,captureForFastRestart)


















            handle=obj.data;
            if ishandle(handle)
                udata=get(handle,'UserData');
                if strcmp(udata.Id,'6DOFcpp')
                    if(~captureForFastRestart)
                        if isfield(udata,'Index')&&isfield(udata,'sixDofData')

                            udata.Index=udata.Index+1;
                        else

                            udata.Index=1;
                            udata.snapshot=[];
                            udata.sixDofData=obj.sixDofData;
                        end

                        for k=1:size(udata.sixDofData,1)
                            udata.snapshot(udata.Index).body(k).position=udata.sixDofData(k,1:3);
                            udata.snapshot(udata.Index).body(k).rotation=udata.sixDofData(k,4:6);
                        end
                    else

                        if~isfield(udata,'sixDofData')
                            udata.sixDofData=obj.sixDofData;
                        end
                        if~isfield(udata,'Index')
                            udata.Index=0;
                        end
                        for k=1:size(udata.sixDofData,1)
                            udata.fastRestartSnapshot.body(k).position=obj.sixDofData(k,1:3);
                            udata.fastRestartSnapshot.body(k).rotation=obj.sixDofData(k,4:6);
                        end
                    end
                else
                    if(~captureForFastRestart)

                        udata.Index=udata.Index+1;
                        udata.snapshot(udata.Index).lines=[];
                        udata.snapshot(udata.Index).vertices=[];
                        udata.snapshot(udata.Index).camera=[];
                        udata.snapshot(udata.Index)=obj.captureSnapshotImpl(udata);
                    else
                        udata.fastRestartSnapshot=obj.captureSnapshotImpl(udata);
                    end
                end


                set(handle,'UserData',udata);
            else
                warning(message('aeroblks:saeroanim3dof:noFigure'));
            end
        end
        function snapshot=captureSnapshotImpl(~,udata)

            snapshot.lines.craft.x1=get(udata.line(1),'XData');
            snapshot.lines.craft.x2=get(udata.line(1),'YData');
            snapshot.lines.craft.x3=get(udata.line(1),'ZData');
            snapshot.lines.target.x1=get(udata.line(2),'XData');
            snapshot.lines.target.x2=get(udata.line(2),'YData');
            snapshot.lines.target.x3=get(udata.line(2),'ZData');
            snapshot.vertices.craft=get(udata.craft,'vertices');
            if strcmp(udata.Id,'3DOF')
                snapshot.vertices.target=get(udata.target,'vertices');
            end
            snapshot.camera.position=get(udata.axes(1),'cameraPosition');
            snapshot.camera.upvector=get(udata.axes(1),'cameraUpVector');
            snapshot.camera.target=get(udata.axes(1),'cameraTarget');
            snapshot.camera.viewangle=get(udata.axes(1),'cameraViewAngle');
        end
        function popLatest(obj,numberOfSnapshots)






            handle=obj.data;
            if ishandle(handle)
                udata=get(handle,'UserData');


                if udata.Index>0
                    udata.Index=udata.Index-numberOfSnapshots;
                end


                set(handle,'UserData',udata);
            end
        end
        function popOldest(~,~)


        end
        function size(obj,sz)






            handle=obj.data;
            if ishandle(handle)
                udata=get(handle,'UserData');
                if udata.Index>sz
                    udata.Index=udata.Index-1;
                    udata.snapshot=udata.snapshot(2:end);
                end

                set(handle,'UserData',udata);
            end
        end
        function clear(obj)







            if ishandle(obj.data)
                handle=obj.data;
                udata=get(handle,'userData');

                udata.snapshot=[];
                udata.Index=0;
                if strcmp(udata.Id,'6DOFcpp')&&isfield(udata,'sixDofData')
                    sz=size(udata.sixDofData);
                    udata.sixDofData=zeros(sz);
                end

                set(handle,'userData',udata);
            end
        end
        function rollBack(obj)

            if ishandle(obj.data)
                handle=obj.data;
                udata=get(handle,'userData');
                restoreSnapshot(obj,handle,udata,udata.snapshot(udata.Index));
            else
                warning(message('aeroblks:saeroanim3dof:noFigure'));
            end
        end
        function restoreSnapshot(~,handle,udata,snapshot)





            flag_nofig=0;
            if strcmp(udata.Id,'6DOFcpp')
                if isfield(udata,'figure')
                    if~ishghandle(udata.figure)
                        warning(message('aeroblks:MATLABAnimation:noFigure',...
                        get_param(handle,'Name')));
                        flag_nofig=1;
                    end
                else
                    warning(message('aeroblks:MATLABAnimation:noFigure',...
                    get_param(handle,'Name')));
                    flag_nofig=1;
                end
            end
            if flag_nofig==0
                if strcmp(udata.Id,'6DOFcpp')

                    h=get(udata.figure,'UserData');
                    if isa(h,'Aero.Animation');
                        for k=1:numel(h.Bodies)
                            h.moveBody(k,snapshot.body(k).position,...
                            snapshot.body(k).rotation);
                        end
                        h.updateCamera(0);
                    end
                else

                    x1=snapshot.lines.craft.x1;
                    x2=snapshot.lines.craft.x2;
                    x3=snapshot.lines.craft.x3;
                    set(udata.line(1),'XData',x1,'YData',x2,'ZData',x3);
                    x1=snapshot.lines.target.x1;
                    x2=snapshot.lines.target.x2;
                    x3=snapshot.lines.target.x3;
                    set(udata.line(2),'XData',x1,'YData',x2,'ZData',x3);
                    if strcmp(udata.Id,'3DOF')
                        set(udata.target,'vertices',snapshot.vertices.target);
                    end
                    set(udata.craft,'vertices',snapshot.vertices.craft);
                    set(udata.axes(1),'cameraUpVector',snapshot.camera.upvector,...
                    'cameraPosition',snapshot.camera.position,...
                    'cameraTarget',snapshot.camera.target,...
                    'cameraViewAngle',snapshot.camera.viewangle);
                    drawnow;
                end

                set(handle,'userData',udata);
            end
        end
        function reset(obj)


            handle=obj.data;
            if ishandle(handle)
                udata=get(handle,'UserData');
                if(isfield(udata,'fastRestartSnapshot')&&...
                    ~isempty(udata.fastRestartSnapshot))

                    restoreSnapshot(obj,handle,udata,udata.fastRestartSnapshot);
                else
                    warning(message('aeroblks:MATLABAnimation:noFigure',...
                    get_param(handle,'Name')));
                end
            end
        end
    end
end


