function vals=getPropAllowedValues(~,prop)




    switch prop
    case{'NameMode'}
        vals={...
        DAStudio.message('Simulink:Logging:SigLogDlgNameModeFalse'),...
        DAStudio.message('Simulink:Logging:SigLogDlgNameModeTrue'),...
        };
    otherwise
        vals={};
    end

end

