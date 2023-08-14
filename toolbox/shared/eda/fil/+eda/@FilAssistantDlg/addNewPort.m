function addNewPort(this,name,direction,width,type,toNewTable)



    if(nargin==5)
        toNewTable=false;
    end

    newRow=cell(1,4);

    newRow{1,1}=name;


    newRow{1,4}.Type='combobox';
    switch(lower(direction))
    case{'out','output','buffer'}
        newRow{1,2}.Value=1;
        PortKindEnum=this.BuildInfo.getPortTypes('Out');
    otherwise
        newRow{1,2}.Value=0;
        PortKindEnum=this.BuildInfo.getPortTypes('In');
    end

    newRow{1,2}.Type='combobox';
    newRow{1,2}.Entries=this.BuildInfo.getPortDirections;
    newRow{1,4}.Entries=PortKindEnum;


    if(width>=0)
        newRow{1,3}=sprintf('%d',width);
    else
        newRow{1,3}=' ';
    end

    if(type==-1)
        type=0;
        if(newRow{1,2}.Value==0)
            if(~isempty(regexpi(name,'(^clk$)|(^clock$)|(_clk$)|(_clock$)')))
                type=1;
            elseif(~isempty(regexpi(name,'(^rst$)|(^reset$)|(_rst$)|(_reset$)|(^rstx$)|(^resetx$)|(^rst_x$)|(^reset_x$)|(^rstn$)|(^resetn$)|(^rst_n$)|(^reset_n$)')))
                type=3;
            elseif(~isempty(regexpi(name,'(^en$)|(^enable$)|(_en$)|(_enable$)')))
                type=2;
            end
        end
    end

    newRow{1,4}.Value=type;


    if(toNewTable)
        this.NewPortTableData=[this.NewPortTableData;newRow];
    else
        this.PortTableData=[this.PortTableData;newRow];
    end
