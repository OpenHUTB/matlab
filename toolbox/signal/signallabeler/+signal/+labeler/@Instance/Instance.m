classdef Instance




    methods(Static)
        function signalLabelerGUI=gui(varargin)
            signalLabelerGUI=signal.labeler.Instance.getSetGUI();
            signal.labeler.Instance.getSetGUIOpenningFlag(true);
            isQuery=(nargin==1&&ischar(varargin{1}));
            if~isQuery&&(isempty(signalLabelerGUI)||~isRunning(signalLabelerGUI))
                SDIEngine=Simulink.sdi.Instance.engine();
                signalLabelerGUI=signal.labeler.WebGUI(SDIEngine,varargin{:});
                signal.labeler.Instance.getSetGUI(signalLabelerGUI);
            end
            signal.labeler.Instance.getSetGUIOpenningFlag(false);
        end


        function out=isSignalLabelerRunning()

            gui=signal.labeler.Instance.gui('isGUIUp');
            out=~isempty(gui)&&isRunning(gui);
        end


        function setUseSystemBrowser(useSystemBrowserParam)
            useSystemBrowserParam=logical(useSystemBrowserParam);
            useSystemBrowser=Simulink.sdi.getUseSystemBrowser;
            if useSystemBrowser~=useSystemBrowserParam
                isOpen=signal.labeler.Instance.isSignalLabelerRunning();
                signal.labeler.Instance.close();
                signal.labeler.Instance.getSetGUI([]);
                Simulink.sdi.setUseSystemBrowser(useSystemBrowserParam);
                if isOpen
                    signal.labeler.Instance.open();
                end
            end
        end


        function open(varargin)
            [flag,~]=builtin('license','checkout','Signal_Toolbox');
            if~flag
                error(message('signal:signallabeler:SPTRequired'));
            end

            if signal.labeler.Instance.getSetGUIOpenningFlag()
                return;
            end


            persistent storage;
            if isempty(storage)
                storage=1;%#ok
                try

                    bWasRunning=signal.labeler.Instance.isSignalLabelerRunning();
                    gui=signal.labeler.Instance.getMainGUI(varargin{:});


                    if bWasRunning
                        gui.bringToFront();
                    end
                catch me %#ok
                end
                storage=[];
            end
        end


        function close(filename)

            if signal.labeler.Instance.isSignalLabelerRunning()
                gui=signal.labeler.Instance.gui;
                if nargin>0
                    signal.labeler.save(filename);
                end
                gui.Close;
            end
            signal.labeler.Instance.getSetGUI([]);
            signal.labeler.Instance.getSetGUIOpenningFlag(false);
        end

    end



    methods(Hidden=true,Static=true)
        function gui=getSetGUI(obj)

            mlock;
            persistent GUI;
            if nargin>0
                GUI=obj;
            elseif~isempty(GUI)&&~isvalid(GUI)
                GUI=[];
            end
            gui=GUI;
        end


        function isOpening=getSetGUIOpenningFlag(val)

            mlock;
            persistent GUIIsOpening;
            if nargin>0
                GUIIsOpening=val;
            elseif isempty(GUIIsOpening)
                GUIIsOpening=false;
            end
            isOpening=GUIIsOpening;
        end


        function result=getMainGUI(varargin)

            result=signal.labeler.Instance.gui(varargin{:});
        end


        function onMATLABExit()
            signal.labeler.Instance.close();
        end
    end
end
