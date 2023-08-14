function str=ramEntityVhdl(this,inPorts,outPorts)










    str=[...
'LIBRARY IEEE;\n'...
    ,'USE IEEE.std_logic_1164.ALL;\n'...
    ,'USE IEEE.numeric_std.ALL;\n'...
    ,'\n'...
    ];


    str=[str...
    ,'ENTITY ',this.entityName,' is\n'...
    ];


    for n=1:length(inPorts)

        if n==1
            s1='PORT( ';
        else
            s1='';
        end

        str=[str...
        ,sprintf('%8s%-32s%-10s%s%s%s',s1,inPorts(n).Name,':   IN',...
        inPorts(n).PortType,';',inPorts(n).PortComment)];
    end


    for n=1:length(outPorts)

        if n==length(outPorts)
            s1='';
        else
            s1=';';
        end
        str=[str...
        ,sprintf('%8s%-32s%-10s%s%s%s','',outPorts(n).Name,':   OUT',...
        outPorts(n).PortType,s1,outPorts(n).PortComment)];
    end


    str=[str...
    ,'        );\n'...
    ,'END ',this.entityName,';\n'...
    ,'\n'...
    ,'\n'...
    ];

