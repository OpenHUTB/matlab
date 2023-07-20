function[lineMaps,lineStarts]=reportToLineMaps(report,scriptWhitelist)




    if(~isfield(report,'inference')&&~isa(report,'eml.InferenceReport'))||(nargin>1&&isempty(scriptWhitelist))
        lineMaps={};
        lineStarts={};
        return;
    end

    if~isa(report,'eml.InferenceReport')
        scripts=report.inference.Scripts;
    else
        scripts=report.Scripts;
    end

    lineMaps=cell(1,numel(scripts));
    lineStarts=lineMaps;
    if nargin<2
        scriptWhitelist=1:numel(scripts);
    end

    for i=1:numel(scriptWhitelist)
        scriptId=scriptWhitelist(i);
        [lineMaps{scriptId},lineStarts{scriptId}]=codergui.internal.createLineMap(scripts(scriptId).ScriptText);
    end
end
