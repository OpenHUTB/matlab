function copyCSErrorArgs(matcher,oldM3IModel)




    argMetaClass=Simulink.metamodel.arplatform.interface.ArgumentData.MetaClass;

    oldM3IArgSeqs=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(oldM3IModel,argMetaClass,true);
    for ii=1:oldM3IArgSeqs.size()
        oldM3IArg=oldM3IArgSeqs.at(ii);
        if strcmp(oldM3IArg.Direction.toString(),'Error')
            newM3IArg=i_findErrorArg(matcher,oldM3IArg);
            if newM3IArg.isvalid()

                matcher.set(newM3IArg,oldM3IArg);


                newM3IArg.Name=oldM3IArg.Name;
            end
        end
    end

    function newM3IArg=i_findErrorArg(matcher,oldM3IArg)

        newM3IArg=M3I.ClassObject;

        oldM3IOp=oldM3IArg.containerM3I;
        newM3IOp=matcher.getFirst(oldM3IOp);
        if newM3IOp.isvalid()
            for ii=1:newM3IOp.Arguments.size()
                if strcmp(newM3IOp.Arguments.at(ii).Direction.toString(),'Error')
                    newM3IArg=newM3IOp.Arguments.at(ii);
                    return
                end
            end
        end
