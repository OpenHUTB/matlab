function dlgStruct=dlgChildContainer(this,dlgName,varargin)









    enableIdx=find(strcmp(varargin,'Enabled'));
    if isempty(enableIdx)
        linkEnable=true;
    else
        linkEnable=varargin{enableIdx(1)+1};
        varargin=[varargin(1:enableIdx(1)-1),varargin(enableIdx(1)+2:end)];
    end

    r=RptgenML.Root;
    thisChild=this.down;
    i=0;
    childItems={};
    rowStretch=[];

    if isa(this,'RptgenML.LibraryCategory')


        viewMethod='dlgViewChild';
        viewArg1=this;
    else
        viewMethod='viewChild';
        viewArg1=r;
    end



    while~isempty(thisChild)

        if isa(thisChild,'RptgenML.LibraryComponent')
            nStr=thisChild.DisplayName;
            if~isempty(thisChild.ComponentInstance)
                try
                    nStr=getName(thisChild.ComponentInstance);
                end
            end
            dStr=thisChild.getDescription('-deferred');
        elseif isa(thisChild,'RptgenML.ComponentMakerData')
            nStr=thisChild.PropertyName;
            dStr=thisChild.Description;
        elseif isa(thisChild,'RptgenML.StylesheetEditor')
            nStr=thisChild.DisplayName;
            dStr=thisChild.Description;
        elseif isa(thisChild,'rptgen.rptcomponent')
            nStr=thisChild.getName;
            dStr=thisChild.getDescription;
        elseif isa(thisChild,'RptgenML.LibraryRpt')
            nStr=thisChild.FileName;
            dStr=rptgen.truncateString(thisChild.getDescription('-deferred'),'',128);
        elseif isa(thisChild,'RptgenML.StylesheetAttribute')
            if rptgen.use_java
                nStr=char(com.mathworks.toolbox.rptgen.xml.StylesheetEditor.formatParameterDisplayID(thisChild.JavaHandle));
            else
                nStr=mlreportgen.re.internal.ui.StylesheetEditor.formatParameterDisplayID(thisChild.JavaHandle);
            end
            dStr=rptgen.truncateString(thisChild.Value,'',128);
        elseif isa(thisChild,'RptgenML.StylesheetHeaderCell')
            nStr=thisChild.getDisplayLabel;
            dStr=rptgen.truncateString(thisChild.Value,'',128);
        elseif isa(thisChild,'RptgenML.StylesheetElement')
            nStr=thisChild.getDisplayLabel;
            dStr=char(thisChild.DescriptionShort);
        else
            nStr=thisChild.getDisplayLabel;
            dStr='';
        end

        i=i+1;
        childItems=[childItems,...
        {struct('Type','hyperlink',...
        'Name',nStr,...
        'Alignment',1,...
        'ToolTip',getString(message('rptgen:RptgenML:viewLabel')),...
        'Enabled',linkEnable,...
        'MatlabMethod',viewMethod,...
        'MatlabArgs',{{viewArg1,thisChild}},...
        'ColSpan',[1,1],...
        'RowSpan',[i,i]),...
        this.dlgText(dStr,...
        'WordWrap',1,...
        'ColSpan',[2,2],...
        'RowSpan',[i,i])}];
        rowStretch(i)=0;












        thisChild=thisChild.right;
    end

    i=i+1;
    childItems{end+1}=this.dlgText('',...
    'ColSpan',[1,2],...
    'RowSpan',[i,i]);
    rowStretch(i)=1;

    dlgStruct=this.dlgContainer(childItems,...
    dlgName,...
    'LayoutGrid',[i,2],...
    'ColStretch',[0,1],...
    'RowStretch',rowStretch,...
    varargin{:});



