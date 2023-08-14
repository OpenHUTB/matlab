classdef MATLABCaptureVector<handle
    properties

        TempDir1;
        TempDir2;
        Design;
        Design_tb;
        InputArgs;
        OutputArgs;

        RawDpiData;
        OutLogNamePrefix='dpig_out';
        InLogNamePrefix='dpig_in';
        DpiSrcPath;
    end

    methods
        function obj=MATLABCaptureVector

            obj.TempDir1=[MATLAB_DPICGen.DPICGenInst.SrcPath,filesep,'TempDir'];
            obj.TempDir2=[obj.TempDir1,filesep,'work'];

            obj.Design=MATLAB_DPICGen.DPICGenInst.moduleName;
            obj.Design_tb=MATLAB_DPICGen.DPICGenInst.tbModuleName;

            obj.DpiSrcPath=MATLAB_DPICGen.DPICGenInst.SrcPath;

            NumIO=MATLAB_DPICGen.DPICGenInst.dpig_codeinfo.InStruct.NumPorts;
            obj.InputArgs=cell(1,NumIO);

            if iscell(MATLAB_DPICGen.DPICGenInst.InputArgs)
                obj.InputArgs=MATLAB_DPICGen.DPICGenInst.InputArgs;
            else
                obj.InputArgs{1}=MATLAB_DPICGen.DPICGenInst.InputArgs;
            end
















            NumIO=MATLAB_DPICGen.DPICGenInst.dpig_codeinfo.OutStruct.NumPorts;
            obj.OutputArgs=cell(1,NumIO);
            for ii=1:NumIO
                PortFlatName=MATLAB_DPICGen.DPICGenInst.dpig_codeinfo.OutStruct.Port{ii};
                NRows=MATLAB_DPICGen.DPICGenInst.dpig_codeinfo.PortMap(PortFlatName).MLMatrixSize(1);
                NColumns=MATLAB_DPICGen.DPICGenInst.dpig_codeinfo.PortMap(PortFlatName).MLMatrixSize(2);
                VarType=MATLAB_DPICGen.DPICGenInst.dpig_codeinfo.PortMap(PortFlatName).MLType;
                IsVarSize=MATLAB_DPICGen.DPICGenInst.dpig_codeinfo.PortMap(PortFlatName).IsVarSize;
                switch VarType
                case 'logical'

                    if IsVarSize



                        obj.OutputArgs{ii}=false(1,10);
                    else
                        obj.OutputArgs{ii}=false(NRows,NColumns);
                    end
                case{'uint8','uint16','uint32','uint64','int8','int16','int32','int64','single','double'}
                    if IsVarSize



                        obj.OutputArgs{ii}=zeros(1,10,VarType);
                    else
                        obj.OutputArgs{ii}=zeros(NRows,NColumns,VarType);
                    end
                otherwise




                    if IsVarSize



                        obj.OutputArgs{ii}=zeros(1,10);
                    else
                        obj.OutputArgs{ii}=zeros(NRows,NColumns);
                    end
                end







            end

        end

        function RunSimulation(obj)

            try
                mkdir(obj.TempDir2)













                C=onCleanup(@()rmdir(obj.TempDir1,'s'));





                if~isempty(obj.InputArgs)&&(isa(obj.InputArgs{1},'embedded.fi')&&~ismatrix(obj.InputArgs{1}))
                    error(message('HDLLink:DPITestbench:FixedPointMultiDimensionalArraysNotSupported'));
                end





                obj.RawDpiData=coder.internal.Float2FixedConverter.runTestBenchToLogDataNew(obj.TempDir1...
                ,obj.TempDir2...
                ,obj.Design...
                ,{obj.Design_tb}...
                ,obj.InputArgs...
                ,-1...
                ,[]...
                ,[]);
            catch Err
                rethrow(Err);
            end

            assert(~isempty(obj.RawDpiData.iter),message('HDLLink:DPITestbench:NoValuesLogged'));



        end

        function varSizeDataActualSizeMap=saveToMatFile(obj,tbdir,DataFileMap,PortMap)
            varSizeDataActualSizeMap=containers.Map;
            DATFileDir=[obj.DpiSrcPath,filesep,tbdir];
            if(~isempty(obj.RawDpiData))
                Iterations=obj.RawDpiData.iter-1;


                for idx=keys(PortMap)
                    KeyVal=idx{1};
                    PortData=[];
                    if PortMap(KeyVal).IsVarSize


                        capturedVector=obj.RawDpiData.([PortMap(KeyVal).Direction,'s']).(PortMap(KeyVal).NativeMATLABName);
                        varSizeDataActualSizeMap(KeyVal)=numel(capturedVector{1});
                    end





                    if isempty(PortMap(KeyVal).StructInfo)




                        l_printdatafile(DATFileDir,...
                        DataFileMap(KeyVal),...
                        l_FormatData(obj.RawDpiData.([PortMap(KeyVal).Direction,'s']).(PortMap(KeyVal).NativeMATLABName),Iterations,PortMap(KeyVal).RowMajor))
                        continue;
                    else





                        RawData=obj.RawDpiData.([PortMap(KeyVal).Direction,'s']).(PortMap(KeyVal).StructInfo.TopStructName{1});
                    end


                    for idx1=1:Iterations











                        l_ProcessRawStructData(RawData{idx1},...
                        PortMap(KeyVal).StructInfo.TopStructDim,...
                        [PortMap(KeyVal).StructInfo.TopStructName,PortMap(KeyVal).NativeMATLABName]);
                    end

                    l_printdatafile(DATFileDir,...
                    DataFileMap(KeyVal),...
                    PortData);
                end
            else
                error(message('HDLLink:DPITestbench:NoInputVectors'));
            end

            function l_ProcessRawStructData(RawData,ArraySubProblem,NameSubProblem)






                if isempty(ArraySubProblem)







                    if isempty(PortData)&&islogical(RawData)



                        PortData=logical(PortData);
                    end
                    PortData=[PortData;l_FormatData(RawData,Iterations,PortMap(KeyVal).RowMajor)];
                elseif PortMap(KeyVal).IsComplex&&numel(ArraySubProblem)==1


                    if strcmp(PortMap(KeyVal).StructInfo.ElementAccess(end-1:end),'im')

                        LoggedRawDataOrSubstruct=imag(RawData);
                    else

                        LoggedRawDataOrSubstruct=real(RawData);
                    end

                    l_ProcessRawStructData(LoggedRawDataOrSubstruct,ArraySubProblem(2:end),NameSubProblem(2:end));
                elseif ArraySubProblem(1)==1
                    if iscell(RawData)




                        error(message('HDLLink:DPIG:CellArraysNotSupported'));
                    else

                        assert(isfield(RawData,NameSubProblem{2}),message('HDLLink:DPIG:CellArraysNotSupported'));





                        LoggedRawDataOrSubstruct=RawData.(NameSubProblem{2});
                    end

                    l_ProcessRawStructData(LoggedRawDataOrSubstruct,ArraySubProblem(2:end),NameSubProblem(2:end));
                else





                    if any(PortMap(KeyVal).StructInfo.TopRowMajor)

                        RawData=ConvertColumnMajorToRowMajorForFlattening(RawData);
                    end
                    for idx_n=1:ArraySubProblem(1)
                        l_ProcessRawStructData(RawData(idx_n).(NameSubProblem{2}),ArraySubProblem(2:end),NameSubProblem(2:end));
                    end
                end
            end
        end
    end
end

function FormattedData=l_FormatData(RawData,Iter,IsRowMajor)

    if isempty(RawData)
        error(message('HDLLink:DPITestbench:IncompleteIOVector'));
    end

    if~iscell(RawData)



        if IsRowMajor
            RawData=ConvertColumnMajorToRowMajorForFlattening(RawData);
        end
        FormattedData=reshape(RawData,numel(RawData),1);
    else
        for ii=1:Iter

            if isempty(RawData{ii})
                error(message('HDLLink:DPITestbench:IncompleteIOVector'));
            elseif ii>1&&~isequal(size(RawData{ii-1}),size(RawData{ii}))
                error(message('HDLLink:DPITestbench:VarArgSizeNotSupported'));
            end

        end


        RawData=RawData(1:Iter,:);
        if IsRowMajor
            RawData=cellfun(@(x)ConvertColumnMajorToRowMajorForFlattening(x),RawData,'UniformOutput',false);
        end
        if isa(RawData{1},'embedded.fi')

            if~ismatrix(RawData{1})
                error(message('HDLLink:DPITestbench:FixedPointMultiDimensionalArraysNotSupported'));
            end
            TempHorzCat=reshape(RawData,1,numel(RawData));
            TempHorzCat=horzcat(TempHorzCat{:});
        else




            TempHorzCat=cat(ndims(RawData{1}),RawData{:});
        end





        FormattedData=reshape(TempHorzCat,numel(TempHorzCat),1);

    end
end

function l_printdatafile(Dattbdir,varname,vardata)
    hexdata=l_convert2hex(vardata);
    hexdata=[hexdata,repmat('\n',size(hexdata,1),1)];
    hexdata=reshape(hexdata',1,numel(hexdata));
    filename=[Dattbdir,filesep,varname];
    fid=fopen(filename,'w');
    c=onCleanup(@()fclose(fid));
    if fid==-1
        error('Failed to open file %d for write',filename);
    end
    fprintf(fid,hexdata(:)');
end

function outTemp=l_convert2hex(data)
    if isa(data,'embedded.fi')
        if data.issigned
            if data.WordLength>64
                outTemp=ll_getSignedFixedPointData();
                return;
            else





                data=storedInteger(data(:));
            end
        else
            outTemp=hex(data(:));
            return;
        end
    end

    if isenum(data)
        if isa(data,'int8')
            data=int8(data);
        elseif isa(data,'uint8')
            data=uint8(data);
        elseif isa(data,'int16')
            data=int16(data);
        elseif isa(data,'uint16')
            data=uint16(data);
        elseif isa(data,'int32')
            data=int32(data);
        elseif isa(data,'uint32')
            data=uint32(data);
        else
            error(message('HDLLink:DPITargetCC:Unsupported64BitEnum'));
        end
    end

    if isinteger(data)||islogical(data)


        if isa(data,'uint64')||isa(data,'int64')
            UnformattedHexOut=dec2hex(typecast(data,'uint32'),8);









            sz=size(UnformattedHexOut);
            Temp=reshape(UnformattedHexOut',sz(2)*2,[]);
            Temp=Temp';
            outTemp=[Temp(:,sz(2)+1:end),Temp(:,1:sz(2))];
            return;

        elseif~isa(data,'uint32')&&~isa(data,'int32')
            data=cast(data,'int32');
            data=typecast(data,'uint32');
        else
            data=typecast(data,'uint32');
        end
        outTemp=dec2hex(data(:));
    elseif isfloat(data)
        outTemp=num2hex(data(:));
    else
        error('HDLLink:DPITargetCC:dpigInvalidDataTypeCapture',class(data));
    end
    function OutStr=ll_getSignedFixedPointData()

        if any(bitget(data,data.WordLength))||mod(data.WordLength,64)==0


            OutStr=hex(data(:));
        else


            OutStr=hex(bitconcat(fi(uint64(bitget(data,data.WordLength))*intmax('uint64'),0,64-mod(data.WordLength,64),0),data));
        end
    end
end

function y=ConvertColumnMajorToRowMajorForFlattening(x)


    y=reshape(permute(x,ndims(x):-1:1),size(x));
end





