

classdef(Abstract)ScriptGeneration<handle


    properties

        hTurnkey=[];
    end

    properties(Abstract,SetAccess=protected)
Vendor
    end

    properties(SetAccess=protected)

        UserFileName='';



        SetupFileName='';



        ScriptFileName='';
    end

    properties(Access=protected,Dependent)

SetupFunctionName
    end

    properties(GetAccess=public,SetAccess=private,Hidden)

        FileID=-1;
    end

    properties(GetAccess=public,SetAccess=protected)

        HardwareObjectVarName='hFPGA';


        HardwareObjectConstructor='fpga';
        HardwareObjectReleaseMethod='release';
    end

    properties(Access=protected)
        FilePrefix='gs';
        SetupFunctionPostfix='setup';
        ScriptFilePostfix='interface';
    end

    properties(Abstract,Access=protected)

MessageString
    end

    methods
        function obj=ScriptGeneration(hTurnkey)

            obj.hTurnkey=hTurnkey;
        end
    end


    methods
        function fcnName=get.SetupFunctionName(obj)
            [~,fcnName,~]=fileparts(obj.SetupFileName);
        end
    end


    methods
        function[status,result,validateCell]=generateScript(obj)
            status=true;
            result='';
            validateCell={};

            [status,result,validateCell2]=obj.initScriptGen(status,result);
            validateCell=[validateCell,validateCell2];
            if~result


                return;
            end

            validateCell2=obj.generateSetupFunction;
            validateCell=[validateCell,validateCell2];

            validateCell2=obj.generateInterfaceScript;
            validateCell=[validateCell,validateCell2];

            [status,result]=obj.finishScriptGen(status,result);
        end
    end

    methods(Hidden)
        function isit=isCommandLineDisplay(obj)
            isit=obj.hTurnkey.hD.cmdDisplay;
        end
    end

    methods(Access=protected)
        function validateCell=generateSetupFunction(obj)

            obj.openFile(obj.SetupFileName);


            closeFile=onCleanup(@()obj.closeFile());


            obj.addFunctionDefinition(obj.FileID,obj.SetupFunctionName,{obj.HardwareObjectVarName},{});


            obj.generateSetupFcnHeader;


            validateCell=obj.generateInterfaceDrivers;


            obj.addEndStatement(obj.FileID);
        end

        function validateCell=generateInterfaceScript(obj)

            obj.openFile(obj.ScriptFileName);


            closeFile=onCleanup(@()obj.closeFile());


            obj.generateScriptHeader;


            obj.addSection(obj.FileID,sprintf('Create %s object',obj.HardwareObjectConstructor));
            vendor=sprintf('"%s"',obj.Vendor);
            obj.addFunctionCall(obj.FileID,obj.HardwareObjectConstructor,{vendor},{obj.HardwareObjectVarName});
            obj.addEmptyLine(obj.FileID);


            obj.addSection(obj.FileID,sprintf('Setup %s object',obj.HardwareObjectConstructor));
            obj.addComment(obj.FileID,sprintf('This function configures the "%s" object with the same interfaces as the generated IP core',obj.HardwareObjectConstructor));
            obj.addFunctionCall(obj.FileID,obj.SetupFunctionName,{obj.HardwareObjectVarName},{});
            obj.addEmptyLine(obj.FileID);


            obj.addSection(obj.FileID,'Write/read DUT ports');
            obj.addComment(obj.FileID,'Uncomment the following lines to write/read DUT ports in the generated IP Core.')
            obj.addComment(obj.FileID,'Update the example data in the write commands with meaningful data to write to the DUT.')
            validateCell=obj.generateInterfaceAccessCommands;


            obj.addSection(obj.FileID,'Release hardware resources');
            obj.addFunctionCall(obj.FileID,obj.HardwareObjectReleaseMethod,{obj.HardwareObjectVarName},{});
            obj.addEmptyLine(obj.FileID);
        end

        function[status,result,validateCell]=initScriptGen(obj,status,result)




            obj.UserFileName=obj.hTurnkey.hD.hCodeGen.ModelName;
            setupFileName=sprintf('%s_%s_%s.m',obj.FilePrefix,obj.UserFileName,obj.SetupFunctionPostfix);
            scriptFileName=sprintf('%s_%s_%s.m',obj.FilePrefix,obj.UserFileName,obj.ScriptFilePostfix);


            generatedFileNames={setupFileName,scriptFileName};
            fileExists=isfile(generatedFileNames);
            overwriteFiles=false;




            if any(fileExists)&&~obj.isCommandLineDisplay

                yesStr=message('hdlcommon:workflow:Yes').getString;
                noStr=message('hdlcommon:workflow:No').getString;
                cancelStr=message('hdlcommon:workflow:Cancel').getString;
                fileNames=strjoin(generatedFileNames(fileExists),', ');
                optionName=message('hdlcommon:workflow:HDLWASWInterfaceScript').getString;
                proceedMsg=message('hdlcommon:workflow:ScriptGenMsgOverwriteScript',fileNames,yesStr,noStr,cancelStr,optionName);
                headerMsg=message('hdlcommon:workflow:ScriptGenMsgOverwriteScriptHeader');


                userChoice=questdlg(proceedMsg.getString,headerMsg.getString,yesStr,noStr,cancelStr,noStr);

                switch userChoice
                case yesStr

                    overwriteFiles=true;
                case noStr

                    overwriteFiles=false;
                case{cancelStr,''}

                    msg=message('hdlcommon:workflow:ScriptGenMsgOverwriteScriptFail',optionName,optionName);
                    validateCell=downstream.tool.generateErrorWithStruct(msg,obj.isCommandLineDisplay);
                    result=false;
                    return;
                end
            end


            if any(fileExists)&&~overwriteFiles
                [~,setupName,setupExt]=fileparts(setupFileName);
                [~,scriptName,scriptExt]=fileparts(scriptFileName);
                suffix=1;
                while isfile(setupFileName)||isfile(scriptFileName)
                    setupFileName=[setupName,num2str(suffix),setupExt];
                    scriptFileName=[scriptName,num2str(suffix),scriptExt];
                    suffix=suffix+1;
                end
            end


            obj.SetupFileName=setupFileName;
            obj.ScriptFileName=scriptFileName;


            link=sprintf('<a href="matlab:open(''%s'')">%s</a>',obj.ScriptFileName,obj.ScriptFileName);
            msg=message('hdlcommon:workflow:ScriptGenMsgGenerateScript',obj.MessageString,link);
            [status,result]=obj.publishMessage(msg,status,result);
            validateCell={};
        end

        function[status,result]=finishScriptGen(obj,status,result)



            if status
                [status,result]=obj.runCallbackPostSWInterfaceScript(status,result);
            end


            msg=message('hdlcommon:workflow:ScriptGenMsgFinishScript',obj.MessageString);
            [status,result]=obj.publishMessage(msg,status,result);
        end

        function validateCell=generateInterfaceDrivers(obj)




            validateCell={};



            interfaceIDList=obj.hTurnkey.getHostInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hHostInterface=obj.hTurnkey.getHostInterface(interfaceID);
                validateCellInterface=hHostInterface.generateScriptDriver(obj);
                validateCell=[validateCell,validateCellInterface];%#ok<AGROW>
            end
        end

        function validateCell=generateInterfaceAccessCommands(obj)









            validateCell={};



            interfaceIDList=obj.hTurnkey.getHostInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hHostInterface=obj.hTurnkey.getHostInterface(interfaceID);
                validateCell{end+1}=hHostInterface.generateInterfaceAccessCommand(obj);%#ok<AGROW>
            end
        end
    end


    methods(Access=protected)
        function openFile(obj,fileName)
            [~,~,ext]=fileparts(fileName);
            if isempty(ext)
                fileName=[fileName,'.m'];
            end
            fileID=downstream.tool.createFile(fileName);
            obj.FileID=fileID;
        end

        function closeFile(obj)
            status=fclose(obj.FileID);
            if status==-1
                error('Could not close file.')
            else
                obj.FileID=-1;
            end
        end

        function generateScriptHeader(obj)
            prodInfo=ver('MATLAB');

            obj.addLine(obj.FileID,'%--------------------------------------------------------------------------');
            obj.addComment(obj.FileID,'Host Interface Script');
            obj.addComment(obj.FileID,'');
            obj.addComment(obj.FileID,sprintf('Generated with %s %s %s at %s.',prodInfo.Name,prodInfo.Version,prodInfo.Release,datestr(now,'HH:MM:SS on dd/mm/yyyy')));
            obj.addComment(obj.FileID,sprintf('This script was created for the IP Core generated from design ''%s''.',obj.UserFileName));
            obj.addComment(obj.FileID,'');
            obj.addComment(obj.FileID,'Use this script to access DUT ports in the design that were mapped to compatible IP core interfaces.');
            obj.addComment(obj.FileID,'You can write to input ports in the design and read from output ports directly from MATLAB.');
            obj.addComment(obj.FileID,'To write to input ports, use the "writePort" command and specify the port name and input data. The input data will be cast to the DUT port''s data type before writing.');
            obj.addComment(obj.FileID,'To read from output ports, use the "readPort" command and specify the port name. The output data will be returned with the same data type as the DUT port.');
            obj.addComment(obj.FileID,'Use the "release" command to release MATLAB''s control of the hardware resources.');
            obj.addLine(obj.FileID,'%--------------------------------------------------------------------------');
            obj.addEmptyLine(obj.FileID);
        end

        function generateSetupFcnHeader(obj)
            prodInfo=ver('MATLAB');

            obj.addLine(obj.FileID,'%--------------------------------------------------------------------------');
            obj.addComment(obj.FileID,'Host Interface Script Setup');
            obj.addComment(obj.FileID,'');
            obj.addComment(obj.FileID,sprintf('Generated with %s %s %s at %s.',prodInfo.Name,prodInfo.Version,prodInfo.Release,datestr(now,'HH:MM:SS on dd/mm/yyyy')));
            obj.addComment(obj.FileID,sprintf('This function was created for the IP Core generated from design ''%s''.',obj.UserFileName));
            obj.addComment(obj.FileID,'');
            obj.addComment(obj.FileID,sprintf('Run this function on an "%s" object to configure it with the same interfaces as the generated IP core.',obj.HardwareObjectConstructor));
            obj.addLine(obj.FileID,'%--------------------------------------------------------------------------');
            obj.addEmptyLine(obj.FileID);
        end

        function[status,result]=runCallbackPostSWInterfaceScript(obj,status,result)
            hDI=obj.hTurnkey.hD;

            [status2,log2]=hdlturnkey.plugin.runCallbackPostSWInterfaceScript(hDI);
            status=status&&status2;

            if~status&&obj.isCommandLineDisplay
                msg=message('hdlcommon:workflow:ReferenceDesignPostSWScriptCallback',log2);
                error(msg);
            else
                [status,result]=obj.publishMessage(log2,status,result);
            end
        end

        function[status,result]=publishMessage(obj,msg,status,result)
            if isa(msg,'message')
                msg=msg.getString;
            end

            if isempty(msg)
                return;
            end

            hDI=obj.hTurnkey.hD;
            if hDI.cmdDisplay
                hdldisp(msg);
            else
                result=sprintf('%s\n%s',result,msg);
            end
        end
    end


    methods(Static)
        function addFunctionCall(fileID,fcnName,inputArgs,outputArgs,varargin)





            fcnStr=hdlturnkey.backend.ScriptGeneration.getFunctionSyntax(fcnName,inputArgs,outputArgs);
            fcnCallStr=[fcnStr,';'];
            hdlturnkey.backend.ScriptGeneration.addLine(fileID,fcnCallStr,varargin{:});
        end

        function addFunctionDefinition(fileID,fcnName,inputArgs,outputArgs,varargin)





            fcnStr=hdlturnkey.backend.ScriptGeneration.getFunctionSyntax(fcnName,inputArgs,outputArgs);
            fcnDefStr=['function ',fcnStr];
            hdlturnkey.backend.ScriptGeneration.addLine(fileID,fcnDefStr,varargin{:});
        end

        function addEndStatement(fileID)


            hdlturnkey.backend.ScriptGeneration.addLine(fileID,'end');
        end

        function addSection(fileID,sectionStr)

            section=['%% ',sectionStr];
            hdlturnkey.backend.ScriptGeneration.addLine(fileID,section);
        end

        function addComment(fileID,commentStr)

            comment=['% ',commentStr];
            hdlturnkey.backend.ScriptGeneration.addLine(fileID,comment);
        end

        function addInlineComment(fileID,commentStr)

            comment=[' % ',commentStr];
            hdlturnkey.backend.ScriptGeneration.addText(fileID,comment);
        end

        function addEmptyLine(fileID)

            hdlturnkey.backend.ScriptGeneration.addLine(fileID,'');
        end

        function addLine(fileID,lineStr,varargin)

            p=inputParser;
            p.addParameter('GenerateAsComment',false);
            p.parse(varargin{:});

            if p.Results.GenerateAsComment
                lineStr=['% ',lineStr];
            end

            line=[lineStr,newline];
            hdlturnkey.backend.ScriptGeneration.addText(fileID,line);
        end

        function addText(fileID,textStr)







            textStr=insertBefore(textStr,'%','%');
            textStr=insertBefore(textStr,'\','\');


            fprintf(fileID,textStr);
        end

        function fcnStr=getFunctionSyntax(fcnName,inputArgs,outputArgs)






            outputArgStr=strjoin(outputArgs,', ');
            if length(outputArgs)>1

                outputArgStr=['[',outputArgStr,']'];
            end
            if~isempty(outputArgStr)
                outputArgStr=[outputArgStr,' = '];
            end


            inputArgStr=strjoin(inputArgs,', ');


            fcnStr=[outputArgStr,fcnName,'(',inputArgStr,')'];
        end

        function pvPairsStr=getPVPairsSyntax(pvPairs,varargin)










            p=inputParser;
            p.addOptional('LineBreak',false);
            p.addParameter('GenerateAsComment',false);
            p.parse(varargin{:});
            lineBreak=p.Results.LineBreak;
            generateAsComment=p.Results.GenerateAsComment;


            pvPairs=cellfun(@(pv)strjoin(pv,', '),pvPairs,'UniformOutput',false);


            if~lineBreak
                pvPairsStr=strjoin(pvPairs,', ');
            else
                tab=sprintf('\t');
                if generateAsComment


                    pvPairsStr=strjoin(pvPairs,[', ...',newline,'%',tab]);
                else
                    pvPairsStr=strjoin(pvPairs,[', ...',newline,tab]);
                end


                if generateAsComment
                    pvPairsStr=['...',newline,'%',tab,pvPairsStr];
                else
                    pvPairsStr=['...',newline,tab,pvPairsStr];
                end
            end
        end
    end
end
