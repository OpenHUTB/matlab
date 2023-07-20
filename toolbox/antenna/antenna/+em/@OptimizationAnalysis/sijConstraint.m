function f=sijConstraint(obj)

    f=@sijConstraintAnalyze;

    function constraintvalue=sijConstraintAnalyze(propValues)


        DesiredSij=obj.OptimStruct.Value{strcmpi(obj.OptimStruct.ConstraintsFunctionName,'Sij')};
        operator=obj.OptimStruct.Operator{strcmpi(obj.OptimStruct.ConstraintsFunctionName,'Sij')};
        checkConsVal=0;
        ConflictingBound=false;


        setValues2Antenna(obj,propValues);


        try
            checkConsVal=processSparameterCross(obj,'Constraint');
drawnow
        catch
            ConflictingBound=true;
        end


        constraintvalue=processConstraint(obj,DesiredSij,checkConsVal,operator,ConflictingBound,checkConsVal,'S11 (dB)');
    end
end