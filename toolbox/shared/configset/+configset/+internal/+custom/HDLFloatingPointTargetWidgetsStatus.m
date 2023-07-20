function[status,dscr]=HDLFloatingPointTargetWidgetsStatus(cs,name)



    dscr='';
    hdlcc=cs.getComponent('HDL Coder');
    cli=hdlcc.getCLI;

    fp=cli.FloatingPointTargetConfiguration;

    if isempty(fp)


        status=configset.internal.data.ParamStatus.InAccessible;
    else
        switch upper(fp.Library)
        case{'NATIVEFLOATINGPOINT'}
            if ismember(name,{'NFPLatencyStrategy','HandleDenormals','NFPAlgoMultStrategy'})
                status=configset.internal.data.ParamStatus.Normal;
            else
                status=configset.internal.data.ParamStatus.InAccessible;
            end

        case{'ALTERAFPFUNCTIONS'}
            if ismember(name,{'FrequencyModeInitLogic','FloatingPointDataTypeString',...
                'FloatingPointDataTypeInsert','FloatingPointIPConfigTable'})
                status=configset.internal.data.ParamStatus.Normal;
            else
                status=configset.internal.data.ParamStatus.InAccessible;
            end


        case{'ALTFP','XILINXLOGICORE'}
            if ismember(name,{'FloatingPointDataTypeString',...
                'FloatingPointDataTypeInsert','FloatingPointIPConfigTable',...
                'LatencyStrategy','LatencyModeObjective'})
                status=configset.internal.data.ParamStatus.Normal;
            else
                status=configset.internal.data.ParamStatus.InAccessible;
            end
        end
    end


