function res=targetHasOpenCB(target)




    res=SLStudio.Utils.objectIsValidBlock(target)&&~isempty(get_param(target.handle,'OpenFcn'));
end
