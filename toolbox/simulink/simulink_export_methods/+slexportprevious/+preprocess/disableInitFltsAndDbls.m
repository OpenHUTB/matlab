function disableInitFltsAndDbls(obj)




    if isR2008aOrEarlier(obj.ver)
        try

            cs=getActiveConfigSet(obj.modelName);
            opt=cs.getComponent('Optimization');
            if isequal(get_param(cs,'IsERTTarget'),'off')
                opt.setPropEnabled('InitFltsAndDblsToZero','off');
            end
        catch %#ok<CTCH>
            return;
        end
    end
end
