function ent=MacroAccessImplementation(ent,hThis,hCSO)

    fcnName=hThis.getImplementationFunctionName(hCSO);







    if~isempty(fcnName)
        if(isempty(coder.getObjectName(hCSO)))


            ent=[];
        else


            ent.Implementation.Name=fcnName;
            ent.EntryInfo.ObjectName=coder.getObjectName(hCSO);
        end
    end

end

