function result=getSignModeList(option)




    switch option
    case 'SignUnsign'
        result=getSignedUnsignedModes;
    case 'SignOnly'
        result=getSignedOnlyModes;
    otherwise
        assert(false,'Unsupported option');
    end





    function result=getSignedUnsignedModes()
        result={
'UDTSignedSign'
'UDTUnsignedSign'
        };

        function result=getSignedOnlyModes()
            result={
'UDTSignedSign'
            };


