function launchDDGSpreadSheet(this,topModelName,currentModelName)






    tab_cont=find(strcmp(currentModelName,this.modelList),1);
    studioTab_cont=find(strcmp(topModelName,this.modelList),1);

    this.currentTabIndex=tab_cont;
    this.modelLegendState{tab_cont}='on';

    warningStruct=warning('off','Simulink:Engine:CompileNeededForSampleTimes');
    this.legendBlockInfo{tab_cont}=get_param(currentModelName,'rateIndexTaskIdxMap');
    warning(warningStruct.state,'Simulink:Engine:CompileNeededForSampleTimes');

    if(isempty(this.legendBlockInfo{tab_cont}))
        if(isequal(this.modelLegendState{studioTab_cont},'on')&&length(this.ssSource)>=studioTab_cont)
            this.studio{studioTab_cont}.hideComponent(this.ssSource{studioTab_cont}.mComponent);
        end
        return;
    end

    this.clearHilite(currentModelName);
    studio=this.studio{studioTab_cont};

    compName=char(studio.getStudioTag+"ssCompLegend");
    ssComp=studio.getComponent('GLUE2:SpreadSheet',compName);
    mlock;
    ssConfigStr='{"hidecolumns":true, "disablepropertyinspectorupdate":true, "expandall":true, "enablemultiselect":false}';

    if(isempty(ssComp)||~ssComp.isvalid)
        ssComp=GLUE2.SpreadSheetComponent(studio,compName);
        studio.registerComponent(ssComp);
        this.ssSource{studioTab_cont}=Simulink.STOSpreadSheet.SourceObj(currentModelName,topModelName,this,tab_cont,ssComp);
        ssComp.setEmptyListMessage("There is no data.");
        studio.moveComponentToDock(ssComp,DAStudio.message('Simulink:utility:TimingLegendTitle'),'Right','stacked');
        ssComp.setSource(this.ssSource{studioTab_cont});
    else
        this.ssSource{studioTab_cont}.updateViewData(currentModelName,topModelName);
        ssComp.setSource(this.ssSource{studioTab_cont});
    end
    ssComp.setConfig(ssConfigStr);
    studio.showComponent(ssComp);
    ssComp.update();
end
