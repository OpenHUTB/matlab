function[bias,slope,result]=getScalingFromLinearCompuMethod(m3iObj)





    bias=0;
    slope=1;
    result=false;
    toolId='ARXML_CompuMethodInfo';
    tok=regexp(m3iObj.getExternalToolInfo(toolId).externalId,'#','split');
    for ii=2:numel(tok)
        if strcmp(tok(ii),'Bias')
            result=true;
            bias=str2double(tok(ii+1));
        elseif strcmp(tok(ii),'Slope')
            result=true;
            slope=str2double(tok(ii+1));
        end
        ii=ii+1;%#ok<FXSET>
    end
end


