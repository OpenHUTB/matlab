

classdef Metadata<handle
    properties(Hidden,Access=private)
a2lObj
        MetadataInfo containers.Map
        isA2L(1,1)logical
        useXCPParser(1,1)logical=false;
    end

    methods
        function obj=Metadata(inData)
            obj.MetadataInfo=containers.Map('KeyType','char','ValueType','any');
            if~isempty(inData)&&~isstruct(inData)&&isfile(inData)
                try
                    if obj.useXCPParser
                        obj.a2lObj=xcpA2L(inData);
                    else
                        obj.a2lObj=internal.CodeImporter.getObjFromA2L_File(inData);
                    end
                    obj.isA2L=true;

                    obj.MetadataInfo.remove(keys(obj.MetadataInfo));
                catch ME
                    throw(ME);
                end
            else

                obj.a2lObj=[];
                obj.isA2L=false;

                obj.MetadataInfo.remove(keys(obj.MetadataInfo));

                for vIdx=1:length(inData)
                    name=inData(vIdx).Name;
                    value=inData(vIdx).Value;
                    realValue=inData(vIdx).RealValue;
                    units=inData(vIdx).Units;
                    description=inData(vIdx).Description;
                    fixdtType=inData(vIdx).fixdt;
                    minValue=inData(vIdx).Min;
                    maxValue=inData(vIdx).Max;

                    exists=obj.MetadataInfo.isKey(name);
                    if exists
                        errmsg=MException(message('Simulink:CodeImporter:DuplicateVariableNameInMetadataFile',name));
                        throw(errmsg);
                    else
                        obj.MetadataInfo(name)=polyspace.internal.codeinsight.utils.MetadataInfo(...
                        name,...
                        fixdtType,...
                        value,...
                        realValue,...
                        minValue,...
                        maxValue,...
                        description,...
                        units,...
                        'Signal');
                    end
                end
            end
        end
    end

    methods
        function result=getVariableInfo(obj,varName)
            result=[];
            exists=obj.MetadataInfo.isKey(varName);
            if exists
                result=obj.MetadataInfo(varName);
            else
                if~obj.isA2L
                    return;
                end

                if obj.useXCPParser

                    isMeasurement=obj.a2lObj.MeasurementInfo.isKey(varName);


                    if isMeasurement
                        mObj=obj.a2lObj.MeasurementInfo(varName);

                        name=mObj.Name;
                        description=mObj.LongIdentifier;
                        minValue=mObj.LowerLimit;
                        maxValue=mObj.UpperLimit;
                        if~isempty(mObj.Conversion)


                            units=mObj.Conversion.Unit;
                            [mWordSize,mSign]=obj.findWordSizeAndSign(mObj.LocDataType);
                            fixdtType=obj.computeFixdtType(mWordSize,mSign,mObj.Conversion);
                        else
                            units='';
                            fixdtType='';
                        end


                        obj.MetadataInfo(name)=polyspace.internal.codeinsight.utils.MetadataInfo(...
                        name,...
                        fixdtType,...
                        '',...
                        '',...
                        minValue,...
                        maxValue,...
                        description,...
                        units,...
                        'Signal');
                        result=obj.MetadataInfo(name);
                        return;
                    end

                    isCharacteristic=obj.a2lObj.CharacteristicInfo.isKey(varName);
                    if isCharacteristic
                        cObj=obj.a2lObj.CharacteristicInfo(varName);

                        name=cObj.Name;
                        description=cObj.LongIdentifier;
                        minValue=cObj.LowerLimit;
                        maxValue=cObj.UpperLimit;
                        if~isempty(cObj.Conversion)


                            units=cObj.Conversion.Unit;

                            recLayout=cObj.Deposit;
                            recLayoutItem=recLayout.Records{1};

                            [cWordSize,cSign]=obj.findWordSizeAndSign(recLayoutItem.DataType);
                            fixdtType=obj.computeFixdtType(cWordSize,cSign,cObj.Conversion);
                        else
                            units='';
                            fixdtType='';
                        end


                        obj.MetadataInfo(name)=polyspace.internal.codeinsight.utils.MetadataInfo(...
                        name,...
                        fixdtType,...
                        '',...
                        '',...
                        minValue,...
                        maxValue,...
                        description,...
                        units,...
                        'Parameter');
                        result=obj.MetadataInfo(name);
                        return;
                    end
                else
                    assert(isstruct(obj.a2lObj));

                    mLogicalIdx=strcmp(obj.a2lObj.sig.Names,varName);
                    mCellStruct=obj.a2lObj.sig.Entries(mLogicalIdx);

                    if~isempty(mCellStruct)

                        mStruct=mCellStruct{1};
                        name=mStruct.name;
                        minValue=mStruct.Min;
                        maxValue=mStruct.Max;
                        units='';
                        description='';


                        [mWordSize,mSign]=obj.findWordSizeAndSign(mStruct.DataType);




                        compu_method=mStruct.cm;
                        [slope,bias]=obj.getSlopeAndBias(compu_method);
                        fixdtType=obj.constructFixdtString(num2str(mSign),num2str(mWordSize),slope,bias);


                        obj.MetadataInfo(name)=polyspace.internal.codeinsight.utils.MetadataInfo(...
                        name,...
                        fixdtType,...
                        '',...
                        '',...
                        minValue,...
                        maxValue,...
                        description,...
                        units,...
                        'Signal');
                        result=obj.MetadataInfo(name);
                        return;
                    end



                    cLogicalIdx=strcmp(obj.a2lObj.par.Names,varName);
                    cCellStruct=obj.a2lObj.par.Entries(cLogicalIdx);

                    if~isempty(cCellStruct)

                        cStruct=cCellStruct{1};
                        name=cStruct.name;
                        minValue=cStruct.Min;
                        maxValue=cStruct.Max;
                        units='';
                        description='';


                        record_type=cStruct.RecordType;
                        recLogicalIndex=strcmp(obj.a2lObj.record.Names,record_type);
                        recCellStruct=obj.a2lObj.record.Entries(recLogicalIndex);

                        if~isempty(recCellStruct)
                            recStruct=recCellStruct{1};
                            [mWordSize,mSign]=obj.findWordSizeAndSign(recStruct.DataType);
                        end


                        compu_method=cStruct.cm;
                        [slope,bias]=obj.getSlopeAndBias(compu_method);

                        fixdtType=obj.constructFixdtString(num2str(mSign),num2str(mWordSize),slope,bias);


                        obj.MetadataInfo(name)=polyspace.internal.codeinsight.utils.MetadataInfo(...
                        name,...
                        fixdtType,...
                        '',...
                        '',...
                        minValue,...
                        maxValue,...
                        description,...
                        units,...
                        'Parameter');
                        result=obj.MetadataInfo(name);
                        return;
                    end

                end



                obj.MetadataInfo(varName)=[];
            end
        end

        function result=isempty(obj)
            result=isempty(obj.MetadataInfo)&&isempty(obj.a2lObj);
        end
    end

    methods(Hidden,Access=private)

        function[slope,bias]=getSlopeAndBias(obj,compu_method)
            slope=[];
            bias=[];
            cmLogicalIdx=strcmp(obj.a2lObj.compumethod.Names,compu_method);
            cmCellStruct=obj.a2lObj.compumethod.Entries(cmLogicalIdx);

            if~isempty(cmCellStruct)
                cmStruct=cmCellStruct{1};
                textCell=cmStruct.Text;





                ratIdx=find(strcmp(textCell,'COEFFS'));





                linIdx=find(strcmp(textCell,'COEFFS_LINEAR'));

                if~isempty(ratIdx)
                    a=str2double(textCell{ratIdx+1});
                    b=str2double(textCell{ratIdx+2});
                    c=str2double(textCell{ratIdx+3});
                    d=str2double(textCell{ratIdx+4});
                    e=str2double(textCell{ratIdx+5});
                    f=str2double(textCell{ratIdx+6});

                    if a==0&&d==0&&e==0
                        slope=f/b;
                        bias=-c/f;
                    end
                end

                if~isempty(linIdx)
                    slope=str2double(textCell{linIdx+1});
                    bias=str2double(textCell{linIdx+2});
                end
            end
        end

        function[wordSize,wSign]=findWordSizeAndSign(~,locDataType)
            assert(ischar(locDataType));
            wordSize=[];
            wSign=[];
            switch(locDataType)
            case 'UBYTE'
                wordSize=8;
                wSign=0;
            case 'SBYTE'
                wordSize=8;
                wSign=1;
            case 'UWORD'
                wordSize=16;
                wSign=0;
            case 'SWORD'
                wordSize=16;
                wSign=1;
            case 'ULONG'
                wordSize=32;
                wSign=0;
            case 'SLONG'
                wordSize=32;
                wSign=1;
            case 'A_UINT64'
                wordSize=64;
                wSign=0;
            case 'A_INT64'
                wordSize=64;
                wSign=1;








            end
        end

        function fixdtType=computeFixdtType(obj,wordSize,wSign,conversionObj)
            fixdtType='';
            isRat=isa(conversionObj,'xcp.CompuMethodRational');
            isLin=isa(conversionObj,'xcp.CompuMethodLinear');
            if(~isRat&&~isLin)||isempty(wordSize)||isempty(wSign)
                return
            end

            if isRat





                if conversionObj.a~=0&&conversionObj.d~=0&&conversionObj.e~=0


                    return;
                end

                slope=(conversionObj.f/conversionObj.b);
                bias=-1*(conversionObj.c/conversionObj.b);
            end

            if isLin


                slope=(conversionObj.a);
                bias=(conversionObj.b);
            end
            wordSizeChar=num2str(wordSize);
            wSignChar=num2str(wSign);
            fixdtType=obj.constructFixdtString(wSignChar,wordSizeChar,slope,bias);
        end

        function fixdtStr=constructFixdtString(~,wSignChar,wordSizeChar,slope,bias)
            fixdtStr='';
            if isempty(wSignChar)||isempty(wordSizeChar)||isempty(slope)||isempty(bias)
                return;
            end







            if(bias==0)&&(log(slope)/log(2))==floor(log(slope)/log(2))
                fractionLengthChar=num2str(log(slope)/log(2));
                fixdtStr=['fixdt(',wSignChar,',',wordSizeChar,',',fractionLengthChar,')'];
            else
                slopeChar=num2str(slope);
                biasChar=num2str(bias);
                fixdtStr=['fixdt(',wSignChar,',',wordSizeChar,',',slopeChar,',',biasChar,')'];
            end
        end
    end
end

