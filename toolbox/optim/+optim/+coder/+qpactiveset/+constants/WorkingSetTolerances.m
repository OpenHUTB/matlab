function val=WorkingSetTolerances(cname)














%#codegen

    coder.allowpcode('plain');

    switch cname
    case 'Slack0'
        val=double(1e-5);
    otherwise
        assert(false,'qpactiveset_WorkingSetTolerances unexpected input');
    end

end

