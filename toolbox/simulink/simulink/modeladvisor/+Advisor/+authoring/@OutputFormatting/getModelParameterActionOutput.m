


function ft=getModelParameterActionOutput(this,system)
    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft2=ModelAdvisor.FormatTemplate('TableTemplate');



    if isa(getActiveConfigSet(bdroot(system)),'Simulink.ConfigSetRef')
        ft.setCheckText(DAStudio.message('Advisor:engine:CCOFModelParamFixConfSetRef'));
    else

        ft.setCheckText(DAStudio.message('Advisor:engine:CCOFModelParamFixDescription'));
        ft2.setCheckText(DAStudio.message('Advisor:engine:CCOFModelParamNotFixedDescription'));

        colHeadings={DAStudio.message('Advisor:engine:Parameter'),...
        DAStudio.message('Advisor:engine:PreviousValue'),...
        DAStudio.message('Advisor:engine:CurrentValue')};
        colHeadings2={DAStudio.message('Advisor:engine:Parameter'),...
        DAStudio.message('Advisor:engine:CurrentValue'),...
        DAStudio.message('Advisor:engine:RecValues')};
        ft.setColTitles(colHeadings);
        ft2.setColTitles(colHeadings2);

        constraintIDs=this.Constraints.keys;

        for n=1:this.Constraints.length
            constraint=this.Constraints(constraintIDs{n});


            if constraint.WasFixed
                row={constraint.getHyperlinkToParameter(system),...
                constraint.value2String(constraint.CurrentValue),...
                constraint.value2String(constraint.FixValue)};
                ft.addRow(row);
            end
            if~constraint.WasFixed&&~constraint.ResultStatus&&~constraint.IsInformational
                if~isempty(constraint.PreRequisiteConstraintIDs)&&~isempty(constraint.FixValue)
                    row={constraint.getHyperlinkToParameter(system),...
                    DAStudio.message('Advisor:engine:CCOFPreRequConstraintNotFullfilled'),...
                    constraint.value2String(constraint.FixValue)};
                    ft2.addRow(row);
                elseif~isempty(constraint.FixValue)&&~isempty(constraint.CurrentValue)
                    row={constraint.getHyperlinkToParameter(system),...
                    constraint.value2String(constraint.CurrentValue),...
                    constraint.value2String(constraint.FixValue)};
                    ft2.addRow(row);

                elseif isempty(constraint.FixValue)&&isa(constraint,'Advisor.authoring.ERTSystemTargetFileParameterConstraint')
                    row={constraint.getHyperlinkToParameter(system),...
                    constraint.value2String(constraint.CurrentValue),...
                    DAStudio.message('Advisor:engine:CCERTBasedTarget')};
                    ft2.addRow(row);
                end
            end
        end


        if isempty(ft.TableInfo)
            ft.setCheckText(DAStudio.message('Advisor:engine:CCOFModelParamNothingFixed'));
        end
    end


    ft.setSubBar(false);
    if~isempty(ft.TableInfo)&&~isempty(ft2.TableInfo)
        ft.setSubBar(true);
        ft2.setSubBar(false);
        ft=[ft;ft2];
    end
end