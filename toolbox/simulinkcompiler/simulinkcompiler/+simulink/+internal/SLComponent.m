classdef SLComponent<matlab.ui.componentcontainer.ComponentContainer




    properties(Access=protected,Abstract,Transient)




tgEventsTriggeringUpdateGUI
    end

    methods(Access=public,Hidden,Abstract)



updateGUI



disableControlForInvalidTarget

enableControlForValidTarget
    end

    properties(Access=protected,Transient,NonCopyable)













        firstUpdate=true;




        tgEventListenersTriggeringUpdateGUI=[]








        tgListenerCreate=[]
        tgListenerDestroy=[]

    end

    properties(Access=private,Transient)
        TargetI=[]
    end

    methods(Access=protected)
        function updateGUIWrapper(obj,varargin)
            args=varargin{:};
            try
                obj.updateGUI(args);
            catch ME



                if~strcmp(ME.identifier,'MATLAB:class:InvalidHandle')
                    rethrow(ME);
                end
            end
        end
    end



    properties(Dependent)
SimulationTarget
    end
    methods
        function set.SimulationTarget(obj,value)
            obj.initTarget(value);
        end

        function target=get.SimulationTarget(obj)
            target=obj.TargetI;
        end
    end

    properties(SetAccess=private,GetAccess=protected,Transient,NonCopyable)



        GetTargetNameFcnH=[]



        TargetSelectorObj=[]
    end
    methods
        function value=get.GetTargetNameFcnH(obj)
            if isempty(obj.GetTargetNameFcnH)

                obj.initTarget([]);
            end
            value=obj.GetTargetNameFcnH;
        end
    end

    properties(Access=private,Transient,NonCopyable)



        TargetChangedListener=[]




        DefaultTargetChangedListener=[]







        ConnectedListener=[]
        DisconnectedListener=[]






        ProgressDlg=[]
    end



    events
GUIUpdated
    end



    methods(Access=protected)
        function initTarget(obj,nameOrObj)

            if isempty(nameOrObj)
                obj.TargetI=simulink.SimulationTarget.getDefaultSimulationTarget();
                obj.GetTargetNameFcnH=@()obj.TargetI.TargetSettings.name;

                if~isempty(obj.DefaultTargetChangedListener)
                    delete(obj.DefaultTargetChangedListener);
                    obj.DefaultTargetChangedListener=[];
                end
            elseif isa(nameOrObj,'simulink.internal.Target')



                if~isscalar(nameOrObj)
                    simulink.internal.throw.Error('simulinkcompiler:simulink_components:InitInvalidArg');
                end

                obj.TargetSelectorObj=[];
                obj.TargetI=nameOrObj;
                obj.GetTargetNameFcnH=@()obj.TargetI.TargetSettings.name;

                if~isempty(obj.DefaultTargetChangedListener)
                    delete(obj.DefaultTargetChangedListener);
                    obj.DefaultTargetChangedListener=[];
                end
            end

            if~isempty(obj.TargetSelectorObj)
                obj.TargetChangedListener=...
                listener(obj.TargetSelectorObj,...
                'TargetSelectionChanged',...
                @(src,evnt)obj.targetSelectionChanged());
            end



            obj.targetSelectionChanged();
        end
    end




    methods(Access=public,Hidden)
        function targetSelectionChanged(obj)


            if isempty(obj.tgEventListenersTriggeringUpdateGUI)
                obj.tgEventListenersTriggeringUpdateGUI=...
                containers.Map('KeyType','char','ValueType','any');
            else
                listeners=obj.tgEventListenersTriggeringUpdateGUI.values;
                cellfun(@(x)delete(x),listeners);
                obj.tgEventListenersTriggeringUpdateGUI.remove(obj.tgEventListenersTriggeringUpdateGUI.keys);
            end
            if~isempty(obj.tgListenerCreate)||~isempty(obj.tgListenerDestroy)
                delete(obj.ConnectedListener);
                delete(obj.DisconnectedListener);
                obj.tgListenerDestroy();
            end



            tg=obj.tgGetTargetObject();
            if isempty(tg)
                obj.disableControlForInvalidTarget();
                return;
            end




            if obj.isDesignTime(),return;end









            for i=1:length(obj.tgEventsTriggeringUpdateGUI)
                evnt=obj.tgEventsTriggeringUpdateGUI{i};
                obj.tgEventListenersTriggeringUpdateGUI(evnt)=...
                listener(tg,evnt,@(src,evnt)obj.updateGUIWrapper(evnt));
            end
            if~isempty(obj.tgListenerCreate)||~isempty(obj.tgListenerDestroy)
                obj.ConnectedListener=listener(tg,'Connected',...
                @(src,evnt)obj.tgListenerCreate());
                obj.DisconnectedListener=listener(tg,'Disconnected',...
                @(src,evnt)obj.tgListenerDestroy());
                if tg.isConnected()
                    obj.tgListenerCreate();
                end
            end



            obj.updateGUIWrapper([]);
        end
    end




    methods(Access=protected)
        function TF=isSimulationTarget(obj,varargin)
            if~isempty(varargin)
                targetName=varargin{1};
            else
                targetName=obj.GetTargetNameFcnH();
            end

            TF=strcmp(targetName,...
            simulink.TargetTypes.SL_SIMULATION_TARGET.Value);
        end
    end




    methods(Access=protected)
        function openProgressDlg(obj,msg,title)
            obj.ProgressDlg=uiprogressdlg(...
            ancestor(obj.Parent,'figure'),...
            'Indeterminate','on',...
            'Message',msg,...
            'Title',title);
        end

        function closeProgressDlg(obj)
            try
                if~isempty(obj.ProgressDlg)
                    drawnow nocallbacks;
                    delete(obj.ProgressDlg);
                    obj.ProgressDlg=[];
                end
            catch ME



                if~strcmp(ME.identifier,'MATLAB:class:InvalidHandle')
                    rethrow(ME);
                end
            end
        end
    end




    methods(Access=protected)
        function uialert(obj,ME,varargin)
            fig=ancestor(obj.Parent,'figure');
            if strcmp(fig.Visible,'off')
                return;
            end
            errorTitle=message('simulinkcompiler:simulink_components:TargetErrorTitle');
            uialert(fig,ME.message,errorTitle.getString(),varargin{:});
        end

        function uiwarning(obj,msg)
            fig=ancestor(obj.Parent,'figure');
            if strcmp(fig.Visible,'off')
                return;
            end

            warningTitle=message('simulinkcompiler:simulink_components:TargetWarningTitle');
            uialert(fig,msg,warningTitle.getString(),'Icon','warning','Modal',true);
        end
    end




    methods(Access=protected)
        function val=isDesignTime(obj)





            val=false;
            if isprop(ancestor(obj,'figure'),'DesignTimeProperties')
                val=true;
            end
        end

        function verifyTargetIsInitialised(obj)


            if isempty(obj.TargetI)||obj.TargetI.isTargetEmpty()
                obj.disableControlForInvalidTarget();
            else
                obj.enableControlForValidTarget();
            end
        end


    end




    methods(Access=protected)





        function tg=tgGetTargetObject(obj,varargin)
            tg=[];

            if~isempty(varargin)
                targetName=varargin{1};
            else
                targetName=obj.GetTargetNameFcnH();
            end

            if obj.isSimulationTarget(targetName)
                tg=obj.TargetI;
            end
        end
    end




    methods(Access=public)
        function delete(obj)
            delete(obj.TargetChangedListener);
            delete(obj.DefaultTargetChangedListener);
            delete(obj.ConnectedListener);
            delete(obj.DisconnectedListener);

            delete(obj.ProgressDlg);

            if~isempty(obj.tgEventListenersTriggeringUpdateGUI)
                listeners=obj.tgEventListenersTriggeringUpdateGUI.values;
                cellfun(@(x)delete(x),listeners);
            end

            obj.tgListenerDestroy();
        end
    end




    methods
        function set.GetTargetNameFcnH(obj,value)
            validateattributes(value,{'function_handle'},{'scalar'});
            obj.GetTargetNameFcnH=value;
        end

        function set.TargetSelectorObj(obj,value)
            if~isempty(value)
                validateattributes(value,{'slrealtime.ui.control.TargetSelector'},{'scalar'});
            end
            obj.TargetSelectorObj=value;
        end
    end
end
