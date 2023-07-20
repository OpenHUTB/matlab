


function libSID=getLibSID(obj)
    try
        libSID=Simulink.ID.getLibSID(obj.Handle);
    catch
        libSID='';
    end
end
