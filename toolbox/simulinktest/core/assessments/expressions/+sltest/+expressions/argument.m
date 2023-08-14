function argumentHandle=argument(name,types)




    import sltest.expressions.*
    argumentHandle=ArgumentHandle.makeMoveFrom(mi.argument(name,types));
end
