function result=modelref_RCSCRenamedMsg(csTop,csChild,varargin)













    topMode=csTop.get_param('RCSCRenamedMsg');
    childMode=csChild.get_param('RCSCRenamedMsg');


    result=false;
    if strcmp(topMode,'error')
        if~strcmp(childMode,'error')
            result=true;
        end
    end
end
