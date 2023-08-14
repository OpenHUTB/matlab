
function dlgStruct=getPassiveDialogSchema(obj,~)




    dlgStruct=[];
    dlgTag='Tree_';
    try
        text1.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:SimulinkModel'));
        text1.Type='text';
        text1.RowSpan=[1,1];
        text1.ColSpan=[1,1];

        modelOpen.Type='hyperlink';
        modelOpen.MatlabMethod='actionCallback';
        modelOpen.Name=obj.resultsExplorer.topModelName;
        modelOpen.MatlabArgs={obj,'modelOpen'};
        modelOpen.RowSpan=[1,1];
        modelOpen.ColSpan=[2,2];
        modelOpen.Tag=[dlgTag,'modelOpen'];
        modelOpen.WidgetId=[dlgTag,'modelOpen'];

        text2.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:InputFolder'));
        text2.Type='text';
        text2.Graphical=true;
        text2.RowSpan=[2,2];
        text2.ColSpan=[1,1];

        folderOpen.Type='hyperlink';
        folderOpen.MatlabMethod='actionCallback';
        folderOpen.Name=obj.resultsExplorer.getInputDir();
        folderOpen.MatlabArgs={obj,'folderOpen'};
        folderOpen.RowSpan=[2,2];
        folderOpen.ColSpan=[2,2];
        folderOpen.Tag=[dlgTag,'folderOpen'];
        folderOpen.WidgetId=[dlgTag,'folderOpen'];
        folderOpen.DialogRefresh=true;


        refreshButton.Type='pushbutton';
        refreshButton.FilePath=fullfile(matlabroot,'toolbox','slcoverage','+cvi','+ResultsExplorer','@ResultsExplorer','icons','refresh.png');
        refreshButton.Type='pushbutton';
        refreshButton.ToolTip=getString(message('Slvnv:simcoverage:cvresultsexplorer:SyncFolder'));
        refreshButton.Mode=true;
        refreshButton.RowSpan=[2,2];
        refreshButton.ColSpan=[3,3];
        refreshButton.Tag=[dlgTag,'refreshButton'];
        refreshButton.WidgetId=[dlgTag,'refreshButton'];
        refreshButton.MatlabMethod='actionCallback';
        refreshButton.MatlabArgs={obj,'syncFolder'};

        ch=getChecksum(obj.resultsExplorer);
        checksumGroupItems={};
        if~isempty(ch)
            checksumTxt1.Type='text';
            checksumTxt1.Name=sprintf('u1: %d',ch(1));
            checksumTxt1.RowSpan=[1,1];
            checksumTxt1.ColSpan=[1,1];

            checksumTxt2.Type='text';
            checksumTxt2.Name=sprintf('u2: %d',ch(2));
            checksumTxt2.RowSpan=[1,1];
            checksumTxt2.ColSpan=[2,2];

            checksumTxt3.Type='text';
            checksumTxt3.Name=sprintf('u3: %d',ch(3));
            checksumTxt3.RowSpan=[1,1];
            checksumTxt3.ColSpan=[3,3];

            checksumTxt4.Type='text';
            checksumTxt4.Name=sprintf('u4: %d',ch(4));
            checksumTxt4.RowSpan=[1,1];
            checksumTxt4.ColSpan=[4,4];
            checksumGroupItems={checksumTxt1,checksumTxt2,checksumTxt3,checksumTxt4};
        end
        checksumGroup.Type='group';
        checksumGroup.Flat=true;
        checksumGroup.Visible=~isempty(ch);
        checksumGroup.Alignment=2;
        checksumGroup.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:Checksum'));
        checksumGroup.Items=checksumGroupItems;
        checksumGroup.LayoutGrid=[1,4];
        checksumGroup.ColSpan=[1,4];
        checksumGroup.RowSpan=[3,3];


        iFiles=obj.resultsExplorer.incompatibleFiles;
        incompGroup.Type='group';
        incompGroup.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:IncompatibleFiles'));
        incompGroup.Flat=true;
        incompGroup.Visible=~isempty(iFiles);
        incompGroup.LayoutGrid=[numel(iFiles)+1,4];
        incompGroup.ColSpan=[1,4];
        incompGroup.RowSpan=[4,4];

        if~isempty(iFiles)

            items={};
            for idx=1:numel(iFiles)
                [~,fileName]=fileparts(iFiles{idx});
                items=[items,{fileName}];%#ok<AGROW>
            end
            text.Name=strjoin(items,', ');
            text.Type='text';
            text.Graphical=true;

            incompGroup.Items={text};
        end

        dlgStruct.DialogTitle=getString(message('Slvnv:simcoverage:cvresultsexplorer:CovFolder'));
        dlgStruct.LayoutGrid=[5,4];
        dlgStruct.RowStretch=[0,0,0,0,1];
        dlgStruct.ColStretch=[0,0,0,1];
        dlgStruct.Items={modelOpen,folderOpen,refreshButton,text1,text2,checksumGroup,incompGroup};
        dlgStruct.Sticky=true;
        dlgStruct.DialogTag=[dlgTag,'passive'];
        dlgStruct.HelpArgs={dlgStruct.DialogTag};
        dlgStruct.HelpMethod='cvi.ResultsExplorer.ResultsExplorer.helpFcn';
    catch MEx
        rethrow(MEx);
    end