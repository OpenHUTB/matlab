function addRow(this,rowInfo)




    if(isempty(this.ColTitles))
        DAStudio.error('Simulink:tools:NoColumnTitles');
    else
        curNumCols=size(this.ColTitles,2);
        newNumCols=size(rowInfo,2);
        if(curNumCols~=newNumCols)
            DAStudio.error('Simulink:tools:RowColumnMismatch',num2str(curNumCols));
        end
    end
    if(isempty(this.TableInfo))

        this.TableInfo=rowInfo;
    else

        this.TableInfo=[this.TableInfo;rowInfo];
    end
