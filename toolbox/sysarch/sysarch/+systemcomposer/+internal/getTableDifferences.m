function[addedRows,modifiedRows,deletedRows,addedColumns,deletedColumns]=getTableDifferences(reference_Table,updated_Table,uniqueID)








    if(all(ismember(updated_Table.Properties.VariableNames,reference_Table.Properties.VariableNames)))
        commonColumnNames=updated_Table.Properties.VariableNames;
    else

        addedColumns=updated_Table(~ismember(updated_Table.Properties.VariableNames,reference_Table.Properties.VariableNames));
        deletedColumns=reference_Table(~ismember(reference_Table.Properties.VariableNames,updated_Table.Properties.VariableNames));
        commonColumnNames=intersect(table1.Properties.VariableNames,table2.Properties.VariableNames);
    end


    temp_component_Id='';
    temp_component_Parameter='';
    temp_component_Value='';
    temp_component_Old_Value='';

    if(~isempty(reference_Table)&&~isempty(updated_Table))



        addedRows=updated_Table(~ismember(updated_Table.(uniqueID),reference_Table.(uniqueID)),:);



        deletedRows=reference_Table(~ismember(reference_Table.(uniqueID),updated_Table.(uniqueID)),:);


        modifiedRows={};
        Ref_Comp_List=reference_Table.(uniqueID);
        New_Comp_List=updated_Table.(uniqueID);

        common_nodes=intersect(New_Comp_List,Ref_Comp_List);

        for index=1:length(common_nodes)


            for colItr=1:numel(commonColumnNames)
                if(~strcmp(table2array(reference_Table(ismember(reference_Table.(uniqueID),common_nodes{index}),commonColumnNames(colItr))),...
                    table2array(updated_Table(ismember(updated_Table.(uniqueID),common_nodes{index}),commonColumnNames(colItr)))))

                    if isempty(temp_component_Id)

                        temp_component_Id=common_nodes{index};
                        temp_component_Parameter=commonColumnNames(colItr);
                        temp_component_Value=table2array(updated_Table(ismember(updated_Table.(uniqueID),common_nodes{index}),commonColumnNames(colItr)));
                        temp_component_Old_Value=table2array(reference_Table(ismember(reference_Table.(uniqueID),common_nodes{index}),commonColumnNames(colItr)));

                    else

                        temp_component_Id=[temp_component_Id,common_nodes(index)];%#ok<*AGROW>
                        temp_component_Parameter=[temp_component_Parameter,commonColumnNames(colItr)];
                        temp_component_Value=[temp_component_Value,table2array(updated_Table(ismember(updated_Table.(uniqueID),common_nodes{index}),commonColumnNames(colItr)))];
                        temp_component_Old_Value=[temp_component_Old_Value,table2array(reference_Table(ismember(reference_Table.(uniqueID),common_nodes{index}),commonColumnNames(colItr)))];
                    end
                end

            end
        end

        if(~isempty(temp_component_Id))
            modifiedRows=table(temp_component_Id',temp_component_Parameter',temp_component_Value',temp_component_Old_Value');
            modifiedRows.Properties.VariableNames={uniqueID,'ModifiedParameter','UpdatedValue','OldValue'};
        end

    elseif(~isempty(reference_Table))
        addedRows=updated_Table(:,:);
        modifiedRows={};
        deletedRows={};
    else
        addedRows={};
        deletedRows=reference_Table(:,:);
        modifiedRows={};
    end
end





