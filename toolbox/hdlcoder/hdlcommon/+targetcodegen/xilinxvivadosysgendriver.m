



classdef xilinxvivadosysgendriver<targetcodegen.xilinxsysgendriver
    properties(SetAccess=private)
        xModel=[];
    end


    methods(Static)

        function xsgexist=hasXSG(varargin)
            cgInfo=targetcodegen.basedriver.getCGInfo(varargin{:});
            xsgexist=isfield(cgInfo,'XsgVivadoCodeGenResults')&&...
            isfield(cgInfo.XsgVivadoCodeGenResults,'Files')&&...
            ~isempty(cgInfo.XsgVivadoCodeGenResults.Files);
        end

        function fileList=getXSGFiles(filetype,libname,varargin)
            cgInfo=targetcodegen.basedriver.getCGInfo(varargin{:});

            fileList={};
            if isfield(cgInfo,'XsgVivadoCodeGenResults')
                fileTypeList=filetype.getFileType(hdlsynthtoolenum.Vivado);
                if isfield(cgInfo.XsgVivadoCodeGenResults,'Files')
                    if isfield(cgInfo.XsgVivadoCodeGenResults.Files,libname)
                        allXsgFiles=cgInfo.XsgVivadoCodeGenResults.Files.(libname);
                        for i=1:length(fileTypeList)
                            curExt=fileTypeList{i};
                            if isfield(allXsgFiles,curExt)
                                fileList=[fileList,allXsgFiles.(curExt)];
                            end
                        end
                    end
                end
            end
        end


        function str=getXSGSynthesisScripts(hDI,fromDir,varargin)
            str='';


            if isempty(hDI)

                hModel=bdroot;
                hdriver=hdlmodeldriver(hModel);



                vivadoSysgenQueryFlow=downstream.queryflowmodesenum.VIVADOSYSGEN;




                hDI=downstream.DownstreamIntegrationDriver(hModel,false,false,'',vivadoSysgenQueryFlow,hdriver,false,false,true);
            end

            xsgCodeGenPath=targetcodegen.xilinxsysgendriver.getXSGCodeGenPath(varargin{:});


            if(~isempty(xsgCodeGenPath))
                [createCoeDirStr,relCoeDir,coeDirSetName]=hDI.hToolDriver.hEmitter.generateTclCreateCoeDir;
                coeDir=strrep(fullfile(hDI.hToolDriver.getProjectPath,relCoeDir),'\','/');
                hasDUTDesignCoeFiles=false;
                for i=1:length(xsgCodeGenPath)
                    libName=xsgCodeGenPath{i};
                    fileList=targetcodegen.xilinxvivadosysgendriver.getXSGFiles(targetcodegen.xilinxsysgenfileenum.HDL,libName,varargin{:});
                    coeList=targetcodegen.xilinxvivadosysgendriver.getXSGFiles(targetcodegen.xilinxsysgenfileenum.COE,libName,varargin{:});
                    tclList=targetcodegen.xilinxvivadosysgendriver.getXSGFiles(targetcodegen.xilinxsysgenfileenum.TCL,libName,varargin{:});
                    codeGenDir=strrep(hDI.hCodeGen.CodegenDir,'\','/');
                    libPath=[codeGenDir,'/',libName];
                    prjPath=strrep(hDI.hToolDriver.getProjectPath,'\','/');

                    addCoeFileStr={};
                    copyCoeFilesStr={};
                    sourceTclFilesStr={};

                    if~hasDUTDesignCoeFiles
                        hasDUTDesignCoeFiles=~isempty(coeList);
                    end



                    for j=1:length(fileList)
                        fileName=fileList{j};
                        filePath=[libPath,'/',fileName];
                        fileList{j}=filePath;
                    end

                    for j=1:length(coeList)
                        fileName=coeList{j};
                        filePath=[coeDir,'/',fileName];
                        coeList{j}=filePath;
                    end

                    for j=1:length(tclList)
                        fileName=tclList{j};
                        filePath=[libPath,'/',fileName];
                        tclList{j}=filePath;
                    end




                    if~isempty(coeList)
                        addCoeFileStr=hDI.hToolDriver.hEmitter.generateTclFileList(coeList,'',prjPath,true);

                        relLibPath=strrep(hDI.hToolDriver.hEmitter.getRelativeFolderPath(prjPath,libPath),'\','/');
                        copyCoeFilesStr=targetcodegen.xilinxvivadosysgendriver.getCOEFileCopyTcl(libName,relLibPath,coeDirSetName);
                    end

                    addHdlFileStr=hDI.hToolDriver.hEmitter.generateTclFileList(fileList,libName,fromDir);
                    addFileStr=[addHdlFileStr,addCoeFileStr];
                    if~isempty(tclList)
                        sourceTclFilesStr=hDI.hToolDriver.hEmitter.generateSourceExtTclFileList(tclList);
                    end

                    allStr=[copyCoeFilesStr,addFileStr,sourceTclFilesStr];
                    str=[str,sprintf('%s\n',allStr{:})];
                end


                if hasDUTDesignCoeFiles
                    str=[createCoeDirStr,str];
                end
            end
        end



        function str=getXSGSynthesisScriptsCustom(hdlSynthCmd,isVHDL,prjName,varargin)
            str='';

            xsgCodeGenPath=targetcodegen.xilinxsysgendriver.getXSGCodeGenPath(varargin{:});
            if(~isempty(xsgCodeGenPath))
                coeDirSetName='coeDir';
                [createCoeDirStr,coeDir]=targetcodegen.xilinxvivadosysgendriver.getCreateCoeDirTcl(prjName,coeDirSetName);
                hasDUTDesignCoeFiles=false;
                for i=1:length(xsgCodeGenPath)
                    libName=xsgCodeGenPath{i};
                    fileList=targetcodegen.xilinxvivadosysgendriver.getXSGFiles(targetcodegen.xilinxsysgenfileenum.HDL,libName,varargin{:});
                    coeList=targetcodegen.xilinxvivadosysgendriver.getXSGFiles(targetcodegen.xilinxsysgenfileenum.COE,libName,varargin{:});
                    tclList=targetcodegen.xilinxvivadosysgendriver.getXSGFiles(targetcodegen.xilinxsysgenfileenum.TCL,libName,varargin{:});



                    if~hasDUTDesignCoeFiles
                        hasDUTDesignCoeFiles=~isempty(coeList);
                    end

                    [hdlSynthCmdParts,foundhdlSynthCmdParts]=regexp(hdlSynthCmd,'(?<addFileCmdStr>\w+)\s(?<codegenStr>.+)%s\\n','names');
                    if foundhdlSynthCmdParts
                        addFileCmd=hdlSynthCmdParts.addFileCmdStr;
                        codeGenDir=hdlSynthCmdParts.codegenStr;
                    else
                        addFileCmd='add_file';
                        codeGenDir='';
                    end

                    libPath=[codeGenDir,libName];


                    if~isempty(coeList)
                        copyCoeFilesStr=targetcodegen.xilinxvivadosysgendriver.getCOEFileCopyTcl(libName,libPath,coeDirSetName);
                        str=[str,sprintf('%s\n',copyCoeFilesStr{:})];
                    end

                    for j=1:length(fileList)
                        fileName=fileList{j};
                        filePath=[libName,'/',fileName];
                        fileList{j}=filePath;
                        addHdlFileStr=sprintf(hdlSynthCmd,filePath);

                        str=[str,addHdlFileStr];
                    end

                    for j=1:length(coeList)
                        fileName=coeList{j};
                        filePath=[coeDir,'/',fileName];
                        coeList{j}=filePath;
                        addCoeFileStr=sprintf('%s %s\n',addFileCmd,filePath);

                        str=[str,addCoeFileStr];
                    end

                    for j=1:length(tclList)
                        fileName=tclList{j};
                        filePath=[libPath,'/',fileName];
                        tclList{j}=filePath;
                    end

                    libraryStr={};
                    if isVHDL
                        list_of_files=strjoin(fileList,[' ',codeGenDir]);
                        list_of_files=[codeGenDir,list_of_files];

                        libraryStr=sprintf('set_property library %s [get_files [concat %s]]\n',libName,list_of_files);

                        str=[str,libraryStr];
                    end

                    sourceTclFilesStr='';
                    if~isempty(tclList)
                        sourceTclFilesStr=sprintf('source %s\n',tclList{:});

                        str=[str,sourceTclFilesStr];
                    end
                end


                if hasDUTDesignCoeFiles
                    str=[sprintf('%s\n',createCoeDirStr{:}),str];
                end
            end
        end

        function[tclStr,coeDir]=getCreateCoeDirTcl(prjName,coeDirSetName)
            coeDir=[prjName,'.srcs/sources_1/ip'];
            tclStr={['set coeDir "',coeDir,'"'],...
            ['if {[file exists $',coeDirSetName,'] == 0} {'],...
            ['    file mkdir $',coeDirSetName],...
            '}'};
        end

        function tclStr=getCOEFileCopyTcl(libName,libSrcDir,coeDirSetName)
            tclStr={['set coeList_',libName,' [glob -nocomplain -directory "',libSrcDir,'" *.coe]'],...
            ['foreach coe_',libName,' $coeList_',libName,' {'],...
            ['    if {[lsearch -exact $',coeDirSetName,' [file rootname coeList_',libName,']] == -1} {'],...
            ['       file copy -force $coe_',libName,' $',coeDirSetName],...
            '     }',...
            '}'};
        end

        function varargout=findXSGBlks(blk,xsgdrv)
            if nargin<2
                try
                    xsgdrv=targetcodegen.xilinxvivadosysgendriver(bdroot(blk));
                catch me %#ok<*NASGU>
                    varargout{1}=[];
                    varargout{2}=[];
                    return
                end
            end
            xsgBlks=xsgdrv.getSystemGeneratorTokens(blk);
            varargout{1}=xsgBlks;
            varargout{2}=xsgdrv;
        end
    end

    methods
        function obj=xilinxvivadosysgendriver(modelpath)
            if nargin<1
                modelpath=bdroot;
            end

            obj.xModel=xilinx.model(modelpath);
            obj.xModel.enableHDLCoderAPI();
        end

        function xsgIslands=getXSGIslands(obj)
            xsgIslands=obj.xModel.getSystemGeneratorSubSystems();
        end

        function xsgTokens=getSystemGeneratorTokens(obj,blockPath)
            if nargin<2
                xsgTokens=obj.xModel.getSystemGeneratorTokens;
            else
                slbh=get_param(blockPath,'handle');
                xsgTokens=obj.xModel.getSystemGeneratorTokens(slbh);
            end
        end

        function isXsgIsland=isXSGIsland(obj,slbh)
            xsgIslands=obj.getXSGIslands;
            blkpath=[get_param(slbh,'parent'),'/',get_param(slbh,'name')];
            isXsgIsland=sum(cellfun(@(x)strcmpi(x,blkpath),xsgIslands));
        end

        function settings=getSettings(obj)
            settings=obj.xModel.getSettings;
        end

        function updateXSGSettings(obj,newsettings)
            obj.xModel.updateSettings(newsettings);

        end

        function xDesignInfo=generate(obj,islandbh)
            settings=obj.getSettings();
            settings.SubSystem=islandbh;
            xDesignInfo=obj.xModel.generate(settings);
            if~isempty(xDesignInfo)&&isfield(xDesignInfo,'files');
                targetcodegen.xilinxvivadosysgendriver.populateXSGFiles(xDesignInfo.files,settings.VHDLLibrary);
            end

        end

        function varargout=get(obj,propnames)
            if iscell(propnames)
                varargout=cellfun(@(x)obj.getpropvalue(x),propnames,'UniformOutput',false);
            else
                varargout{1}=obj.getpropvalue(propnames);
            end

        end

    end

    methods(Access=private)
        function value=getpropvalue(obj,propname)
            value=[];
            curSettings=obj.getSettings;
            if isfield(curSettings,propname)
                value=curSettings.(propname);
            end
        end


    end

    methods(Static)
        function settings=getXSGSettings(slbh,xsgdrv)
            if nargin<2
                try
                    xsgdrv=targetcodegen.xilinxvivadosysgendriver(bdroot(slbh));
                catch me %#ok<*NASGU>
                    settings=[];
                    return
                end
            end
            settings=xsgdrv.getSettings();
        end

        function varargout=isXSGSubsystem(slbh,xsgdrv)
            if nargin<2
                try
                    xsgdrv=targetcodegen.xilinxvivadosysgendriver(bdroot(slbh));
                catch me %#ok<*NASGU>
                    varargout{1}=false;
                    varargout{2}=[];
                    return
                end
            end
            bool=xsgdrv.isXSGIsland(slbh);
            varargout{1}=bool;
            varargout{2}=xsgdrv;
        end

        function populateXSGFiles(xsgFiles,libname)
            hdlCurrentDriver=hdlcurrentdriver();
            files=targetcodegen.xilinxvivadosysgendriver.classifyFile(xsgFiles);
            hdlCurrentDriver.cgInfo.XsgVivadoCodeGenResults.Files.(libname)=files;
        end

        function files=classifyFile(xsgFiles)
            files=struct('hdl',[],'coe',[],'mif',[],'tcl',[],'other',[]);
            for ii=1:length(xsgFiles)
                xsgFile=xsgFiles{ii}.name;
                [~,~,fileext]=fileparts(xsgFile);

                switch(fileext(2:end))
                case{'v','verilog','vhd','vhdl'}
                    files.hdl{end+1}=xsgFile;
                case 'coe'
                    files.coe{end+1}=xsgFile;
                case 'mif'
                    files.mif{end+1}=xsgFile;
                case 'tcl'
                    files.tcl{end+1}=xsgFile;
                otherwise
                    files.other{end+1}=xsgFile;
                end
            end
        end
    end

end


