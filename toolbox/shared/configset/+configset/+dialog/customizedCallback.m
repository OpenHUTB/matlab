function customizedCallback(dlg,p)



    if ishandle(p)&&~isempty(p)
        switch p.Name
        case 'SignalLogging'

            hSrc=dlg.getSource.Source.Source;
            isConfigSetRef=double(isempty(hSrc.getConfigSet())||~hSrc.isActive||hSrc.isObjectLocked);
            dlg.setEnabled('Tag_ConfigSet_DataIO_SignalLoggingConfigure',~isConfigSetRef&&p.Value);


        case 'SolverType'
            dlg.setWidgetValue('Tag_ConfigSet_Solver_VariableSolver',1);
            dlg.setWidgetValue('Tag_ConfigSet_Solver_FixedSolver',4);

            dlg.setVisible('Tag_ConfigSet_Solver_ZeroCrossingOptions',strcmp(p.Value,'Variable-step'));
        end
    end


