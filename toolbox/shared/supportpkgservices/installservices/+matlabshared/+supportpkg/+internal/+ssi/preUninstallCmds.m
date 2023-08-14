function preUninstallCmds()


    try
        if matlabshared.supportpkg.internal.ssi.util.isProductInstalled('Simulink')
            matlabshared.supportpkg.internal.ssi.util.closeSimulinkSystem();
        end
        clear classes;
    catch ex
        baseException=MException(ex.identifier,ex.message);
        throwAsCaller(baseException);
    end
end