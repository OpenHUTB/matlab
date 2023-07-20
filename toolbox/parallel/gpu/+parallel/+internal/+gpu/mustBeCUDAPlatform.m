function mustBeCUDAPlatform()







    if~parallel.internal.gpu.isCUDAPlatform()
        try
            parallel.internal.gpu.errorIfNotCUDAPlatform()
        catch E
            throwAsCaller(E);
        end
    end

end
