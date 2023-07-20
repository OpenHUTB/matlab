classdef Instance





    methods(Static)


        function sigAnalyzerGUI=gui(varargin)
            util=Simulink.sdi.Instance.getSetSAUtils();
            if isempty(util)
                Simulink.sdi.Instance.getSetSAUtils(signal.sigappsshared.SignalUtilities);
            end
            sigAnalyzerGUI=signal.analyzer.Instance.getSetGUI();
            signal.analyzer.Instance.getSetGUIOpenningFlag(true);
            isQuery=(nargin==1&&ischar(varargin{1}));
            if~isQuery&&(isempty(sigAnalyzerGUI)||~isRunning(sigAnalyzerGUI))
                SDIEngine=Simulink.sdi.Instance.engine();
                sigAnalyzerGUI=signal.analyzer.WebGUI(SDIEngine,varargin{:});
                signal.analyzer.Instance.getSetGUI(sigAnalyzerGUI);
            end
            signal.analyzer.Instance.getSetGUIOpenningFlag(false);
        end


        function out=isSDIRunning()

            gui=signal.analyzer.Instance.gui('isGUIUp');
            out=~isempty(gui)&&isRunning(gui);
        end


        function setUseSystemBrowser(useSystemBrowserParam)
            useSystemBrowserParam=logical(useSystemBrowserParam);
            useSystemBrowser=Simulink.sdi.getUseSystemBrowser;
            if useSystemBrowser~=useSystemBrowserParam
                isOpen=signal.analyzer.Instance.isSDIRunning();
                signal.analyzer.Instance.close();
                signal.analyzer.Instance.getSetGUI([]);
                Simulink.sdi.setUseSystemBrowser(useSystemBrowserParam);
                if isOpen
                    signal.analyzer.Instance.open();
                end
            end
        end


        function open(varargin)
            [flag,~]=builtin('license','checkout','Signal_Toolbox');
            if~flag
                error(message('SDI:sigAnalyzer:SPTRequired'));
            end

            if signal.analyzer.Instance.getSetGUIOpenningFlag()
                return;
            end


            persistent storage;
            if isempty(storage)
                storage=1;%#ok
                try


                    if~Simulink.sdi.enableMultiAppMode
                        Simulink.sdi.close();
                    end


                    bWasRunning=signal.analyzer.Instance.isSDIRunning();
                    gui=signal.analyzer.Instance.getMainGUI(varargin{:});


                    if bWasRunning
                        gui.bringToFront();
                    end
                catch me %#ok
                end
                storage=[];
            end
        end


        function close(filename)

            if signal.analyzer.Instance.isSDIRunning()
                gui=signal.analyzer.Instance.gui;
                if nargin>0
                    signal.analyzer.save(filename);
                end
                gui.Close;
            end
            signal.analyzer.Instance.getSetGUI([]);
            signal.analyzer.Instance.getSetGUIOpenningFlag(false);
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

            result=signal.analyzer.Instance.gui(varargin{:});
        end


        function onMATLABExit()
            signal.analyzer.Instance.close();
        end


        function createLabelRepository()
            matname=signal.sigappsshared.SignalUtilities.getStorageLSSFilename();
            if exist(matname,'file')==2

                delete(matname)
            end
            m=matfile(matname,'Writable',true);
            m.Options=[];
        end
    end
end
