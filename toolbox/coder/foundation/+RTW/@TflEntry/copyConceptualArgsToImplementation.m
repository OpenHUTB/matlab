function copyConceptualArgsToImplementation(h)









    cArgs=h.ConceptualArgs;
    numArgs=length(cArgs);

    for idx=1:numArgs
        if strcmp(class(cArgs(idx)),'RTW.TflArgMatrix')==1
            implArg=RTW.TflArgPointer;
            implArg.Name=cArgs(idx).Name;
            implArg.IOType=cArgs(idx).IOType;
            implArg.CheckType=cArgs(idx).CheckType;

            mET=cArgs(idx).Type;
            implArg.Type.Identifier=mET.Identifier;
            implArg.Type.Name=mET.Name;
            implArg.Type.ReadOnly=mET.ReadOnly;
            implArg.Type.Volatile=mET.Volatile;
            implArg.Type.BaseType=mET.BaseType;
        else
            implArg=cArgs(idx);

        end

        if(idx==1)&&strcmp(cArgs(1).IOType,'RTW_IO_OUTPUT')

            h.Implementation.setReturn(implArg);
        else
            h.Implementation.addArgument(implArg);
        end
    end
