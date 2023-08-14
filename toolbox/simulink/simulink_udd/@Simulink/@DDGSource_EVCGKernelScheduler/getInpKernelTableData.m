function[tblColHead,tblData]=getInpKernelTableData(this)





    numInports=length(this.DialogData.InportBlockNamesArray);

    inpnameId=this.getColId('blkname');
    inpiterId=this.getColId('inpIter');

    tblColHead{inpnameId}=DAStudio.message('Simulink:dialog:ForEachPortColHead');
    tblColHead{inpiterId}='Neighborhood';

    numTblDataEntries=length(this.DialogData.InportBlockNamesArray);


    tblData=cell(numTblDataEntries,length(tblColHead));

    numData=0;
    if isempty(this.DialogData.StencilTable)
        return;
    end
    oneRow=size(this.DialogData.StencilTable,1)==1;
    inputIterValues=this.DialogData.StencilTable.InputPartition;
    for i=1:numInports
        numData=numData+1;


        col_inpname.Type='edit';
        col_inpname.Alignment=6;
        if numData<10
            prtnumStr=sprintf([num2str(i),'    ']);
        elseif numData<100
            prtnumStr=[num2str(i),'   '];
        else
            prtnumStr=[num2str(i),'  '];
        end
        col_inpname.Value=string([prtnumStr,this.DialogData.InportBlockNamesArray{i}]);
        col_inpname.Enabled=false;
        tblData{numData,inpnameId}=col_inpname;


        if oneRow
            inpIterVal=isequal(inputIterValues,'on');
        else
            inpIterVal=isequal(inputIterValues(i,:),'on');
        end
        col_inpiter.Type='checkbox';
        col_inpiter.Value=inpIterVal;
        col_inpiter.Enabled=true;
        tblData{numData,inpiterId}=col_inpiter;

    end
end
