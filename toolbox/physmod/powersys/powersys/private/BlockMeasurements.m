function Multimeter=BlockMeasurements(block,rlc,Multimeter)






    BlockFullName=getfullname(block);
    syslength=length(bdroot(BlockFullName))+2;
    BlockName=strrep(BlockFullName(syslength:end),setstr(10),' ');

    x=size(rlc,1);
    mesurerequest=get_param(block,'Measurements');

    switch mesurerequest

    case 'Branch voltage'

        Multimeter.Yu(end+1,1:2)=rlc(x,1:2);
        Multimeter.V{end+1}=['Ub: ',BlockName];

    case 'Branch voltages'

        Multimeter.Yu(end+1,1:2)=rlc(x-2,1:2);
        Multimeter.Yu(end+1,1:2)=rlc(x-1,1:2);
        Multimeter.Yu(end+1,1:2)=rlc(x,1:2);
        Multimeter.V{end+1}=['Ub1: ',BlockName];
        Multimeter.V{end+1}=['Ub2: ',BlockName];
        Multimeter.V{end+1}=['Ub3: ',BlockName];

    case 'Branch current'

        Multimeter.I{end+1}=['Ib: ',BlockName];
        Multimeter.Yi{end+1,1}=x;

    case 'Branch currents'

        Multimeter.I{end+1}=['Ib1: ',BlockName];
        Multimeter.I{end+1}=['Ib2: ',BlockName];
        Multimeter.I{end+1}=['Ib3: ',BlockName];
        Multimeter.Yi{end+1,1}=x-2;
        Multimeter.Yi{end+1,1}=x-1;
        Multimeter.Yi{end+1,1}=x;

    case 'Branch voltage and current'

        Multimeter.Yu(end+1,1:2)=rlc(x,1:2);
        Multimeter.V{end+1}=['Ub: ',BlockName];
        Multimeter.I{end+1}=['Ib: ',BlockName];
        Multimeter.Yi{end+1,1}=x;

    case 'Branch voltages and currents'

        Multimeter.Yu(end+1,1:2)=rlc(x-2,1:2);
        Multimeter.Yu(end+1,1:2)=rlc(x-1,1:2);
        Multimeter.Yu(end+1,1:2)=rlc(x,1:2);
        Multimeter.Yi{end+1,1}=x-2;
        Multimeter.Yi{end+1,1}=x-1;
        Multimeter.Yi{end+1,1}=x;
        Multimeter.V{end+1}=['Ub1: ',BlockName];
        Multimeter.V{end+1}=['Ub2: ',BlockName];
        Multimeter.V{end+1}=['Ub3: ',BlockName];
        Multimeter.I{end+1}=['Ib1: ',BlockName];
        Multimeter.I{end+1}=['Ib2: ',BlockName];
        Multimeter.I{end+1}=['Ib3: ',BlockName];

    case 'Winding voltages'

        Multimeter.Yu(end+1,1:2)=rlc(x-1,1:2);
        Multimeter.V{end+1}=['Uw1: ',BlockName];
        Multimeter.Yu(end+1,1:2)=rlc(x,1:2);
        Multimeter.V{end+1}=['Uw2: ',BlockName];

    case 'Winding currents'

        Multimeter.I{end+1}=['Iw1: ',BlockName];
        Multimeter.Yi{end+1,1}=x-1;
        Multimeter.I{end+1}=['Iw2: ',BlockName];
        Multimeter.Yi{end+1,1}=x;

    case{'Winding voltages and currents','All voltages and currents','All measurements (V I Flux)'}

        Multimeter.Yu(end+1,1:2)=rlc(x-1,1:2);
        Multimeter.V{end+1}=['Uw1: ',BlockName];
        Multimeter.Yu(end+1,1:2)=rlc(x,1:2);
        Multimeter.V{end+1}=['Uw2: ',BlockName];
        Multimeter.I{end+1}=['Iw1: ',BlockName];
        Multimeter.Yi{end+1,1}=x-1;
        Multimeter.I{end+1}=['Iw2: ',BlockName];
        Multimeter.Yi{end+1,1}=x;

    end