function h=CreateNewRow(this,currRowH)
    if nargin==1
        h=hdllinkddg.PortExtendedRowSource;
    else
        h=hdllinkddg.PortExtendedRowSource(currRowH);
    end
end
