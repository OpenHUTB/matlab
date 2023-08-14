function[widths,headings,height]=GetColInfo(this)












    widths=[18,18,16];
    headings={...
    l_GetUIString('FPGAProjectPropertyName'),...
    l_GetUIString('FPGAProjectPropertyValue'),...
    l_GetUIString('FPGAProjectPropertyProcess')...
    };
    height=1;
end


function str=l_GetUIString(key)
    postfix='_Name';
    str=DAStudio.message(['EDALink:FPGAUI:',key,postfix]);
end
