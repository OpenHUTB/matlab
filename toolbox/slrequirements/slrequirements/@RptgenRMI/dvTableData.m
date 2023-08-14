function result=dvTableData(option)

    persistent dvItems current

    if nargin<1
        option=gcs;
    elseif isa(option,'double')
        current=option;
        validateIndex(dvItems{1},current);
        option='getAt';
    end

    if any(strcmp(option,{'description','label','link','plabel','type','value'}))
        validateIndex(dvItems{1},current);
    end

    switch option
    case 'clear'
        result=~isempty(dvItems);
        dvItems=cell(0,3);
        current=-1;
    case 'count'
        if isempty(dvItems)
            result=0;
        else
            result=size(dvItems{1},1);
        end
    case 'description'
        result=get_param(dvItems{1}(current),'Description');
    case 'getAt'
        result=packOne(dvItems{1}(current),dvItems{2}{current},dvItems{3}(current));
    case 'getNext'
        current=current+1;
        validateIndex(dvItems{1},current);
        result=packOne(dvItems{1}(current),dvItems{2}{current},dvItems{3}(current));
    case 'hasData'
        result=~isempty(dvItems);
    case 'hasNext'
        result=~isempty(dvItems)&&current<=size(dvItems{1},1);
    case 'info'
        result=getString(message('Slvnv:RptgenRMI:getType:DvItemInfoValue',...
        dvItems{2}{current},RptgenRMI.dvTableData('plabel')));
    case 'label'
        result=get_param(dvItems{1}(current),'Name');
    case 'link'
        objH=dvItems{1}(current);
        objSid=Simulink.ID.getSID(objH);
        [sidMdl,sidNum]=strtok(objSid,':');
        objNavCmd=['rmiobjnavigate(''',sidMdl,''',''',sidNum,''');'];
        result=rmiut.cmdToUrl(objNavCmd);
    case 'plabel'
        result=get_param(dvItems{3}(current),'Name');
    case 'type'
        result=dvItems{3}{current};
    case 'value'
        try
            result=get_param(dvItems{1}(current),'MaskValueString');
        catch
            result='';
        end
    otherwise

        dvItems=rmisl.sldvFind(option);
        current=0;
    end

end

function pack=packOne(objH,type,parentH)
    pack={objH,type,parentH};
end

function validateIndex(data,idx)
    if idx<0||idx>size(data,1)
        error('Invalid index: %d',idx);
    end
end

