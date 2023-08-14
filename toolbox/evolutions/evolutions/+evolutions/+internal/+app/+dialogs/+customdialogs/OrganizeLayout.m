classdef OrganizeLayout<evolutions.internal.ui.tools.CustomDialogInterface




    properties(Access=protected)

        Prompt={getString(message('evolutions:ui:OrganizeLayoutDialogPrompt'))}
        Title=getString(message('evolutions:ui:OrganizeLayoutDialogTitle'))


ListBox
FileListPath
FileList

DeleteBtn
RenameBtn
CloseBtn
    end

    properties(Hidden,SetAccess=private,GetAccess=public)

DialogWidth
DialogHeight

WorkingGridRows
WorkingGridCols
    end

    methods(Access=?evolutions.internal.app.dialogs.customdialogs.CustomDialogFactory)
        function obj=OrganizeLayout()

            obj@evolutions.internal.ui.tools.CustomDialogInterface;
            obj.setDialogTitle(obj.Title);
        end

    end

    methods(Hidden)
        function setLayoutPath(obj,fileListPath)
            obj.FileListPath=fileListPath;
            refreshFileList(obj);
        end

        function refreshFileList(obj)
            folderList=dir(fullfile(obj.FileListPath,'*.json'));
            obj.ListBox.Items=cell.empty;
            obj.ListBox.ItemsData=cell.empty;
            if~isempty(folderList)
                layouts=cell.empty;%#ok<NASGU>
                fileNames={folderList.name}';

                nonHiddenFiles=cellfun(@(x)~strcmp(x(1),'.'),fileNames);
                layouts=fileNames(nonHiddenFiles);
                for idx=1:numel(layouts)
                    [~,name]=fileparts(layouts{idx});
                    obj.ListBox.Items{end+1}=name;
                    obj.ListBox.ItemsData{end+1}=fullfile(obj.FileListPath,layouts{idx});
                    obj.ListBox.Value=obj.ListBox.ItemsData{1};
                end
            end
            setButtonStates(obj);
        end
    end

    methods(Access=protected)

        function installCallbacks(obj)

            obj.DeleteBtn.ButtonPushedFcn=@obj.deleteBtnAction;
            obj.RenameBtn.ButtonPushedFcn=@obj.renameBtnAction;
            obj.CloseBtn.ButtonPushedFcn=@(~,~)delete(obj.Figure);
        end

        function deleteBtnAction(obj,~,~)


            if isfile(obj.ListBox.Value)
                delete(obj.ListBox.Value);
                refreshFileList(obj);
            end
        end

        function renameBtnAction(obj,~,~)
            obj.Output=struct('Action','delete','Value',obj.ListBox.Value);
            delete(obj.Figure);
        end
    end

    methods(Access=protected)

        function setButtonStates(obj)
            obj.DeleteBtn.Enable=~isempty(obj.ListBox.Items);
            obj.RenameBtn.Enable=~isempty(obj.ListBox.Items);
        end

        function setDialogSize(obj)
            obj.DialogWidth=410;
            obj.DialogHeight=200;
        end

        function setWorkingGridDimensions(obj)
            obj.WorkingGridRows={'1x','3x','2x'};
            obj.WorkingGridCols={'1x'};
        end

        function createDialogComponents(obj)

            obj.createLabel(obj.Prompt);


            obj.createListBox;


            obj.createButtons;
        end

        function createListBox(obj)
            listBox=uilistbox(obj.WorkingGrid,'BackgroundColor','white');
            listBox.Layout.Row=2;
            listBox.Items=cell.empty;
            obj.ListBox=listBox;
        end

        function createButtons(obj)
            btnGridRow={'1x'};
            btnGridCols={'1x','1x','1x'};
            btnGrid=uigridlayout...
            (obj.WorkingGrid,'RowHeight',btnGridRow,'ColumnWidth',btnGridCols);
            btnGrid.Layout.Row=3;
            deleteBtn=uibutton(btnGrid,'Text',...
            getString(message('evolutions:ui:DeleteLayoutButton')));
            deleteBtn.Layout.Column=1;

            renameBtn=uibutton(btnGrid,'Text',...
            getString(message('evolutions:ui:RenameLayoutButton')));
            renameBtn.Layout.Column=2;

            closeBtn=uibutton(btnGrid,'Text',...
            getString(message('evolutions:ui:CloseLayoutButton')));
            closeBtn.Layout.Column=3;

            obj.DeleteBtn=deleteBtn;
            obj.RenameBtn=renameBtn;
            obj.CloseBtn=closeBtn;
        end
    end
end
