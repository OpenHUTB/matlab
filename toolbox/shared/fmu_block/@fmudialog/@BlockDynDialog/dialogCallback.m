function dialogCallback(this,dlg,tag,varargin)


    switch(tag)

    case 'logging_toggle_tag'
        enabled=varargin{1};
        dlg.setEnabled('FMUDebugLoggingPanel',enabled);
        dlg.setEnabled('FMUDebugLoggingRedirect',enabled);

    case 'logging_filter_tag'
        loggingEntries={...
        'FMUBlock:FMU:FMULoggingStatus_OK',...
        'FMUBlock:FMU:FMULoggingStatus_WARNING',...
        'FMUBlock:FMU:FMULoggingStatus_DISCARD',...
        'FMUBlock:FMU:FMULoggingStatus_ERROR',...
        'FMUBlock:FMU:FMULoggingStatus_FATAL',...
        'FMUBlock:FMU:FMULoggingStatus_PENDING',...
        };
        untranslatedEntries={...
        'OK','Warning','Discard','Error','Fatal','Pending'};
        filter={};
        for i=1:length(loggingEntries)
            if(dlg.getWidgetValue(['FMUDebugLoggingFilterCheckBox',i]))
                filter{length(filter)+1}=['',untranslatedEntries{i},''];%#ok
            end
        end
        this.DialogData.DebugLoggingFilter=filter;

    case 'open_working_directory_tag'
        web(varargin{1});

    case 'open_log_file_tag'
        if exist(varargin{1},'file')==0
            errordlg(DAStudio.message('FMUBlock:FMU:FMULogFileNotFound',varargin{1}),DAStudio.message('FMUBlock:FMU:OpenFMULogFile'));
        else
            web(varargin{1});
        end

    case 'open_documentation_file_tag'
        if exist(varargin{1},'file')==0
            errordlg(DAStudio.message('FMUBlock:FMU:FMUDocumentationFileNotFound',varargin{1}),DAStudio.message('FMUBlock:FMU:OpenFMUDocumentationFile'));
        else
            web(varargin{1});
        end

    case 'fmu_sample_time_tag'
        this.DialogData.FMUSampleTime=dlg.getWidgetValue('FMUSampleTime');

    case 'fmu_tolerance_value_tag'
        this.DialogData.FMUToleranceValue=dlg.getWidgetValue('FMUToleranceValue');

    case 'fmu_is_tolerance_used_tag'
        enabled=varargin{1};
        dlg.setEnabled('FMUToleranceValue',enabled);

    case 'simulate_using_tag'
        switch varargin{1}
        case 0
            this.DialogData.SimulateUsing='FMU';
        case 1
            this.DialogData.SimulateUsing='Native Simulink Behavior';
        otherwise
            assert(false,'invalid mode for Simulate using');
        end









    end

end