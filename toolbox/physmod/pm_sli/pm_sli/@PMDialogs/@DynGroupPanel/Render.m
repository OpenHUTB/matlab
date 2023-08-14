function[retVal,schema]=Render(hThis,schema)












    retVal=true;

    childItems={};
    [retVal,childItems]=renderChildren(hThis,childItems);



    nPanels=numel(childItems);

    if(~strcmp(hThis.Style,'TabContainer'))
        for(idx=1:nPanels)
            childItems{idx}.RowSpan=[idx,idx];
        end
    end

    if(nPanels==0)
        nPanels=1;
    end

    RowStretchVect=zeros(1,nPanels);

    renderedName=pm.sli.internal.resolveMessageString(hThis.Label);
    grpPanel.Name=renderedName;
    grpPanel.Tag=hThis.ObjId;

    switch(hThis.Style)
    case 'HorzLine'
        grpPanel.Type='group';
        grpPanel.Flat=true;
        grpPanel.RowSpan=[1,1];
        grpPanel.ColSpan=[1,1];
        grpPanel.LayoutGrid=[1,1];
        grpPanel.RowStretch=[0];

    case{'Box','Flat'}
        grpPanel.Type='group';
        grpPanel.RowSpan=[1,1];
        grpPanel.ColSpan=[1,1];
        grpPanel.Flat=strcmpi(hThis.Style,'Flat');
        grpPanel.LayoutGrid=[(nPanels+1),1];
        grpPanel.Items=childItems;
        grpPanel.RowStretch=zeros(1,nPanels);
        grpPanel.RowStretch(end+1)=1;
    case 'NoBoxWithTitle'
        grpPanel.Type='panel';

        labelTxt.Name=renderedName;
        labelTxt.Type='text';
        labelTxt.RowSpan=[2,2];
        labelTxt.ColSpan=[1,1];

        newKidList{1}=labelTxt;

        spacer.Type='panel';
        spacer.RowSpan=[1,1];
        spacer.ColSpan=[1,1];
        spacer.LayoutGrid=[1,1];

        newKidList{2}=spacer;
        newKidList{3}=spacer;
        newKidList{3}.RowSpan=[3,3];


        for(idx=4:(nPanels+3))
            newKidList{idx}=childItems{(idx-3)};
            newKidList{idx}.RowSpan=[idx,idx];
            newKidList{idx}.ColSpan=[1,1];
        end

        grpPanel.RowSpan=[1,1];
        grpPanel.ColSpan=[1,1];
        grpPanel.LayoutGrid=[nPanels+3,1];
        grpPanel.Items=newKidList;
        grpPanel.RowStretch=zeros(nPanels+3);

    case 'NoBoxWithTitleAndLine'
    case 'NoBoxWithTitleAndSpace'
    case{'NoBoxNoTitle','Spacer'}
        grpPanel.Type='panel';
        grpPanel.RowSpan=[1,1];
        grpPanel.ColSpan=[1,1];
        grpPanel.LayoutGrid=[(nPanels+1),1];
        grpPanel.Items=childItems;
        grpPanel.RowStretch=zeros(1,nPanels);
        grpPanel.RowStretch(end+1)=1;
    case 'TabPage'
        grpPanel.Name=renderedName;
        grpPanel.Items=childItems;
    case 'TabContainer'
        grpPanel.Type='tab';
        grpPanel.RowSpan=[1,1];
        grpPanel.ColSpan=[1,1];
        grpPanel.LayoutGrid=[nPanels,1];
        grpPanel.Tabs=childItems;
    case 'VerticalAlignment'
        [layoutGrid,rowStretch,colStretch,children]=l_explodeChildren(childItems);
        grpPanel.Type='group';
        grpPanel.RowSpan=[1,1];
        grpPanel.ColSpan=[1,1];
        grpPanel.Flat=strcmpi(hThis.Style,'Flat');
        grpPanel.LayoutGrid=layoutGrid;
        grpPanel.Items=children;
        grpPanel.RowStretch=rowStretch;
        grpPanel.ColStretch=colStretch;
    otherwise
        grpPanel.Type='group';
        grpPanel.RowSpan=[1,1];
        grpPanel.ColSpan=[1,1];
        grpPanel.LayoutGrid=[nPanels,1];
        grpPanel.Items=childItems;
        grpPanel.RowStretch=zeros(1,nPanels);
    end



    if hThis.BoxStretch
        grpPanel.RowStretch=zeros(1,grpPanel.LayoutGrid(1));
        grpPanel.RowStretch(1)=1;
    end


    if~strcmpi(hThis.StdLayoutCfg,'Unset')
        grpPanel=hThis.CleanAndLayoutDDGSchema(grpPanel,hThis.StdLayoutCfg);
    end

    schema=grpPanel;

end

function[layoutGrid,rowstretch,colstretch,grandchildren]=l_explodeChildren(childItems)





    nPanels=numel(childItems);
    firstChild=childItems{1};
    panelLayoutGrid=firstChild.LayoutGrid;
    panelColStretch=firstChild.ColStretch;

    grandchildren={};
    for i=1:nPanels
        for j=1:length(childItems{i}.Items)
            grandChild=childItems{i}.Items{j};
            grandChild.RowSpan=[i,i];
            grandchildren=[grandchildren,grandChild];
        end
    end
    rowstretch=zeros(1,nPanels);
    colstretch=panelColStretch;
    layoutGrid=[nPanels,panelLayoutGrid(2)];

end
