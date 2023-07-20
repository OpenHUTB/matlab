function errMsg=checkComponentTreeUp(~,thisParent)





    errMsg='';

    parent=thisParent;
    while~isempty(parent)
        if isa(parent,'rptgen_sl.csl_data_dict_loop')
            return
        else
            parent=parent.up;
        end
    end

    errMsg=getString(message('RptgenSL:csl_data_dictionary:missingAncestor'));




