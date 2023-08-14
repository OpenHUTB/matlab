function checkObj=getCheckObject(obj,objData)




    blockData=obj.sldvData.ModelObjects(objData.modelObjectIdx);
    switch objData.type

    case 'Array bounds'
        checkObj=Sldv.Validator.CheckValidator.ArrayOutOfBounds(blockData);

    case 'Overflow'
        checkObj=Sldv.Validator.CheckValidator.OverflowCheck(blockData);
    case 'Division by zero'
        checkObj=Sldv.Validator.CheckValidator.DivideByZeroCheck(blockData);
    case 'Inf value'
        checkObj=Sldv.Validator.CheckValidator.Inf(blockData);
    case 'NaN value'
        checkObj=Sldv.Validator.CheckValidator.NaN(blockData);

    case 'Block input range violation'
        checkObj=Sldv.Validator.CheckValidator.BlockInputRangeViolations(blockData);
    case 'Design Range'
        checkObj=Sldv.Validator.CheckValidator.SignalRangeError(blockData);

    case 'Hisl_0002'
        checkObj=Sldv.Validator.CheckValidator.Hisl_0002(blockData);
    case 'Hisl_0003'
        checkObj=Sldv.Validator.CheckValidator.Hisl_0003(blockData);
    case 'Hisl_0004'
        checkObj=Sldv.Validator.CheckValidator.Hisl_0004(blockData);
    case 'Hisl_0028'
        checkObj=Sldv.Validator.CheckValidator.Hisl_0028(blockData);
    otherwise
        checkObj=Sldv.Validator.CheckValidator.ErrorDetectionCheck(blockData);
    end
end
