





classdef Data<legacycode.lct.util.IdObject


    properties(Dependent)
Identifier
    end


    properties
        DataTypeName char
        DataType legacycode.lct.types.Type
        IsComplex logical=false


        DimsInfo legacycode.lct.spec.DimInfo
    end


    properties(Dependent,SetAccess=protected)

        Dimensions int32
        Width int32
        IsDynamicArray logical
    end


    properties(Hidden,Dependent,SetAccess=protected)

DataTypeId
    end


    properties(SetAccess=protected)
        Kind legacycode.lct.spec.DataKind
        Radix char
    end



    properties(Hidden)




        IsPartOfSpec logical=true;


        BusInfo=struct(...
        'Data',legacycode.lct.spec.Data.empty(),...
        'PWorkIdx',-1,...
        'Keys',{cell(0,1)}...
        )



        CArrayND=struct(...
        'Data',legacycode.lct.spec.Data.empty(),...
        'DWorkIdx',-1,...
        'MatInfo',0...
        )


        pwIdx int32=[]
        dwIdx int32=[]
    end


    properties(SetAccess=protected,GetAccess=protected)

        RawIndentifier char
    end


    methods




        function this=Data(varargin)

            this@legacycode.lct.util.IdObject(varargin{:});

            this.Kind=legacycode.lct.spec.DataKind.Unknown;
        end




        function val=get.DataTypeId(this)
            if isempty(this.DataType)
                val=0;
            else
                val=this.DataType.Id;
            end
        end




        function val=get.Dimensions(this)

            val=[this.DimsInfo.Val];


            if isempty(val)||this.isExprArg()
                val=1;
            end
        end




        function val=get.Width(this)

            dim=this.Dimensions;

            if all(dim>=0)

                val=prod(dim);
            else

                val=-1;
            end
        end




        function val=get.Identifier(this)
            val=this.RawIndentifier;
        end








        function set.Identifier(this,val)


            dataKind=legacycode.lct.spec.DataKind.Unknown;
            dataRadix=val;
            dataId=0;


            if~isempty(val)
                [radix,idx]=legacycode.lct.spec.Common.splitIdentifier(val);
                if~isempty(radix)

                    dataRadix=radix;
                    dataId=idx;


                    dataRole=legacycode.lct.spec.Common.Radix2RoleMap(dataRadix);
                    dataKind=legacycode.lct.spec.DataKind.fromString(dataRole);
                end
            end


            this.Kind=dataKind;
            this.Radix=dataRadix;
            this.Id=dataId;



            if this.isUnknown()
                this.RawIndentifier=val;
            else
                this.RawIndentifier=sprintf('%s%d',dataRadix,dataId);
            end
        end




        function val=get.IsDynamicArray(this)
            val=false;
            this.forEachDimsInfo(@(o,idx,dimsInfo)hasInf(dimsInfo));
            function hasInf(dimsInfo)
                val=val||dimsInfo.IsInf;
            end
        end




        function forEachDimsInfo(this,funHandle)

            for ii=1:numel(this.DimsInfo)

                funHandle(this,ii,this.DimsInfo(ii));
            end
        end


        function val=isInput(this)
            val=this.Kind==legacycode.lct.spec.DataKind.Input;
        end

        function val=isOutput(this)
            val=this.Kind==legacycode.lct.spec.DataKind.Output;
        end

        function val=isParameter(this)
            val=this.Kind==legacycode.lct.spec.DataKind.Parameter;
        end

        function val=isDWork(this)
            val=this.Kind==legacycode.lct.spec.DataKind.DWork;
        end

        function val=isExprArg(this)
            val=this.Kind==legacycode.lct.spec.DataKind.ExprArg;
        end

        function val=isDSM(this)
            val=this.Kind==legacycode.lct.spec.DataKind.DSM;
        end

        function val=isUnknown(this)
            val=this.Kind==legacycode.lct.spec.DataKind.Unknown;
        end
    end


    methods(Access=protected)




        function newObj=copyElement(this)

            newObj=copyElement@matlab.mixin.Copyable(this);


            newObj.BusInfo.Data=newObj.BusInfo.Data.empty();
            newObj.CArrayND.Data=newObj.CArrayND.Data.empty();
        end

    end
end


