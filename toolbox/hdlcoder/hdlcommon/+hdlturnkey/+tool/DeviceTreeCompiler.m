classdef DeviceTreeCompiler<handle



    properties(Access=protected)
        hDeviceTree devicetree
        CompiledDeviceTreePath string

    end

    methods
        function obj=DeviceTreeCompiler
        end

        function addDeviceTree(obj,devTree,includeDirs,comments)









            if nargin<4
                comments=string.empty;
            end

            [devTree,includeDirs,comments]=convertCharsToStrings(devTree,includeDirs,comments);
            obj.addSourceDeviceTree(devTree,includeDirs,comments);
        end

        function[status,result]=compileDeviceTree(obj,outputFilePathDTB,compileOnHost)


            if nargin<3
                compileOnHost=false;
            end

            status=true;
            result='';






            if isempty(obj.hDeviceTree)
                return;

            end



            msg=message('hdlcommon:workflow:DeviceTreeCompilerBegin');
            result=sprintf('%s\n%s',result,msg.getString);


            [folderName,baseFileName]=fileparts(outputFilePathDTB);
            sourceFileName=baseFileName+".dts";
            outputFileNameDTS=baseFileName+".output.dts";
            sourceFilePath=fullfile(folderName,sourceFileName);
            outputFilePathDTS=fullfile(folderName,outputFileNameDTS);

            obj.hDeviceTree.printSource(sourceFilePath);

            link=sprintf('<a href="matlab:open(''%s'')">%s</a>',sourceFilePath,sourceFilePath);
            msg=message('hdlcommon:workflow:DeviceTreeCompilerPrintSource',link);
            result=sprintf('%s\n%s',result,msg.getString);


            msg=message('hdlcommon:workflow:DeviceTreeCompilerRun');
            result=sprintf('%s\n%s',result,msg.getString);

            compileOptions={};
            compileOptions(end+1:end+2)={"IncludeDirectories",obj.hDeviceTree.IncludeDirectories};
            if~compileOnHost

                hBoardParams=codertarget.hdlcxilinx.internal.BoardParameters;
                remoteShell=codertarget.hdlcoder.internal.LinuxShell(hBoardParams);
                remoteShell.validateConnection();
                compileOptions(end+1:end+2)={"RemoteShell",remoteShell};
            end



            outputFilePaths=[outputFilePathDTB,outputFilePathDTS];
            compileOptions(end+1:end+2)={"OutputType",["dtb","dts"]};


            devicetree.compileDeviceTree(sourceFilePath,outputFilePaths,compileOptions{:});

            msg=message('hdlcommon:workflow:DeviceTreeCompilerFinish',outputFilePathDTB);
            result=sprintf('%s\n%s',result,msg.getString);
        end
    end

    methods(Access=protected)
        function addSourceDeviceTree(obj,partialDevTree,includeDirs,comments)











            if isstring(partialDevTree)
                devTreeToInclude=partialDevTree;
                partialDevTree=devicetree;
                hIncludeNode=partialDevTree.addIncludeStatement(devTreeToInclude);
                hIncludeNode.addComment(comments);
            end

            if~isa(partialDevTree,'devicetree')
                error('Incorrect device tree format.')
            end

            if isempty(obj.hDeviceTree)

                obj.hDeviceTree=devicetree;
            end



            obj.hDeviceTree.appendDeviceTree(partialDevTree);
            obj.hDeviceTree.addIncludeDirectory(includeDirs);
        end
    end
end

