function result=getScalingModeList(option)




    switch option
    case 'BPt_SB_Best'
        result=getScalingBPt_SB_Best;
    case 'BPt_Best'
        result=getScalingBPt_Best;
    case 'BPt_SB'
        result=getScalingBPt_SB;
    case 'BPt'
        result=getScalingBPt;
    case 'Int'
        result=getScalingInt;
    otherwise
        assert(false,'Unsupported option');
    end





    function result=getScalingBPt_SB_Best()
        result={
'UDTBinaryPointMode'
'UDTSlopeBiasMode'
'UDTBestPrecisionMode'
        };

        function result=getScalingBPt_Best()
            result={
'UDTBinaryPointMode'
'UDTBestPrecisionMode'
            };

            function result=getScalingBPt_SB()
                result={
'UDTBinaryPointMode'
'UDTSlopeBiasMode'
                };

                function result=getScalingBPt()
                    result={
'UDTBinaryPointMode'...
                    };

                    function result=getScalingInt()
                        result={
'UDTIntegerMode'
                        };


