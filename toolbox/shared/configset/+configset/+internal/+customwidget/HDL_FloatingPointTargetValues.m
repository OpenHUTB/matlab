function out=HDL_FloatingPointTargetValues(cs,~,direction,widgetVals)














    cs=cs.getConfigSet;
    hdlcc=cs.getComponent('HDL Coder');
    cli=hdlcc.getCLI;
    adp=configset.internal.getConfigSetAdapter(cs);

    fp=cli.FloatingPointTargetConfiguration;

    if direction==0
        if isempty(fp)
            out={'None','','','','','','','','',''};
        else
            out{1}=upper(fp.Library);
            if strcmpi(fp.Library,'NATIVEFLOATINGPOINT')
                out(2:10)={upper(fp.LibrarySettings.LatencyStrategy),...
                fp.LibrarySettings.HandleDenormals,...
                fp.LibrarySettings.MantissaMultiplyStrategy,...
                '','','','','',''};
            else
                switch upper(fp.Library)
                case{'ALTERAFPFUNCTIONS'}
                    out(2:10)={'','','',...
                    loc_onoff(fp.LibrarySettings.InitializeIPPipelinesToZero),...
                    '','','','',''};
                case{'ALTFP','XILINXLOGICORE'}
                    out(2:10)={'','','','','','','',...
                    fp.LibrarySettings.LatencyStrategy,...
                    fp.LibrarySettings.Objective};
                end
                if adp.tmpWidgetValues.isKey('FloatingPointDataTypeString')
                    out{6}=adp.tmpWidgetValues('FloatingPointDataTypeString');
                else
                    out{6}='SINGLE_TO_NUMERICTYPE(1, 32, 16)';
                    adp.tmpWidgetValues('FloatingPointDataTypeString')=out{6};
                end
                out{8}=fp.IPConfig.outputInString();
            end
        end


    elseif direction==1
        lib=upper(widgetVals{1});
        if strcmp(lib,'NONE')
            fp=[];
        elseif isa(lib,'hdlcoder.FloatingPointTargetConfig')

            fp=lib;
        elseif isempty(fp)||~strcmpi(lib,fp.Library)

            fp=hdlcoder.createFloatingPointTargetConfig(lib);
        else
            switch lib
            case{'NATIVEFLOATINGPOINT'}
                if~isempty(widgetVals{2})


                    fp.LibrarySettings.LatencyStrategy=widgetVals{2};
                    fp.LibrarySettings.HandleDenormals=loc_onoff(widgetVals{3});
                    fp.LibrarySettings.MantissaMultiplyStrategy=widgetVals{4};
                    fp.LibrarySettings.Version='1.0.0';
                end
            case{'ALTERAFPFUNCTIONS'}
                if~isempty(widgetVals{5})
                    fp.IPConfig.inputInString(widgetVals{8});
                    fp.IPConfig.consolidate();
                    fp.LibrarySettings.InitializeIPPipelinesToZero=strcmp(widgetVals{5},'on');
                    adp.tmpWidgetValues.remove('FloatingPointDataTypeString');
                    validate_input(fp,widgetVals{6});
                    adp.tmpWidgetValues('FloatingPointDataTypeString')=widgetVals{6};
                end



            case{'ALTFP','XILINXLOGICORE'}
                if~isempty(widgetVals{9})
                    fp.IPConfig.inputInString(widgetVals{8});
                    fp.IPConfig.consolidate();
                    fp.LibrarySettings.LatencyStrategy=widgetVals{9};
                    fp.LibrarySettings.Objective=widgetVals{10};
                    adp.tmpWidgetValues.remove('FloatingPointDataTypeString');
                    validate_input(fp,widgetVals{6});
                    adp.tmpWidgetValues('FloatingPointDataTypeString')=widgetVals{6};
                end


            end
        end
        out=fp;
    end
end

function validate_input(fp,val)
    [key,~,~]=fp.IPConfig.m_strategy.fromVisualPV('Convert',val);
    fp.IPConfig.m_strategy.getBaseKey(key);
end

function val=loc_onoff(boolVal)
    if ischar(boolVal)
        val=boolVal;
    elseif boolVal
        val='on';
    else
        val='off';
    end
end


