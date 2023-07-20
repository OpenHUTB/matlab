function UpdateFimathForFiConstructors(block,hb,h,slMsgName)





    Fold=hb.FimathForFiConstructors;
    Fnew='Same as FIMATH for fixed-point input signals';
    if~isequal(Fold,Fnew)
        if askToReplace(h,block)
            reason=DAStudio.message(slMsgName,h.cleanLocationName(block));
            if(doUpdate(h))
                hb.FimathForFiConstructors=Fnew;
            end
            appendTransaction(h,block,reason,{{'set',hb,'FimathForFiConstuctors',Fnew}});
        end
    end

end
