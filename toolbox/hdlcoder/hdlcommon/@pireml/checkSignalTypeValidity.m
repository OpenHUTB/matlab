function checkSignalTypeValidity(hSignalType,compName)




    hBaseType=hSignalType;


    if isprop(hBaseType,'Type')
        hBaseType=hBaseType.Type;
    end


    if isprop(hBaseType,'getLeafType')

        hBaseType=hBaseType.getLeafType;
    end


    if isprop(hBaseType,'WordLength')&&hBaseType.WordLength>128


        if isempty(compName)
            m=message('hdlcoder:makehdl:wordlengthOverflow',num2str(hBaseType.WordLength));
        else
            m=message('hdlcoder:makehdl:wordlengthOverflowComp',num2str(hBaseType.WordLength),compName);
        end
        error(m);
    end
end

