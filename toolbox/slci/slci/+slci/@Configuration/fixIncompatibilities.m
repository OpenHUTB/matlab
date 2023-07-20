function result=fixIncompatibilities(aObj)





    result=true;


    mgr=slci.internal.ModelStateMgr(aObj.getModelName());

    try


        if aObj.getTopModel()
            mgr.compileModelForTop();
        else
            mgr.compileModelForRef();
        end


        aObj.SetupRefMdls();


        summary=aObj.checkModelCompatibility();
        Incompabitilities=summary.Incompatibilities;


        mgr.terminate();



        for j=numel(Incompabitilities):-1:1
            try
                incompat=Incompabitilities(j);
                fixed=incompat.getConstraint.fix(incompat);
                if~fixed
                    result=false;
                end
            catch
                result=false;
            end
        end
    catch

        mgr.terminate();
        result=false;
        return;
    end


    if(aObj.getFollowModelLinks())
        results=aObj.FixSubModels();
        if any(~results)
            result=false;
        end
    end


end


