



function[total_pin_count,io_data]=calcIOPinsForDut(gp)

    dut_ntwk=gp.getTopNetwork;
    [inMATLAB,~]=hdlismatlabmode();
    try
        if(~inMATLAB)
            dut_fullname=getfullname(dut_ntwk.SimulinkHandle);
        else
            dut_fullname=dut_ntwk.Name;
        end
    catch mEx %#ok<NASGU>
        dut_fullname=dut_ntwk.Name;
    end
    dut_in=dut_ntwk.PirInputPorts;
    dut_out=dut_ntwk.PirOutputPorts;


    in_pins_count=zeros(1,length(dut_in));
    for itr=1:length(dut_in)
        [in_pins_count(itr),io_data.inputs(itr)]=calcIOPinsAtPort(dut_in(itr),itr,dut_fullname,inMATLAB);
    end


    total_in_pin_count=sum(in_pins_count);
    if(total_in_pin_count==0)
        io_data.inputs=[];
    end

    io_data.pin_count=struct('total',[],'inputs',[],'outputs',[]);
    io_data.pin_count.inputs=total_in_pin_count;


    out_pins_count=zeros(1,length(dut_out));
    for itr=1:length(dut_out)
        [out_pins_count(itr),io_data.outputs(itr)]=calcIOPinsAtPort(dut_out(itr),itr,dut_fullname,inMATLAB);
    end

    total_out_pin_count=sum(out_pins_count);
    io_data.pin_count.outputs=total_out_pin_count;
    if(total_out_pin_count==0)
        io_data.outputs=[];
    end

    total_pin_count=sum([total_out_pin_count,total_in_pin_count]);
    io_data.pin_count.total=total_pin_count;
end


function[pins_count,data_info]=calcIOPinsAtPort(port_pin,pin_pos,dut_fullname,inMATLAB)



    data_info=struct('datatype',[],'bitlength',[],'isarray',[],'numberofelements',[],'SimulinkHandle',-1,'Name','','Kind','','SimulinkRate','','isTestpoint',0);
    data_info.SimulinkHandle=port_pin.Signal.SimulinkHandle;

    data_info.Kind=port_pin.Kind;

    data_info.Name=[dut_fullname,'/',port_pin.Name];

    if(~inMATLAB&&strcmpi(port_pin.Kind,'data'))
        try
            data_info.SimulinkHandle=get_param(data_info.Name,'handle');
        catch mEx %#ok<NASGU>
            data_info.SimulinkHandle=-1;
        end
    end



    if port_pin.isTestpoint
        testpointSignalDriverName=port_pin.getTestpointSignalDriver;
        testpointSignalPortIndex=port_pin.getTestpointSignalPortIndex;
        blkH=get_param(testpointSignalDriverName,'handle');
        portH=get_param(blkH,'Porthandles');
        totalOutPorts=length(portH.Outport);
        if totalOutPorts>=testpointSignalPortIndex
            outportH=getfield(portH,'Outport',{testpointSignalPortIndex});
            data_info.SimulinkHandle=outportH;
            data_info.isTestpoint=1;
        end
    end


    leafType=port_pin.Signal.Type.getLeafType;
    if port_pin.Signal.Type.isArrayType&&any([leafType.isWordType,isprop(leafType,'WordLength')])
        pins_count=port_pin.Signal.Type.getLeafType.WordLength*prod(port_pin.Signal.Type.Dimensions);
        data_info.datatype='Fixed';

        data_info.bitlength=leafType.WordLength;
        data_info.isarray=true;
        data_info.numberofelements=prod(port_pin.Signal.Type.Dimensions);
        data_info.SimulinkRate=port_pin.Signal.SimulinkRate;

    elseif isa(port_pin.Signal.Type.BaseType,'hdlcoder.tp_double')

        data_info.datatype='double';
        data_info.bitlength=64;
        data_info.SimulinkRate=port_pin.Signal.SimulinkRate;

        if port_pin.Signal.Type.isArrayType
            data_info.isarray=true;
            data_info.numberofelements=prod(port_pin.Signal.Type.Dimensions);
            pins_count=data_info.bitlength*data_info.numberofelements;

        else
            data_info.isarray=false;
            data_info.numberofelements=1;
            pins_count=64;
        end

    elseif isa(port_pin.Signal.Type.BaseType,'hdlcoder.tp_single')

        data_info.datatype='single';
        data_info.bitlength=32;
        data_info.SimulinkRate=port_pin.Signal.SimulinkRate;

        if port_pin.Signal.Type.isArrayType
            data_info.isarray=true;
            data_info.numberofelements=prod(port_pin.Signal.Type.Dimensions);
            pins_count=data_info.bitlength*data_info.numberofelements;
        else
            data_info.isarray=false;
            data_info.numberofelements=1;
            pins_count=32;
        end

    elseif~port_pin.Signal.Type.isArrayType&&isprop(port_pin.Signal.Type,'WordLength')
        pins_count=port_pin.Signal.Type.WordLength;
        data_info.datatype='Fixed';
        data_info.SimulinkRate=port_pin.Signal.SimulinkRate;

        data_info.bitlength=port_pin.Signal.Type.WordLength;
        data_info.isarray=false;
        data_info.numberofelements=1;
    elseif port_pin.Signal.Type.getLeafType.isEnumType
        data_info.datatype='Enumeration';
        data_info.bitlength=nextpow2(length(port_pin.Signal.Type.getLeafType.EnumValues));
        data_info.SimulinkRate=port_pin.Signal.SimulinkRate;

        if port_pin.Signal.Type.isArrayType
            data_info.isarray=true;
            data_info.numberofelements=prod(port_pin.Signal.Type.Dimensions);
        else
            data_info.isarray=false;
            data_info.numberofelements=1;
        end
        pins_count=data_info.bitlength*data_info.numberofelements;
    elseif port_pin.Signal.Type.getLeafType.isRecordType
        data_info.datatype='Bus';
        flattenedMem=port_pin.Signal.Type.getLeafType.MemberTypesFlattened;
        bitLen=0;
        for i=1:length(flattenedMem)
            if(flattenedMem(i).isArrayType)
                bitLen=bitLen+flattenedMem(i).BaseType.WordLength*prod(flattenedMem(i).Dimensions);
            elseif(flattenedMem(i).isEnumType)
                bitLen=bitLen+nextpow2(length(flattenedMem(i).EnumValues));
            else
                bitLen=bitLen+flattenedMem(i).WordLength;
            end
        end
        data_info.bitlength=bitLen;
        data_info.SimulinkRate=port_pin.Signal.SimulinkRate;

        if port_pin.Signal.Type.isArrayType
            data_info.isarray=true;
            data_info.numberofelements=port_pin.Signal.Type.Dimensions;
        else
            data_info.isarray=false;
            data_info.numberofelements=1;
        end
        pins_count=data_info.bitlength*data_info.numberofelements;
    else
        assert(false,sprintf(DAStudio.message('hdlcoder:report:unknownOrUnexpectedPort',pin_pos,port_pin.Name)));
    end
    port_datatype=port_pin.getSLTypeInfo();
    if~isempty(port_datatype)
        data_info.datatype=port_datatype;
    end
end




