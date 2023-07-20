function ret=MxArrayToProto(data)








    ret=mathworks.scenario.common.Data;


    if iscell(data)
        ret.cell_element=getCell(data);


    elseif isstruct(data)
        if numel(data)==1
            vStruct=ssm.sl_agent_metadata.internal.MxArrayToProtoFactory.getStructElement(data);
            ret.struct_element=vStruct;
        else

            ret.array_element=structToArray(data);
        end


    elseif isnumeric(data)
        ret.array_element=numberToArray(data);


    elseif ischar(data)
        ret.array_element=ssm.sl_agent_metadata.internal.MxArrayToProtoFactory.getArrayObject(data);


    elseif isstring(data)
        ret.array_element=stringToArray(data);


    elseif islogical(data)
        ret.array_element=ssm.sl_agent_metadata.internal.MxArrayToProtoFactory.getArrayObject(data);
    end
end


function vArray=stringToArray(data)
    vArray=mathworks.scenario.common.Array;
    vArray.dimensions=uint64(size(data));

    for idx=numel(data):-1:1
        vValue(idx)=mathworks.scenario.common.Value;
        vValue(idx).string_element=string(data(idx));
    end
    vArray.elements=vValue;
end

function vArray=numberToArray(data)
    vArray=mathworks.scenario.common.Array;
    vArray.dimensions=uint64(size(data));

    if isempty(data);return;end

    for idx=numel(data):-1:1
        vValue(idx)=mathworks.scenario.common.Value;
        if isreal(data)

            vNumber=ssm.sl_agent_metadata.internal.MxArrayToProtoFactory.getNumberObject(data(idx));
            vValue(idx).number_element=vNumber;
        else


            vComplex=mathworks.scenario.common.Complex;
            rNumber=ssm.sl_agent_metadata.internal.MxArrayToProtoFactory.getNumberObject(real(data(idx)));
            iNumber=ssm.sl_agent_metadata.internal.MxArrayToProtoFactory.getNumberObject(imag(data(idx)));

            vComplex.real_element=rNumber;
            vComplex.imag_element=iNumber;

            vValue(idx).complex_element=vComplex;
        end
    end
    vArray.elements=vValue;
end

function vArray=structToArray(data)


    vArray=mathworks.scenario.common.Array;
    vArray.dimensions=uint64(size(data));
    for idx=numel(data):-1:1
        vValue(idx)=mathworks.scenario.common.Value;

        vStruct=ssm.sl_agent_metadata.internal.MxArrayToProtoFactory.getStructElement(data(idx));
        vValue(idx).struct_element=vStruct;
    end
    vArray.elements=vValue;
end

function vCell=getCell(data)
    vCell=mathworks.scenario.common.Cell;
    vCell.dimensions=uint64(size(data));

    if isempty(data);return;end


    for idx=numel(data):-1:1
        buf(idx)=ssm.sl_agent_metadata.MxArrayToProto(data{idx});
    end

    vCell.elements=buf;
end


