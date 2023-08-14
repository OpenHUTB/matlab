function fullPathToObject=getFullName(SID)


    fullPathToObject='';
    if isempty(Simulink.ID.checkSyntax(SID))&&Simulink.ID.isValid(SID)



        [object,remainder]=Simulink.ID.getHandle(SID);
        if strncmp(class(object),'Stateflow',9)


            fullPathToObject=object.getFullName();






            if Advisor.BaseRegisterCGIRInspectorResults.isValidMATLABFcnStartEndPostFix(remainder)&&...
                (isa(object,'Stateflow.EMChart')||isa(object,'Stateflow.EMFunction'))
                fullPathToObject=[fullPathToObject,':',remainder];
            end
        else
            fullPathToObject=Simulink.ID.getFullName(SID);
        end
    end
end