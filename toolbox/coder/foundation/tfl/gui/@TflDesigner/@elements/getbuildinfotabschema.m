function tabcontent=getbuildinfotabschema(this)



    ResourcePath=fullfile(fileparts(mfilename('fullpath')),'..','resources');

    if~strcmp(class(this.object),'RTW.TflCustomization')

        headfiledesc.Name=DAStudio.message('RTW:tfldesigner:ImplHeaderFileText');
        headfiledesc.Type='edit';
        headfiledesc.RowSpan=[1,1];
        headfiledesc.ColSpan=[1,3];
        headfiledesc.Tag='Tfldesigner_HeaderFile';
        headfiledesc.Source=this;
        headfiledesc.Value=fullfile(this.object.Implementation.HeaderPath,...
        this.object.Implementation.HeaderFile);


        implheadfilebutton.Name='...';
        implheadfilebutton.Type='pushbutton';
        implheadfilebutton.RowSpan=[1,1];
        implheadfilebutton.ColSpan=[4,4];
        implheadfilebutton.Tag='Tfldesigner_AddHeaderFile';
        implheadfilebutton.Enabled=true;
        implheadfilebutton.Visible=true;
        implheadfilebutton.Source=this;
        implheadfilebutton.ObjectMethod='addbuildinfofile';
        implheadfilebutton.MethodArgs={'%dialog',implheadfilebutton.Tag};
        implheadfilebutton.ArgDataTypes={'handle','string'};
        implheadfilebutton.DialogRefresh=true;
        implheadfilebutton.MaximumSize=[18,18];
        implheadfilebutton.BackgroundColor=[167,167,167];


        sourcefiledesc.Name=DAStudio.message('RTW:tfldesigner:ImplSourceFileText');
        sourcefiledesc.Type='edit';
        sourcefiledesc.RowSpan=[2,2];
        sourcefiledesc.ColSpan=[1,3];
        sourcefiledesc.Tag='Tfldesigner_SourceFile';
        sourcefiledesc.Source=this;
        sourcefiledesc.Value=fullfile(this.object.Implementation.SourcePath,...
        this.object.Implementation.SourceFile);


        implsourcefilebutton.Name='...';
        implsourcefilebutton.Type='pushbutton';
        implsourcefilebutton.RowSpan=[2,2];
        implsourcefilebutton.ColSpan=[4,4];
        implsourcefilebutton.Tag='Tfldesigner_AddSourceFile';
        implsourcefilebutton.Enabled=true;
        implsourcefilebutton.Visible=true;
        implsourcefilebutton.Source=this;
        implsourcefilebutton.ObjectMethod='addbuildinfofile';
        implsourcefilebutton.MethodArgs={'%dialog',implsourcefilebutton.Tag};
        implsourcefilebutton.ArgDataTypes={'handle','string'};
        implsourcefilebutton.DialogRefresh=true;
        implsourcefilebutton.MaximumSize=[18,18];
        implsourcefilebutton.BackgroundColor=[167,167,167];



        additionalheadfiles.Name=DAStudio.message('RTW:tfldesigner:AddHeadPathsText');
        additionalheadfiles.Type='listbox';
        additionalheadfiles.RowSpan=[3,4];
        additionalheadfiles.ColSpan=[1,3];
        additionalheadfiles.Tag='Tfldesigner_AdditionalHeadFiles';
        additionalheadfiles.ListKeyPressCallback=@removelistentry;
        additionalheadfiles.DialogRefresh=true;
        additionalheadfiles.MultiSelect=false;
        additionalheadfiles.Editable=true;
        additionalheadfiles.Entries=[this.object.AdditionalHeaderFiles;...
        this.object.AdditionalIncludePaths];

        additionalheadfilesbutton.Name='File...';
        additionalheadfilesbutton.Type='pushbutton';
        additionalheadfilesbutton.RowSpan=[3,3];
        additionalheadfilesbutton.ColSpan=[4,4];
        additionalheadfilesbutton.Tag='Tfldesigner_AddAdditionalHeadFiles';
        additionalheadfilesbutton.Enabled=true;
        additionalheadfilesbutton.Visible=true;
        additionalheadfilesbutton.Source=this;
        additionalheadfilesbutton.ObjectMethod='addbuildinfofile';
        additionalheadfilesbutton.MethodArgs={'%dialog',additionalheadfilesbutton.Tag};
        additionalheadfilesbutton.ArgDataTypes={'handle','string'};
        additionalheadfilesbutton.DialogRefresh=true;
        additionalheadfilesbutton.MaximumSize=[60,50];
        additionalheadfilesbutton.Alignment=8;

        additionalheadpathbutton.Name='Path...';
        additionalheadpathbutton.Type='pushbutton';
        additionalheadpathbutton.RowSpan=[4,4];
        additionalheadpathbutton.ColSpan=[4,4];
        additionalheadpathbutton.Tag='Tfldesigner_AddAdditionalHeadPaths';
        additionalheadpathbutton.Enabled=true;
        additionalheadpathbutton.Visible=true;
        additionalheadpathbutton.Source=this;
        additionalheadpathbutton.ObjectMethod='addbuildinfofile';
        additionalheadpathbutton.MethodArgs={'%dialog',additionalheadpathbutton.Tag};
        additionalheadpathbutton.ArgDataTypes={'handle','string'};
        additionalheadpathbutton.DialogRefresh=true;
        additionalheadpathbutton.MaximumSize=[60,50];
        additionalheadpathbutton.Alignment=2;


        removeheadpathbutton.Type='pushbutton';
        removeheadpathbutton.RowSpan=[4,4];
        removeheadpathbutton.ColSpan=[4,4];
        removeheadpathbutton.Tag='Tfldesigner_RemoveHeadPaths';
        removeheadpathbutton.Enabled=true;
        removeheadpathbutton.Visible=true;
        removeheadpathbutton.Source=this;
        removeheadpathbutton.ObjectMethod='removelistentry';
        removeheadpathbutton.MethodArgs={'%dialog',removeheadpathbutton.Tag,''};
        removeheadpathbutton.ArgDataTypes={'handle','string','string'};
        removeheadpathbutton.DialogRefresh=true;
        removeheadpathbutton.MaximumSize=[60,50];
        removeheadpathbutton.Alignment=8;
        removeheadpathbutton.FilePath=fullfile(ResourcePath,'delete.png');

        if isempty(this.object.AdditionalHeaderFiles)&&...
            isempty(this.object.AdditionalIncludePaths)
            removeheadpathbutton.Enabled=false;
        end



        additionalsourcefiles.Name=DAStudio.message('RTW:tfldesigner:AddSourceFilesText');
        additionalsourcefiles.Type='listbox';
        additionalsourcefiles.RowSpan=[5,6];
        additionalsourcefiles.ColSpan=[1,3];
        additionalsourcefiles.Tag='Tfldesigner_AdditionalSourceFiles';
        additionalsourcefiles.Source=this;
        additionalsourcefiles.ListKeyPressCallback=@removelistentry;
        additionalsourcefiles.DialogRefresh=true;
        additionalsourcefiles.MultiSelect=false;
        additionalsourcefiles.Entries=[this.object.AdditionalSourceFiles;...
        this.object.AdditionalSourcePaths];

        additionalsourcefilesbutton.Name='File...';
        additionalsourcefilesbutton.Type='pushbutton';
        additionalsourcefilesbutton.RowSpan=[5,5];
        additionalsourcefilesbutton.ColSpan=[4,4];
        additionalsourcefilesbutton.Tag='Tfldesigner_AddAdditionalSourceFiles';
        additionalsourcefilesbutton.Enabled=true;
        additionalsourcefilesbutton.Visible=true;
        additionalsourcefilesbutton.Source=this;
        additionalsourcefilesbutton.ObjectMethod='addbuildinfofile';
        additionalsourcefilesbutton.MethodArgs={'%dialog',additionalsourcefilesbutton.Tag};
        additionalsourcefilesbutton.ArgDataTypes={'handle','string'};
        additionalsourcefilesbutton.DialogRefresh=true;
        additionalsourcefilesbutton.MaximumSize=[60,50];
        additionalsourcefilesbutton.Alignment=8;

        additionalsourcepathbutton.Name='Path...';
        additionalsourcepathbutton.Type='pushbutton';
        additionalsourcepathbutton.RowSpan=[6,6];
        additionalsourcepathbutton.ColSpan=[4,4];
        additionalsourcepathbutton.Tag='Tfldesigner_AddAdditionalSourcePaths';
        additionalsourcepathbutton.Enabled=true;
        additionalsourcepathbutton.Visible=true;
        additionalsourcepathbutton.Source=this;
        additionalsourcepathbutton.ObjectMethod='addbuildinfofile';
        additionalsourcepathbutton.MethodArgs={'%dialog',additionalsourcepathbutton.Tag};
        additionalsourcepathbutton.ArgDataTypes={'handle','string'};
        additionalsourcepathbutton.DialogRefresh=true;
        additionalsourcepathbutton.MaximumSize=[60,50];
        additionalsourcepathbutton.Alignment=2;

        removesourcepathbutton.Type='pushbutton';
        removesourcepathbutton.RowSpan=[6,6];
        removesourcepathbutton.ColSpan=[4,4];
        removesourcepathbutton.Tag='Tfldesigner_RemoveSourcePaths';
        removesourcepathbutton.Enabled=true;
        removesourcepathbutton.Visible=true;
        removesourcepathbutton.Source=this;
        removesourcepathbutton.ObjectMethod='removelistentry';
        removesourcepathbutton.MethodArgs={'%dialog',removesourcepathbutton.Tag,''};
        removesourcepathbutton.ArgDataTypes={'handle','string','string'};
        removesourcepathbutton.DialogRefresh=true;
        removesourcepathbutton.MaximumSize=[60,50];
        removesourcepathbutton.Alignment=8;
        removesourcepathbutton.FilePath=fullfile(ResourcePath,'delete.png');

        if isempty(this.object.AdditionalSourceFiles)&&...
            isempty(this.object.AdditionalSourcePaths)
            removesourcepathbutton.Enabled=false;
        end


        additionallinkfiles.Name=DAStudio.message('RTW:tfldesigner:AddLinkObjFilePathText');
        additionallinkfiles.Type='listbox';
        additionallinkfiles.RowSpan=[7,8];
        additionallinkfiles.ColSpan=[1,3];
        additionallinkfiles.Tag='Tfldesigner_AdditionalLinkFiles';
        additionallinkfiles.Source=this;
        additionallinkfiles.ListKeyPressCallback=@removelistentry;
        additionallinkfiles.DialogRefresh=true;
        additionallinkfiles.MultiSelect=false;
        additionallinkfiles.Entries=[this.object.AdditionalLinkObjs;...
        this.object.AdditionalLinkObjsPaths];

        additionallinkfilesbutton.Name='File...';
        additionallinkfilesbutton.Type='pushbutton';
        additionallinkfilesbutton.RowSpan=[7,7];
        additionallinkfilesbutton.ColSpan=[4,4];
        additionallinkfilesbutton.Tag='Tfldesigner_AddAdditionalLinkFiles';
        additionallinkfilesbutton.Enabled=true;
        additionallinkfilesbutton.Visible=true;
        additionallinkfilesbutton.Source=this;
        additionallinkfilesbutton.ObjectMethod='addbuildinfofile';
        additionallinkfilesbutton.MethodArgs={'%dialog',additionallinkfilesbutton.Tag};
        additionallinkfilesbutton.ArgDataTypes={'handle','string'};
        additionallinkfilesbutton.DialogRefresh=true;
        additionallinkfilesbutton.MaximumSize=[60,50];
        additionallinkfilesbutton.Alignment=8;


        additionallinkpathbutton.Name='Path...';
        additionallinkpathbutton.Type='pushbutton';
        additionallinkpathbutton.RowSpan=[8,8];
        additionallinkpathbutton.ColSpan=[4,4];
        additionallinkpathbutton.Tag='Tfldesigner_AddAdditionalLinkPath';
        additionallinkpathbutton.Enabled=true;
        additionallinkpathbutton.Visible=true;
        additionallinkpathbutton.Source=this;
        additionallinkpathbutton.ObjectMethod='addbuildinfofile';
        additionallinkpathbutton.MethodArgs={'%dialog',additionallinkpathbutton.Tag};
        additionallinkpathbutton.ArgDataTypes={'handle','string'};
        additionallinkpathbutton.DialogRefresh=true;
        additionallinkpathbutton.MaximumSize=[60,50];
        additionallinkpathbutton.Alignment=2;

        removelinkpathbutton.Type='pushbutton';
        removelinkpathbutton.RowSpan=[8,8];
        removelinkpathbutton.ColSpan=[4,4];
        removelinkpathbutton.Tag='Tfldesigner_RemoveLinkPath';
        removelinkpathbutton.Enabled=true;
        removelinkpathbutton.Visible=true;
        removelinkpathbutton.Source=this;
        removelinkpathbutton.ObjectMethod='removelistentry';
        removelinkpathbutton.MethodArgs={'%dialog',removelinkpathbutton.Tag,''};
        removelinkpathbutton.ArgDataTypes={'handle','string','string'};
        removelinkpathbutton.DialogRefresh=true;
        removelinkpathbutton.MaximumSize=[60,50];
        removelinkpathbutton.Alignment=8;
        removelinkpathbutton.FilePath=fullfile(ResourcePath,'delete.png');

        if isempty(this.object.AdditionalLinkObjs)&&...
            isempty(this.object.AdditionalLinkObjsPaths)
            removelinkpathbutton.Enabled=false;
        end



        linkflagsLbl.Name=DAStudio.message('RTW:tfldesigner:AddLinkFlags');
        linkflagsLbl.Type='text';
        linkflagsLbl.RowSpan=[1,1];
        linkflagsLbl.ColSpan=[1,1];

        linkflags.Type='edit';
        linkflags.RowSpan=[1,1];
        linkflags.ColSpan=[2,3];
        linkflags.Tag='Tfldesigner_LinkFlags';
        linkflags.Source=this;

        linkflags.Value=createCellStr(this.object.AdditionalLinkFlags);

        compileflagsLbl.Name=DAStudio.message('RTW:tfldesigner:AddCompileFlags');
        compileflagsLbl.Type='text';
        compileflagsLbl.RowSpan=[2,2];
        compileflagsLbl.ColSpan=[1,1];

        compileflags.Type='edit';
        compileflags.RowSpan=[2,2];
        compileflags.ColSpan=[2,3];
        compileflags.Tag='Tfldesigner_CompileFlags';
        compileflags.Source=this;

        compileflags.Value=createCellStr(this.object.AdditionalCompileFlags);



        linkpanel.Type='panel';
        linkpanel.LayoutGrid=[1,3];
        linkpanel.RowSpan=[9,9];
        linkpanel.ColSpan=[1,3];
        linkpanel.RowStretch=ones(1,1);
        linkpanel.ColStretch=ones(1,3);
        linkpanel.Items={linkflagsLbl,linkflags,compileflagsLbl,compileflags};


        copydir.Name=DAStudio.message('RTW:tfldesigner:CopyToBuildDirText');
        copydir.Type='checkbox';
        copydir.RowSpan=[10,10];
        copydir.ColSpan=[1,3];
        copydir.Tag='Tfldesigner_CopyFilestoBuildDir';
        copydir.Source=this;
        copydir.Value=~isempty(this.object.GenCallback);

        contentPanel.Type='panel';
        contentPanel.LayoutGrid=[5,4];
        contentPanel.RowSpan=[1,5];
        contentPanel.ColSpan=[1,4];
        contentPanel.RowStretch=ones(1,20);
        contentPanel.ColStretch=ones(1,4);
        contentPanel.Items={headfiledesc,implheadfilebutton,...
        sourcefiledesc,implsourcefilebutton,...
        additionalheadfiles,additionalheadfilesbutton,...
        additionalheadpathbutton,removeheadpathbutton,...
        additionalsourcefiles,additionalsourcepathbutton,...
        additionalsourcefilesbutton,removesourcepathbutton,...
        additionallinkfiles,additionallinkpathbutton,...
        additionallinkfilesbutton,removelinkpathbutton,...
        linkpanel,copydir};

        keydesc=this.getDialogWidget('Tfldesigner_Key');
        if isempty(keydesc.Value)
            contentPanel.Enabled=false;
        end

        tabcontent.Type='panel';
        tabcontent.Name=DAStudio.message('RTW:tfldesigner:PropertiesText');
        tabcontent.LayoutGrid=[1,1];
        tabcontent.RowStretch=ones(1,1);
        tabcontent.ColStretch=ones(1,1);
        tabcontent.Items={contentPanel};
    end


    function str=createCellStr(cellstr)

        str='';
        for len=1:length(cellstr)
            str=[str,cellstr{len},' '];%#ok
        end
        str=strtrim(str);



