function success=checkExceptionIdentifier(me,msgId)




    success=any(strfind(me.identifier,msgId));
    if(~success)
        N=length(me.cause);
        for idx=1:N
            ex1=me.cause{idx};
            success=Simulink.ModelReference.Conversion.checkExceptionIdentifier(ex1,msgId);
            if success
                break;
            end
        end
    end
end
