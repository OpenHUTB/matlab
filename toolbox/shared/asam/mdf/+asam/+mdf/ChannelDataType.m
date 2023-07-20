classdef ChannelDataType<double







    enumeration
        Missing(NaN)
        Unspecified(-1)
        IntegerUnsignedLittleEndian(0)
        IntegerUnsignedBigEndian(1)
        IntegerSignedLittleEndian(2)
        IntegerSignedBigEndian(3)
        RealLittleEndian(4)
        RealBigEndian(5)
        StringASCII(6)
        StringUTF8(7)
        StringUTF16LittleEndian(8)
        StringUTF16BigEndian(9)
        ByteArray(10)
        MIMESample(11)
        MIMEStream(12)
        CANOpenDate(13)
        CANOpenTime(14)
        ComplexRealLittleEndian(15)
        ComplexRealBigEndian(16)
    end
end
