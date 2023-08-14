function tgt=executeChanges(hObj,chg,tgt)



    vTF=isfield(chg,{'vis','en','val'});


    if(isa(tgt,'struct'))
        if(vTF(1)),tgt=l_executeCellChange(chg.vis,tgt,'Visible');end
        if(vTF(2)),tgt=l_executeCellChange(chg.en,tgt,'Enabled');end
        if(vTF(3)),l_executeCellChange(chg.val,hObj,'Value');end



    elseif(isa(tgt,'DAStudio.Dialog'))
        if(vTF(1)),l_executeDlgChange(hObj,chg.vis,@tgt.setVisible,'Visible');end
        if(vTF(2)),l_executeDlgChange(hObj,chg.en,@tgt.setEnabled,'Enabled');end
        if(vTF(3)),l_executeDlgChange(hObj,chg.val,@tgt.setWidgetValue,'Value');end


    else

    end
end

function tgt=l_executeCellChange(chg,tgt,tgtField)
    if(~isempty(chg)),propNames=fieldnames(chg);
    else propNames=[];
    end
    for ii=1:length(propNames)
        propName=propNames{ii};
        switch(tgtField)
        case{'Visible','Enabled'}
            tgt.(propName).(tgtField)=chg.(propName);
        case{'Value'}
            tgt.(propName)=chg.(propName);
        end
    end
end

function l_executeDlgChange(hObj,chg,tgtFcn,tgtField)
    if(~isempty(chg)),propNames=fieldnames(chg);
    else propNames=[];
    end
    for ii=1:length(propNames)
        propName=propNames{ii};
        if(hObj.isUsingEditWidget(propName)&&~strcmp(tgtField,'Value'))
            wtags=struct2cell(dpigen.EditWidget.getWidgetTags(hObj,propName));
        else
            wtags={hObj.genTag(propName)};
        end
        cellfun(@(tag,pname)(tgtFcn(tag,chg.(pname))),...
        wtags,repmat({propName},size(wtags)));
    end
end
