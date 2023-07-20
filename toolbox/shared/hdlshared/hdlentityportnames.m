function portnames=hdlentityportnames()





    ports=[hdlinportsignals,hdloutportsignals];

    portnames={};
    for n=1:length(ports)
        portnames{end+1}=hdlsignalname(ports(n));
    end



