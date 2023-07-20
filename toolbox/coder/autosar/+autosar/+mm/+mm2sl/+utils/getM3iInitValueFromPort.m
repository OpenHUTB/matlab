function m3iInitValue=getM3iInitValueFromPort(m3iPort,m3iDataElements)




    m3iInitValue=[];
    portInfo=autosar.mm.Model.findPortInfo(...
    m3iPort,m3iDataElements,'DataElements');
    if~isempty(portInfo)&&~isempty(portInfo.comSpec)
        if portInfo.comSpec.InitialValue.isvalid()
            m3iInitValue=portInfo.comSpec.InitialValue;
        elseif portInfo.comSpec.InitValue.isvalid()
            m3iInitValue=portInfo.comSpec.InitValue;
        end
    end
end
