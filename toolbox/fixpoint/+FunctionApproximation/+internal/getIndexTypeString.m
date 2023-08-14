function indexTypeString=getIndexTypeString()




    indexFiValue=fi([],numerictype('uint32'));
    indexTypeString=['idxType = coder.const(',indexFiValue.tostring,');'];
end
