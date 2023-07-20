

classdef CodeGenInfo<handle


    properties

        EntityTop='';
        CodegenDir='';
        SrcFileList={};

        SubModelData=[];

        SysGenVivadoResults=[];

        TimeStamp='';
        isVHDL=false;
        StartNodeName='';


        cgInfoBackupCopy=[];


        DUTCodeGenSrcFileList={};


        ModelName='';


        hCHandle=0;


        isMLHDLC=false;
    end

    properties(Access=protected,Hidden=true)

        hD=0;
    end

    methods

        function obj=CodeGenInfo(hDI,modelName,hdlDrv)

            obj.hD=hDI;


            if isempty(hdlDrv)

                if obj.hD.codesignflag
                    load_system(modelName);
                end


                [obj.hCHandle,obj.ModelName]=...
                downstream.CodeGenInfo.getCodeGenHandle(modelName);
                obj.isMLHDLC=false;
            else


                obj.hCHandle=hdlDrv;
                obj.ModelName=modelName;
                obj.isMLHDLC=true;
            end



            if obj.hCHandle.CodeGenSuccessful
                obj.getCodeGenInfo;
            end
        end

        function getCodeGenInfo(obj)

            obj.EntityTop=obj.hCHandle.cgInfo.topName;
            obj.CodegenDir=obj.hCHandle.hdlMakeCodegendir;
            obj.TimeStamp=obj.hCHandle.TimeStamp;
            obj.isVHDL=obj.hCHandle.getParameter('isvhdl');
            obj.StartNodeName=obj.hCHandle.getStartNodeName;

            if~obj.isTurnkeyCodeGen

                getDUTCodeGenSrcFileList(obj);
            else

                attachTurnkeyFileList(obj);
            end
        end

        function result=isNewCodeGen(obj)

            result=false;

            if isempty(obj.TimeStamp)

                error(message('hdlcommon:workflow:CodeGenNotComplete'));

            elseif~strcmp(obj.TimeStamp,obj.hCHandle.TimeStamp)

                result=true;

            end
        end

        function mdlName=getModelName(obj)
            mdlName=obj.ModelName;
        end

        function dutName=getDutName(obj)

            if obj.isMLHDLC
                dutName=obj.hCHandle.getStartNodeName;
            else
                dutName=hdlget_param(obj.ModelName,'HDLSubsystem');
            end
            if isempty(dutName)
                dutName=obj.ModelName;
            end
        end

        function isVHDL=isTargetVHDL(obj)
            if obj.isMLHDLC
                isVHDL=strcmpi(hdlgetparameter('target_language'),'VHDL');
            else
                isVHDL=strcmpi(hdlget_param(obj.getModelName,'TargetLanguage'),'VHDL');
            end
        end

        function ext=getVHDLExt(obj)
            if obj.isMLHDLC
                ext=hdlgetparameter('vhdl_file_ext');
            else
                ext=hdlget_param(obj.getModelName,'VHDLFileExtension');
            end
            if isempty(ext)
                ext='.vhd';
            end
        end

        function ext=getVerilogExt(obj)
            if obj.isMLHDLC
                ext=hdlgetparameter('verilog_file_ext');
            else
                ext=hdlget_param(obj.getModelName,'VerilogFileExtension');
            end
            if isempty(ext)
                ext='.v';
            end
        end

        function srcFilePathList=getSrcFilePathList(obj)

            srcFilePathList=fullfile(obj.CodegenDir,obj.SrcFileList);
        end

        function setBackupCgInfo(obj)
            obj.cgInfoBackupCopy=obj.hCHandle.cgInfo;
        end

        function cgInfo=getBackupCgInfo(obj)
            cgInfo=obj.cgInfoBackupCopy;
        end

        function getDUTCodeGenSrcFileList(obj)


            obj.SrcFileList=downstream.CodeGenInfo.getCodeGenSrcFileList(obj.hCHandle);
            obj.DUTCodeGenSrcFileList=obj.SrcFileList;
            obj.SubModelData=obj.hCHandle.SubModelData;


            cgInfo=obj.hCHandle.cgInfo;
            isVivadoXSG=targetcodegen.xilinxvivadosysgendriver.hasXSG(cgInfo);
            if isVivadoXSG
                obj.SysGenVivadoResults=cgInfo.XsgVivadoCodeGenResults;
            end
        end

        function getDUTCodeGenInfo(obj)

            obj.CodegenDir=obj.hCHandle.hdlMakeCodegendir;
            obj.isVHDL=obj.hCHandle.getParameter('isvhdl');

            getDUTCodeGenSrcFileList(obj);
        end
    end

    methods(Access=protected)

        function isTurnkey=isTurnkeyCodeGen(obj)


            if~isempty(obj.hD.hTurnkey)&&...
                strcmp(obj.hD.hTurnkey.TimeStamp,obj.TimeStamp)
                isTurnkey=true;
            else
                isTurnkey=false;
            end
        end

        function attachTurnkeyFileList(obj)



            dutFileList=obj.DUTCodeGenSrcFileList;
            turnkeyFileList=obj.hD.hTurnkey.TurnkeyFileList;

            obj.SrcFileList=downstream.CodeGenInfo.combineFileList(...
            dutFileList,turnkeyFileList);

        end

    end

    methods(Static)

        function[hc,curmodel]=getCodeGenHandle(modelName)

            narginchk(1,1);
            curmodel=bdroot(modelName);

            if isempty(curmodel)
                error(message('hdlcommon:hdlcommon:NoOpenModels'));
            end

            try

                hc=hdlmodeldriver(curmodel);
            catch %#ok<CTCH>
                hc=[];
            end
        end

        function srcFileList=getCodeGenSrcFileList(hc)

            srcFileList=hc.cgInfo.hdlFiles;
        end

        function combinedFileList=combineFileList(firstFileList,secondFileList)

            firstFileListLength=length(firstFileList);
            secondFileListLength=length(secondFileList);

            combinedFileList=cell(firstFileListLength+secondFileListLength,1);
            for ii=1:firstFileListLength
                combinedFileList{ii}=firstFileList{ii};
            end
            for ii=1:secondFileListLength
                combinedFileList{firstFileListLength+ii}=secondFileList{ii};
            end
        end
    end

end


