function out=getCharArray(val)




    if Simulink.ModelReference.ProtectedModel.isValidSingleString(val)
        out=char(val);
    elseif ischar(val)
        out=val;
    else
        out='';
    end
end