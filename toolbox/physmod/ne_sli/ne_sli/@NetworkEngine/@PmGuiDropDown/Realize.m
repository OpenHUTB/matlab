function retStatus=Realize(hThis)







    retStatus=true;
    iMatch=[];
    try
        blkHandle=pmsl_getdoublehandle(hThis.BlockHandle);


        cs=physmod.schema.internal.blockComponentSchema(blkHandle);
        p=member(cs,hThis.ValueBlkParam);
        hThis.Label=p.Label;



        if~isempty(p)
            enumData=pm.sli.getEnumData(p.Default.Value);
            if~isempty(enumData)
                hThis.Choices=lValidateChoices(enumData.enumStrings);
                hThis.ChoiceVals=enumData.enumValues;
                hThis.MapVals=enumData.enumValMap;
            elseif(strcmp(p.Default.Value,'true')||...
                strcmp(p.Default.Value,'false'))
                hThis.Choices={'True','False'};
                hThis.ChoiceVals=[true,false];
                hThis.MapVals={'true','false'};
            elseif~isempty(p.Choices)
                hThis.Choices=lValidateChoices({p.Choices.Description});
                hThis.ChoiceVals=cellfun(@(val)value(val,'1'),{p.Choices.Value});
                hThis.MapVals=cellfun(...
                @(val)simscape.engine.sli.internal.cleanmaskvalue(...
                val.value('1')),{p.Choices.Value},'UniformOutput',false);
            end
        end


        strVal=get_param(blkHandle,hThis.ValueBlkParam);
        iMatch=find(strcmp(strVal,hThis.MapVals),1,'first');


        if isempty(iMatch)
            ws=get_param(blkHandle,'MaskWSVariables');
            iBlkParam=strcmp({ws.Name},hThis.ValueBlkParam);
            if nnz(iBlkParam)>0
                maskVal=ws(iBlkParam).Value;
                iMatch=find(maskVal==hThis.ChoiceVals,1,'first');
            end
        end
    catch

    end


    if isempty(iMatch)
        iMatch=1;
    end
    hThis.Value=hThis.Choices{iMatch};


    hThis.Value=pm.sli.internal.resolveMessageString(hThis.Value);
    hThis.Choices=pm.sli.internal.resolveMessageStrings(hThis.Choices);

end

function c=lValidateChoices(choices)
    if~iscellstr(choices)
        error('Choices is expected to be a cellstr');
    end
    c=choices;
end