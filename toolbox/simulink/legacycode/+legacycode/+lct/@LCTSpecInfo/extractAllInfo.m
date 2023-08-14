function extractAllInfo(this,type)






    this.reset(this.Specs);


    if isempty(this.Specs)
        return
    end


    this.forEachFunction(@(o,n,f)parseFun(n));

    function parseFun(funKind)

        specStr=this.Specs.([funKind,'FcnSpec']);

        function currFun=loc_parseCurrentFun(specStr)
            currFun=legacycode.lct.spec.Function(specStr);
            if currFun.IsSpecified

                currFun.forEachArg(@(f,a)this.linkData(f,a));


                this.validateFun(currFun,funKind);
            end
        end

        if iscell(specStr)
            this.Fcns.(funKind)=cell(1,numel(specStr));
            for idx=1:numel(specStr)

                this.Fcns.(funKind){idx}=loc_parseCurrentFun(specStr{idx});
            end
        else
            this.Fcns.(funKind)=loc_parseCurrentFun(specStr);
        end
    end



    this.useInt64=this.DataTypes.UseInt64;



    usingGlobalIO=~isempty(this.Specs.GlobalVarSpec)||~isempty(this.Specs.GetSetSpec);
    if usingGlobalIO
        if~isfield(this.Specs.Options,'stubSimBehavior')||~this.Specs.Options.stubSimBehavior
            error(message('Simulink:tools:LCTGlobalIORequireStubSimBehavior'));
        end
        if this.Specs.Options.singleCPPMexFile
            error(message('Simulink:tools:LCTGlobalIODoesntSupportSingleCPPMexFile'));
        end
        if this.Specs.Options.supportsMultipleExecInstances
            error(message('Simulink:tools:LCTGlobalIODoesntSupportMultipleExecInstances'));
        end
        if isfield(this.Specs.Options,'convert2DMatrixToRowMajor')&&this.Specs.Options.convert2DMatrixToRowMajor
            error(message('Simulink:tools:LCTGlobalIODoesntSupportConvert2DMatrixToRowMajor'));
        elseif isfield(this.Specs.Options,'convertNDArrayToRowMajor')&&this.Specs.Options.convertNDArrayToRowMajor
            error(message('Simulink:tools:LCTGlobalIODoesntSupportConvertNDArrayToRowMajor'));
        end
    end


    this.GlobalIO=legacycode.lct.spec.LCTGlobalIO(this.Specs.GlobalVarSpec,this.Specs.GetSetSpec);



    for cField={'Inputs','Outputs','DataStores'}
        for kData=1:numel(this.GlobalIO.(cField{:}))
            this.linkData('',this.GlobalIO.(cField{:})(kData).VarSpec);
        end
    end

    for kData=1:numel(this.GlobalIO.Parameters)
        this.linkData('',this.GlobalIO.Parameters(kData).VarSpec,'WorkspaceName',this.GlobalIO.Parameters(kData).WorkspaceName);
    end


    iAddDynamicArrayInformation(this);



    this.validate();


    this.SampleTime=iTransformSampleTime(this.Specs.SampleTime);


    iTransformDWorkAsPWork(this);

    this.hasRowMajorNDArray=false;
    if this.Specs.Options.convertNDArrayToRowMajor


        iAddDWorksForNDArrayMarshaling(this);
    end

    if strcmp(type,'c')


        this.extractBusInformation();
        this.BusInfoExtracted=true;


        iAddDynamicSizeInformation(this);
    end



    iAddDWorksForBusIOMarshaling(this);


    [this.canUseSFunCgAPI,this.sfunCgWarningID]=iCanUseSfcnCGIRAPI(this);



    iExtractWrapperFlags(this);
    this.isCPP=strcmp(this.Specs.Options.language,'C++');

    if strcmp(type,'c')||strcmp(type,'slblock')

        this.ParamAsDimensionId=iGetParamIdUsedByValueAsDimension(this);
    end

    this.InfoExtracted=true;

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




function iTransformDWorkAsPWork(this)

    this.DWorks.forEachData(@(s,id,d)transform(d));

    function transform(dWork)
        dataType=this.DataTypes.Items(dWork.DataTypeId);
        if strcmp(dataType.Name,'void')

            this.DWorksInfo.NumPWorks=this.DWorksInfo.NumPWorks+1;
            this.DWorksInfo.PWorksId=sort([this.DWorksInfo.PWorksId,dWork.Id]);
            dWork.pwIdx=this.DWorksInfo.NumPWorks;
        else

            this.DWorksInfo.NumDWorks=this.DWorksInfo.NumDWorks+1;
            this.DWorksInfo.DWorksId=sort([this.DWorksInfo.DWorksId,dWork.Id]);
            dWork.dwIdx=this.DWorksInfo.NumDWorks;
        end
    end
end




function[canUseSFunCgAPI,sfunCgWarningID]=iCanUseSfcnCGIRAPI(this)

    sfunCgWarningID='';

    if this.Specs.Options.singleCPPMexFile==false

        canUseSFunCgAPI=false;

    elseif strcmpi(this.Specs.Options.language,'C++')


        canUseSFunCgAPI=false;
        sfunCgWarningID='LCTSFcnCppCodeAPIWarningCppNotSupported';

    else


        for ii=(this.DataTypes.NumSLBuiltInDataTypes+1):this.DataTypes.Numel
            if~isempty(this.DataTypes.Items(ii).HeaderFile)



                canUseSFunCgAPI=false;
                sfunCgWarningID='LCTSFcnCppCodeAPIWarningNoSLDataObjectSupport';
                return
            end
        end


        for ii=this.DWorks.Ids
            if isempty(this.DWorks.Items(ii).dwIdx)

                canUseSFunCgAPI=false;
                sfunCgWarningID='LCTSFcnCppCodeAPIWarningVoidWorkNotSupported';
                return
            end
        end


        switch numel(this.Specs.HeaderFiles)
        case 0


        case 1


            if(this.Specs.HeaderFiles{1}(1)=='"')||(this.Specs.HeaderFiles{1}(1)=='<')
                canUseSFunCgAPI=false;
                sfunCgWarningID='LCTSFcnCppCodeAPIWarningEnclosedHeaderfilesNotSupported';
                return
            end

        otherwise
            canUseSFunCgAPI=false;
            sfunCgWarningID='LCTSFcnCppCodeAPIWarningManyHeaderfilesNotSupported';
            return
        end

        canUseSFunCgAPI=true;
    end

end





function iExtractWrapperFlags(this)

    this.hasWrapper=false;
    this.hasBus=false;
    this.hasStruct=false;
    this.hasAlias=false;
    this.hasEnum=false;
    this.hasSLObject=false;

    for ii=(this.DataTypes.NumSLBuiltInDataTypes+1):this.DataTypes.Numel
        dataType=this.DataTypes.Items(ii);
        if~isempty(dataType.HeaderFile)
            this.hasWrapper=true;
        end
        if dataType.IsBus==1
            this.hasBus=true;
        end
        if dataType.IsStruct==1
            this.hasStruct=true;
        end
        if dataType.IsEnum==1
            this.hasEnum=true;
        end
        if this.DataTypes.isAliasType(dataType)
            this.hasAlias=true;
        end
        this.hasSLObject=this.hasSLObject||dataType.HasObject;
    end

    this.hasBusOrStruct=this.hasBus||this.hasStruct;

end




function iAddDWorksForBusIOMarshaling(this)

    this.forEachDataSetDataOnly(@(d)addDWork(d));

    function addDWork(dataSpec)
        if this.DataTypes.isAggregateType(dataSpec.DataTypeId)&&...
            ~this.Specs.Options.stubSimBehavior


            dWork=copy(dataSpec);
            dWork.Identifier=sprintf('work%d',this.DWorksForBus.Numel+1);
            dWork.IsPartOfSpec=false;
            dWork.dwIdx=[];
            dWork.pwIdx=this.DWorksInfo.NumPWorks+this.DWorksForBus.Numel+1;


            dWork.BusInfo.Data=dataSpec;


            this.DWorksForBus.add(dWork);


            dataSpec.BusInfo.Data=dWork;
            dataSpec.BusInfo.PWorkIdx=dWork.pwIdx;
        end
    end
end




function paramId=iGetParamIdUsedByValueAsDimension(this)


    paramId=[];


    this.forEachDataSetDataOnly(@(d)getParamId(d));


    paramId=unique(paramId);

    function getParamId(dataSpec)

        if dataSpec.isParameter()
            return
        end


        dimsInfo=dataSpec.DimsInfo;
        for ii=1:numel(dimsInfo)
            if dimsInfo(ii).Val==-1&&dimsInfo(ii).HasInfo==1
                exprInfo=dimsInfo(ii).Info;
                for jj=1:numel(exprInfo)
                    if exprInfo(jj).Kind=='v'
                        paramId=[paramId,exprInfo(jj).Id];%#ok<AGROW>
                    end
                end
            end
        end
    end
end





function iAddDWorksForNDArrayMarshaling(this)

    this.forEachDataSetDataOnly(@(d)addDWork(d));

    function addDWork(dataSpec)
        matInfo=this.getNDArrayMarshalingInfo(dataSpec);
        if matInfo>0


            dWork=copy(dataSpec);
            dWork.Identifier=sprintf('work%d',this.DWorksForNDArray.Numel+1);
            dWork.IsPartOfSpec=false;
            dWork.CArrayND.MatInfo=matInfo;
            dWork.pwIdx=[];
            dWork.dwIdx=this.DWorksInfo.NumDWorks+this.DWorksForNDArray.Numel+1;


            dWork.CArrayND.Data=dataSpec;


            this.DWorksForNDArray.add(dWork);


            dataSpec.CArrayND.Data=dWork;
            dataSpec.CArrayND.DWorkIdx=dWork.dwIdx;
            dataSpec.CArrayND.MatInfo=dWork.CArrayND.MatInfo;


            this.hasRowMajorNDArray=true;
        end
    end
end




function iAddDynamicSizeInformation(this)


    this.forEachDataSet(@(o,n,s)visitDataSet(s,n(1:end-1)));

    function visitDataSet(dataSet,dataKind)
        if~any(strcmp(dataKind,{'Input','Output','DWork'}))
            return
        end


        dynSizeField=[dataKind,'DynSize'];
        this.DynamicSizeInfo.(dynSizeField)=cell(1,dataSet.Numel);
        hasDynSizeField=[dataKind,'HasDynSize'];
        this.DynamicSizeInfo.(hasDynSizeField)=false;


        dataSet.forEachData(@(s,idx,d)visitData(d,idx,dynSizeField,hasDynSizeField));
    end

    function visitData(dataSpec,idx,dynSizeField,hasDynSizeField)

        isDynSized=this.isTrueDynamicSize(dataSpec);

        this.DynamicSizeInfo.(dynSizeField){idx}=isDynSized;

        this.DynamicSizeInfo.(hasDynSizeField)=any(isDynSized==true)||this.DynamicSizeInfo.(hasDynSizeField);
    end
end




function iAddDynamicArrayInformation(this)


    hasDynamicArrayArgument=false;
    function visitSpec(dataSpec)
        if hasDynamicArrayArgument

            return
        end
        for ii=1:numel(dataSpec.DimsInfo)
            hasDynamicArrayArgument=hasDynamicArrayArgument||dataSpec.DimsInfo(ii).IsInf;
        end
    end


    this.forEachDataSetDataOnly(@(d)visitSpec(d));
    this.hasDynamicArrayArgument=hasDynamicArrayArgument;


    hasDynamicArrayAggregate=false;
    function visitType(dataType)
        if hasDynamicArrayAggregate

            return
        end
        hasDynamicArrayAggregate=hasDynamicArrayAggregate||...
        this.DataTypes.hasDynamicArrayElement(dataType);
    end

    this.DataTypes.forEachData(@(o,idx,t)visitType(t));
    this.hasDynamicArrayAggregate=hasDynamicArrayAggregate;

end





