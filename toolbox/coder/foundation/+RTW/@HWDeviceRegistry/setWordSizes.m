function setWordSizes(h,ws)





























    h.BitPerChar=ws(1);
    h.BitPerShort=ws(2);
    h.BitPerInt=ws(3);
    h.BitPerLong=ws(4);
    h.WordSize=ws(5);
    if length(ws)>7
        h.BitPerFloat=ws(6);
        h.BitPerDouble=ws(7);
        h.BitPerPointer=ws(8);
    end
    if length(ws)>8
        h.BitPerLongLong=ws(9);

    end
    if length(ws)>9
        h.BitPerSizeT=ws(10);
        h.BitPerPtrDiffT=ws(11);
    end
