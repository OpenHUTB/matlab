







function tableInfo=AddIndiceHyperLinkToTable(indices,sfObj,sourceSnippet)
    bCorrectIndices=false;
    if nargin==2
        sourceSnippet=sfObj.LabelString;
        bCorrectIndices=true;
    end

    tableInfo={};

    if isempty(indices)||isempty(sfObj)
        return;
    end

    if~isa(indices,'double')
        indices=double(indices);
    end

    if isa(sfObj,'Stateflow.State')
        linkStr=ModelAdvisor.Text([sfObj.Path,'/',sfObj.Name]);
    else
        linkStr=ModelAdvisor.Text(sfObj.Path);
    end
    objID=Simulink.ID.getSID(sfObj);
    linkStr.setHyperlink(['matlab: Simulink.ID.hilite(''',objID,''')']);

    if~bCorrectIndices
        flagStart=strfind(sourceSnippet,sfObj.LabelString(indices(1):indices(2)));
        if isempty(flagStart)
            flagStart=1;
        end
        msgStr=Advisor.Utils.Stateflow.highlightSFLabelByIndex(sourceSnippet,[flagStart,flagStart+max(indices(:))-min(indices(:))]);
    else
        msgStr=Advisor.Utils.Stateflow.highlightSFLabelByIndex(sourceSnippet,[min(indices(:)),max(indices(:))]);
    end

    tableInfo=[tableInfo;{msgStr,linkStr}];
end


