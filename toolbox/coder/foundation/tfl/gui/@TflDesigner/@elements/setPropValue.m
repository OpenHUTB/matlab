function setPropValue(h,propName,propValue)








    if~isempty(propValue)&&isequal(h.getPropValue(propName),propValue)
        return;
    end

    needupdate=false;

    if length(propName)>1&&((strcmp(propName(1:2),'In')||...
        strcmp(propName(1:3),'Out'))&&strcmp(propName(end-3:end),'Type'))
        setConceptualArgValue(h,propName,propValue);
        needupdate=true;
    elseif length(propName)>6&&(strcmp(propName(1:6),'ImplIn')||...
        (strcmp(propName,'ImplReturnType')))
        setImplementationArgValue(h,propName,propValue);
        needupdate=true;
    else
        switch propName

        case 'Priority'
            value=str2double(propValue);

            if isempty(value)||(value>100)||(value<0)

                errorstr=DAStudio.message('RTW:tfldesigner:ErrorInvalidPriority');

                dlghandle=TflDesigner.getdialoghandle;
                if~isempty(dlghandle)
                    dlghandle.setFocus('Tfldesigner_Priority');
                end
                dp=DAStudio.DialogProvider;
                dp.errordlg(errorstr,DAStudio.message('RTW:tfldesigner:ErrorText'),true);
                me=TflDesigner.getexplorer;
                root=me.getRoot;
                root.setproperror=errorstr;
            else
                if~isnan(value)
                    h.object.Priority=value;
                end
            end
            needupdate=true;
        case 'SaturationMode'
            entries=h.getentries('Tfldesigner_SaturationMode');
            if length(propValue)>1
                h.Object.SaturationMode=h.getEnumString(propValue);
            else
                value=str2double(propValue);
                h.object.SaturationMode=h.getEnumString(entries{value+1});
            end
        case 'RoundingMode'
            value=str2num(propValue);%#ok
            if isempty(value)
                value=0;
            end
            entries=h.getentries('Tfldesigner_RoundingMode');
            modes={entries{value+1}};%#ok
            for i=1:length(modes)
                modesCell{i}=h.getEnumString(modes{i});%#ok
            end
            h.object.RoundingModes=modesCell;
        case 'SlopesMustBeTheSame'
            h.object.SlopesMustBeTheSame=logical(str2double(propValue));

        case 'MustHaveZeroNetBias'
            h.object.MustHaveZeroNetBias=logical(str2double(propValue));

        case 'RelativeScalingFactorE'
            h.object.RelativeScalingFactorE=str2double(propValue);

        case 'RelativeScalingFactorF'
            h.object.RelativeScalingFactorF=str2double(propValue);

        case 'NetSlopeAdjustmentFactor'
            h.object.NetSlopeAdjustmentFactor=str2double(propValue);

        case 'NetFixedExponent'
            h.object.NetFixedExponent=str2double(propValue);

        case 'BiasMustBeTheSame'
            h.object.BiasMustBeTheSame=logical(str2double(propValue));

        case{'ImplementationName','Implementation'}


            h.object.Implementation.Name=propValue;
            needupdate=true;
        case 'ImplType'
            h.object.ImplType=h.getEnumString(propValue);

        case 'AcceptExprInput'
            h.object.AcceptExprInput=logical(str2double(propValue));

        case 'SideEffects'
            h.object.SideEffects=logical(str2double(propValue));

        case 'InlineFcn'
            h.object.InlineFcn=logical(str2double(propValue));

        case 'Precise'
            h.object.Precise=logical(str2double(propValue));

        case 'SupportNonFinite'
            entries=h.getentries('Tfldesigner_SupportNonFinite');
            if length(propValue)>1
                h.object.SupportNonFinite=h.getEnumString(propValue);
            else
                value=str2double(propValue);
                h.object.SupportNonFinite=h.getEnumString(entries{value+1});
            end
        case 'ImplementationCallback'
            h.object.ImplCallback=propValue;

        case 'AlgorithmInfo'
            switch(h.object.Key)
            case{'sin','cos','sincos','atan2'}
                entries=h.getentries('Tfldesigner_AlgorithmInfo');
            case 'rSqrt'
                entries=h.getentries('Tfldesigner_RSQRT_AlgorithmInfo');
            case 'fir2d'
                entries=h.getentries('Tfldesigner_FIR2D_AlgorithmInfo');
            case 'ConvCorr1d'
                entries=h.getentries('Tfldesigner_CONVCORR_AlgorithmInfo');
            case 'reciprocal'
                entries=h.getentries('Tfldesigner_RECIPROCAL_AlgorithmInfo');
            otherwise
                entries=[];
            end
            if~isempty(entries)
                value=str2double(propValue);
                h.object.EntryInfo.Algorithm=h.getEnumString(entries{value+1});
            end
        case 'AddMinusAlgorithm'
            if strcmp(h.object.Key,'RTW_OP_ADD')||strcmp(h.object.Key,'RTW_OP_MINUS')
                entries=h.getentries('Tfldesigner_AddMinusAlgorithm');
                value=str2double(propValue);
                h.object.EntryInfo.Algorithm=h.getEnumString(entries{value+1});
            end
        case 'CountDirection'
            entries=h.getentries('Tfldesigner_TIMER_CountDirection');
            if~isempty(entries)
                value=str2double(propValue);
                h.object.EntryInfo.CountDirection=h.getEnumString(entries{value+1});
            end
        case 'TicksPerSecond'
            h.object.EntryInfo.TicksPerSecond=str2double(propValue);
        case 'FIR2D_OutputMode'
            entries=h.getentries('Tfldesigner_FIR2D_OutputMode');
            if~isempty(entries)
                value=str2double(propValue);
                h.object.EntryInfo.OutputMode=h.getEnumString(entries{value+1});
            end
        case 'FIR2D_NumInRows'
            h.object.EntryInfo.NumInRows=str2double(propValue);
        case 'FIR2D_NumInCols'
            h.object.EntryInfo.NumInCols=str2double(propValue);
        case 'FIR2D_NumOutRows'
            h.object.EntryInfo.NumOutRows=str2double(propValue);
        case 'FIR2D_NumOutCols'
            h.object.EntryInfo.NumOutCols=str2double(propValue);
        case 'FIR2D_NumMaskRows'
            h.object.EntryInfo.NumMaskRows=str2double(propValue);
        case 'FIR2D_NumMaskCols'
            h.object.EntryInfo.NumMaskCols=str2double(propValue);
        case 'CONVCORR1D_NumIn1Rows'
            h.object.EntryInfo.NumIn1Rows=str2double(propValue);
        case 'CONVCORR1D_NumIn2Rows'
            h.object.EntryInfo.NumIn2Rows=str2double(propValue);
        case 'LOOKUP_SearchMethod'
            entries=h.getentries('Tfldesigner_LOOKUP_Search');
            if~isempty(entries)
                value=str2double(propValue);
                h.object.EntryInfo.SearchMethod=h.getEnumString(entries{value+1});
            end
        case 'LOOKUP_IntrpMethod'
            entries=h.getentries('Tfldesigner_LOOKUP_Interp');
            if~isempty(entries)
                value=str2double(propValue);
                h.object.EntryInfo.IntrpMethod=h.getEnumString(entries{value+1});
            end
        case 'LOOKUP_ExtrpMethod'
            entries=h.getentries('Tfldesigner_LOOKUP_Extrp');
            if~isempty(entries)
                value=str2double(propValue);
                h.object.EntryInfo.ExtrpMethod=h.getEnumString(entries{value+1});
            end
        case 'EntryTag'
            if isempty(propValue)
                dp=DAStudio.DialogProvider;
                message=DAStudio.message('RTW:tfldesigner:DWorkEntryTabError');
                dp.errordlg(message,DAStudio.message('RTW:tfldesigner:ErrorText'),true);
            else
                h.object.EntryTag=num2str(propValue);
            end
        case{'InterpMethod','ExtrapMethod','IndexSearchMethod',...
            'RemoveProtectionInput','RemoveProtectionIndex','UseOneInputPortForAllInputData',...
            'SupportTunableTableSize','NumberOfTableDimensions',...
            'InputsSelectThisObjectFromTable','UseLastTableValue',...
            'ValidIndexMayReachLast','RndMeth','SaturateOnIntegerOverflow',...
            'UseLastBreakpoint','BeginIndexSearchUsingPreviousIndexResult',...
            'UseRowMajorAlgorithm','AngleUnit'}
            if isprop(h.object,'AlgorithmParams')
                if isprop(h.apSet,propName)
                    propStr={};
                    propValue=strrep(propValue,'{','');
                    propValue=strrep(propValue,'}','');
                    propValue=strrep(propValue,'''','');
                    [value,remain]=strtok(propValue,',');
                    propStr{end+1}=strtrim(value);
                    while~isempty(remain)
                        [value,remain]=strtok(remain(2:end),',');
                        propStr{end+1}=strtrim(value);%#oktogrow
                    end
                    h.apSet.(propName).Value=propStr;
                end
            end
        case 'ArrayLayout'
            entries=h.getentries('Tfldesigner_ArrayLayout');
            if length(propValue)>1
                h.Object.ArrayLayout=h.getEnumString(propValue);
            else
                value=str2double(propValue);
                h.object.ArrayLayout=h.getEnumString(entries{value+1});
            end
            needupdate=true;
        case 'AllowShapeAgnosticMatch'
            h.object.AllowShapeAgnosticMatch=logical(str2double(propValue));
        end
    end

    if needupdate
        h.firepropertychanged;
        h.isValid=false;
        h.parentnode.isDirty=true;
        h.parentnode.firehierarchychanged;
    end
end

function setConceptualArgValue(h,propName,propValue)




    dlghandle=TflDesigner.getdialoghandle;



    if~dlghandle.isDisableDialog

        currentIndex=dlghandle.getWidgetValue('Tfldesigner_ActiveConceptArg');
        endIndex=strfind(propName,'Type')-1;
        names={h.object.ConceptualArgs(:).Name};

        if~isempty(strfind(propName,'Out'))
            index=propName(4:endIndex);
            argIndex=find(strcmp(names,['y',index]),1)-1;
        else
            index=propName(3:endIndex);
            argIndex=find(strcmp(names,['u',index]),1)-1;
        end

        if~isempty(argIndex)&&currentIndex~=argIndex
            dlghandle.setWidgetValue('Tfldesigner_ActiveConceptArg',argIndex);
            h.applyconceptargchanges(dlghandle);
        end

        dlghandle.setWidgetValue('Tfldesigner_DataType',propValue);
        h.applyconceptargchanges(dlghandle);
        dlghandle.apply;

    end
end

function setImplementationArgValue(h,propName,propValue)




    dlghandle=TflDesigner.getdialoghandle;



    if~dlghandle.isDisableDialog
        currentIndex=h.activeimplarg;
        if strcmp(propName,'ImplReturnType')
            inputIndex=0;
        else
            endIndex=strfind(propName,'Type')-1;
            inputIndex=str2double(propName(7:endIndex));
        end

        dtypeentries=h.getentries('Tfldesigner_ImplDatatype');
        dtIndex=find(strcmp(dtypeentries,propValue),1)-1;

        if currentIndex~=inputIndex
            dlghandle.setWidgetValue('Tfldesigner_ImplfuncArglist',inputIndex);
            h.applyimplargchanges(dlghandle);
        end

        dlghandle.setWidgetValue('Tfldesigner_ImplDatatype',dtIndex);
        h.applyimplargchanges(dlghandle);
        dlghandle.apply;

    end
end




