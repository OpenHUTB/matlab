function out=ExtModeTransport(cs,~)




    cs=cs.getConfigSet;

    vals=extmode_transports(cs);
    out={};
    for i=1:length(vals)
        val=vals{i};
        s=[];
        s.val=i-1;
        s.str=i-1;
        s.disp=val;
        out{i}=s;%#ok
    end
    out=cell2mat(out);
