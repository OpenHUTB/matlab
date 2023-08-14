function[repMaxInfo,repMinInfo,resolutionInfo,otherInfo]=collectDataTypeInfo(hDialog,dtTag,dtaItems)












    fixdtString=getFixdtString(hDialog,dtTag,dtaItems);


    repMaxInfo.Name=DAStudio.message('Simulink:dialog:UDTIPRepMaxName');
    repMinInfo.Name=DAStudio.message('Simulink:dialog:UDTIPRepMinName');
    resolutionInfo.Name=DAStudio.message('Simulink:dialog:UDTIPResolutionName');

    unknownStr=DAStudio.message('Simulink:dialog:UDTIPUnknownVal');
    cannotEvalStr=DAStudio.message('Simulink:dialog:UDTIPCannotEvalComm');
    emptyfieldStr=DAStudio.message('Simulink:dialog:UDTIPEmptyFieldComm');
    nonnumStr=DAStudio.message('Simulink:dialog:UDTIPNonNumComm');
    nonscalarStr=DAStudio.message('Simulink:dialog:UDTIPNonScalarComm');
    complexStr=DAStudio.message('Simulink:dialog:UDTIPComplexComm');
    nanStr=DAStudio.message('Simulink:dialog:UDTIPNanComm');
    minusInfStr=DAStudio.message('Simulink:dialog:UDTIPMinusInfComm');
    plusInfStr=DAStudio.message('Simulink:dialog:UDTIPPlusInfComm');

    assumeSignedStr=DAStudio.message('Simulink:dialog:UDTIPAssumeSignedComm');


    evalOk=0;
    evalWarn=1;
    evalSkip=2;


    maxValStrLength=10;
    try
        dt=evalInContext(hDialog,fixdtString);



        if~isa(dt,'Simulink.NumericType')
            return;
        end

        binaryPointString='Fixed-point: binary point scaling';
        slopeBiasModeString='Fixed-point: slope and bias scaling';
        bestPrecModeString='Fixed-point: unspecified scaling';

        isInheritSign=isempty(dt.SignednessBool);
        switch dt.DataTypeMode
        case{binaryPointString,slopeBiasModeString}
            if isInheritSign
                dt.Signedness='Signed';
            end
            [repMin,repMax]=SimulinkFixedPoint.DataType.getFixedPointRepMinMaxRwvInDouble(dt);
            repMaxInfo.Val=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(repMax);
            repMinInfo.Val=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(repMin);
            resolutionInfo.Val=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(dt.Slope);

        case bestPrecModeString



            repMax=Inf;
            repMin=-Inf;
            repMaxInfo.Val=unknownStr;
            repMinInfo.Val=unknownStr;
            resolutionInfo.Val=unknownStr;
        end
        if isInheritSign
            repMaxInfo.Comm=assumeSignedStr;
            repMinInfo.Comm=assumeSignedStr;
        else
            repMaxInfo.Comm='';
            repMinInfo.Comm='';
        end
        resolutionInfo.Comm='';
        repMaxInfo.EvalStatus=evalOk;
        repMinInfo.EvalStatus=evalOk;
        resolutionInfo.EvalStatus=evalOk;
    catch err %#ok 

        repMax=Inf;
        repMin=-Inf;
        repMaxInfo.Val=unknownStr;
        repMinInfo.Val=unknownStr;
        resolutionInfo.Val=unknownStr;
        repMaxInfo.Comm=cannotEvalStr;
        repMinInfo.Comm=cannotEvalStr;
        resolutionInfo.Comm=cannotEvalStr;
        repMaxInfo.EvalStatus=evalWarn;
        repMinInfo.EvalStatus=evalWarn;
        resolutionInfo.EvalStatus=evalWarn;
    end




    [scalingTags,scalingTagTypes]=getScalingTagAndTypes(dtaItems.scalingMaxTag,...
    dtaItems.scalingValueTags,...
    dtaItems.scalingMinTag);
    otherInfo=cell(1,length(scalingTags));

    hDlgSource=hDialog.getSource;


    for i=1:length(scalingTags)
        scalingTag=scalingTags{i};
        prompt=getPromptForWidget(hDialog,scalingTag);
        if isempty(prompt)
            switch scalingTagTypes(i)
            case 0
                prompt=DAStudio.message('Simulink:dialog:UDTIPDesignMinDefaultName');
            case 1
                prompt=DAStudio.message('Simulink:dialog:UDTIPDesignMaxDefaultName');
            case 2
                prompt='';
            otherwise
                assert(true,'Unexpected scalingTagType');
            end
        end
        strBeforeEval=hDialog.getWidgetValue(scalingTag);

        comments='';
        valEvalStatus=evalOk;

        if~hDialog.isEnabled(scalingTag)



            if isa(hDialog.getSource,'Simulink.typeeditor.app.Element')||...
                isa(hDialog.getSource,'Simulink.typeeditor.app.Object')
                if isempty(strBeforeEval)&&isnumeric(strBeforeEval)
                    strBeforeEval='[]';
                end
            end


            strAfterEval=strBeforeEval;
            valEvalStatus=evalSkip;
            if length(strAfterEval)>maxValStrLength
                strAfterEval=[strAfterEval(1:maxValStrLength),'...'];
            end
        else
            try
                value=evalOneScalingField(hDialog,scalingTag,scalingTagTypes(i));

                if isempty(value)
                    strAfterEval='[]';
                else

                    valueMin=min(value);
                    valueMax=max(value);
                    if(valueMin~=valueMax)
                        strAfterEval=[SimulinkFixedPoint.DataType.compactButAccurateNum2Str(valueMin)...
                        ,' .. ',SimulinkFixedPoint.DataType.compactButAccurateNum2Str(valueMax)];
                    else
                        strAfterEval=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(valueMax);
                    end
                    if valueMin<repMin||valueMax>repMax
                        if valueMin<repMin
                            absDiff=repMin-valueMin;
                        else
                            absDiff=valueMax-repMax;
                        end









                        absDiffStr=num2str(absDiff);
                        bitDiffStr=num2str(absDiff/dt.Slope);
                        comments=DAStudio.message('Simulink:dialog:UDTIPOutOfRangeComm',absDiffStr,bitDiffStr);
                        valEvalStatus=evalWarn;
                    end
                end
            catch err
                valEvalStatus=evalWarn;
                strAfterEval=strBeforeEval;
                switch(err.identifier)
                case 'Simulink:dialog:UDTScalingEmptyFieldErr'


                    if isa(hDlgSource,'Stateflow.Object')||isa(hDlgSource,'Simulink.Data')
                        valEvalStatus=evalOk;
                        comments='';
                    else
                        comments=emptyfieldStr;
                    end

                case 'Simulink:dialog:UDTScalingComplexValErr'
                    comments=complexStr;

                case 'Simulink:dialog:UDTScalingNanValErr'
                    comments=nanStr;

                case 'Simulink:dialog:UDTScalingNonNumValErr'
                    comments=nonnumStr;

                case 'Simulink:dialog:UDTScalingNonScalarValErr'
                    comments=nonscalarStr;

                case 'Simulink:dialog:UDTScalingMinusInfValErr'
                    comments=minusInfStr;

                case 'Simulink:dialog:UDTScalingPlusInfValErr'
                    comments=plusInfStr;

                otherwise
                    comments=cannotEvalStr;
                end
                if length(strAfterEval)>maxValStrLength
                    strAfterEval=[strAfterEval(1:maxValStrLength),'...'];
                end
            end
        end


        otherInfo{i}.Name=prompt;
        otherInfo{i}.Val=strAfterEval;
        otherInfo{i}.Comm=comments;
        otherInfo{i}.EvalStatus=valEvalStatus;
    end



