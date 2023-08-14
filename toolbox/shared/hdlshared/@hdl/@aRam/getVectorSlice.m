function[upperv,lowerv]=getVectorSlice(this,vwidth)






    idx_u={num2str(vwidth*2-1),num2str(vwidth)};
    idx_l={num2str(vwidth-1),'0'};

    if this.isVhdl
        s={'(',' DOWNTO ',')'};
    else
        s={'[',':',']'};
    end

    if vwidth==1
        upperv=[s{1},'1',s{3}];
        lowerv=[s{1},'0',s{3}];
    else
        upperv=[s{1},idx_u{1},s{2},idx_u{2},s{3}];
        lowerv=[s{1},idx_l{1},s{2},idx_l{2},s{3}];
    end




