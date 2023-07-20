function dtMap=getDatatableAttributes()






    dtReaderBlock=struct(...
    'BusType','Topic',...
    'QueryString','Query',...
    'TableType','Topic',...
    'Query','Query');



    dtMap=struct(...
    'DataTableReader',dtReaderBlock);
end
