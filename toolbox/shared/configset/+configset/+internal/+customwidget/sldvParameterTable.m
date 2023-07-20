function[parameterTable,dscr]=sldvParameterTable(cs,~)
















    dscr='';
    if isa(cs,'Simulink.ConfigSetRef')
        localCS=cs.LocalConfigSet;
        sldv=localCS.getComponent('Design Verifier');
        sldvshareprivate('syncOverrideStatusOfSldvParamTable',cs);
    else
        sldv=cs.getComponent('Design Verifier');
    end

    mdlH=sldv.getModel;

    pmanager=sldv.getParameterManager(mdlH,cs);

    if slavteng('feature','BusParameterTuning')
        pdata=pmanager.getFlatListOfParams();
    else
        pdata=pmanager.getAllParams;
    end
    if~isempty(pdata)
        if slavteng('feature','BusParameterTuning')
            pnames={pdata.name};
            paramCount=length(pnames);
            TableData=cell(paramCount,1);
            Types=cell(paramCount,1);
            for idx=1:length(pdata)
                parameter=pdata(idx).value;
                Types{idx,1}='checkbox';
                TableData{idx,1}=pmanager.isParamUsedInAnalysis(pnames{idx});
                Types{idx,2}='edit';
                TableData{idx,2}=parameter.Name;
                Types{idx,3}='edit';
                TableData{idx,3}=parameter.Constraint;
                Types{idx,4}='edit';
                TableData{idx,4}=parameter.getValue2Str();
                Types{idx,5}='edit';
                TableData{idx,5}=parameter.getMin2Str();
                Types{idx,6}='edit';
                TableData{idx,6}=parameter.getMax2Str();
                Types{idx,7}='edit';
                TableData{idx,7}=pmanager.locate(pnames{idx});
            end
        else
            pnames=fieldnames(pdata);
            paramCount=length(pnames);
            TableData=cell(paramCount,1);
            Types=cell(paramCount,1);
            for idx=1:length(pnames)
                Types{idx,1}='checkbox';
                TableData{idx,1}=pmanager.isParamUsedInAnalysis(pnames{idx});
                Types{idx,2}='edit';
                TableData{idx,2}=pdata.(pnames{idx}).Name;
                Types{idx,3}='edit';
                TableData{idx,3}=pdata.(pnames{idx}).Constraint;
                Types{idx,4}='edit';
                TableData{idx,4}=pdata.(pnames{idx}).getValue2Str();
                Types{idx,5}='edit';
                TableData{idx,5}=pdata.(pnames{idx}).getMin2Str();
                Types{idx,6}='edit';
                TableData{idx,6}=pdata.(pnames{idx}).getMax2Str();
                Types{idx,7}='edit';
                TableData{idx,7}=pmanager.locate(pnames{idx});
            end
        end
    else
        paramCount=0;
        TableData={};
        Types={};
    end


    parameterTable.ColumnHeaders=true;
    parameterTable.ColumnLabels={DAStudio.message('Sldv:dialog:sldvParamConfigTableColHeadUse'),...
    DAStudio.message('Sldv:dialog:sldvParamConfigTableColHeadName'),...
    DAStudio.message('Sldv:dialog:sldvParamConfigTableColHeadConstraint'),...
    DAStudio.message('Sldv:dialog:sldvParamConfigTableColHeadValue'),...
    DAStudio.message('Sldv:dialog:sldvParamConfigTableColHeadMin'),...
    DAStudio.message('Sldv:dialog:sldvParamConfigTableColHeadMax'),...
    DAStudio.message('Sldv:dialog:sldvParamConfigTableColHeadLocation')
    };
    parameterTable.RowHeaders=false;

    parameterTable.SelectRow=true;
    parameterTable.Size=[paramCount,7];
    parameterTable.Data=TableData;
    parameterTable.Types=Types;
    parameterTable.ColumnEditable=[true,false,true,false,false,false,false];
    parameterTable.ColumnIDs={'Use','Name','Constraint','Value','Min','Max','Model_Element'};
    parameterTable.DisableCompletely=true;



