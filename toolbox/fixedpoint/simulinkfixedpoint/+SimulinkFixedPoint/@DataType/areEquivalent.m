function resBool=areEquivalent(dt1,dt2)



    if bothTrueFixPt(dt1,dt2)||bothScaledDouble(dt1,dt2)

        resBool=sameFixPtAttribs(dt1,dt2);
    else
        resBool=strcmp(dt1.DataTypeMode,dt2.DataTypeMode);
    end



    function res=bothTrueFixPt(dt1,dt2)


        res=(SimulinkFixedPoint.DataType.isFixedPointType(dt1)...
        &&...
        SimulinkFixedPoint.DataType.isFixedPointType(dt2));


        function res=bothScaledDouble(dt1,dt2)


            res=(SimulinkFixedPoint.DataType.isScaledDouble(dt1)...
            &&...
            SimulinkFixedPoint.DataType.isScaledDouble(dt2));


            function res=sameFixPtAttribs(dt1,dt2)















                res=(isequal(dt1.SignednessBool,dt2.SignednessBool)&&...
                dt1.WordLength==dt2.WordLength&&...
                dt1.Slope==dt2.Slope&&...
                dt1.Bias==dt2.Bias);
