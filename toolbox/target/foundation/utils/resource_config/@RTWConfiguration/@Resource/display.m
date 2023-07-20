function display(resource)




    allocations=resource.allocations.find('-class','RTWConfiguration.Allocation');


    disp(sprintf('\n'));
    disp(' --- All Resources --------------------- ');
    disp([sprintf(' |''%s''\n',resource.resources{:})]);
    disp(' --- Allocations ----------------------- ');
    if~isempty(allocations)
        for alloc=allocations
            t=evalc('alloc.host_object');
            t=strrep(t,sprintf('ans =\n'),'');
            t=strrep(t,sprintf('\n'),'');
            values=alloc.value;
            disp([' | ',t,' -> ',sprintf('''%s'' ',values{:})]);
        end
    end
    disp(' ---------------------------------------');
