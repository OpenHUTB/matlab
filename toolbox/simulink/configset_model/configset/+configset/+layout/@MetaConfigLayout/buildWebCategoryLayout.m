function buildWebCategoryLayout(layout,mcc,dirName)





    disp(['  building ',mcc.Name,' web layout']);

    document=matlab.io.xml.dom.Document('component');
    root=document.getDocumentElement;
    root.setAttribute('id',mcc.Class);

    advGroup=containers.Map;


    nodes=layout.TopLevelPanes;
    n=length(nodes);
    for i=1:n
        node=nodes{i};
        loc_emitXmlElement(mcc,node,document,root,layout,false,advGroup,[]);
    end


    loc_specialCases(mcc,document,root)


    fileName=[mcc.Class,'.xml'];
    file=fullfile(dirName,fileName);
    writer=matlab.io.xml.dom.DOMWriter;
    writer.Configuration.FormatPrettyPrint=true;
    writeToURI(writer,document,file);

end


function param=loc_emitXmlElement(mcc,node,document,refNode,layout,adv,advGroup,groupColumnInfo)



    if ismember(mcc.Name,node.Components)

        name=node.Name;
        group=document.createElement(node.Type);

        group.setAttribute('id',name);
        group.setAttribute('key',node.Key);
        if node.Advanced
            adv=true;
            group.setAttribute('class','adv');
            if isempty(advGroup)
                advGroup(mcc.Name)=group;
            end
        end
        if strcmp(node.Type,'tree')
            tag=node.EnableTriggerType;
        else
            tag=node.Tag;
        end

        if~isempty(node.Feature)
            group.setAttribute('feature',[node.Feature.Name,':',num2str(node.Feature.Value)]);
        end
        if~isempty(tag)
            group.setAttribute('tag',tag);
        end
        if~isempty(node.DialogSchemaFunction)
            group.setAttribute('function',node.DialogSchemaFunction);
        end
        cshpath=node.CSHPath;
        if~isempty(cshpath)
            group.setAttribute('cshpath',strjoin(cshpath,'/'));
        end

        eng=node.NameEnglish;
        if~isempty(eng)
            group.setAttribute('eng',eng);
        end

        group.setAttribute('border',num2str(node.ShowBorder));
        if strncmp(node.EnableTriggerType,'toggle',6)
            group.setAttribute('toggle',node.EnableTriggerType(8:end));
        end

        if sum(node.ColumnWidth)>0
            group.setAttribute('columnwidths',jsonencode(num2cell(node.ColumnWidth)));
        end

        refNode.appendChild(group);


        rowSizes=node.RowSizes;
        currentRow=1;
        objectsInRow=0;
        insertBlankAtEnd=zeros(1,length(rowSizes));

        for i=1:length(node.Children)
            includeWidget=true;
            subNode=node.Children{i};
            label=node.ChildNeedsLabel(i);
            cshp=node.ChildHasCustomCSHPath{i};
            csht=node.ChildHasCustomCSHTag{i};
            objectsInRow=objectsInRow+1;

            if isa(subNode,'configset.layout.CategoryUIGroup')
                loc_emitXmlElement(mcc,subNode,document,group,layout,...
                adv,advGroup,node.ActualColumnInfo{i});
            else
                if isa(subNode,'configset.internal.data.ParamStaticData')
                    name=subNode.Name;
                    fullName=subNode.FullName;
                    if isa(subNode,'configset.internal.data.WidgetStaticData')
                        paramName=subNode.Parameter.Name;
                    else
                        paramName=subNode.Name;
                    end
                elseif ischar(subNode)
                    if strcmp(subNode,'*SPACE*')
                        objectsInRow=objectsInRow-1;
                        rowSizes(currentRow)=rowSizes(currentRow)-1;
                        includeWidget=false;
                        if objectsInRow==rowSizes(currentRow)
                            insertBlankAtEnd(currentRow)=1;
                        end
                    else
                        name=subNode;
                        fullName=name;
                        mcs=layout.MetaCS;
                        mcs.addComponent(mcc);
                        paramName=mcs.WidgetNameMap(name);
                    end
                end




                if includeWidget&&strcmp(mcc.Type,'Target')
                    includeWidget=false;
                    widgets=layout.MetaCS.findWidget(fullName);
                    allWidgets=layout.MetaCS.findWidget(name);


                    if~iscell(allWidgets)||...
                        (~iscell(widgets)&&strcmp(widgets.Component,mcc.Name))
                        includeWidget=true;
                    else


                        if~iscell(widgets)
                            widgets={widgets};
                        end
                        for x=1:length(widgets)
                            w=widgets{x};
                            if strcmp(w.Component,'Target')||strcmp(w.Component,mcc.Name)
                                g=layout.getWidgetGroup(w.FullName,true,false);
                                if~isempty(g)&&strcmp(g(1).Name,node.Name)
                                    includeWidget=true;
                                    break;
                                end
                            end
                        end
                    end
                end

                if objectsInRow==rowSizes(currentRow)
                    currentRow=currentRow+1;
                    objectsInRow=0;
                end

                if~includeWidget
                    continue;
                end

                param=document.createElement('widget');
                param.setAttribute('param',paramName);
                if label
                    param.setAttribute('label','1');
                end
                if~isempty(cshp)
                    param.setAttribute('cshpath',cshp);
                end
                if~isempty(csht)
                    param.setAttribute('cshtag',csht);
                end
                param.setAttribute('id',name);

                if adv
                    param.setAttribute('adv','1');
                end

                columnInfo=loc_convertColumn(node.ActualColumnInfo{i});
                param.setAttribute('columnpos',columnInfo);

                group.appendChild(param);
            end

        end

        rowSizes=jsonencode(num2cell(rowSizes));
        group.setAttribute('rows',rowSizes);
        if~isempty(find(insertBlankAtEnd,1))
            group.setAttribute('blankatend',jsonencode(num2cell(insertBlankAtEnd)));
        end
        if~isempty(groupColumnInfo)
            columnInfo=loc_convertColumn(groupColumnInfo);
            group.setAttribute('columnpos',columnInfo);
        end

    else
        for i=1:length(node.Children)
            subNode=node.Children{i};

            if isa(subNode,'configset.layout.CategoryUIGroup')
                loc_emitXmlElement(mcc,subNode,document,refNode,layout,adv,advGroup,node.ActualColumnInfo{i});
            end
        end
    end
end


function columnInfo=loc_convertColumn(cols)
    columnInfo=[cols(1),cols(2)-cols(1)+1];
    if length(cols)==4

        columnInfo(3:4)=[cols(3),cols(4)-cols(3)+1];
    end
    columnInfo=jsonencode(num2cell(columnInfo));
end

function loc_specialCases(mcc,document,root)



    if strcmp(mcc.Class,'simmechanics.DiagnosticsConfigSet')||...
        strcmp(mcc.Class,'simmechanics.ExplorerConfigSet')||...
        strcmp(mcc.Class,'CCSTargetConfig.RtdxConfig')

        remove=root.item(0);
        keep=remove.item(0);
        root.removeChild(remove);
        root.appendChild(keep);
    end


    if strcmp(mcc.Class,'Simulink.ConfigSet')
        pane=document.createElement('pane');
        pane.setAttribute('id',mcc.Class);
        pane.setAttribute('key',mcc.NameKey);
        root.appendChild(pane);
    end
end
