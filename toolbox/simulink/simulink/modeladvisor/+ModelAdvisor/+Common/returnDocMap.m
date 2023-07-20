function returnDocMap(rule)




    prefix=lower(rule(1:2));
    switch prefix
    case{'ar','na','jm','db','jc','hd'}
        helpview([docroot,'/toolbox/simulink/helptargets.map'],rule);
    case 'hi'
        helpview([docroot,'/toolbox/simulink/helptargets.map'],rule);
    otherwise
        helpview([docroot,'/toolbox/simulink/helptargets.map']);
    end

end