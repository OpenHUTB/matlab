function mainPanel=getMainSchema(obj)


    modelH=obj.studio.App.blockDiagramHandle;
    [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(modelH);

    index=1;
    items={};
    if strcmp(mappingType,'AutosarTarget')
        message=DAStudio.message('RTW:autosar:uiModelTip');
    else
        message='Set default mappings';
    end
    [item1,t1,cm]=loc_createAtRow(index,'hyperlink',...
    'CodeMapping',message,'Code Mapping');
    items=[items,item1,t1,cm];
    index=index+1;

    if~strcmp(mappingType,'AutosarTarget')
        [item2,t2,md]=loc_createAtRow(index,'hyperlink',...
        'ModelData','Set individual mappings','Model Data');
        items=[items,item2,t2,md];
        index=index+1;
    end
    [item3,t3,pi]=loc_createAtRow(index,'hyperlink',...
    'PropertyInspector','Set addtional settings','Property Inspector');
    items=[items,item3,t3,pi];
    index=index+1;
    if strcmp(mappingType,'AutosarTarget')
        [item4,t4,cdui]=loc_createAtRow(index,'text',...
        'AutosarPropertiesUI',DAStudio.message('RTW:autosar:configAutosarInterface'),'Click the badge in the bottom-left corner of the canvas to launch Configure Autosar Interface UI');
        items=[items,item4,t4,cdui];
    else
        [item4,t4,cdui]=loc_createAtRow(index,'text',...
        'CoderDataUI','Code Dictionary','Click the badge in the bottom-left corner of the canvas to launch coder data UI');
        items=[items,item4,t4,cdui];
    end

    index=index+1;
    [item5,t5,ssa]=loc_createAtRow(index,'text',...
    'SingleSelectAction','See generated code','Select an element in canvas and the "Trace to Code" action');
    items=[items,item5,t5,ssa];
    mainPanel.Type='group';
    mainPanel.Name='Instructions';
    mainPanel.Items=items;

    mainPanel.LayoutGrid=[10,5];
    mainPanel.ColStretch=[0,1,1,1,1];

    function[item,t,w]=loc_createAtRow(rowNum,type,tag,title,name)

        r=rowNum*2;

        item.Type='text';
        item.Name=[num2str(rowNum),'.'];
        item.RowSpan=[r,r];
        item.ColSpan=[1,1];
        item.WordWrap=true;

        t.Type='text';
        t.Name=title;
        t.RowSpan=[r,r];
        t.ColSpan=[2,5];
        t.WordWrap=true;

        w.Type=type;
        w.Name=name;
        w.Tag=tag;
        w.RowSpan=[r+1,r+1];
        w.ColSpan=[2,5];
        w.FontPointSize=8;

        if strcmp(type,'hyperlink')
            w.ObjectMethod='dialogCallback';
            w.MethodArgs={'%tag','%value'};
            w.ArgDataTypes={'string','mxArray'};
        elseif strcmp(type,'text')
            w.WordWrap=true;
        end
