function highliteCallback(this,dlg,widgetTag)






    rowIdx=dlg.getSelectedTableRow(widgetTag)+1;

    if~this.tableIdxMap.isempty&&this.tableIdxMap.isKey(rowIdx)
        prop=this.tableIdxMap(rowIdx);
        ssid=this.getPropSSID(prop);
        if~isempty(ssid)
            Simulink.ID.hilite(ssid);
        else
            highliteByProperty(this,prop)
        end
    else
        Simulink.ID.hilite(Simulink.ID.getSID(gcb));
    end
    function highliteByProperty(this,prop)


        allBlocks=find_system(this.modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','LookUnderMasks','all');
        hp={};
        for idx=1:numel(allBlocks)
            cssid=Simulink.ID.getSID(allBlocks{idx});
            props=getProperties(this,cssid);
            for pidx=1:numel(props)
                currProp=props(pidx);
                if isequal(prop.id,currProp.id)&&isequal(prop.value,currProp.value)
                    hp=[hp,{cssid}];
                end
            end
        end
        Simulink.ID.hilite(hp);
