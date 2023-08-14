function str=ramEntityVerilog(this,inPorts,outPorts)










    if hdlgetparameter('use_verilog_timescale')
        ts_str='`timescale 1 ns / 1 ns';
    else
        ts_str='';
    end
    str=[...
'\n'...
    ,ts_str,'\n'...
    ,'\n'...
    ];


    str=[str...
    ,'module ',this.entityName,'\n'...
    ,'          (\n'...
    ];


    for n=1:length(inPorts)
        str=[str,sprintf('%11s%s','',[inPorts(n).Name,',\n'])];
    end

    for n=1:length(outPorts)
        if n==length(outPorts)
            s1='';
        else
            s1=',';
        end
        str=[str,sprintf('%11s%s%s%s','',outPorts(n).Name,s1,'\n')];
    end

    str=[str...
    ,'          );\n'...
    ,'\n'...
    ,'\n'...
    ];


    for n=1:length(inPorts)

        s1=strrep(inPorts(n).PortType,']','] ');
        str=[str...
        ,sprintf('%2s%-8s%s%s%s%s','','input',s1,inPorts(n).Name,...
        ';',inPorts(n).PortComment)];
    end


    for n=1:length(outPorts)

        s1=strrep(outPorts(n).PortType,']','] ');
        str=[str...
        ,sprintf('%2s%-8s%s%s%s%s','','output',s1,outPorts(n).Name,...
        ';',outPorts(n).PortComment)];
    end


    str=[str...
    ,'\n'...
    ,'\n'...
    ];

