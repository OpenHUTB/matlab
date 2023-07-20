function createFromXml(obj,layout,groupNode,tagPrefix,tabGroupTag)




    tagTypes={'widget','lwidget','pane','group','tree','tab','tab_group','space'};

    node=groupNode;
    nodeType=node.getNodeName;
    obj.Type=nodeType;
    obj.RowSizes=[];
    obj.ColumnWidth=[];


    nameNode=configset.internal.helper.getChildNodeByTagName(node,'name');
    name_en='';
    if~isempty(nameNode)
        name=configset.internal.helper.getSingleNodeValue(node,'name');
        nameNode=configset.internal.helper.getChildNodeByTagName(node,'name_en');
        if~isempty(nameNode)
            name_en=configset.internal.helper.getSingleNodeValue(node,'name_en');
        end
    else
        name='';
    end
    obj.Name=name;
    obj.NameEnglish=name_en;

    if strcmp(nodeType,'pane')&&isempty(name_en)
        error('CategoryUIGroup:Noname_en',['No name_en tag for pane ',name]);
    end



    if node.hasAttribute('components')
        component_list=strtrim(node.getAttribute('components'));
        obj.Components=strsplit(component_list,'\s*,\s*','DelimiterType','RegularExpression');
        for i=1:length(obj.Components)
            if isempty(layout.MetaCS.getComponent(obj.Components{i}))
                error('CategoryUIGroup:InvalidComponentName',['No such component: ',obj.Components{i}]);
            end
        end
    end


    f=configset.internal.util.parseFeatureString(node.getAttribute('feature'));
    if~isempty(f)
        obj.Feature=f;
        layout.FeatureSet{end+1}=f.Name;
    end


    keyNode=configset.internal.helper.getChildNodeByTagName(node,'key');
    if isempty(keyNode)
        obj.Key='';
    else
        obj.Key=configset.internal.helper.getSingleNodeValue(node,'key');
        str=keyNode{1}.getAttribute('function');
        obj.KeyFunction=configset.internal.util.createCustomFunction(class(obj),str);
    end

    if isempty(name)&&isempty(keyNode)
        error('CategoryUIGroup:NoKeyOrNameForGroup','No key or name for group');
    end
    if isempty(name)
        obj.Name=obj.Key;
    end


    if layout.GroupObjectMap.isKey(obj.Name)
        if isempty(obj.Feature)
            error('CategoryUIGroup:DuplicateGroupName',['Duplicate group name ''',obj.Name,''' not allowed.']);
        else


            layout.GroupObjectMap(obj.Name)=[obj,layout.GroupObjectMap(obj.Name)];
        end
    else
        layout.GroupObjectMap(obj.Name)=obj;
    end


    if node.hasAttribute('show')
        trigger=strtrim(node.getAttribute('show'));
        switch nodeType
        case 'tab'
            if isnan(str2double(trigger))
                error('CategoryUIGroup:InvalidTab',['Show value for tab ',obj.Name,' must be a number']);
            end
            obj.EnableTriggerType=[tabGroupTag,':',trigger];
        case 'group'
            if strcmp(trigger,'toggle')
                obj.EnableTriggerType=trigger;

                if node.hasAttribute('show_function')
                    trigger_function=strtrim(node.getAttribute('show_function'));
                    obj.EnableTriggerType=[trigger,':',trigger_function];
                end
            else
                error('CategoryUIGroup:InvalidShow',['Show type for group ',obj.Name,' can only be ''toggle''']);
            end
        case 'tree'
            obj.EnableTriggerType=trigger;
        otherwise
            error('CategoryUIGroup:InvalidShow','Show attribute is only valid for tab, group, or tree tags');
        end
    else
        obj.EnableTriggerType='';
    end

    obj.ShowBorder=true;
    if node.hasAttribute('border')
        border=strtrim(node.getAttribute('border'));
        if strcmp(border,'0')
            obj.ShowBorder=false;
        end
    end


    if node.hasAttribute('function')
        obj.DialogSchemaFunction=strtrim(node.getAttribute('function'));
    else
        obj.DialogSchemaFunction='';
    end


    tagNode=configset.internal.helper.getChildNodeByTagName(node,'tag');
    if~isempty(tagNode)
        if tagNode{1}.hasAttribute('prefix')
            prefix=strtrim(tagNode{1}.getAttribute('prefix'));
        else
            prefix=tagPrefix;
        end
        tag=configset.internal.helper.getSingleNodeValue(node,'tag');
        obj.Tag=[prefix,tag];



    end



    tagNode=configset.internal.helper.getChildNodeByTagName(node,'tabTag');
    if~isempty(tagNode)
        if tagNode{1}.hasAttribute('prefix')
            prefix=strtrim(tagNode{1}.getAttribute('prefix'));
        else
            prefix=tagPrefix;
        end
        obj.TabTag=[prefix,configset.internal.helper.getSingleNodeValue(node,'tabTag')];
    end

    if strcmp(nodeType,'tab_group')
        tabGroupTag=obj.Tag;
    end


    obj.CSHPath='';
    pathNode=configset.internal.helper.getChildNodeByTagName(node,'cshpath');
    if~isempty(pathNode)
        path=configset.internal.helper.getSingleNodeValue(node,'cshpath');
        obj.CSHPath=strsplit(path,'/');
    end


    adv=node.getAttribute('advanced');
    if strcmp(adv,'1')
        obj.Advanced=true;
    end


    cNodes=groupNode.getChildNodes();
    nodes={};
    childCount=0;


    for i=1:cNodes.getLength
        node=cNodes.item(i-1);
        nodeName=node.getNodeName;
        if strcmp(nodeName,'row')
            rowNodes=node.getChildNodes();
            rowCount=0;
            for r=1:rowNodes.getLength
                rowNode=rowNodes.item(r-1);
                rowNodeName=rowNode.getNodeName;
                if strcmp(rowNodeName,'row')
                    error('CategoryUIGroup:NestedRows','Rows cannot contain other rows.  Make a separate group.');
                elseif ismember(rowNodeName,tagTypes)
                    nodes{end+1}=rowNode;%#ok<AGROW>
                    rowCount=rowCount+1;
                end
            end
            obj.RowSizes(end+1)=rowCount;
        elseif ismember(nodeName,tagTypes)
            nodes{end+1}=node;%#ok<AGROW>
            obj.RowSizes(end+1)=1;
        end
    end



    columns=max(obj.RowSizes);
    obj.ColumnHasLabel=zeros(1,columns);
    columnWidth=zeros(1,columns);
    widgetWidth=zeros(1,length(nodes));
    columnPos=zeros(1,length(nodes));
    columnLabelSpan=zeros(1,length(nodes));
    columnSpan=zeros(1,length(nodes));
    widgetsInRow=1;
    currentColumn=1;
    currentRow=1;
    for i=1:length(nodes)
        node=nodes{i};
        nodeName=node.getNodeName;
        columnPlacement=strtrim(node.getAttribute('column'));
        if~isempty(columnPlacement)
            c=strsplit(columnPlacement,':');
            if length(c)==3
                colStart=str2double(c{1});
                colWidget=str2double(c{2});
                colEnd=str2double(c{3});
            else
                colStart=str2double(c{1});
                colWidget=0;
                colEnd=str2double(c{2});
            end
        else
            colStart=currentColumn;
            colWidget=0;
            colEnd=currentColumn;
        end

        w=strtrim(node.getAttribute('width'));
        if~isempty(w)
            if strcmp(w(end),'%')
                w=w(1:end-1);
            else
                error('CategoryUIGroup:ColumnWidth','Column widths should be expressed as percentages');
            end
            w=str2double(w);
            if w<0||w>100
                error('CategoryUIGroup:ColumnWidth','Column widths should be between 0%% and 100%%');
            end
            if currentColumn>columns||columnWidth(currentColumn)==0||w<columnWidth(currentColumn)
                columnWidth(currentColumn)=w;
            end
            widgetWidth(i)=columnWidth(currentColumn);
        end

        switch nodeName
        case{'widget','lwidget'}
            childCount=childCount+1;
            wName=strtrim(node.getFirstChild.getNodeValue);
            child=layout.MetaCS.findWidget(wName);
            if isempty(child)
                error(['No widget found with name ',wName]);
            end

            groupStruct.Feature=~isempty(obj.Feature);
            groupStruct.Group=obj;
            groupStruct.Index=childCount;



            if iscell(child)
                childList=child;
                child=wName;
            else
                if layout.WidgetGroupMap.isKey(wName)&&layout.WidgetGroupMap.isKey(child.Name)




                    if~strcmp(wName,child.FullName)&&isempty(obj.Feature)
                        error('CategoryUIGroup:DuplicateWidgetName',...
                        ['Parameter ',wName,' found in multiple places in Layout Model.  Use full name.']);
                    end
                end
                childList={child};
            end

            for c=1:length(childList)
                if layout.WidgetGroupMap.isKey(wName)&&layout.WidgetGroupMap.isKey(childList{c}.Name)




                    existing=layout.WidgetGroupMap(childList{c}.Name);
                    if~isempty(obj.Feature)
                        newStruct.Feature=true;
                    else
                        newStruct.Feature=existing.Feature;
                    end
                    if~ismember(groupStruct.Group,existing.Group)
                        newStruct.Group=[groupStruct.Group,existing.Group];
                        newStruct.Index=[groupStruct.Index,existing.Index];
                    else
                        newStruct=existing;
                    end

                    layout.WidgetGroupMap(childList{c}.Name)=newStruct;
                    if strcmp(wName,childList{c}.FullName)



                        layout.WidgetGroupMap(wName)=groupStruct;
                    else
                        layout.WidgetGroupMap(childList{c}.FullName)=newStruct;
                    end
                else
                    layout.WidgetGroupMap(childList{c}.Name)=groupStruct;






                    layout.WidgetGroupMap(wName)=groupStruct;
                    if~contains(wName,':')

                        layout.WidgetGroupMap(childList{c}.FullName)=groupStruct;
                    end
                end
                if~isempty(childList{c}.Feature)
                    child=wName;
                end
            end

        case 'space'
            childCount=childCount+1;
            child='*SPACE*';

        case{'pane','group','tab','tab_group','tree'}
            childCount=childCount+1;
            child=configset.layout.CategoryUIGroup(layout,node,tagPrefix,tabGroupTag,obj.Feature);
            child.IndexInParentGroup=childCount;
            if layout.ParentGroupMap.isKey(child.Name)
                existingParents=layout.ParentGroupMap(child.Name);
                if~iscell(existingParents)
                    existingParents={existingParents};
                end
                if~ismember(obj.Name,existingParents)

                    layout.ParentGroupMap(child.Name)=[obj.Name,existingParents];
                end
            else
                layout.ParentGroupMap(child.Name)=obj.Name;
            end

        otherwise
            child=[];
        end


        if~isempty(child)
            obj.Children{childCount}=child;
            columnPos(childCount)=colStart;
            if colWidget==0
                columnLabelSpan(childCount)=-1;
            else
                columnLabelSpan(childCount)=colWidget-colStart;
            end
            columnSpan(childCount)=colEnd-colStart+1;

            if strcmp(nodeName,'lwidget')
                if colEnd==colStart
                    obj.ColumnHasLabel(colStart)=true;
                end
                obj.ChildNeedsLabel(childCount)=true;
            else
                if strcmp(nodeName,'tree')
                    obj.ColumnHasLabel(colStart)=true;
                end
                obj.ChildNeedsLabel(childCount)=false;
            end

            if node.hasAttribute('cshpath')
                cshp=node.getAttribute('cshpath');
                obj.ChildHasCustomCSHPath{childCount}=cshp;
            else
                obj.ChildHasCustomCSHPath{childCount}='';
            end
            if node.hasAttribute('cshtag')
                csht=node.getAttribute('cshtag');
                obj.ChildHasCustomCSHTag{childCount}=csht;
            else
                obj.ChildHasCustomCSHTag{childCount}='';
            end

            obj.ShowNames(childCount)=true;
            if node.hasAttribute('name')
                showName=strtrim(node.getAttribute('name'));
                if strcmp(showName,'empty')
                    obj.ShowNames(childCount)=false;
                end
            end
        end

        if~ismember(nodeName,{'pane','tab'})
            if widgetsInRow==obj.RowSizes(currentRow)
                if colEnd>columns
                    columns=colEnd;
                    if length(obj.ColumnHasLabel)<columns
                        obj.ColumnHasLabel(columns)=false;
                    end
                end
                currentColumn=1;
                widgetsInRow=1;
                currentRow=currentRow+1;
            else
                currentColumn=colEnd+1;
                widgetsInRow=widgetsInRow+1;
            end
        end

    end



    allocatedWidths=sum(columnWidth);
    if allocatedWidths>0
        numAllocatedWidths=sum(arrayfun(@(x)x>0,columnWidth));
        hasColumnWidths=true;
        obj.ColumnWidth=zeros(1,columns+sum(obj.ColumnHasLabel));




        remainingWidth=(100-allocatedWidths)/(columns-numAllocatedWidths);
        obj.ColumnWidth=arrayfun(@(x)remainingWidth,obj.ColumnWidth);
    else
        hasColumnWidths=false;
        obj.ColumnWidth=zeros(1,columns+sum(obj.ColumnHasLabel));
    end


    currentRow=1;
    currentColumn=1;
    widgetsInRow=1;
    actualColumn=1;

    for i=1:length(obj.Children)
        startColumn=columnPos(i);
        labelColumn=startColumn+columnLabelSpan(i)-1;
        endColumn=startColumn+columnSpan(i)-1;

        if currentColumn>startColumn


            for c=startColumn:currentColumn-1
                if obj.ColumnHasLabel(c)
                    actualColumn=actualColumn-2;
                else
                    actualColumn=actualColumn-1;
                end
            end
        else


            for c=currentColumn:startColumn-1
                if obj.ColumnHasLabel(c)
                    actualColumn=actualColumn+2;
                else
                    actualColumn=actualColumn+1;
                end
            end
        end
        span=0;
        for c=startColumn:endColumn
            if obj.ColumnHasLabel(c)
                span=span+2;
            else
                span=span+1;
            end
        end


        if obj.ChildNeedsLabel(i)
            if columnLabelSpan(i)==-1
                labelSpan=floor(span/2);
            elseif columnLabelSpan(i)==0
                labelSpan=1;
            else
                labelSpan=0;
                for c=startColumn:labelColumn
                    if obj.ColumnHasLabel(c)
                        labelSpan=labelSpan+2;
                    else
                        labelSpan=labelSpan+1;
                    end
                end
            end

            obj.ActualColumnInfo{i}=[actualColumn,actualColumn+labelSpan-1...
            ,actualColumn+labelSpan,actualColumn+span-1];

            actualColumn=actualColumn+span;
        else
            obj.ActualColumnInfo{i}=[actualColumn,actualColumn+span-1];
            actualColumn=actualColumn+span;
        end
        currentColumn=endColumn;

        if hasColumnWidths
            if widgetWidth(i)~=0
                obj.ColumnWidth(actualColumn-1)=widgetWidth(i);
            end
        end
        if widgetsInRow==obj.RowSizes(currentRow)
            currentColumn=1;
            widgetsInRow=1;
            actualColumn=1;
            currentRow=currentRow+1;
        else
            currentColumn=currentColumn+1;
            widgetsInRow=widgetsInRow+1;
        end
    end

    if hasColumnWidths

        c=1;
        for i=1:length(obj.ColumnHasLabel)
            if obj.ColumnHasLabel(i)
                obj.ColumnWidth(c)=0;
                c=c+2;
            else
                c=c+1;
            end
        end
    end


    if strcmp(obj.EnableTriggerType,'tree')
        obj.EnableTriggerType=strjoin(cellfun(@(c)c.Name,obj.Children,'UniformOutput',false),':');
    end
end








