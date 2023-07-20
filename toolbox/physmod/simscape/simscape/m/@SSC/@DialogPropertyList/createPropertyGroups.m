function groups=createPropertyGroups(lst,varargin)







    ;



    properties=lst.Properties;
    items={};
    groupnames={};
    groupdesc={};
    for i=1:length(properties)
        items{end+1}=properties(i).makeWidget(varargin{:});
        groupnames{end+1}=properties(i).getGroup;
        groupdesc{end+1}=properties(i).getGroupDescription;
    end




    [uniquegroups,g,idx]=unique(groupnames);
    groups=struct('Name',{''},...
    'Items',{{}},...
    'Description','');
    groups=repmat(groups,1,length(g));
    groupidx=zeros(length(g),1);
    itemrow=zeros(length(g),1);
    groupcnt=1;




    i=0;
    while i<length(items);
        i=i+1;
        groupnum=idx(i);
        if groupidx(groupnum)==0
            groupidx(groupnum)=groupcnt;
            groups(groupnum).Name=groupnames{i};
            groups(groupnum).Description=groupdesc{i};
            groupcnt=groupcnt+1;
        end

        itemstoadd={};
        if properties(i).HasUnit
            label.Name=items{i}.Name;
            label.Type='text';
            label.ColSpan=[1,1];

            value=items{i};
            value.Name='';
            value.ColSpan=[2,2];

            i=i+1;

            if~properties(i).IsUnit
                pm_error('physmod:simscape:simscape:SSC:DialogPropertyList:createPropertyGroups:UnitExpected');
            end

            unit=items{i};
            unit.ColSpan=[3,3];

            itemstoadd={label,value,unit};
        elseif properties(i).RowWithButton

            checkbox=items{i};
            checkbox.ColSpan=[1,3];

            i=i+1;
            pushbutton=items{i};
            pushbutton.ColSpan=[3,3];

            itemstoadd={checkbox,pushbutton};
        else
            if strcmp(items{i}.Type,'checkbox')
                checkbox=items{i};
                checkbox.ColSpan=[1,3];

                itemstoadd={checkbox};
            else
                label.Name=items{i}.Name;
                label.Type='text';
                label.ColSpan=[1,1];

                value=items{i};
                value.Name='';
                value.ColSpan=[2,3];
                label.Buddy=value.Tag;

                itemstoadd={label,value};
            end
        end

        itemrow(groupnum)=itemrow(groupnum)+1;
        rowspan=[itemrow(groupnum),itemrow(groupnum)];

        for j=1:length(itemstoadd)
            itemstoadd{j}.RowSpan=rowspan;
            groups(groupnum).Items{end+1}=itemstoadd{j};
        end
    end

    groups(groupidx)=groups;



