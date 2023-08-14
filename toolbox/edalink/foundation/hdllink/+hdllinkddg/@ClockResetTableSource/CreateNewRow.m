function h=CreateNewRow(this,currRowH)
    if nargin==1
        h=hdllinkddg.ClockResetRowSource;
    else
        h=hdllinkddg.ClockResetRowSource(currRowH);
    end
end
