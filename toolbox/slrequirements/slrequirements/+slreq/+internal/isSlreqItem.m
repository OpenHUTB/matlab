function tf=isSlreqItem(objOrUri)



    switch class(objOrUri)

    case 'slreq.data.Requirement'
        tf=true;





    otherwise
        tf=false;
    end

end
