function[infoStruct,h]=lct_pGetFullInfoStructure(h,type)






    if nargin<1
        DAStudio.error('Simulink:tools:LCTErrorFirstFcnArgumentMustBeStruct');
    end

    if numel(h)>1
        DAStudio.error('Simulink:tools:LCTErrorFirstFcnArgumentMustBeScalarStruct');
    end


    if nargin<2
        type='other';
    else
        type=lower(type);
    end

    if legacycode.lct.util.feature('newImpl')
        [infoStruct,h]=legacycode.lct.LCTSpecInfo.extract(h,type);
        return
    end


    if~isa(h,'legacycode.LCT')
        h=legacycode.LCT(h);
    end
    oldInfoStruct=legacycode.LCT.getSpecStruct(false,h);

    infoStruct=legacycode.util.lct_pInitStructure('Info');
    infoStruct.Specs=oldInfoStruct;



    infoStruct=legacycode.util.lct_pParseFcnSpec(infoStruct,'InitializeConditions');
    infoStruct=legacycode.util.lct_pParseFcnSpec(infoStruct,'Start');
    infoStruct=legacycode.util.lct_pParseFcnSpec(infoStruct,'Output');
    infoStruct=legacycode.util.lct_pParseFcnSpec(infoStruct,'Terminate');



    legacycode.util.lct_pValidateInputOutputParameter(infoStruct);


    infoStruct.SampleTime=iTransformSampleTime(infoStruct.Specs.SampleTime);


    infoStruct=iTransformDWorkAsPWork(infoStruct);



    infoStruct.DWorks.NumDWorkForBus=0;
    infoStruct.DWorks.DWorksForBusId=[];
    extraDWork=legacycode.util.lct_pInitStructure('Data');
    extraDWork.pwIdx=[];
    extraDWork.dwIdx=[];
    infoStruct.DWorks.DWorkForBus(1:0)=extraDWork;

    infoStruct.DWorks.NumDWorkFor2DMatrix=0;
    infoStruct.DWorks.DWorkFor2DMatrixId=[];
    extraDWork=legacycode.util.lct_pInitStructure('Data');
    extraDWork.pwIdx=[];
    extraDWork.dwIdx=[];
    infoStruct.DWorks.DWorkFor2DMatrix(1:0)=extraDWork;

    infoStruct.has2DMatrix=false;
    if infoStruct.Specs.Options.convertNDArrayToRowMajor


        infoStruct=iAddDWorkFor2DMatrixMarshalling(infoStruct);
    end

    if strcmp(type,'c')


        infoStruct=legacycode.util.lct_pFillBusInformation(infoStruct);
    end



    infoStruct=iAddDWorkForBusIOMarshalling(infoStruct);



    infoStruct.DWorks.TotalNumDWorks=infoStruct.DWorks.NumDWorks+...
    infoStruct.DWorks.NumDWorkFor2DMatrix+...
    infoStruct.DWorks.NumDWorkForBus+2*int32(infoStruct.DWorks.NumDWorkForBus>0);


    [infoStruct.canUseSFcnCGIRAPI,infoStruct.warningID]=iCanUseSfcnCGIRAPI(infoStruct);



    [hasWrapper,hasBus,hasStruct,hasAlias,hasEnum,hasSLObject]=iNeedSFunctionWrapper(infoStruct);
    infoStruct.hasWrapper=hasWrapper;
    infoStruct.hasBus=hasBus;
    infoStruct.hasStruct=hasStruct;
    infoStruct.hasBusOrStruct=hasBus||hasStruct;
    infoStruct.hasAlias=hasAlias;
    infoStruct.hasEnum=hasEnum;
    infoStruct.hasSLObject=hasSLObject;
    infoStruct.isCPP=strcmp(infoStruct.Specs.Options.language,'C++');

    if strcmp(type,'c')||strcmp(type,'slblock')

        infoStruct.Parameters.ParamAsDimensionId=iGetParamIdUsedByValueAsDimension(infoStruct);
    end

end


function st=iTransformSampleTime(st)

    if ischar(st)||(isstring(st)&&isscalar(st))
        st=char(st);
    else


        if st(1)==-1
            st='inherited';
        else

            if numel(st)==1
                if st(1)==0
                    st(2)=1;
                else
                    st(2)=0;
                end
            end
        end
    end

end


function infoStruct=iTransformDWorkAsPWork(infoStruct)


    infoStruct.DWorks.NumDWorks=0;
    infoStruct.DWorks.NumPWorks=0;

    infoStruct.DWorks.DWorksId=[];
    infoStruct.DWorks.PWorksId=[];

    for ii=1:infoStruct.DWorks.Num

        thisDWork=infoStruct.DWorks.DWork(ii);
        thisDataType=infoStruct.DataTypes.DataType(thisDWork.DataTypeId);
        if strcmp(thisDataType.Name,'void')
            infoStruct.DWorks.NumPWorks=infoStruct.DWorks.NumPWorks+1;
            infoStruct.DWorks.PWorksId=sort([infoStruct.DWorks.PWorksId,ii]);
            infoStruct.DWorks.DWork(ii).pwIdx=infoStruct.DWorks.NumPWorks;
            infoStruct.DWorks.DWork(ii).dwIdx=[];
        else
            infoStruct.DWorks.NumDWorks=infoStruct.DWorks.NumDWorks+1;
            infoStruct.DWorks.DWorksId=sort([infoStruct.DWorks.DWorksId,ii]);
            infoStruct.DWorks.DWork(ii).pwIdx=[];
            infoStruct.DWorks.DWork(ii).dwIdx=infoStruct.DWorks.NumDWorks;
        end
    end

end


function[canUseSFcnCGIRAPI,warningID]=iCanUseSfcnCGIRAPI(infoStruct)

    warningID='';

    if infoStruct.Specs.Options.singleCPPMexFile==false

        canUseSFcnCGIRAPI=false;

    elseif strcmp(infoStruct.Specs.Options.language,'C++')


        canUseSFcnCGIRAPI=false;
        warningID='LCTSFcnCppCodeAPIWarningCppNotSupported';

    else


        for ii=(infoStruct.DataTypes.NumSLBuiltInDataTypes+1):infoStruct.DataTypes.NumDataTypes
            if~isempty(infoStruct.DataTypes.DataType(ii).HeaderFile)



                canUseSFcnCGIRAPI=false;
                warningID='LCTSFcnCppCodeAPIWarningNoSLDataObjectSupport';
                return
            end
        end


        for ii=1:infoStruct.DWorks.Num

            thisDWork=infoStruct.DWorks.DWork(ii);
            if isempty(thisDWork.dwIdx)

                canUseSFcnCGIRAPI=false;
                warningID='LCTSFcnCppCodeAPIWarningVoidWorkNotSupported';
                return
            end
        end


        switch numel(infoStruct.Specs.HeaderFiles)
        case 0


        case 1


            if(infoStruct.Specs.HeaderFiles{1}(1)=='"')||(infoStruct.Specs.HeaderFiles{1}(1)=='<')
                canUseSFcnCGIRAPI=false;
                warningID='LCTSFcnCppCodeAPIWarningEnclosedHeaderfilesNotSupported';
                return
            end

        otherwise
            canUseSFcnCGIRAPI=false;
            warningID='LCTSFcnCppCodeAPIWarningManyHeaderfilesNotSupported';
            return
        end

        canUseSFcnCGIRAPI=true;

    end

end


function[bool,hasBus,hasStruct,hasAlias,hasEnum,hasSLObject]=iNeedSFunctionWrapper(infoStruct)

    DataTypes=infoStruct.DataTypes;
    bool=false;
    hasBus=false;
    hasStruct=false;
    hasAlias=false;
    hasEnum=false;
    hasSLObject=false;

    for ii=(DataTypes.NumSLBuiltInDataTypes+1):DataTypes.NumDataTypes
        if~isempty(DataTypes.DataType(ii).HeaderFile)
            bool=true;
        end
        if DataTypes.DataType(ii).IsBus==1
            hasBus=true;
        end
        if DataTypes.DataType(ii).IsStruct==1
            hasStruct=true;
        end
        if DataTypes.DataType(ii).IsEnum==1
            hasEnum=true;
        end
        if((DataTypes.DataType(ii).Id~=DataTypes.DataType(ii).IdAliasedThruTo)&&...
            (DataTypes.DataType(ii).IdAliasedTo~=-1))
            hasAlias=true;
        end
        hasSLObject=hasSLObject||DataTypes.DataType(ii).HasObject;
    end

end


function infoStruct=iAddDWorkForBusIOMarshalling(infoStruct)

    for ii=1:infoStruct.Inputs.Num
        thisDataType=infoStruct.DataTypes.DataType(infoStruct.Inputs.Input(ii).DataTypeId);
        if thisDataType.IsBus==1||thisDataType.IsStruct==1
            infoStruct.DWorks.NumDWorkForBus=infoStruct.DWorks.NumDWorkForBus+1;
            infoStruct.DWorks.DWorksForBusId(end+1)=infoStruct.DWorks.NumDWorkForBus;
            infoStruct.Inputs.Input(ii).BusInfo.DWorkId=infoStruct.DWorks.NumDWorkForBus;
            theDWork=infoStruct.Inputs.Input(ii);
            theDWork.IsPartOfSpec=false;
            theDWork.pwIdx=[];
            theDWork.dwIdx=[];
            theDWork.BusInfo.Type='Input';
            theDWork.BusInfo.DataId=ii;
            infoStruct.DWorks.DWorkForBus(end+1)=theDWork;
        end
    end

    for ii=1:infoStruct.Outputs.Num
        thisDataType=infoStruct.DataTypes.DataType(infoStruct.Outputs.Output(ii).DataTypeId);
        if thisDataType.IsBus==1||thisDataType.IsStruct==1
            infoStruct.DWorks.NumDWorkForBus=infoStruct.DWorks.NumDWorkForBus+1;
            infoStruct.DWorks.DWorksForBusId(end+1)=infoStruct.DWorks.NumDWorkForBus;
            infoStruct.Outputs.Output(ii).BusInfo.DWorkId=infoStruct.DWorks.NumDWorkForBus;
            theDWork=infoStruct.Outputs.Output(ii);
            theDWork.IsPartOfSpec=false;
            theDWork.pwIdx=[];
            theDWork.dwIdx=[];
            theDWork.BusInfo.Type='Output';
            theDWork.BusInfo.DataId=ii;
            infoStruct.DWorks.DWorkForBus(end+1)=theDWork;
        end
    end

    for ii=1:infoStruct.Parameters.Num
        thisDataType=infoStruct.DataTypes.DataType(infoStruct.Parameters.Parameter(ii).DataTypeId);
        if thisDataType.IsBus==1||thisDataType.IsStruct==1
            infoStruct.DWorks.NumDWorkForBus=infoStruct.DWorks.NumDWorkForBus+1;
            infoStruct.DWorks.DWorksForBusId(end+1)=infoStruct.DWorks.NumDWorkForBus;
            infoStruct.Parameters.Parameter(ii).BusInfo.DWorkId=infoStruct.DWorks.NumDWorkForBus;
            theDWork=infoStruct.Parameters.Parameter(ii);
            theDWork.IsPartOfSpec=false;
            theDWork.pwIdx=[];
            theDWork.dwIdx=[];
            theDWork.BusInfo.Type='Parameter';
            theDWork.BusInfo.DataId=ii;
            infoStruct.DWorks.DWorkForBus(end+1)=theDWork;
        end
    end

    for ii=1:infoStruct.DWorks.Num
        thisDataType=infoStruct.DataTypes.DataType(infoStruct.DWorks.DWork(ii).DataTypeId);
        if thisDataType.IsBus==1||thisDataType.IsStruct==1
            infoStruct.DWorks.NumDWorkForBus=infoStruct.DWorks.NumDWorkForBus+1;
            infoStruct.DWorks.DWorksForBusId(end+1)=infoStruct.DWorks.NumDWorkForBus;
            infoStruct.DWorks.DWork(ii).BusInfo.DWorkId=infoStruct.DWorks.NumDWorkForBus;
            theDWork=infoStruct.DWorks.DWork(ii);
            theDWork.IsPartOfSpec=false;
            theDWork.BusInfo.Type='DWork';
            theDWork.BusInfo.DataId=ii;
            infoStruct.DWorks.DWorkForBus(end+1)=theDWork;
        end
    end

end


function paramId=iGetParamIdUsedByValueAsDimension(infoStruct)



    paramId=[];


    for ii=1:infoStruct.Inputs.Num
        thisData=infoStruct.Inputs.Input(ii);

        for jj=1:length(thisData.Dimensions)

            if thisData.Dimensions(jj)==-1&&thisData.DimsInfo.HasInfo(jj)==1
                if strcmp(thisData.DimsInfo.DimInfo(jj).Type,'Parameter')&&...
                    (thisData.DimsInfo.DimInfo(jj).DimRef==0)

                    paramId=[paramId,thisData.DimsInfo.DimInfo(jj).DataId];%#ok<AGROW>
                end
            end
        end
    end


    for ii=1:infoStruct.Outputs.Num
        thisData=infoStruct.Outputs.Output(ii);

        for jj=1:length(thisData.Dimensions)

            if thisData.Dimensions(jj)==-1&&thisData.DimsInfo.HasInfo(jj)==1
                if strcmp(thisData.DimsInfo.DimInfo(jj).Type,'Parameter')&&...
                    (thisData.DimsInfo.DimInfo(jj).DimRef==0)

                    paramId=[paramId,thisData.DimsInfo.DimInfo(jj).DataId];%#ok<AGROW>
                end
            end
        end
    end


    for ii=1:infoStruct.DWorks.Num
        thisData=infoStruct.DWorks.DWork(ii);

        for jj=1:length(thisData.Dimensions)

            if thisData.Dimensions(jj)==-1&&thisData.DimsInfo.HasInfo(jj)==1
                if strcmp(thisData.DimsInfo.DimInfo(jj).Type,'Parameter')&&...
                    (thisData.DimsInfo.DimInfo(jj).DimRef==0)

                    paramId=[paramId,thisData.DimsInfo.DimInfo(jj).DataId];%#ok<AGROW>
                end
            end
        end
    end

    paramId=unique(paramId);

end


function infoStruct=iAddDWorkFor2DMatrixMarshalling(infoStruct)

    fType={'Input','Output','Parameter'};
    for ii=1:numel(fType)
        for jj=1:infoStruct.([fType{ii},'s']).Num
            thisData=infoStruct.([fType{ii},'s']).(fType{ii})(jj);
            matInfo=legacycode.LCT.get2DMatrixMarshalingInfo(infoStruct,thisData.DataTypeId,thisData.Dimensions);
            if matInfo>0

                infoStruct.DWorks.NumDWorkFor2DMatrix=infoStruct.DWorks.NumDWorkFor2DMatrix+1;
                infoStruct.DWorks.DWorkFor2DMatrixId(end+1)=infoStruct.DWorks.NumDWorkFor2DMatrix;
                theDWork=thisData;
                theDWork.IsPartOfSpec=false;
                theDWork.CMatrix2D.Type=fType{ii};
                theDWork.CMatrix2D.DataId=jj;
                theDWork.CMatrix2D.MatInfo=matInfo;
                theDWork.pwIdx=[];
                theDWork.dwIdx=[];
                infoStruct.DWorks.DWorkFor2DMatrix(end+1)=theDWork;


                infoStruct.([fType{ii},'s']).(fType{ii})(jj).CMatrix2D.DWorkId=infoStruct.DWorks.NumDWorkFor2DMatrix;
                infoStruct.([fType{ii},'s']).(fType{ii})(jj).CMatrix2D.MatInfo=theDWork.CMatrix2D.MatInfo;


                infoStruct.has2DMatrix=true;
            end
        end
    end

end



