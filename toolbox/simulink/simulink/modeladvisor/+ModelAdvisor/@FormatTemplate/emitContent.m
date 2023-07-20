function[contentOut]=emitContent(this)



    switch this.FormatType
    case 'ListTemplate'
        [contentOut]=formatTypeOne(this);
    case 'TableTemplate'
        [contentOut]=formatTypeTwo(this);
    otherwise
        contentOut='';
    end

    if~isempty(contentOut)&&~isempty(this.LocalStyles)



        temp=contentOut;
        contentOut=Advisor.Element('div');
        contentOut.addContent(this.LocalStyles);
        contentOut.addContent(temp);
    end
end

function[contentOut]=formatTypeTwo(this)

















    contentOut=ModelAdvisor.Paragraph;
    contentOut=FormatCheckText(this,contentOut);
    contentOut=FormatSubTitle(this,contentOut);
    contentOut=FormatInformation(this,contentOut);
    contentOut=FormatRef(this,contentOut);
    contentOut=FormatSubResult(this,contentOut);
    [publishTable,contentOut]=formatTable(this,contentOut);
    contentOut=FormatRecAction(this,contentOut,publishTable);
end


function[contentOut]=formatTypeOne(this)

























    contentOut=ModelAdvisor.Paragraph;
    contentOut=FormatCheckText(this,contentOut);
    contentOut=FormatSubTitle(this,contentOut);
    contentOut=FormatInformation(this,contentOut);
    contentOut=FormatRef(this,contentOut);
    contentOut=FormatSubResult(this,contentOut);
    [flagListObj,contentOut]=formatListObj(this,contentOut);
    contentOut=FormatRecAction(this,contentOut,flagListObj);
end


function contentOut=FormatCheckText(this,contentOut)
    lb=ModelAdvisor.LineBreak;
    if(~isempty(this.CheckText))
        if(~isempty(this.SubTitle))
            contentOut.addItem([this.checkText,lb,lb]);
        elseif isempty(this.Information)&&~isempty(this.RefLink)
            contentOut.addItem(this.checkText);
        else
            contentOut.addItem([this.checkText,lb]);
        end
    end
end


function contentOut=FormatSubTitle(this,contentOut)
    lb=ModelAdvisor.LineBreak;
    if(~isempty(this.SubTitle))
        if(~isempty(this.Information))
            contentOut.addItem([this.SubTitle,lb]);
        elseif isempty(this.RefLink)
            contentOut.addItem([this.SubTitle,lb,lb]);
        else
            contentOut.addItem(this.SubTitle);
        end
    end
end

function contentOut=FormatInformation(this,contentOut)
    lb=ModelAdvisor.LineBreak;
    if(~isempty(this.Information))
        contentOut.addItem(this.Information(1));
        for inx=2:length(this.Information)
            contentOut.addItem([lb,this.Information(inx)]);
        end
        if(isempty(this.RefLink))
            contentOut.addItem([lb,lb]);
        end
    else
        if(~isempty(this.CheckText)&&isempty(this.RefLink)&&~isempty(this.SubResultStatusText)&&isempty(this.SubTitle))
            contentOut.addItem(lb);
        end
    end
end

function contentOut=FormatSubResult(this,contentOut)
    lb=ModelAdvisor.LineBreak;
    if~strcmp(this.SubResultStatus,'None')
        if strcmp(this.SubResultStatus,'Pass')
            statText=ModelAdvisor.Text([DAStudio.message('Simulink:tools:PassedMsg'),' '],{'Pass','bold'});
        elseif strcmp(this.SubResultStatus,'Fail')
            statText=ModelAdvisor.Text([DAStudio.message('Simulink:tools:FailedMsg'),' '],{'Fail','bold'});
        elseif strcmp(this.SubResultStatus,'Warn')

            statText=ModelAdvisor.Text([DAStudio.message('Simulink:tools:WarningMsg'),' '],{'Warn','bold'});
        end
        contentOut.addItem(statText);
    end
    if(strcmp(this.SubResultStatus,'None'))
        if(~isempty(this.SubResultStatusText))
            contentOut.addItem(this.SubResultStatusText);
        end
    else
        if(~isempty(this.SubResultStatusText))
            contentOut.addItem([lb,this.SubResultStatusText]);
        end
    end
end



function contentOut=FormatRecAction(this,contentOut,flag)
    lb=ModelAdvisor.LineBreak;
    if(isempty(this.RecAction)==0)
        fixText=ModelAdvisor.Text(DAStudio.message('Simulink:tools:RecAction'),{'bold'});
        if flag
            contentOut.addItem(fixText);
        elseif(strcmp(this.subResultStatus,'None')&&isempty(this.subResultStatusText))
            contentOut.addItem([lb,fixText]);
        else
            contentOut.addItem([lb,lb,fixText]);
        end


        for inx=1:length(this.RecAction)
            contentOut.addItem([lb,this.RecAction(inx)]);
        end
    end
    if(this.SubBar)
        if isempty(this.RecAction)&&strcmp(this.subResultStatus,'None')&&isempty(this.subResultStatusText)&&~isempty(this.RefLink)
            brStr='';
        else
            brStr='<br />';
        end
        bar=ModelAdvisor.Text([brStr,'_________________________________________________________________________________________']);
        contentOut.addItem(bar);
    end
end

function[contentOut]=FormatRef(this,contentOut)






    if(~isempty(this.RefLink))&&(length(this.RefLink{1})>0)
        refText=ModelAdvisor.Text(DAStudio.message('Simulink:tools:SeeAlso'),{'bold'});
        objList=ModelAdvisor.List();
        objList.setType('bulleted');

        for inx=1:length(this.RefLink)
            if(~isempty(this.RefLink{inx}))
                if~iscell(this.RefLink{inx})
                    DAStudio.error('Simulink:tools:RefLinksCells');
                end
                for j=1:length(this.RefLink{inx})
                    if isa(this.RefLink{inx}{j},'ModelAdvisor.Text')
                        this.RefLink{inx}{j}=this.RefLink{inx}{j}.Content;
                    end
                end
                if(strcmpi(this.RefLink{inx}{1},'matlab'))&&length(this.RefLink{inx})==4
                    str=['<a href="matlab:helpview([docroot,'...
                    ,'''',this.RefLink{inx}{2},'''],',...
                    '''',this.RefLink{inx}{3},''')">',...
                    this.RefLink{inx}{4},'</a>'];
                elseif(strcmpi(this.RefLink{inx}{1},'guideline'))
                    str=['<a href="matlab:ModelAdvisor.Common.returnDocMap(''',...
                    this.RefLink{inx}{2},''')">',...
                    this.RefLink{inx}{3},'</a>'];
                elseif(strcmpi(this.RefLink{inx}{1},'custom'))
                    str=['<a href="matlab:helpview(''',...
                    this.RefLink{inx}{2},''')">',...
                    this.RefLink{inx}{3},'</a>'];
                elseif(length(this.RefLink{inx})>1)
                    str=['<a href= " matlab:web(''',this.RefLink{inx}{1},''')">',this.RefLink{inx}{2},'</a>'];
                else
                    str=[this.RefLink{inx}{1}];
                end
                if~isempty(str)
                    objList.addItem(ModelAdvisor.Text(str));
                end
            end
        end
        if~isempty(objList.Items)
            contentOut.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak,refText,objList]);
        else
            contentOut.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        end
    end
end


function[flagListObj,contentOut]=formatListObj(this,contentOut)

    flagListObj=~isempty(this.ListObj);
    if(flagListObj)
        objList=ModelAdvisor.List();
        objList.setType('bulleted');
        for inx=1:length(this.ListObj)
            entry=formatEntry(this,this.ListObj{inx});
            if~isempty(entry)
                objList.addItem(entry);
            end
        end
        contentOut.addItem(objList);
    end
end

function[publishTable,contentOut]=formatTable(this,contentOut)
    lb=ModelAdvisor.LineBreak;
    publishTable=~isempty(this.TableInfo);
    if publishTable
        if~(strcmp(this.subResultStatus,'None')&&isempty(this.subResultStatusText))
            contentOut.addItem([lb,lb]);
        else
            contentOut.addItem(lb);
        end
        if(~isempty(this.TableTitle))
            contentOut.addItem(this.TableTitle);
        end
        numCol=length(this.ColTitles);
        numRow=size(this.TableInfo,1);


        childTable=ModelAdvisor.Table(numRow,numCol);


        for jnx=1:numCol
            childTable.setColHeading(jnx,this.ColTitles(jnx));
            for inx=1:numRow
                entry=[];
                if iscell(this.TableInfo{inx,jnx})&&length(this.TableInfo{inx,jnx})>1
                    for idx=1:length(this.TableInfo{inx,jnx})
                        entry=[entry,formatEntry(this,this.TableInfo{inx,jnx}{idx}),ModelAdvisor.LineBreak];
                    end
                    entry=[entry,ModelAdvisor.LineBreak];
                else
                    entry=formatEntry(this,this.TableInfo{inx,jnx});
                end
                childTable.setEntry(inx,jnx,entry);
            end
        end
        if isempty(this.RecAction)
            contentOut.addItem([childTable,lb]);
        else
            contentOut.addItem([childTable,lb,lb]);
        end
    end
end


