function makeFcnPropsTable(this,d,out,cCaller)






    if strcmp(this.FcnPropsPropListMode,'manual')
        propList=this.FcnPropsPropList;
    else

        propList=slreportgen.utils.getSimulinkObjectParameters(cCaller,'Block');

        toRemove={'FunctionName','AvailableFunctions','FunctionPortSpecification','PortSpecificationString'};
        propList=setdiff(propList,toRemove);

        propList=[propList;{'Description'}];
    end


    name=mlreportgen.utils.normalizeString(getfullname(cCaller));
    if strcmp(this.FcnPropsTableTitleType,'none')
        titleType='none';
        titleStr='';
    else
        titleType='manual';
        if strcmp(this.FcnPropsTableTitleType,'auto')
            titleStr=[name,' ',getString(message('RptgenSL:csl_ccaller:functionPropertiesLabel'))];
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

    tbl=autoBlkTableComp.atMakeAutoTable(d,cCaller);

    out.appendChild(tbl);
end
