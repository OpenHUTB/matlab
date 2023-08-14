function retObj=createCustomAttribObj(hThisCSC,inModel)




    try

        className=hThisCSC.createCustomAttribClass(inModel);


        retObj=feval(className);

    catch err
        DAStudio.error('Simulink:dialog:CSCDefnCustomAttribClassCreateCustomObj',...
        hThisCSC.OwnerPackage,hThisCSC.Name,err.message);

    end



