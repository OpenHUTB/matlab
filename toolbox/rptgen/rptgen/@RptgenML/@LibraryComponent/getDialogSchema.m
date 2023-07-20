function dlgStruct=getDialogSchema(this,name)





    if~isa(this.ComponentInstance,this.ClassName)
        this.ComponentInstance=this.makeComponent(false);
    end

    if~isa(this.ComponentInstance,this.ClassName)

        wErrorText=this.dlgText(...
        sprintf(getString(message('rptgen:RptgenML_LibraryComponent:cannotLoadMsg')),...
        this.DisplayName,this.ClassName),...
        'WordWrap',1,...
        'RowSpan',[1,1],...
        'ColSpan',[2,2]);

        wErrorIcon=struct(...
        'Type','image',...
        'RowSpan',[1,1],...
        'ColSpan',[1,1],...
        'FilePath',fullfile(toolboxdir('rptgen'),'resources','warning.png'));

        wErrorPanel=this.dlgContainer({
wErrorText
wErrorIcon
        },getString(message('rptgen:RptgenML_LibraryComponent:errorLabel')),...
        'RowStretch',0,...
        'ColStretch',[0,1],...
        'LayoutGrid',[1,2]);

        dlgStruct=this.dlgMain(name,wErrorPanel);
        enableAdd=0;
    else

        dlgStruct=disableAll(this.ComponentInstance.getDialogSchema(name));
        enableAdd=1;
    end


    addIconPath=fullfile(toolboxdir('rptgen'),...
    'resources','Component_unparentable.png');

    wAddButton=struct('Type','pushbutton',...
    'Enabled',enableAdd,...
    'RowSpan',[1,1],...
    'ColSpan',[1,1],...
    'ObjectMethod','exploreAction',...
    'FilePath',addIconPath);

    wAddText=this.dlgText(getString(message('rptgen:RptgenML_LibraryComponent:addToReportMsg')),...
    'RowSpan',[1,1],...
    'ColSpan',[2,2]);

    wAddComponent=this.dlgContainer({
wAddButton
wAddText
    },getString(message('rptgen:RptgenML_LibraryComponent:addComponentMsg')),...
    'LayoutGrid',[1,2],...
    'ColStretch',[0,1]);



    try
        desc=getDescription(this.ComponentInstance);
    catch ME
        desc=sprintf(getString(message('rptgen:RptgenML_LibraryComponent:cannotGetDescMsg')),...
        this.DisplayName,this.ClassName,ME.message);
    end
    wHelpText=this.dlgText(desc,...
    'RowSpan',[1,1],...
    'ColSpan',[2,2]);

    wHelp=this.dlgContainer({
wHelpText
    },getString(message('rptgen:RptgenML_LibraryComponent:helpLabel')),...
    'LayoutGrid',[1,2],...
    'ColStretch',[0,1]);


    dlgStruct=RptgenML.dlgAddPanel(dlgStruct,wAddComponent,wHelp);


    function s=disableAll(s)

        if isstruct(s)
            if isfield(s,'Items')
                s.Items=disableAll(s.Items);
            elseif isfield(s,'Tabs')
                s.Tabs=disableAll(s.Tabs);
            elseif isfield(s,'Type')&&strcmp(s.Type,'panel')

            elseif isfield(s,'Type')&&strcmp(s.Type,'text')

            else
                s.Enabled=0;
            end
        elseif iscell(s)
            for i=1:length(s)
                s{i}=disableAll(s{i});
            end
        end
