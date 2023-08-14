function result=colorHex2Float(hex)
    rawHex=extractAfter(hex,'#');
    c1Float=hex2dec([rawHex(1),rawHex(2)])/255;
    c2Float=hex2dec([rawHex(3),rawHex(4)])/255;
    c3Float=hex2dec([rawHex(5),rawHex(6)])/255;
    result=sprintf('[%f %f %f]',c1Float,c2Float,c3Float);
end
