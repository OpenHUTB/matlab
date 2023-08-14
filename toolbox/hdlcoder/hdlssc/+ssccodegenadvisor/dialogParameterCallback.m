function dialogParameterCallback(mdladvObj,hDlg,varargin)





    hValue=varargin{1};
    hTag=varargin{2};





    if numel(varargin)>2
        validationToleranceTag=varargin{3};





        hDlg.setEnabled(validationToleranceTag,hValue);
    end







    sscCodeGenWorkflowObjCheck=mdladvObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
    sscCodeGenWorkflowObj=sscCodeGenWorkflowObjCheck.ResultData;

    switch hTag
    case 'com.mathworks.hdlssc.ssccodegenadvisor.precisionTag'

        sscCodeGenWorkflowObj.precisionVal=hValue;
        switch hValue
        case 0
            hdldatatype='Single';
            newTolVal=sscCodeGenWorkflowObj.ValidationToleranceSingle;
        case 1
            hdldatatype='Double';
            newTolVal=sscCodeGenWorkflowObj.ValidationToleranceDouble;
        case 2
            hdldatatype='MixedDoubleSingle';
            newTolVal=sscCodeGenWorkflowObj.ValidationToleranceSingle;
        end
        if isempty(sscCodeGenWorkflowObj.ValidationToleranceUser)
            hDlg.setWidgetValue('com.mathworks.hdlssc.ssccodegenadvisor.validationToleranceTag',...
            num2str(newTolVal));
            sscCodeGenWorkflowObj.ValidationTolerance=newTolVal;
        end



        sscCodeGenWorkflowObj.setHDLDataType(hdldatatype);
    case 'com.mathworks.hdlssc.ssccodegenadvisor.generateValidationLogicTag'


        sscCodeGenWorkflowObj.GenerateValidation=hValue;

    case 'com.mathworks.hdlssc.ssccodegenadvisor.validationToleranceTag'
        ValTol=str2double(hValue);

        if~isfinite(ValTol)||~isreal(ValTol)||ValTol<=0
            hDlg.setWidgetValue(hTag,num2str(sscCodeGenWorkflowObj.ValidationTolerance));
            error('hdlcoder:hdlssc:InvalidValTol',DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor:InvalidValidationTolerance'));
        end

        sscCodeGenWorkflowObj.ValidationTolerance=ValTol;
        sscCodeGenWorkflowObj.ValidationToleranceUser=ValTol;


    case 'com.mathworks.hdlssc.ssccodegenadvisor.numSolverIterationsTag'

        numIter=str2double(hValue);

        if~isfinite(numIter)||~isreal(numIter)||numIter<1||floor(numIter)~=numIter
            hDlg.setWidgetValue(hTag,num2str(sscCodeGenWorkflowObj.NumberOfSolverIterations));
            error('hdlcoder:hdlssc:InvalidSolverIter',DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor:InvalidSolverIterations'));
        end

        sscCodeGenWorkflowObj.NumberOfSolverIterations=numIter;


    case 'com.mathworks.hdlssc.ssccodegenadvisor.ModelOrderReductionValLogicTag'
        sscCodeGenWorkflowObj.modelOrderReductionValLogic=hValue;


    case 'com.mathworks.hdlssc.ssccodegenadvisor.ModelOrderReductionValTolTag'
        ValTol=str2double(hValue);

        if~isfinite(ValTol)||~isreal(ValTol)||ValTol<0
            hDlg.setWidgetValue(hTag,num2str(sscCodeGenWorkflowObj.modelOrderReductionValTol));
            error('hdlcoder:hdlssc:InvalidOrderValTol',DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor:InvalidValidationTolerance'));
        end

        sscCodeGenWorkflowObj.modelOrderReductionValTol=ValTol;
    case 'com.mathworks.hdlssc.ssccodegenadvisor.ramMapTag'

        switch hValue
        case 0
            sscCodeGenWorkflowObj.UseRAM='Auto';

        case 1
            sscCodeGenWorkflowObj.UseRAM='On';
        case 2
            sscCodeGenWorkflowObj.UseRAM='Off';

        end


    end

end


