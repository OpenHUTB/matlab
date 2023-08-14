function[ports,declarations,instance]=hdlentityports(name)



    if~hdlisfiltercoder
        ports='';
        declarations='';
        instance='';
    else
        isvhdl=hdlgetparameter('isvhdl');
        isverilog=hdlgetparameter('isverilog');
        if isvhdl
            [ports,declarations]=localvhdlentityports;
        elseif isverilog
            [ports,declarations]=localverilogentityports;
        else
            error(message('HDLShared:directemit:UnknownTargetLanguage',...
            hdlgetparameter('target_language')));
        end

        if nargin==1

            if isvhdl
                instance=localvhdlinstance(name);
            else
                instance=localveriloginstance(name);
            end
        else
            instance='';
        end
    end
end


function[ports,declarations]=localvhdlentityports
    ports='   PORT( ';
    declarations='';
    firstone=1;
    portlist=[hdlinportsignals,hdloutportsignals];
    cchar=hdlgetparameter('comment_char');
    for n=1:length(portlist)
        name=hdlsignalname(portlist(n));
        vtype=hdlsignalvtype(portlist(n));
        sltype=hdlsignalsltype(portlist(n));


        if strcmp(sltype,'boolean')
            comment='';
        else
            comment=[cchar,' ',sltype];
        end

        if hdlisinoutportsignal(portlist(n))
            portdir='INOUT';
        elseif hdlisinportsignal(portlist(n))
            portdir='IN ';
        else
            portdir='OUT';
        end

        if firstone
            ports=[ports,...
            sprintf('%-32s:   %s   %s; %s\n',name,portdir,vtype,comment)];%#ok<*AGROW>
            firstone=0;
        else
            ports=[ports,...
            sprintf('         %-32s:   %s   %s; %s\n',name,portdir,vtype,comment)];
        end
    end


    lastsemi=find(ports==';');
    ports(lastsemi(end))=' ';

    ports=[ports,'         );\n'];
end


function[ports,declarations]=localverilogentityports
    ports='\n               (\n                ';
    declarations='';
    portlist=[hdlinportsignals,hdloutportsignals];
    cchar=hdlgetparameter('comment_char');
    for n=1:length(portlist)
        name=hdlsignalname(portlist(n));
        vtype=hdlsignalvtype(portlist(n));
        sltype=hdlsignalsltype(portlist(n));
        size=hdlwordsize(sltype);

        if size==0
            vtype='wire [63:0]';
        end


        if strcmp(sltype,'boolean')
            comment_str='';
        else
            comment_str=[cchar,sltype];
        end

        dtype='';
        lenvtype=length(vtype);
        if strcmp(vtype(1:3),'reg')&&lenvtype>4
            dtype=vtype(4:end);
        elseif strcmp(vtype(1:4),'wire')&&lenvtype>5
            dtype=vtype(5:end);
        end

        if hdlisinportsignal(portlist(n))
            declarations=[declarations,'  input '];
        else
            declarations=[declarations,'  output'];
        end
        declarations=[declarations,...
        sprintf(' %s %s; %s\n',dtype,name,comment_str)];
        ports=[ports,name,',\n                '];
    end


    ports=[ports(1:end-19),'\n                );\n\n'];
    declarations=[declarations,'\n'];
end


function instance=localveriloginstance(name)
    portnames=hdlentityportnames;
    portmap='';
    for n=1:length(portnames)
        portmap=[portmap,...
        '    .',portnames{n},'(',portnames{n},')',...
        ',\n'];
    end
    portmap=portmap(1:end-3);

    instance=['  ',name,' ',hdllegalname([hdlgetparameter('Instance_prefix'),name,...
    hdlgetparameter('Instance_postfix')]),'\n',...
    '    (\n',...
    portmap,...
    '\n    );\n\n'];
end


function instance=localvhdlinstance(name)
    portnames=hdlentityportnames;
    portmap='';
    for n=1:length(portnames)
        portmap=[portmap,...
        sprintf('              %-32s',portnames{n}),...
        ' => ',portnames{n},',\n'];
    end
    portmap=portmap(1:end-3);

    instance=['  ',hdllegalname([hdlgetparameter('Instance_prefix'),name]),': ',name,'\n',...
    '    PORT MAP (\n',...
    portmap,...
    '      );\n\n'];
end


