function out=HDLCodingStandardCustomizationsValues(cs,~,direction,widgetVals)































    widget_names={...
    'ShowPassingRules',...
    'DetectDuplicateNamesCheck',...
    'HDLKeywords',...
    'ModuleInstanceEntityNameLength',...
    'ModuleInstanceEntityNameLength_min',...
    'ModuleInstanceEntityNameLength_max',...
    'SignalPortParamNameLength',...
    'SignalPortParamNameLength_min',...
    'SignalPortParamNameLength_max',...
    'MinimizeClockEnableCheck',...
    'RemoveResetCheck',...
    'AsynchronousResetCheck',...
    'MinimizeVariableUsage',...
    'InitialStatements',...
    'ConditionalRegionCheck',...
    'ConditionalRegionCheck_length',...
    'CascadedConditionalAssignmentCheck',...
    'IfElseChain',...
    'IfElseChain_length',...
    'IfElseNesting',...
    'IfElseNesting_depth',...
    'MultiplierBitWidth',...
    'MultiplierBitWidth_width',...
    'NonIntegerTypes',...
    'LineLength',...
    'LineLength_length'};

    cs=cs.getConfigSet;
    hdlcc=cs.getComponent('HDL Coder');
    cli=hdlcc.getCLI;

    codingStandards=cli.HDLCodingStandard;
    cso=cli.HDLCodingStandardCustomizations;

    if direction==0
        if strcmpi(codingStandards,'Industry')&&~isa(cso,'hdlcodingstd.IndustryCustomizations')

            cso=hdlcoder.CodingStandard('Industry');
        end

        if isempty(cso)
            out={'off','off','off','off','','','off','','',...
            'off','off','off','off','off','off','','off','off','',...
            'off','','off','','off','off',''};
        else
            checkValues={'off','on'};
            out=cell(1,26);
            for i=1:length(widget_names)
                names=split(widget_names{i},'_');
                if length(names)==1
                    v=cso.(names{1}).enable;
                    out{i}=checkValues{double(v+1)};
                else
                    if strcmp(names{2},'min')
                        num=cso.(names{1}).length(1);
                    elseif strcmp(names{2},'max')
                        num=cso.(names{1}).length(2);
                    else
                        num=cso.(names{1}).(names{2});
                    end
                    out{i}=num2str(num);
                end
            end
        end


    elseif direction==1
        if strcmpi(codingStandards,'None')

            out=cso;
        else


            cso=hdlcoder.CodingStandard('Industry');


            for i=1:length(widget_names)
                names=split(widget_names{i},'_');
                if length(names)==1
                    val=widgetVals{i};
                    if ischar(val)
                        cso.(names{1}).enable=strcmp(val,'on');
                    else
                        cso.(names{1}).enable=val;
                    end
                else



                    val=str2double(widgetVals{i});


                    if val<0||isinf(val)||isnan(val)||~isnumeric(val)
                        error(message('HDLShared:hdldialog:CannotBeNegative'));
                    end

                    if strcmp(names{2},'min')

                        if val>=str2double(widgetVals{i+1})
                            error(message('HDLShared:hdldialog:CannotBeMinMax'));
                        end

                        if val==0
                            error(message('HDLShared:hdldialog:CannotBeNegative'));
                        end
                        cso.(names{1}).length(1)=val;

                    elseif strcmp(names{2},'max')

                        if val==0
                            error(message('HDLShared:hdldialog:CannotBeNegative'));
                        end
                        cso.(names{1}).length(2)=val;
                    else

                        if ismember(names{1},{'MultiplierBitWidth','LineLength'})&&val==0
                            error(message('HDLShared:hdldialog:CannotBeNegative'));
                        end
                        cso.(names{1}).(names{2})=val;
                    end
                end
            end
            out=cso;
        end
    end


