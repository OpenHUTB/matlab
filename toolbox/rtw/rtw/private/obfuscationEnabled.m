function enabled=obfuscationEnabled(h)




    ObfuscationLevel=get_param(h.ModelHandle,'ObfuscateCode');
    enabled=(ObfuscationLevel>0&&ObfuscationLevel<4)&&...
    strcmp(get_param(0,'AcceleratorUseTrueIdentifier'),'off');
