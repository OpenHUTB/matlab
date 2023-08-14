function cppId=getCppIdentifierForBlock(block,prefix)








    if~exist('prefix','var')
        prefix='';
    end




    blockId=Simulink.ID.getSID(block);







    cppId=[prefix,regexprep(blockId,{'^\d*','\s*','\W'},{'','','_'})];
end
