function dlgStruct=getDialogSchema(thisComp,name)


















    wSource_files__auto_generated=thisComp.dlgWidget('Source_files__auto_generated',...
    'RowSpan',[1,1],'ColSpan',[1,2]);

    wHeader_files__auto_generated=thisComp.dlgWidget('Header_files__auto_generated',...
    'RowSpan',[2,2],'ColSpan',[1,2]);

    wCustom_files=thisComp.dlgWidget('Custom_files',...
    'RowSpan',[3,3],'ColSpan',[1,2]);

    cMain=thisComp.dlgContainer({
wSource_files__auto_generated
wHeader_files__auto_generated
wCustom_files
    },DAStudio.message('RTW:report:filesToInclude'),...
    'LayoutGrid',[3,2],...
    'ColStretch',[0,1],...
    'RowStretch',[0,0,0],...
    'ColSpan',[1,1],...
    'RowSpan',[1,1]);














    dlgStruct=thisComp.dlgMain(name,{
cMain
    },'LayoutGrid',[2,1],...
    'RowStretch',[0,1],...
    'ColStretch',[1]);


