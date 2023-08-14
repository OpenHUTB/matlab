function openDictionary(argIn,varargin)








    narginchk(1,2);
    generateChildren=false;
    if nargin==2
        generateChildren=varargin{1};
    end

    ed=Simulink.typeeditor.app.Editor.getInstance;
    st=ed.getStudio;
    ts=st.getToolStrip;
    openAction=ts.getAction('openSLDDAction');
    valid=openAction.enabled;

    if ed.isVisible&&~isempty(st)&&valid
        openAction.enabled=false;

        if ischar(argIn)||isstring(argIn)
            fileToImport=argIn;
        else
            assert(isa(argIn,'dig.CallbackInfo'));
            st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorWaitingForUserInputStatusMsg'));
            [fileName,pathName]=uigetfile({'*.sldd',DAStudio.message('Simulink:busEditor:SLDDFiles')},...
            DAStudio.message('Simulink:busEditor:FileOpenText'));

            fileToImport=fullfile(pathName,fileName);
        end

        if exist(fileToImport,'file')
            [~,name,ext]=fileparts(fileToImport);
            if strcmpi(ext,'.sldd')
                if~isvarname(name)
                    errorStr=DAStudio.message('Simulink:busEditor:InvalidMATLABFileNameForImport',name);
                    Simulink.typeeditor.utils.reportError(errorStr);
                    return;
                elseif sl.interface.dict.api.isInterfaceDictionary(fileToImport)

                    sl.interface.dictionaryApp.StudioApp.open(fileToImport);
                    return;
                end
                st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorOpenInProgressStatusMsg'));
                try
                    edRoot=ed.getSource;
                    sourceIdx=edRoot.findIdx(name);
                    if isempty(sourceIdx)
                        edRoot.addChild(fileToImport);
                        slddNode=edRoot.Children(end);
                    else
                        slddNode=edRoot.Children(sourceIdx);
                        assert(isequal(slddNode.NodeConnection.filespec,fileToImport));
                        tc=ed.getTreeComp;
                        if tc.isMinimized
                            ed.getListComp.setSource(slddNode);
                        end
                        tc.view(slddNode);
                    end

                    if generateChildren
                        slddNode.getChildren;
                    end

                    st.show;
                catch ME
                    Simulink.typeeditor.utils.reportError(ME.message);
                end
            end
        end
        st.setStatusBarMessage(DAStudio.message('Simulink:busEditor:BusEditorReadyStatusMsg'));
    end
