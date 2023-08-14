function out=getOutputText(type)




    switch type
    case 'cpp'
        id="SimulinkCoderApp:toolstrip:EmbeddedCoderCPlusPlusCodeOutputActionText";
    case 'ert'
        id="SimulinkCoderApp:toolstrip:EmbeddedCoderEmbeddedCCodeOutputActionText";
    case 'grt_cpp'
        id="SimulinkCoderApp:toolstrip:SimulinkCoderGenericCPlusPlusCodeOutputActionText";
    case 'grt'
        id="SimulinkCoderApp:toolstrip:SimulinkCoderGenericCCodeOutputActionText";
    otherwise

        id="";
    end


    if id~=""
        text=message(id).getString;
    else
        text=type;
    end

    out=strrep(text,newline,' ');