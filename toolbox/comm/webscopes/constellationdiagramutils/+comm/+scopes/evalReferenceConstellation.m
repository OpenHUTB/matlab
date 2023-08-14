function[result,value]=evalReferenceConstellation(workspace,refparams,clientID,~)


    wsBlock=matlabshared.scopes.WebScope.getInstance(clientID);
    block=wsBlock.FullPath;

    blockConfig=get_param(block,'ScopeConfiguration');
    refValues=refparams;
    value=cell(size(refValues));
    for idx=1:numel(refValues)
        if iscell(refValues)
            currentRefValue=refValues{idx};
        else
            currentRefValue=refValues(idx);
        end
        if(isfield(currentRefValue,'ReferenceConstellation'))
            ref=comm.scopes.getActualRefCon(workspace,currentRefValue,clientID);
            blockConfig.currentReferenceConstellation{idx}=currentRefValue;
            if iscell(ref)
                ref=cell2mat(ref);
            end
            value{idx}=ref;
        end
    end
    xRefData=cell(size(value));
    yRefData=cell(size(value));
    for idx=1:numel(value)
        xRefData{idx}=real(value{idx});
        yRefData{idx}=imag(value{idx});
        value{idx}=mat2str(value{idx});
    end

    graphicalSettings=get_param(block,'Graphicalsettings');
    try
        if~isempty(refparams)
            if~isempty(graphicalSettings)
                decodeGraphicalSettings=jsondecode(graphicalSettings);
                decodeGraphicalSettings.ReferenceConstellation=refparams;
            else
                decodeGraphicalSettings=struct;
                decodeGraphicalSettings.ReferenceConstellation=refparams;
            end
            encodeGraphicalSettings=jsonencode(decodeGraphicalSettings);
            preserveDirty=Simulink.PreserveDirtyFlag(bdroot(block),'blockDiagram');%#ok
            set_param(block,'Graphicalsettings',encodeGraphicalSettings);
            blockConfig.IsCacheReferenceConstellation=true;
        end
    catch
    end
    referenceConstString=get_param(block,'ReferenceConstellation');
    if(iscell(xRefData)&&numel(xRefData)>1)&&(ischar(referenceConstString)||isstring(referenceConstString))
        referenceConstString=regexprep(referenceConstString,{'{','}',']['},{'','','],['});
        if contains(referenceConstString,'[[')
            referenceConstString=regexprep(referenceConstString,{'[[',']]'},{'[',']'});
            referenceConstString=regexprep(referenceConstString,{'],'},{']"'});
            referenceConstString=split(referenceConstString,'"');
            referenceConstString=regexprep(referenceConstString,{']','['},{'',''});
        else
            referenceConstString=regexprep(referenceConstString,{'[',']'},{'',''});
            referenceConstString=split(referenceConstString,',');
        end
    end
    result=struct('referenceConstellation',value,...
    'xRefData',xRefData,'yRefData',yRefData,'referenceConstellationString',referenceConstString);
end


