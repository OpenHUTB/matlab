
function flag=isInputOrientationMixed(this,hInSignals)%#ok<INUSL> 



    inType1=hInSignals(1).Type;
    inType2=hInSignals(2).Type;


    flag=inType1.isArrayType&&inType2.isArrayType;
    flag=flag&&xor(inType1.isRowVector,inType2.isRowVector)&&...
    any([inType1.isColumnVector,inType2.isColumnVector]);
end
