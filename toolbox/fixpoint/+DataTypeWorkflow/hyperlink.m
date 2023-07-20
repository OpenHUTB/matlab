function hyperlink(obj)






    try



        objClass=class(obj);
        switch(objClass)
        case 'DataTypeWorkflow.ProposalSettings'
            showTolerances(obj);
        end

    catch errDiag %#ok<NASGU>


    end
end