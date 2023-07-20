function[efficiency,sorted_loss_breakdown]=calculateEfficiency(lossTable,loadIdentifier)






    power_loss=0;
    power_output=0;
    loss_breakdown=lossTable;
    remove_indices=[];
    for ii=1:length(lossTable.LoggingNode)
        if~isempty(strfind(lossTable.LoggingNode{ii},loadIdentifier))
            if any(strcmp(lossTable.Properties.VariableNames,'SwitchingLosses'))
                power_output=power_output+lossTable.Power(ii)+lossTable.SwitchingLosses(ii);
            else
                power_output=power_output+lossTable.Power(ii);
            end
            remove_indices(end+1)=ii;%#ok<AGROW>
        else
            if any(strcmp(lossTable.Properties.VariableNames,'SwitchingLosses'))
                power_loss=power_loss+lossTable.Power(ii)+lossTable.SwitchingLosses(ii);
            else
                power_loss=power_loss+lossTable.Power(ii);
            end
        end
    end
    if isempty(remove_indices)
        pm_error('physmod:simscape:simscape:internal:powerDissipated:InvalidLoadIdentifier');
    end
    loss_breakdown(remove_indices,:)=[];
    power_input=power_output+power_loss;
    efficiency=power_output/power_input*100;
    sorted_loss_breakdown=sortrows(loss_breakdown,2,'descend');






