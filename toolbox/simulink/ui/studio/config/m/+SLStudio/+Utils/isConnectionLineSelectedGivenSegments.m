function res=isConnectionLineSelectedGivenSegments(cbinfo,selected)




%#ok<INUSL>
    res=false;
    if~isempty(selected)
        for i=1:length(selected)
            next=selected(i);
            if strcmpi(get_param(next.handle,'LineType'),'connection')
                res=true;
                break
            end
        end
    end
end
