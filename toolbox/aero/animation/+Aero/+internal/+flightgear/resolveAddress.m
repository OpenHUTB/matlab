function addr=resolveAddress(addr)




    if any(addr==["127.0.0.1","::1"])
        addr="localhost";
    end
end
