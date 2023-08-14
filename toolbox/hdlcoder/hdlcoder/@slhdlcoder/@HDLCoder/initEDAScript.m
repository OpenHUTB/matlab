function newParams=initEDAScript(this,tool)%#ok


    if any(strcmpi({'vivado','ise','libero','precision','quartus','synplify','custom'},tool))
        edascript=hdlgetedascript(tool);
        newParams={'HDLSynthFilePostfix',edascript.SynScriptPostFix,...
        'HDLSynthInit',edascript.SynScriptInit,...
        'HDLSynthCmd',edascript.SynScriptCmd,...
        'HDLSynthTerm',edascript.SynScriptTerm,...
        'HDLSynthLibCmd',edascript.SynLibCmd,...
        'HDLSynthLibSpec',edascript.SynLibSpec};
    else
        newParams={};
    end
end


