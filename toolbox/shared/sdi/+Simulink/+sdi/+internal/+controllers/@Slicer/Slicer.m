

classdef Slicer<handle



    methods(Static)

        function ret=getController(varargin)

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)



                assert(nargin==1&&isa(varargin{1},'Simulink.sdi.internal.controllers.Dispatcher'));
                dispatcherObj=varargin{1};
                ctrlObj=Simulink.sdi.internal.controllers.Slicer(dispatcherObj);
            end


            ret=ctrlObj;
        end
    end


    methods(Hidden)

        function this=Slicer(dispatcherObj)


            this.Dispatcher=dispatcherObj;
            this.RunIDByIndexMap=Simulink.sdi.Map(int32(0),int32(0));

            import Simulink.sdi.internal.controllers.Slicer;
            this.Dispatcher.subscribe(...
            [Slicer.ControllerID,'/','ready'],...
            @(arg)cb_Ready(this,arg));
            this.Dispatcher.subscribe(...
            [Slicer.ControllerID,'/','slice'],...
            @(arg)cb_Slice(this,arg));
            this.Dispatcher.subscribe(...
            [Slicer.ControllerID,'/','startTime'],...
            @(arg)cb_StartTime(this,arg));
            this.Dispatcher.subscribe(...
            [Slicer.ControllerID,'/','stopTime'],...
            @(arg)cb_StopTime(this,arg));

            this.Dispatcher.subscribe(...
            [Slicer.ControllerID,'/','dataCursorsResp'],...
            @(arg)cb_dataCursorsResp(this,arg));
            this.Dispatcher.subscribe(...
            [Slicer.ControllerID,'/','echoResp'],...
            @(arg)cb_echoResp(this,arg));
            this.Dispatcher.registerRemove(...
            Slicer.ControllerID,...
            @(arg)cb_RemoveClient(this,arg));

            this.Dispatcher.subscribe(...
            [Slicer.ControllerID,'/','manager'],...
            @(arg)cb_Manager(this,arg));
        end


        function cb_Ready(this,arg)
            if Simulink.sdi.slicer()==0
                return;
            end

            this.ClientID=arg.clientID;
            this.State=1;

            setupData=struct;
            setupData.value='cb_Ready';
            this.publishToClient('echo',setupData);

            this.showDataCursors();
        end


        function cb_Slice(this,arg)


            if this.enabled
                if~isempty(this.slicerObj)
                    tw=[arg.data.start,arg.data.stop];
                    this.slicerObj.applySdiTimeWindow(tw);


                    this.publishToClient('disableButtons',struct);
                end
            end
        end

        function cb_RemoveClient(this,arg)
            if~isempty(this.slicerObj)
                this.slicerObj.closeSdiCallback();
            end
        end

        function cb_StartTime(this,arg)

            setupData=struct;
            setupData.value=0;

            this.publishToClient('enableButtons',setupData);
        end

        function cb_StopTime(this,arg)

            setupData=struct;
            setupData.value=0;

            this.publishToClient('enableButtons',setupData);
        end

        function cb_Manager(this,~)
            if~isempty(this.slicerObj)

                open_system(this.getCurrentUser);

                if~isempty(this.slicerObj.dlg)
                    this.slicerObj.dlg.show();
                end
            end
        end

        function cb_dataCursorsResp(this,arg)

            this.cursorPositions=sort([arg.data.start...
            ,arg.data.stop]);
        end

        function cb_echoResp(this,arg)



        end

        function pos=getDataCursors(this)
            setupData=struct;
            this.publishToClient('get_data_cursors',setupData);
            pos=this.cursorPositions;
        end

        function showDataCursors(this)
            setupData=struct;
            setupData.value=2;
            this.publishToClient('show_data_cursors',setupData);
        end

        function hideDataCursors(this)
            setupData=struct;
            this.publishToClient('hide_data_cursors',setupData);
        end

        function moveLeftDataCursor(this,arg)
            setupData=struct;
            setupData.value=arg.data.time;
            this.publishToClient('move_left_datacursor',setupData);
        end

        function moveRightDataCursor(this,arg)
            setupData=struct;
            setupData.value=arg.data.time;
            this.publishToClient('move_right_datacursor',setupData);
        end

        function sliceAreaOn(this,color)




            setupData=struct;
            setupData.value=1;
            setupData.color=color;
            this.publishToClient('highlight_slice_area',setupData);
        end
        function sliceAreaOff(this)
            setupData=struct;
            setupData.value=0;
            this.publishToClient('highlight_slice_area',setupData);
        end



        function toggleDataCursors(this)
            if this.State==1
                this.State=2;
                this.showDataCursors();
            else
                this.State=1;
                this.hideDataCursors();
            end
        end


        function[success,existingMdl]=registerSlicerObj(this,msObj)
            success=true;
            existingMdl=msObj.modelH;
            if~isInUse(this)

                this.slicerObj=msObj;
            elseif isThisSlicerRegistered(this,msObj)

            else

                success=false;
                existingMdl=getCurrentUser(this);
            end
        end

        function deRegisterSlicerObj(this,msObj)
            if this.isThisSlicerRegistered(msObj)


                this.slicerObj=[];
            end
        end

        function yesno=isThisSlicerRegistered(this,msObj)

            assert(isa(msObj,'ModelSlicer'));
            yesno=isInUse(this)&&(msObj==this.slicerObj);
        end

        function yesno=isInUse(this)

            yesno=~isempty(this.slicerObj);
        end

        function userH=getCurrentUser(this)
            userH=[];
            if~isempty(this.slicerObj)
                userH=this.slicerObj.model;
            end
        end

        function enableController(obj,val)
            assert(islogical(val));
            obj.enabled=val;
            obj.enableButton(val);
        end

        function enableButton(obj,val)
            if val
                obj.publishToClient('enableButtons',struct);
            else
                obj.publishToClient('disableButtons',struct);
            end
        end

        function setDataCursorPositions(obj,pos)



            assert(size(pos,2)==2);
            assert(pos(1)<=pos(2));

            arg.data.time=pos(1);
            obj.moveLeftDataCursor(arg);
            arg.data.time=pos(2);
            obj.moveRightDataCursor(arg);
            obj.publishToClient('disableButtons',struct);
        end

        function highlightIntervals(obj,intervals)



            assert(size(intervals,2)==2);
            for i=1:size(intervals,1)
                range=intervals(i,:);
                assert(range(1)<=range(2));

            end
        end
    end


    methods(Access=private)
        function publishToClient(this,msgName,respVal)
            import Simulink.sdi.internal.controllers.Slicer;


            this.Dispatcher.publishToClient(this.ClientID,...
            Slicer.ControllerID,msgName,respVal);
        end
    end


    properties(Hidden)
        ClientID;
        Dispatcher;
        RunIDByIndexMap;
        State;
    end

    properties(Access=private)
        enabled=true;
        slicerObj=[];
        cursorPositions=[-1,-1];
    end

    properties(Constant)
        ControllerID='Slicer';
    end
end


