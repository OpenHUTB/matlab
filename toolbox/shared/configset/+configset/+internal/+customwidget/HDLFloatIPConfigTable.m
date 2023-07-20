function[table,dscr]=HDLFloatIPConfigTable(cs,~)














    dscr='';

    hdlcc=cs.getComponent('HDL Coder');
    cli=hdlcc.getCLI;

    fp=cli.FloatingPointTargetConfiguration;
    table.Size=[0,0];
    table.Data={};
    table.DisableCompletely=false;

    if~isempty(fp)&&~strcmpi(fp.Library,'NativeFloatingPoint')
        tableData=fp.IPConfig.outputInString();
        if~isempty(tableData)

            table.Size=size(tableData);
            nbColumns=table.Size(2);
            if nbColumns==4
                table.ColumnEditable=[false,false,true,true];
            elseif nbColumns==6
                table.ColumnEditable=[false,false,false,false,true,true];
            end
            table.ColumnHeaders=true;
            table.ColumnLabels=tableData.Properties.VariableNames;
            table.Data=table2cell(tableData);
            for r=1:table.Size(1)
                table.ColumnIDs{r}='';
                for c=1:table.Size(2)
                    table.Types{r,c}='edit';
                end
            end
            table.SelectRow=false;
            table.RowHeaders=false;
        end
    end



