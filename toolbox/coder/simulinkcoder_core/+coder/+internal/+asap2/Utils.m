classdef Utils<handle






    methods(Static,Access=public)

        function retVal=is2DimensionalArray(model,paramName)

            paramWidth=1;
            retVal=false;
            mdlWks=get_param(model,'ModelWorkspace');
            paramInfo=evalin(mdlWks,paramName);
            paramDimensions=paramInfo.Dimensions;
            noOfDimension=numel(paramDimensions);
            matrixDims=zeros(1,noOfDimension);
            for i=1:noOfDimension
                matrixDims(i)=paramInfo.Dimensions(i);
                paramWidth=paramWidth*paramDimensions(i);
            end

            if numel(matrixDims)==2&&paramWidth~=1
                retVal=true;
            end
        end


        function validateProfileAttributes(errorsMap,invaliddatatype)

            compuMethodValidationKeys=keys(errorsMap);
            compuMethodValidationValues=errorsMap.values;
            noOfKeys=length(compuMethodValidationKeys);
            errors=MException.empty;
            for ii=1:noOfKeys
                e=MException(message('coderdictionary:profiles:ValidateCompuMethodName',...
                compuMethodValidationKeys{ii}));
                e=coder.internal.asap2.Utils.addNamesAsCauses(e,compuMethodValidationValues{ii}.ConflictingElements);
                errors(end+1)=e;
            end

            if~isempty(invaliddatatype)
                e=MException(message('coderdictionary:profiles:ValidateBitMaskDataType'));
                e=coder.internal.asap2.Utils.addNamesAsCauses(e,invaliddatatype);
                errors(end+1)=e;
            end

            if~isempty(errors)
                combinedError=MException(message('coderdictionary:profiles:ValidateProfileAttribute'));
                for i=1:length(errors)
                    combinedError=combinedError.addCause(errors(i));
                end
                throw(combinedError);
            end
        end

        function expression=getExpressionForAutoSar(implementation)
            switch rtw.connectivity.CodeInfoUtils.class(implementation)
            case 'StructAccessorVariable'





                expression=implementation.Identifier;
            case 'StructExpression'
                if isa(implementation.BaseRegion,'coder.descriptor.StructAccessorVariable')
                    expression=append(coder.internal.asap2.Utils.getExpressionForAutoSar(implementation.BaseRegion),'.',implementation.ElementIdentifier);
                else
                    expression=implementation.assumeOwnershipAndGetExpression;
                end
            otherwise
                expression=implementation.assumeOwnershipAndGetExpression;
            end
        end




        function exception=addNamesAsCauses(...
            ex,...
            names)

            names=unique(names);
            for i=1:length(names)
                blk=names{i};
                cause=MException(message('Simulink:SLMsgViewer:EXCEPTION_MSG',blk));
                ex=ex.addCause(cause);
            end
            exception=ex;
        end

        function[paramWidth,matrixDims]=getWidthFromDimension(dimensions)



            paramWidth=1;
            if contains(class(dimensions),'mf.zero')
                len=dimensions.Size;
            else
                len=length(dimensions);
            end
            matrixDims=zeros(len,0);
            noOfElements=1;
            for i=1:len
                if len==1
                    matrixIndex=i;
                else

                    if noOfElements<=2
                        matrixIndex=3-i;
                    else
                        matrixIndex=i;
                    end
                end

                paramWidth=paramWidth*dimensions(i);
                matrixDims(i)=dimensions(matrixIndex);
                noOfElements=noOfElements+1;
            end
        end

        function tooltip=getASAP2Tooltip(obj,prop)
            switch prop
            case{'Measurement','Calibration'}
                tooltip=DAStudio.message(['coderdictionary:asap2_properties:','Heading'],prop);
            case 'CalibrationAccess'
                if strcmp(obj.getTabName,DAStudio.message('coderdictionary:mapping:DataViewParameters'))
                    tooltip=DAStudio.message('coderdictionary:asap2_properties:CalAccessCharacteristic');
                else
                    tooltip=DAStudio.message('coderdictionary:asap2_properties:CalAccessMeasurement');
                end
            case 'DisplayIdentifier'
                tooltip=DAStudio.message('coderdictionary:asap2_properties:DisplayIdentifier');
            case 'Format'
                tooltip=DAStudio.message('coderdictionary:asap2_properties:Format');
            case 'CompuMethod'
                tooltip=DAStudio.message('coderdictionary:asap2_properties:CompuMethod');
            case 'BitMask'
                tooltip=DAStudio.message('coderdictionary:asap2_properties:BitMask');
            case 'Export'
                tooltip=DAStudio.message('coderdictionary:asap2_properties:Export');
            otherwise
                tooltip=prop;
            end
        end

        function dataType=getAsamDataType(signalBaseType)
            dataType='';

            if isa(signalBaseType,'coder.descriptor.types.Double')...
                ||isa(signalBaseType,'coder.types.Double')
                dataType='FLOAT64_IEEE';


            elseif isa(signalBaseType,'coder.descriptor.types.Single')...
                ||isa(signalBaseType,'coder.types.Single')
                dataType='FLOAT32_IEEE';


            elseif isa(signalBaseType,'coder.descriptor.types.Half')
                dataType='FLOAT16_IEEE';


            elseif isa(signalBaseType,'coder.descriptor.types.Bool')...
                ||isa(signalBaseType,'coder.types.Bool')
                dataType='UBYTE';


            elseif isa(signalBaseType,'coder.descriptor.types.Integer')...
                ||isa(signalBaseType,'coder.descriptor.types.Fixed')...
                ||isa(signalBaseType,'coder.types.Integer')...
                ||isa(signalBaseType,'coder.types.Fixed')
                if signalBaseType.Signedness
                    dataType='S';
                else
                    dataType='U';
                end
                numBits=signalBaseType.WordLength;
                if isa(signalBaseType,'coder.descriptor.types.Fixed')
                    numBits=coder.internal.asap2.Utils.getNumberBitsForFixedPoint(signalBaseType.WordLength);
                end
                switch numBits
                case 8
                    dataType=[dataType,'BYTE'];
                case 16
                    dataType=[dataType,'WORD'];
                case 32
                    dataType=[dataType,'LONG'];
                case 64
                    dataType='A_UINT64';
                    if signalBaseType.Signedness
                        dataType='A_INT64';
                    end
                otherwise
                    assert(false,printf('%d is not supported according to asam specifications.',signalBaseType.WordLength));
                end
            elseif isa(signalBaseType,'coder.descriptor.types.Enum')
                if~isempty(signalBaseType.StorageType)
                    dataType=coder.internal.asap2.Utils.getAsamDataType(signalBaseType.StorageType);
                else


                    dataType='SLONG';
                end
            end
        end
        function signalVarName=getAutosarVariableinfo(var)
            region=var.Implementation;
            if isa(region,'coder.descriptor.AutosarMemoryExpression')&&isa(region.BaseRegion,'coder.descriptor.Variable')




                signalVarName=region.VariableName;

            elseif isa(region,'coder.descriptor.AutosarSenderReceiver')
                signalVarName=region.DataElement;
            elseif isa(region,'coder.descriptor.AutosarCalibration')
                signalVarName=var.GraphicalName;
            elseif isa(region,'coder.descriptor.AutosarInterRunnable')
                signalVarName=region.VariableName;
            else
                while~isempty(region.BaseRegion)&&isa(region.BaseRegion,'coder.descriptor.StructExpression')
                    region=region.BaseRegion;
                end

                if isa(region.BaseRegion,'coder.descriptor.Variable')
                    region=region.BaseRegion;
                end


                if isa(region,'coder.descriptor.AutosarMemoryExpression')
                    signalVarName=region.VariableName;
                else
                    signalVarName=region.Identifier;
                end
            end
        end

        function[signalVarName,type,className]=getVariableInfo(var)
            type='';
            className='';
            signalVarName='';
            region=var.Implementation;
            if~isempty(region)
                if coder.internal.asap2.Utils.isAutosarRTEElement(region)
                    signalVarName=coder.internal.asap2.Utils.getAutosarVariableinfo(var);
                else
                    signalVarName=coder.internal.asap2.Utils.getExpressionForAutoSar(var.Implementation);
                    if~isempty(signalVarName)
                        region=var.Implementation;
                        if isa(region,'coder.descriptor.ArrayExpression')||isa(region,'coder.descriptor.AutosarMemoryExpression')&&strcmp(region.DataAccessMode,'Persistency')
                            region=region.BaseRegion;
                        end
                        if~isempty(region)&&~isa(var.Implementation.Type,'coder.descriptor.types.Opaque')
                            if isa(region,'coder.descriptor.CustomExpression')
                                type=region.Type;
                            elseif~isa(region,'coder.descriptor.Variable')&&~isa(region,'coder.descriptor.CustomVariable')...
                                &&~isa(region,'coder.descriptor.BasicAccessFunctionExpression')
                                varName=region.ElementIdentifier;
                                while~isempty(region.BaseRegion)&&isa(region.BaseRegion,'coder.descriptor.ArrayExpression')
                                    region=region.BaseRegion.BaseRegion;
                                end
                                while~isempty(region.BaseRegion)&&isa(region.BaseRegion,'coder.descriptor.StructExpression')
                                    region=region.BaseRegion;
                                    varName=[region.ElementIdentifier,'.',varName];%#ok<AGROW>
                                end
                            end
                        end
                        if isa(region,'coder.descriptor.StructExpression')&&~isa(region.BaseRegion,'coder.descriptor.ArrayExpression')
                            if isa(region.BaseRegion,'coder.descriptor.Variable')&&...
                                strcmp(region.BaseRegion.Identifier,'ModelMDLOBJ')
                                signalVarName=varName;
                            elseif isa(region.BaseRegion,'coder.descriptor.StructAccessorVariable')
                                className=region.BaseRegion.Accessor.BaseRegion.Type.Identifier;
                            end
                        end
                        if isa(region,'coder.descriptor.ClassMemberExpression')
                            type=region.Type;

                            className=region.BaseRegion.Type.Identifier;
                        end
                    end
                end
            end
        end
        function numBits=getNumberBitsForFixedPoint(wordlength)

            if wordlength<=8
                numBits=8;
            elseif wordlength<=16
                numBits=16;
            elseif wordlength<=32
                numBits=32;
            elseif wordlength<=64
                numBits=64;
            else
                assert(false,'number of bits should be less than or equal to 64')
            end

        end

        function axisType=determineFixAxisType(breakpoint)






            if isa(breakpoint.FixAxisMetadata,'coder.descriptor.EvenSpacingMetadata')

                if(breakpoint.FixAxisMetadata.IsPow2)

                    axisType='FIX_AXIS_PAR';

                else
                    axisType='FIX_AXIS_PAR_DIST';

                end
            elseif isa(breakpoint.FixAxisMetadata,'coder.descriptor.NonEvenSpacingMetadata')
                axisType='FIX_AXIS_PAR_LIST';
            end
        end


        function refToInput=getReferenceInput(isCpp,obj,classObjectName)





            if isa(obj.Implementation,'coder.descriptor.Variable')&&...
                (isempty(obj.Implementation.VarOwner)||strcmp(obj.Implementation.VarOwner,'SLRT'))






                refToInput='NO_INPUT_QUANTITY';
            else
                subString={'.rtb.','.rtdw.'};
                refToInput=coder.internal.asap2.Utils.getFullyQualifiedVariableName(obj,classObjectName);
                if~isempty(classObjectName)&&...
                    (contains(refToInput,subString)||contains(classObjectName,subString))


                    str=eraseBetween(refToInput,1,'.');
                    refToInput=[classObjectName,str];
                end

            end
        end



        function n=DecimalPointCount(val)
            if val~=0

                exp10=-floor(log10(abs(val)));
                mantissa=val*power(10,exp10);



                n=0;
                while n<15
                    if isNearlyInt(mantissa)
                        break;
                    end
                    n=n+1;
                    mantissa=mantissa*10;
                end



                n=max(0,min(n+exp10,16));

            else
                n=0;
            end


            function r=isNearlyInt(val)
                r=abs(val-round(val))<1e-7;
            end


        end
        function category=getAxisCategory(numOfBreakPoints)
            if numOfBreakPoints==1
                category='CURVE';
            elseif numOfBreakPoints==2

                category='MAP';
            elseif numOfBreakPoints==3

                category='CUBOID';
            else
                category=['CUBE_',num2str(numOfBreakPoints)];
            end
        end


        function pName=getFullyQualifiedVariableName(parameter,classObjectName)
            [pName,~,className]=coder.internal.asap2.Utils.getVariableInfo(parameter);
            if isa(parameter.Implementation,'coder.descriptor.StructExpression')
                baseRegion=parameter.Implementation.BaseRegion;
                while~isempty(baseRegion)&&isa(baseRegion,'coder.descriptor.ArrayExpression')
                    region=region.BaseRegion.BaseRegion;

                end
                if~isempty(classObjectName)||~isempty(className)
                    if isa(baseRegion,'coder.descriptor.StructAccessorVariable')
                        pName=[className,'::',pName];
                    elseif(isa(baseRegion,'coder.descriptor.StructExpression')||...
                        isa(baseRegion,'coder.descriptor.ClassMemberExpression'))&&...
                        strcmp(baseRegion.getBaseVariable.Identifier,'ModelMDLOBJ')
                        if isa(baseRegion,'coder.descriptor.StaticMemberExpression')
                            pName=[className,'::',pName];
                        else
                            pName=[classObjectName,'.',pName];
                        end

                    end
                end
            end
        end
        function dataStoreNames=getDataStoreNames(modelMapping)
            dataStoreNames=[];
            if isprop(modelMapping,'SynthesizedLocalDataStores')
                synthesizedLocalDataStores=modelMapping.SynthesizedLocalDataStores;
                for ii=1:numel(synthesizedLocalDataStores)
                    if~isempty(synthesizedLocalDataStores(ii).getIdentifier)
                        dataStoreNames{end+1}=synthesizedLocalDataStores(ii).getIdentifier;
                    else
                        dataStoreNames{end+1}=synthesizedLocalDataStores(ii).Name;
                    end

                end
            end

        end

        function stereotypeValues=getStereoTypeProperties(modelMapping,sigName)

            stereotypeValues=[];
            dataStores=coder.internal.asap2.Utils.getDataStoreNames(modelMapping);
            if any(ismember(dataStores,sigName))
                stereotypeProperties=modelMapping.getStereoTypePropsForSynthesizedLocalDataStores(sigName);
            else
                stereotypeProperties=modelMapping.getMappedStereoTypeProperties(sigName);
            end

            if~isempty(stereotypeProperties)
                stereotypeValues=jsondecode(stereotypeProperties);
            end
        end
        function[isDualScale,dualScaleProperties]=getDualScaleParamAttributes(modelName,objectName)



            c2=0;
            c5=0;
            ASAP2NumberFormat='%0.6';
            min='';
            max='';
            unit='';
            description='Q = V';
            coeffs=[];
            dualScaleCompuMethodName='';
            isDualScale='';
            dualScaleProperties='';
            [varExists,dataObj]=coder.internal.evalObject(modelName,objectName);
            if varExists&&isa(dataObj,'Simulink.DualScaledParameter')
                isDualScale=true;
                min=rtw.connectivity.CodeInfoUtils.double2str(dataObj.CalibrationMin);
                max=rtw.connectivity.CodeInfoUtils.double2str(dataObj.CalibrationMax);
                dualScaleInfo=coder.internal.getDualScaleParamInfo(modelName,objectName);
                if numel(dualScaleInfo.InternalToCalCompuNumerator)==1
                    c3=dualScaleInfo.InternalToCalCompuNumerator(1);
                else
                    c2=dualScaleInfo.InternalToCalCompuNumerator(1);
                    c3=dualScaleInfo.InternalToCalCompuNumerator(2);
                end
                if numel(dualScaleInfo.InternalToCalCompuDenominator)==1
                    c6=dualScaleInfo.InternalToCalCompuDenominator(1);
                else
                    c5=dualScaleInfo.InternalToCalCompuDenominator(1);
                    c6=dualScaleInfo.InternalToCalCompuDenominator(2);
                end
                if c5==0

                    coeffs=sprintf(['%f %f %f %f %f %f'],0,c6,-c3,0,0,c2);
                else
                    coeffs=sprintf(['%f %f %f %f %f %f'],0,c6,-c3,0,-c5,c2);
                end
                unit=dualScaleInfo.CalibrationUnit;
                dualScaleCompuMethodName=[modelName,'_',dualScaleInfo.NameForCompuMethod,'_',unit];
                if c6==0.0
                    description=sprintf(['"Q = ',ASAP2NumberFormat,'f'],-c3);
                else
                    if c3>0.0
                        description=sprintf(['"Q = ',ASAP2NumberFormat,'f*V + ',ASAP2NumberFormat,'f'],c6,-c3);
                    elseif c3<0.0
                        description=sprintf(['"Q = ',ASAP2NumberFormat,'f*V - ',ASAP2NumberFormat,'f'],c6,c3);
                    else
                        description=sprintf(['"Q = ',ASAP2NumberFormat,'f*V'],c6);
                    end
                end
                if c5==0.0
                    if c2~=1.0
                        description=sprintf([description,'/',ASAP2NumberFormat,'f"'],c2);
                    else
                        description=sprintf([description,'"']);
                    end
                else
                    if c2>0.0
                        description=sprintf([description,'/',ASAP2NumberFormat,'f*V + ',ASAP2NumberFormat,'f"'],-c5,c2);
                    elseif c2<0.0
                        description=sprintf([description,'/',ASAP2NumberFormat,'f*V - ',ASAP2NumberFormat,'f"'],c5,-c2);
                    else
                        description=sprintf([description,'/',ASAP2NumberFormat,'f*V"'],-c5);
                    end
                end

            end
            dualScaleProperties.Min=min;
            dualScaleProperties.Max=max;
            dualScaleProperties.Unit=unit;
            dualScaleProperties.Description=description;
            dualScaleProperties.Coefficient=coeffs;
            dualScaleProperties.CompuMethodName=dualScaleCompuMethodName;
        end
        function longIdentifier=getLongIdentifierParam(modelRepo,paramName,parameter)

            modelParam=modelRepo.getModelParameterByName(paramName);
            longIdentifier='';
            if isa(parameter,'coder.descriptor.LookupTableDataInterface')


                longIdentifier=parameter.Description;
            end
            if isempty(longIdentifier)&&~isempty(modelParam)
                longIdentifier=modelParam.Description;
            end
        end
        function identifier=getUniqueName(str)




            randStr=coder.internal.asap2.Utils.getChecksum(num2str(rand(1),'%.32f'));

            str=[str,randStr];


            str=coder.internal.asap2.Utils.convertToValidChars(str);
            if(length(str)>50)
                cs=coder.internal.asap2.Utils.getChecksum(str);

                cs=cs(1:16);

                identifier=[str(1:50-(1+length(cs))),'_',cs];
            else
                identifier=str;
            end

            identifier=regexprep(identifier,'_+','_');


            identifier=regexprep(identifier,'_$','');
        end
        function cs=getChecksum(in)





            narginchk(1,1);


            cs=Simulink.ModelReference.ProtectedModel.encrypt('SHA2',in,false);
        end
        function varname=convertToValidChars(str)


            varname=str;


            varname=regexprep(varname,'^\s*+([^A-Za-z])','x$1','once');


            varname=regexprep(varname,'\s','_');

            illegalChars=unique(varname(regexp(varname,'[^A-Za-z_.0-9]')));
            for illegalChar=illegalChars
                if illegalChar<=intmax('uint8')
                    width=2;
                else
                    width=4;
                end
                replace=['0x',dec2hex(illegalChar,width)];
                varname=strrep(varname,illegalChar,replace);
            end
        end
        function longIdentifier=getLongIdentifierFromImplementationAndClass(modelRepo,dataInterface,class)
            longIdentifier=[];
            elementName=coder.internal.asap2.Utils.getElementName(dataInterface);
            if strcmp(class,'Params')
                longIdentifier=coder.internal.asap2.Utils.getLongIdentifierParam(modelRepo,elementName,dataInterface);
            else
                longIdentifier=modelRepo.getSignalDescriptionBySignalLabel(elementName);
            end
        end
        function shouldExport=isExportableObject(signalImpl,supportStructureElements,includeAUTOSARElements)






            shouldExport=true;
            if~isempty(signalImpl)
                if~supportStructureElements&&isa(signalImpl,'coder.descriptor.StructExpression')
                    shouldExport=false;
                elseif includeAUTOSARElements&&coder.internal.asap2.Utils.isAutosarRTEElement(signalImpl)
                    shouldExport=true;
                elseif isempty(coder.internal.asap2.Utils.getExpressionForAutoSar(signalImpl))

                    shouldExport=false;
                elseif isa(signalImpl,'coder.descriptor.StructExpression')
                    if isa(signalImpl.BaseRegion,'coder.descriptor.ArrayExpression')



                        shouldExport=false;
                    elseif isa(signalImpl.CodeType,'coder.descriptor.types.Pointer')

                        shouldExport=false;
                    end
                elseif isa(signalImpl,'coder.descriptor.PointerVariable')

                    shouldExport=false;
                elseif isa(signalImpl,'coder.descriptor.CustomExpression')...
                    &&isempty(signalImpl.ExprOwner)
                    shouldExport=false;
                elseif isa(signalImpl,'coder.descriptor.BasicAccessFunctionExpression')
                    shouldExport=false;
                end
            else
                shouldExport=false;
            end
        end
        function eventChannelNumber=getRateID(rate,periodicEventList)


            eventChannelNumber='';
            for ii=1:periodicEventList.NumEvents
                if rate==periodicEventList.Rates(ii)
                    eventChannelNumber=['0x',dec2hex(periodicEventList.TIDs(ii),4)];
                    return;
                end
            end
            assert(false,'The rate does not match any of the rates in the model');
        end
        function isLocalVar=isLocalVariable(varImplementation)





            isLocalVar=false;
            if isa(varImplementation,'coder.descriptor.StructExpression')
                region=varImplementation;
                while~isempty(region.BaseRegion)...
                    &&isa(region.BaseRegion,'coder.descriptor.StructExpression')
                    region=region.BaseRegion;

                end
                if isa(region,'coder.descriptor.StructExpression')&&~isempty(region.BaseRegion)
                    region=region.BaseRegion;
                end
            else
                region=varImplementation;
            end
            if isa(region,'coder.descriptor.Variable')
                if(~isprop(region,'VarOwner')||...
                    isempty(region.VarOwner)||...
                    strcmp(region.VarOwner,'SLRT'))&&...
                    ~strcmp(region.StorageSpecifier,'extern')

                    isLocalVar=true;
                end
            end
        end
        function codeType=getImplementationType(implementation)

            codeType=implementation.CodeType;
        end

        function cmFormat=getCompuMethodFormat(dataTypeName)





            try
                numericTypeOfDataType=numerictype(dataTypeName);
                minval=double(numericTypeOfDataType.lowerbound);
                maxval=double(numericTypeOfDataType.upperbound);
                total_Length=ceil(log10(max(abs(minval),max(maxval))));
                switch numericTypeOfDataType.DataTypeMode
                case 'Fixed-point: slope and bias scaling'

                    layout=max(coder.internal.asap2.Utils.DecimalPointCount(numericTypeOfDataType.Slope),coder.internal.asap2.Utils.DecimalPointCount(numericTypeOfDataType.Bias));
                    total_Length=total_Length+layout;

                case 'Fixed-point: binary point scaling'

                    layout=max(0,min(numericTypeOfDataType.FractionLength,16));
                    total_Length=total_Length+layout;

                otherwise
                    total_Length=0;
                    layout=0;
                end
            catch exp
                total_Length=0;
                layout=0;
            end


            if total_Length==0&&layout==0
                cmFormat='customformat';
            else
                cmFormat=['%',num2str(total_Length),'.',num2str(layout)];
            end

        end
        function shouldExportRTE=isAutosarRTEElement(implementation)

            shouldExportRTE=false;
            if slfeature('RTEElementsInASAP2')==1&&...
                (isa(implementation,'coder.descriptor.AutosarCalibration')...
                ||isa(implementation,'coder.descriptor.AutosarMemoryExpression')...
                ||isa(implementation,'coder.descriptor.AutosarSenderReceiver')...
                ||isa(implementation,'coder.descriptor.AutosarInterRunnable'))
                shouldExportRTE=true;
            end
        end
        function elementName=getElementName(dataInterface)
            implementation=dataInterface.Implementation;
            if isa(implementation,'coder.descriptor.CustomVariable')


                elementName=coder.internal.asap2.Utils.getExpressionForAutoSar(implementation);
            elseif isa(dataInterface.Implementation,'coder.descriptor.Variable')
                elementName=implementation.Identifier;
            elseif isa(dataInterface.Implementation,'coder.descriptor.CustomExpression')
                elementName=implementation.ReadExpression;
            elseif isa(dataInterface.Implementation,'coder.descriptor.BasicAccessFunctionExpression')
                elementName=implementation.Prototype.Name;
            elseif slfeature('RTEElementsInASAP2')==1&&...
                coder.internal.asap2.Utils.isAutosarRTEElement(implementation)
                elementName=coder.internal.asap2.Utils.getVariableInfo(dataInterface);
            else
                elementName=implementation.ElementIdentifier;
            end

        end
        function res=getSTF(model)

            cs=getActiveConfigSet(model);
            while isa(cs,'Simulink.ConfigSetRef')
                if~strcmpi(cs.SourceResolved,'on')
                    res=false;
                    return;
                end
                cs=cs.getRefConfigSet();
            end
            res=get_param(model,'SystemTargetFile');
        end
    end
end





