function oStruct=lct_pInitStructure(structType,varargin)





    if legacycode.lct.util.feature('newImpl')
        oStruct=legacycode.lct.util.DataBuilder.newDataStructure(structType,varargin{:});
        return
    end

    switch structType
    case 'FcnArgElement'
        oStruct=iInitFcnArgElement();

    case 'BusElement'
        oStruct=iInitBusElement();

    case 'Data'
        oStruct=iInitData();

    case 'DataTypeElement'
        oStruct=iInitDataTypeElement();

    case 'DataTypes'
        oStruct=iInitDataTypes();

    case 'FcnElement'
        oStruct=iInitFcnElement();

    case 'FcnArgs'
        oStruct=iInitFcnArgs();

    case 'Info'
        oStruct=iInitInfo();

    otherwise
        oStruct=[];
    end



    function info=iInitInfo()



        info.Specs=[];


        info.DataTypes=iInitDataTypes();


        info.Fcns.InitializeConditions=iInitFcnElement();
        info.Fcns.Start=iInitFcnElement();
        info.Fcns.Output=iInitFcnElement();
        info.Fcns.Terminate=iInitFcnElement();


        info.Inputs.Num=0;
        info.Inputs.Id=[];
        info.Inputs.Input=iInitData();


        info.Outputs.Num=0;
        info.Outputs.Id=[];
        info.Outputs.Output=iInitData();


        info.Parameters.Num=0;
        info.Parameters.Id=[];
        info.Parameters.Parameter=iInitData();


        info.DWorks.Num=0;
        info.DWorks.Id=[];
        info.DWorks.DWork=iInitData();


        function busElement=iInitBusElement()


            busElement=struct(...
            'Name','',...
            'DataTypeId',-1,...
            'Offset',0,...
            'Padding',0,...
            'IsComplex',0,...
            'NumDimensions',1,...
            'Dimensions',1,...
            'Width',1...
            );



            function dataTypes=iInitDataTypes()


                DTNames={...
                'double','single',...
                'int8','uint8',...
                'int16','uint16',...
                'int32','uint32',...
'boolean'...
                };

                DataTypeNames=DTNames;

                Enums={...
                'SS_DOUBLE','SS_SINGLE',...
                'SS_INT8','SS_UINT8',...
                'SS_INT16','SS_UINT16',...
                'SS_INT32','SS_UINT32',...
'SS_BOOLEAN'...
                };

                NativeTypes={...
                'real_T','real32_T',...
                'int8_T','uint8_T',...
                'int16_T','uint16_T',...
                'int32_T','uint32_T',...
'boolean_T'...
                };


                Names=NativeTypes;
                StorageIds=1:numel(Names);

                numDataTypes=length(Names);

                dataTypes.NumDataTypes=numDataTypes;
                dataTypes.NumSLBuiltInDataTypes=numDataTypes;
                dataTypes.DataTypeNames=DTNames;
                dataTypes.DataTypeIDs=1:numDataTypes;

                for ii=1:numDataTypes
                    dataTypes.DataType(ii)=iInitDataTypeElement();
                    dataTypes.DataType(ii).Name=Names{ii};
                    dataTypes.DataType(ii).DTName=DTNames{ii};
                    dataTypes.DataType(ii).DataTypeName=DataTypeNames{ii};
                    dataTypes.DataType(ii).NativeType=NativeTypes{ii};
                    dataTypes.DataType(ii).Enum=Enums{ii};
                    dataTypes.DataType(ii).Id=ii;
                    dataTypes.DataType(ii).StorageId=StorageIds(ii);
                    dataTypes.DataType(ii).IdAliasedThruTo=ii;
                    dataTypes.DataType(ii).IsBuiltin=1;
                end



                dataTypes.DataType(end+1)=iInitDataTypeElement();
                dataTypes.DataType(end).Name='void';
                dataTypes.DataType(end).DTName='void';
                dataTypes.DataType(end).DataTypeName='void';
                dataTypes.DataType(end).NativeType='void';
                dataTypes.DataType(end).Enum='SS_POINTER';
                dataTypes.DataType(end).Id=length(dataTypes.DataType);
                dataTypes.DataType(end).StorageId=dataTypes.DataType(end).Id;
                dataTypes.DataType(end).IdAliasedThruTo=dataTypes.DataType(end).Id;

                dataTypes.NumDataTypes=dataTypes.DataType(end).Id;
                dataTypes.DataTypeNames(end+1)={dataTypes.DataType(end).DataTypeName};
                dataTypes.DataTypeIDs(end+1)=dataTypes.DataType(end).Id;



                dataTypes.BusInfo.BusDataTypesId=[];
                dataTypes.BusInfo.OtherDataTypesId=[];
                dataTypes.BusInfo.BusElementHashTable=cell(0,2);
                dataTypes.BusInfo.DataTypeSizeTable=cell(0,1);



                function dtStruct=iInitDataTypeElement()


                    dtStruct=struct(...
                    'DTName','',...
                    'Id',-1,...
                    'IdAliasedTo',-1,...
                    'IdAliasedThruTo',-1,...
                    'StorageId',-1,...
                    'NumElements',0,...
                    'Elements',iInitBusElement(),...
                    'IsBus',0,...
                    'IsStruct',0,...
                    'IsEnum',0,...
                    'EnumInfo',struct('Strings',{},'Values',[],'DefaultValueIdx',1),...
                    'FixedExp',0,...
                    'FracSlope',1,...
                    'Bias',0,...
                    'IsFixedPoint',0,...
                    'IsBuiltin',0,...
                    'HeaderFile','',...
                    'HasObject',0,...
                    'Object',[],...
                    'Name','',...
                    'Enum','',...
                    'DataTypeName','',...
                    'NativeType','',...
                    'IsPartOfSpec',false...
                    );



                    function data=iInitData()


                        data.Identifier='';
                        data.DataTypeId=1;
                        data.IsComplex=0;
                        data.Dimensions=1;
                        data.Width=1;




                        data.IsPartOfSpec=true;







                        data.DimsInfo(1:0)=struct('HasInfo',-1,'DimInfo',struct('Type','','DataId',[],'DimRef',[]));


                        data.BusInfo.DWorkId=-1;
                        data.BusInfo.Type='';
                        data.BusInfo.DataId=-1;
                        data.BusInfo.Keys=cell(0,1);



                        data.CMatrix2D.DWorkId=-1;
                        data.CMatrix2D.Type='';
                        data.CMatrix2D.DataId=-1;
                        data.CMatrix2D.MatInfo=0;


                        function fcn=iInitFcnElement()


                            fcn=struct(...
                            'IsSpecified',0,...
                            'Expression','',...
                            'LhsExpression','',...
                            'RhsExpression','',...
                            'LhsArgs',iInitFcnArgs(),...
                            'RhsArgs',iInitFcnArgs()...
                            );



                            function args=iInitFcnArgs()


                                args.NumArgs=0;
                                args.Arg=iInitFcnArgElement();



                                function arg=iInitFcnArgElement()


                                    arg=struct(...
                                    'Identifier','',...
                                    'Type','',...
                                    'DataId',-1,...
                                    'DataTypeId',-1,...
                                    'IsComplex',0,...
                                    'AccessType','direct',...
                                    'Qualifier','',...
                                    'Expression',''...
                                    );


                                    arg.DimsInfo(1:0)=struct('HasInfo',-1,'DimInfo',struct('Type','','DataId',[],'DimRef',[]));



