classdef TestPointPortInfo<dpig.internal.PortInfo
    properties
SID
RawSignalName
Duplicate

objhandlecast
    end

    properties(Access=private)

CAPI_TestPointSID

SignalAddress
    end

    properties(SetAccess=private,GetAccess=public)

C_UniqueAccessFcnId
    end

    properties(Constant)

        SV_UniqueAccessFcnId='DPI_TestPointAccessFcn';
    end

    methods
        function obj=TestPointPortInfo(CAPIData_DataInterface,SubSysPath)
            if nargin==0
                error('Not enough arguments for dpig.internal.TestPointPortInfo');
            end
            StructFieldInfo=struct('TopStructFlatName',{},...
            'TopStructName',{},...
            'TopStructDim',[],...
            'ElementAccessIndexNumber',[],...
            'ElementAccessIndexVariable',{},...
            'TopStructIndexing',{},...
            'ElementAccess',{},...
            'TopStructType',{});

            StructFieldInfo(1).TopStructFlatName={};
            StructFieldInfo(1).TopStructName={};
            StructFieldInfo(1).TopStructDim=[];
            StructFieldInfo(1).ElementAccessIndexNumber=[];
            StructFieldInfo(1).ElementAccessIndexVariable={};
            StructFieldInfo(1).TopStructIndexing={};
            StructFieldInfo(1).ElementAccess={};
            StructFieldInfo(1).TopStructType={};
            TempMapFlattenedDim=containers.Map;
            TempMapFlattenedDim('FlattenedDimensions')=[];

            if CAPIData_DataInterface.Type.isStructure
                l_me=MException(message('HDLLink:DPITargetCC:BusTP_NotSupported'));
                throw(l_me);
            elseif CAPIData_DataInterface.Type.isEnum

                throw(MException(message('HDLLink:DPITargetCC:EnumTP_NotSupported')));
            elseif CAPIData_DataInterface.Type.isMatrix
                if CAPIData_DataInterface.Type.BaseType.isStructure


                    throw(MException(message('HDLLink:DPITargetCC:BusTP_NotSupported')));
                end
            end

            if CAPIData_DataInterface.Type.isMatrix
                TopDim=int32(l_getScalarDim(CAPIData_DataInterface.Type.Dimensions));
                rtwVarInfo=CAPIData_DataInterface.Type.BaseType;
            else
                TopDim=int32(1);
                rtwVarInfo=CAPIData_DataInterface.Type;
            end

            if isempty(CAPIData_DataInterface.GraphicalName)

                UnderScore='';
                GraphicalName=CAPIData_DataInterface.GraphicalName;
            elseif any(double(CAPIData_DataInterface.GraphicalName)>127)

                UnderScore='';
                GraphicalName='';
            else

                UnderScore='_';
                GraphicalName=CAPIData_DataInterface.GraphicalName;
            end
            TopFlatName=l_TopFlatName(CAPIData_DataInterface,SubSysPath,UnderScore,GraphicalName);


            obj@dpig.internal.PortInfo(rtwVarInfo,...
            '',...
            TopFlatName,...
            StructFieldInfo,...
            TopDim,...
            TempMapFlattenedDim,...
            '',...
            false);



            obj.CAPI_TestPointSID=l_InitCAPI_TestPointSID(CAPIData_DataInterface,SubSysPath);

            if isempty(CAPIData_DataInterface.GraphicalName)
                warning(message('HDLLink:DPITargetCC:TestPointWithNoName'));
                obj.RawSignalName='';
            elseif any(double(CAPIData_DataInterface.GraphicalName)>127)
                warning(message('HDLLink:DPITargetCC:TestPointWithNonASCII'));
                obj.RawSignalName=CAPIData_DataInterface.GraphicalName;
            else
                obj.RawSignalName=CAPIData_DataInterface.GraphicalName;
            end


            obj.SID=strtok(obj.CAPI_TestPointSID,'#');
            obj.SignalAddress=CAPIData_DataInterface.Implementation.getExpression;

            obj.Duplicate=false;


            if isempty(CAPIData_DataInterface.Timing)


                obj.SamplePeriod=nan;
            else

                obj.SamplePeriod=CAPIData_DataInterface.Timing.SamplePeriod;
            end






            obj.C_UniqueAccessFcnId=[obj.SV_UniqueAccessFcnId,'_',strtok(CAPIData_DataInterface.SID,':')];
        end

        function str=getCAPI_TestPointSID(obj)
            str=obj.CAPI_TestPointSID;
        end


        function str=getCopyRTWToOutput(TestPointPortInfo)

            Destination=TestPointPortInfo.getExternalVarsHandlesToCopy();
            Source=TestPointPortInfo.getRTWHandlesToCopy();
            SizeToCopy=TestPointPortInfo.getSizeToCopy();
            if~TestPointPortInfo.DoesPortRequireMarshalling
                str=sprintf('memcpy(%s,%s,sizeof(%s));',Destination,Source,SizeToCopy);
            else
                str=TestPointPortInfo.DPIFixedPointInterfaceMarshallingObj.getBitsFromCData_FcnCall(Destination,Source);
            end

        end

        function str=getTestPointPortPtrFromRTW(TestPointPortInfo)

            str=[TestPointPortInfo.DataType,' *_',TestPointPortInfo.FlatName,'_Ptr =',TestPointPortInfo.getRTWHandlesToCopy,';'];
        end


    end
    methods(Access=protected)
        function str=getExternalVarsHandlesToCopy(TestPointPortInfo)
            str=TestPointPortInfo.FlatName;
        end

        function str=getRTWHandlesToCopy(TestPointPortInfo)

            str=strrep(TestPointPortInfo.SignalAddress,...
            TestPointPortInfo.SignalAddress(1:strfind(TestPointPortInfo.SignalAddress,'->')-1),...
            TestPointPortInfo.objhandlecast);
        end
    end

end

function dim=l_getScalarDim(dimArray)
    dim=prod(reshape(dimArray,numel(dimArray),1));
end

function str=l_InitCAPI_TestPointSID(CAPIData_DataInterface,SubSysPath)%#ok<INUSL>


    if isempty(SubSysPath)


        str=CAPIData_DataInterface.SID;
    else


        str=strrep(CAPIData_DataInterface.SID,strtok(CAPIData_DataInterface.SID,':'),strtok(SubSysPath,'/'));
    end
end

function val=l_TopFlatName(CAPIData_DataInterface,SubSysPath,UnderScore,GraphicalName)
    val=[strrep(strrep(l_InitCAPI_TestPointSID(CAPIData_DataInterface,SubSysPath),'#','_'),':','_'),UnderScore,GraphicalName];
end
