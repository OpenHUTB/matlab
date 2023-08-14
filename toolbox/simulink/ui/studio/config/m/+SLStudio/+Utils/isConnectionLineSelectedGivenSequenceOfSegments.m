function res=isConnectionLineSelectedGivenSequenceOfSegments(cbinfo,selected)




%#ok<INUSL>
    res=false;
    for i=1:selected.size
        next=selected.at(i);
        if strcmpi(get_param(next.handle,'LineType'),'connection')
            res=true;
            break
        end
    end
end
