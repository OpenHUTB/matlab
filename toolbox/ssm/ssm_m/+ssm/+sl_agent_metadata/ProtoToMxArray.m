function ret=ProtoToMxArray(data)






    ret=[];
    if isempty(data)||~isa(data,'mathworks.scenario.common.Data');return;end

    dataType=data.whichOneof('type');
    switch dataType
    case 'array_element'
        ret=getArrayData(data.array_element);

    case 'cell_element'
        ret=getCellData(data.cell_element);

    case 'struct_element'
        ret=getStructData(data.struct_element);
    end
end


function ret=getArrayData(data)
    ret=[];
    if isempty(data.elements)||~isa(data.elements,'mathworks.scenario.common.Value');return;end


    arrayType={'number_element','complex_element','string_element',...
    'struct_element','char_element','logical_element','string_element_deprecated'};
    funPtrList={@numberToArray,@complexToArray,@stringToArray,...
    @structArrayToArray,@charToArray,@logicalToArray,@stringToArray,};
    dicFun=containers.Map(arrayType,funPtrList);


    elemType=data.elements.whichOneof('type');
    funPtr=dicFun(elemType);
    elemdata=[data.elements.(elemType)];
    if strcmp(elemType,'string_element')&&isa(elemdata,'char')

        ret=[string({data.elements.(elemType)})];
    else

        ret=funPtr(elemdata);
    end
    ret=reshape(ret,(data.dimensions)');
end


function ret=getCellData(cellElems)
    ret={};
    if isempty(cellElems.elements);return;end

    for idx=numel(cellElems.elements):-1:1
        ret{idx}=ssm.sl_agent_metadata.ProtoToMxArray(cellElems.elements(idx));
    end
    ret=reshape(ret,(cellElems.dimensions)');
end


function ret=getStructData(structElems)
    ret=struct();
    elems=structElems.elements;
    fieldNames=structElems.names;

    if isempty(fieldNames);return;end


    for idx=1:length(fieldNames)
        ret.(fieldNames{idx})=ssm.sl_agent_metadata.ProtoToMxArray(elems(idx));
    end
end


function ret=structArrayToArray(structArray)

    for idx=numel(structArray):-1:1
        ret(idx)=getStructData(structArray(idx));
    end
end


function ret=numberToArray(numArray)

    nType=numArray.whichOneof('type');
    ret=[numArray.(nType)];
    if strcmp(nType,'uint8_element')
        ret=uint8(ret);
    elseif strcmp(nType,'int8_element')
        ret=int8(ret);
    elseif strcmp(nType,'uint16_element')
        ret=uint16(ret);
    elseif strcmp(nType,'int16_element')
        ret=int16(ret);
    end
end


function ret=complexToArray(complexArray)
    vReal=numberToArray([complexArray.real_element]);
    vImag=numberToArray([complexArray.imag_element]);
    ret=complex(vReal,vImag);
end


function ret=logicalToArray(logicalArray)
    ret=logicalArray;
end


function ret=charToArray(charArray)
    ret=char(charArray);
end


function ret=stringToArray(strArray)

    for idx=numel(strArray):-1:1
        ret{idx}=char(strArray(idx).elements');
    end

    ret=string(ret);
end


