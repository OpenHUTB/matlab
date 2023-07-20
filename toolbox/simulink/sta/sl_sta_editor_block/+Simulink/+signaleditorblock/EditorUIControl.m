classdef EditorUIControl<handle





    properties
JSSubscriber
EditorDlg
BlockH
FullFileName
    end

    methods
        function obj=EditorUIControl

        end

        function set.EditorDlg(obj,EditorDlg)
            obj.EditorDlg=EditorDlg;
            obj.EditorDlg.addOnCleanup(@obj.cbEditorClose);
        end

        function showEditorUI(obj,BlockH)

            fullfileName=Simulink.signaleditorblock.FileUtil.getFullFileNameForBlock(BlockH);
            if~isempty(obj.EditorDlg)&&isvalid(obj.EditorDlg)
                obj.EditorDlg.bringToFront;
            else
                [~,~,ext]=fileparts(fullfileName);
                if~strcmpi(ext,'.mat')
                    throw(MException(message('sl_sta_editor_block:message:NotMATFile',fullfileName)));
                end
                if~exist(fullfileName,'file')&&...
                    ~strcmp(fullfileName,'untitled.mat')
                    throw(MException(message('sl_sta_editor_block:message:NonExistentFile',fullfileName)));
                end

                hash1=Simulink.sta.InstanceMap.getInstance();
                openTags=hash1.getOpenTags;
                IS_EDITOR=false;
                editor=[];

                for kInstance=1:length(openTags)
                    sourceInEditor='';

                    editor=getUIInstance(hash1,openTags{kInstance});

                    if iscell(editor.DataSource)
                        sourceInEditor=editor.DataSource{1};

                        if isa(sourceInEditor,'iofile.File')
                            sourceInEditor=sourceInEditor.FileName;
                        end

                    else
                        sourceInEditor=editor.DataSource;
                    end


                    IS_EDITOR=isa(editor,'Simulink.sta.Editor')&&...
                    isvalid(editor)&&...
                    strcmp(sourceInEditor,fullfileName);

                    if IS_EDITOR
                        break;
                    end
                end
                if~IS_EDITOR
                    model=obj.getModelForBlock(BlockH);
                    editor=Simulink.sta.Editor('Datasource',fullfileName,...
                    'StandAlone',true,...
                    'Model',model,...
                    'SignalEditorBlock',true);
                    editor.show;
                end
                editor.bringToFront;
                topics=Simulink.sta.EditorTopics;
                obj.JSSubscriber=message.subscribe([topics.BASE_MSG,editor.editorAppID,'/dispatcher'],@obj.cbEditorUIUpdate);
                obj.EditorDlg=editor;
            end




            obj.BlockH=BlockH;
            obj.FullFileName=fullfileName;
        end

        function cbEditorClose(obj)

            map=Simulink.signaleditorblock.ListenerMap.getInstance;
            if isempty(obj.FullFileName)
                map.removeListener([num2str(obj.BlockH,32),'untitled.mat']);
            else
                map.removeListener(obj.FullFileName);
            end
        end


        function cbEditorUIUpdate(obj,msg)
            topics=Simulink.sta.EditorTopics;
            if strcmp(msg{1},topics.EDITOR_UPDATED)
                blocks={obj.BlockH};
                map=Simulink.signaleditorblock.ListenerMap.getInstance;
                for id=1:length(blocks)
                    block=blocks{id};



                    UIDataModel=map.getListenerMap(num2str(block,32));
                    if~isempty(UIDataModel)&&isempty(obj.FullFileName)
                        blockProperties=Simulink.signaleditorblock.model.SignalEditorBlock.createBlockProperties(block);
                        try
                            UIDataModel.updateDataModel(blockProperties);
                        catch ME
                            msg=MSLException(getSimulinkBlockHandle(block),ME);
                            throw(msg);
                        end


                        dlgs=Simulink.signaleditorblock.getDialogFromBlockHandle(block);
                        for dlgid=1:length(dlgs)
                            dlg=dlgs(dlgid);
                            dlg.refresh();
                        end
                    else

                        Simulink.signaleditorblock.MaskSetting.enableMaskInitialization(block);
                    end
                end
            elseif strcmp(msg{1},topics.MAT_FILE_UPDATE)
                fileName=msg{2}.filename;
                if ishandle(obj.BlockH)
                    conciseFileName=Simulink.signaleditorblock.FileUtil.getConciseFileNameForFile(fileName);
                    oldFileName=Simulink.signaleditorblock.FileUtil.getFullFileNameForBlock(obj.BlockH);
                    map=Simulink.signaleditorblock.ListenerMap.getInstance;
                    UIDataModel=map.getListenerMap(num2str(obj.BlockH,32));
                    if~isempty(UIDataModel)
                        Simulink.signaleditorblock.MaskSetting.disableMaskInitialization(obj.BlockH);
                        set_param(obj.BlockH,'FileName',conciseFileName);
                        blockProperties=Simulink.signaleditorblock.model.SignalEditorBlock.createBlockProperties(obj.BlockH);
                        try
                            UIDataModel.updateDataModel(blockProperties);
                        catch ME
                            msg=MSLException(obj.BlockH,ME);
                            throw(msg);
                        end

                        dlgs=Simulink.signaleditorblock.getDialogFromBlockHandle(obj.BlockH);
                        for dlgid=1:length(dlgs)
                            dlg=dlgs(dlgid);
                            dlg.refresh();
                        end
                    else
                        set_param(obj.BlockH,'FileName',conciseFileName);
                        Simulink.signaleditorblock.MaskSetting.enableMaskInitialization(obj.BlockH);
                    end

                    editorUIControl=map.getListenerMap(fileName);
                    if isempty(editorUIControl)
                        map.addListener(fileName,obj);
                        obj.FullFileName=fileName;
                    end


                    if strcmp(oldFileName,'untitled.mat')
                        map.removeListener([num2str(obj.BlockH,32),'untitled.mat']);
                    end
                end
            else


            end
        end

        function showUntitledEditorUI(obj,blockH)
            if~isempty(obj.EditorDlg)&&isvalid(obj.EditorDlg)
                obj.EditorDlg.bringToFront;
            else
                Scenario=Simulink.SimulationData.Dataset;
                Scenario{1}=timeseries([0;0],[0;10]);
                Scenario{1}.Name='Signal 1';
                Input.Scenario=Scenario;
                model=obj.getModelForBlock(blockH);
                editor=Simulink.sta.Editor('StandAlone',true,...
                'ViewInput',Input,...
                'EditMode',true,...
                'ForceDirty',true,...
                'Model',model,...
                'SignalEditorBlock',true);
                editor.show();
                obj.EditorDlg=editor;
                topics=Simulink.sta.EditorTopics;
                obj.JSSubscriber=message.subscribe([topics.BASE_MSG,editor.editorAppID,'/dispatcher'],@obj.cbEditorUIUpdate);
                obj.BlockH=blockH;
            end

        end

    end

    methods(Access=private)
        function model=getModelForBlock(~,block)



            model=bdroot(get_param(block,'Parent'));
        end
    end
end

