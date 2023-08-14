



classdef LCTSpecInfo<matlab.mixin.Copyable


    properties(Constant,Hidden)

        FunKinds=legacycode.lct.spec.Common.FunKinds


        DataKinds=legacycode.lct.spec.Common.Roles(1:end-1)
    end


    properties

        Specs legacycode.LCT


        DataTypes legacycode.lct.types.TypeTable


        Fcns struct=struct()


        GlobalIO legacycode.lct.spec.LCTGlobalIO


        Inputs legacycode.lct.spec.DataSet


        Outputs legacycode.lct.spec.DataSet


        Parameters legacycode.lct.spec.DataSet


        DWorks legacycode.lct.spec.DataSet


        DSMs legacycode.lct.spec.DataSet


DynamicSizeInfo
    end


    properties(SetAccess=protected)


        ParamAsDimensionId uint32=[]



        DWorksForBus legacycode.lct.spec.DataSet
        DWorksForNDArray legacycode.lct.spec.DataSet



DWorksInfo


        InfoExtracted logical=false
        BusInfoExtracted logical=false
    end


    properties(Dependent,SetAccess=protected)
        TotalNumDWorks uint32
    end


    properties


        Extra=[]
    end


    properties(Dependent,Hidden)
SampleTime
hasNDArray
hasRowMajorNDArray
canUseSFunCgAPI
sfunCgWarningID
hasWrapper
hasBus
hasStruct
hasBusOrStruct
hasAlias
hasEnum
hasSLObject
isCPP
useInt64
hasDynamicArrayArgument
hasDynamicArrayAggregate
    end

    properties(Dependent,Hidden)
warningID
canUseSFcnCGIRAPI
    end


    methods




        function this=LCTSpecInfo(lctSpec)

            narginchk(0,1);
            if nargin==1
                validateattributes(lctSpec,{'legacycode.LCT','struct'},{'scalar','nonempty'},1);
                if isstruct(lctSpec)

                    lctSpec=legacycode.LCT(lctSpec);
                end
            else

                lctSpec=legacycode.LCT();
            end

            this.Specs=lctSpec;

        end







        function val=get.TotalNumDWorks(this)
            val=this.DWorksInfo.NumDWorks+...
            this.DWorksForNDArray.Numel+...
            2*int32(this.DWorksForBus.Numel>0);
        end





        extractBusInformation(this)





        isDynSize=isTrueDynamicSize(this,dataSpec,theDims)





        matInfo=getNDArrayMarshalingInfo(this,argSpecOrType,theDims)




        extractAllInfo(this,type)





        hFilesStruct=extractAllHeaderFiles(this)




        validateFun(this,funSpec,funKind)




        validate(this)




        function forEachFunction(this,funHandle)
            for ii=1:numel(this.FunKinds)
                funKind=this.FunKinds{ii};
                fcn=this.Fcns.(funKind);
                if iscell(fcn)
                    for idx=1:numel(fcn)
                        funHandle(this,funKind,fcn{idx});
                    end
                else
                    funHandle(this,funKind,fcn);
                end
            end
        end




        function forEachDataSet(this,funHandler)
            for ii=1:numel(this.DataKinds)
                dataSetName=[this.DataKinds{ii},'s'];
                funHandler(this,dataSetName,this.(dataSetName));
            end
        end




        function forEachDataSetData(this,funHandler)
            this.forEachDataSet(...
            @(o,n,s)s.forEachData(...
            @(s,id,d)funHandler(o,n,s,id,d))...
            );
        end





        function forEachDataSetDataOnly(this,funHandler)

            this.forEachDataSet(...
            @(o,n,s)s.forEachData(...
            @(s,id,d)funHandler(d))...
            );
        end




        function data=lookupData(this,dataKind,dataId)
            narginchk(3,3);
            if isa(dataKind,'legacycode.lct.spec.DataKind')
                dataKind=char(dataKind);
            end
            data=this.([dataKind,'s']).Items(dataId);
        end


        function val=get.SampleTime(this)
            val=this.getExtraProp('SampleTime');
        end
        function set.SampleTime(this,val)
            this.Extra.SampleTime=val;
        end
        function val=get.hasNDArray(this)
            val=this.getExtraProp('hasNDArray');
        end
        function set.hasNDArray(this,val)
            this.Extra.hasNDArray=val;
        end
        function val=get.hasRowMajorNDArray(this)
            val=this.getExtraProp('hasRowMajorNDArray');
        end
        function set.hasRowMajorNDArray(this,val)
            this.Extra.hasRowMajorNDArray=val;
        end
        function val=get.canUseSFunCgAPI(this)
            val=this.getExtraProp('canUseSFunCgAPI');
        end
        function set.canUseSFunCgAPI(this,val)
            this.Extra.canUseSFunCgAPI=val;
        end
        function val=get.canUseSFcnCGIRAPI(this)
            val=this.canUseSFunCgAPI;
        end
        function val=get.sfunCgWarningID(this)
            val=this.getExtraProp('sfunCgWarningID');
        end
        function set.sfunCgWarningID(this,val)
            this.Extra.sfunCgWarningID=val;
        end
        function val=get.warningID(this)
            val=this.sfunCgWarningID;
        end
        function val=get.hasWrapper(this)
            val=this.getExtraProp('hasWrapper');
        end
        function set.hasWrapper(this,val)
            this.Extra.hasWrapper=val;
        end
        function val=get.hasBus(this)
            val=this.getExtraProp('hasBus');
        end
        function set.hasBus(this,val)
            this.Extra.hasBus=val;
        end
        function val=get.hasStruct(this)
            val=this.getExtraProp('hasStruct');
        end
        function set.hasStruct(this,val)
            this.Extra.hasStruct=val;
        end
        function val=get.hasAlias(this)
            val=this.getExtraProp('hasAlias');
        end
        function set.hasAlias(this,val)
            this.Extra.hasAlias=val;
        end
        function val=get.hasBusOrStruct(this)
            val=this.getExtraProp('hasBusOrStruct');
        end
        function set.hasBusOrStruct(this,val)
            this.Extra.hasBusOrStruct=val;
        end
        function val=get.hasEnum(this)
            val=this.getExtraProp('hasEnum');
        end
        function set.hasEnum(this,val)
            this.Extra.hasEnum=val;
        end
        function val=get.hasSLObject(this)
            val=this.getExtraProp('hasSLObject');
        end
        function set.hasSLObject(this,val)
            this.Extra.hasSLObject=val;
        end
        function val=get.isCPP(this)
            val=this.getExtraProp('isCPP');
        end
        function set.isCPP(this,val)
            this.Extra.isCPP=val;
        end
        function val=get.useInt64(this)
            val=this.getExtraProp('useInt64');
        end
        function set.useInt64(this,val)
            this.Extra.useInt64=val;
        end
        function val=get.hasDynamicArrayArgument(this)
            val=this.getExtraProp('hasDynamicArrayArgument');
        end
        function set.hasDynamicArrayArgument(this,val)
            this.Extra.hasDynamicArrayArgument=val;
        end
        function val=get.hasDynamicArrayAggregate(this)
            val=this.getExtraProp('hasDynamicArrayAggregate');
        end
        function set.hasDynamicArrayAggregate(this,val)
            this.Extra.hasDynamicArrayAggregate=val;
        end
    end


    methods(Access=protected)




        function reset(this,lctSpec)


            this.InfoExtracted=false;
            this.BusInfoExtracted=false;
            this.Extra=[];
            this.Extra.useInt64=false;
            this.Extra.hasNDArray=false;


            this.Specs=lctSpec;


            this.DataTypes=legacycode.lct.types.TypeTable();


            for ii=1:numel(this.FunKinds)
                this.Fcns.(this.FunKinds{ii})=legacycode.lct.spec.Function();
            end


            for ii=1:numel(this.DataKinds)
                this.([this.DataKinds{ii},'s'])=legacycode.lct.spec.DataSet(this.DataKinds{ii});
            end


            this.DWorksForBus=legacycode.lct.spec.DataSet('DWork');
            this.DWorksForNDArray=legacycode.lct.spec.DataSet('DWork');


            this.DWorksInfo.NumDWorks=0;
            this.DWorksInfo.NumPWorks=0;
            this.DWorksInfo.DWorksId=[];
            this.DWorksInfo.PWorksId=[];

            this.DynamicSizeInfo.InputHasDynSize=false;
            this.DynamicSizeInfo.InputDynSize=[];
            this.DynamicSizeInfo.OutputHasDynSize=false;
            this.DynamicSizeInfo.OutputDynSize=[];
            this.DynamicSizeInfo.DWorkHasDynSize=false;
            this.DynamicSizeInfo.DWorkDynSize=[];
        end




        type=convertDataType(this,funSpec,argSpec,varargin)





        linkData(this,funSpec,argSpec,varargin)




        function val=getExtraProp(this,propName)
            if isfield(this.Extra,propName)
                val=this.Extra.(propName);
            else
                val=[];
            end
        end




        newObj=copyElement(this)





        msg=genMsgForCrossSpecError(this,dataRole,propPosStr,propExprStr)

    end


    methods(Static)






        [lctSpecInfo,lctObj]=extract(lctObj,type)

    end

end


