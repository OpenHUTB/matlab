function onAddNewPort(this,dlg)



    [nRow,~]=size(this.PortTableData);

    if(nRow~=0)
        nrowsel=dlg.getSelectedTableRow('edaPortTable');
        if(nrowsel<0||nrowsel>=nRow)
            nrowsel=nRow-1;
        end
        newRow=this.PortTableData(nrowsel+1,:);

        sigName=newRow{1,1};
        numSuffixStart=regexp(sigName,'(\d*)$');
        if isempty(numSuffixStart)
            sigName=[sigName,'1'];
        else
            numSuffix=eval(sigName(numSuffixStart:end));
            newSuffix=numSuffix+1;
            sigName=[sigName(1:numSuffixStart-1),num2str(newSuffix)];
        end
        newRow{1,1}=sigName;
        this.PortTableData=[this.PortTableData;newRow];
    else
        this.addNewPort('sig1','in',1,0);
    end
    dlg.refresh;

    dlg.selectTableRow('edaPortTable',nRow);
