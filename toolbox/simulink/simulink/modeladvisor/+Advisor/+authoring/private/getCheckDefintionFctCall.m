function mcode=getCheckDefintionFctCall(checkDef)
    lb=sprintf('\n');
    tab=sprintf('\t');
    mcode=[tab,'define_',regexprep(checkDef.ID,'\W','_'),'();',lb];
end