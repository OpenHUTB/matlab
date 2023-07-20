function makeFcnPropsTable(this,d,out,cFcn)






    if strcmp(this.FcnPropsPropListMode,'manual')
        propList=this.FcnPropsPropList;
    else

        propList=slreportgen.utils.getSimulinkObjectParameters(cFcn,'Block');

        toRemove={'OutputCode','TerminateCode','StartCode','InitializeConditionsCode','SymbolSpec'};
        propList=setdiff(propList,toRemove);

        propList=[propList;{'Description'}];
    end


    name=mlreportgen.utils.normalizeString(getfullname(cFcn));
    if strcmp(this.FcnPropsTableTitleType,'none')
        titleType='none';
        titleStr='';
    else
        titleType='manual';
        if strcmp(this.FcnPropsTableTitleType,'auto')
            titleStr=[name,' ',getString(message('RptgenSL:csl_cfcn:functionPropertiesLabel'))];
        else
            titleStr=rptgen.parseExpressionText(this.FcnPropsTableTitle);
        end
    end


    autoBlkTableComp=rptgen_sl.csl_auto_table(...
    'TitleType',titleType,...
    'Title',titleStr,...
    'HeaderType',this.FcnPropsHeaderType,...
    'HeaderColumn1',this.FcnPropsHeaderColumn1,...
    'HeaderColumn2',this.FcnPropsHeaderColumn2,...
    'RemoveEmpty',this.FcnPropsRemoveEmpty,...
    'ShowNamePrompt',this.FcnPropsShowNamePrompt,...
    'ObjectType','block',...
    'PropertyListMode','manual',...
    'PropertyList',propList);

    tbl=autoBlkTableComp.atMakeAutoTable(d,cFcn);

    out.appendChild(tbl);
end
