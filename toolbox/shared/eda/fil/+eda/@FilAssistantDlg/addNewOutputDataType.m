function addNewOutputDataType(this,name,width,datatype,sign,fraclen,toNewTable)



    if(nargin==5)
        toNewTable=false;
    end

    newRow=cell(1,5);

    newRow{1,1}=name;


    newRow{1,2}=width;


    newRow{1,3}.Type='combobox';
    if strcmp(this.BuildInfo.Tool,'MATLAB System Object')
        switch width
        case '1'
            DataTypeKindEnum={'Fixedpoint','Logical'};
        case{'8','16'}
            DataTypeKindEnum={'Fixedpoint','Integer'};
        case '32'
            DataTypeKindEnum={'Fixedpoint','Integer','Single'};
        case '64'
            DataTypeKindEnum={'Fixedpoint','Integer','Double'};
        otherwise
            DataTypeKindEnum={'Fixedpoint'};
        end
        newRow{1,3}.Entries=DataTypeKindEnum;
        switch datatype
        case 'Logical'
            newRow{1,3}.Value=1;
        case 'Integer'
            newRow{1,3}.Value=1;
        otherwise
            newRow{1,3}.Value=0;
        end

    else
        switch width
        case '1'
            DataTypeKindEnum={'Inherit','Fixedpoint','Boolean'};
        case{'8','16'}
            DataTypeKindEnum={'Inherit','Fixedpoint','Integer'};
        case '32'
            DataTypeKindEnum={'Inherit','Fixedpoint','Integer','Single'};
        case '64'
            DataTypeKindEnum={'Inherit','Fixedpoint','Integer','Double'};
        otherwise
            DataTypeKindEnum={'Inherit','Fixedpoint'};
        end
        newRow{1,3}.Entries=DataTypeKindEnum;
        switch datatype
        case 'Inherit'
            newRow{1,3}.Value=0;
        case 'Boolean'
            newRow{1,3}.Value=2;
        case 'Integer'
            newRow{1,3}.Value=2;
        otherwise
            newRow{1,3}.Value=1;
        end
    end


    switch newRow{1,3}.Entries{newRow{1,3}.Value+1}
    case{'Inherit','Logical','Boolean'}
        newRow{1,4}.Type='edit';
        newRow{1,4}.Value=' ';
        newRow{1,4}.Enabled=false;
    otherwise
        newRow{1,4}.Type='combobox';
        SignKindEnum={'Unsigned','Signed'};
        newRow{1,4}.Entries=SignKindEnum;
        if strcmp(sign,'Unsigned')
            newRow{1,4}.Value=0;
        else
            newRow{1,4}.Value=1;
        end
    end


    switch newRow{1,3}.Entries{newRow{1,3}.Value+1}
    case{'Inherit','Logical','Boolean','Integer'}
        newRow{1,5}.Type='edit';
        newRow{1,5}.Value=' ';
        newRow{1,5}.Enabled=false;
    otherwise
        newRow{1,5}.Type='edit';
        newRow{1,5}.Value=fraclen;
    end


    if(toNewTable)
        this.NewOutputDataTypeTableData=[this.NewOutputDataTypeTableData;newRow];
    else
        this.OutputDataTypeTableData=[this.OutputDataTypeTableData;newRow];
    end
