function h=CreateNewRow(this,currRowH)
    if nargin==1
        h=hdllinkddg.ClockRowSource;
    else
        h=hdllinkddg.ClockRowSource(currRowH);
    end
end
