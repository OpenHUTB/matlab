function out=getModelHandle(in)



















    if(ischar(in)||isstring(in))
        try

            out=bdroot(in);
        catch

            pathSplits=slreportgen.utils.pathSplit(in);


            out=bdroot(pathSplits(1));
        end


        out=get_param(out,'Handle');

    elseif isa(in,'GLUE2.HierarchyId')
        tlhid=slreportgen.utils.HierarchyService.getTopLevel(in);
        out=slreportgen.utils.getSlSfHandle(tlhid);

    else

        h=slreportgen.utils.getSlSfHandle(in);

        if isa(h,'Stateflow.Object')

            out=get_param(h.Machine.Name,'Handle');
        else

            out=bdroot(h);
        end
    end
end