function callInfo=CallInfo(prototype,entryname,numBoundFcnInputs,types,complexities,neededUplevels,contextFcnCallsMap,needsRand,theWarnings)






    callInfo=struct(...
    'Prototype',prototype,...
    'EntryName',entryname,...
    'NumInputs',numBoundFcnInputs,...
    'Types',types,...
    'Complexities',complexities,...
    'NeededUplevels',neededUplevels,...
    'FcnContextList',contextFcnCallsMap,...
    'NeedsRand',needsRand,...
    'MATLABWarnings',theWarnings);

end
