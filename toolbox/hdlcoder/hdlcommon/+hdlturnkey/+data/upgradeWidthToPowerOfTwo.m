function newWidth=upgradeWidthToPowerOfTwo(oldWidth)





    num_bytes=2^ceil(log2(ceil(oldWidth/8)));
    newWidth=num_bytes*8;




    if(newWidth<32)
        newWidth=32;
    end
end