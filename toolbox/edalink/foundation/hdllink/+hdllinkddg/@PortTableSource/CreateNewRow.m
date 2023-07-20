function h=CreateNewRow(this,currRowH)
    if nargin==1
        h=hdllinkddg.PortRowSource;
    else
        h=hdllinkddg.PortRowSource(currRowH);
    end
end
