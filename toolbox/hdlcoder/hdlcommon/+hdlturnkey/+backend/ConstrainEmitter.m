




classdef ConstrainEmitter<downstream.ConstraintEmitterBase



    properties


        hTurnkey=[];

        ConstrainFileName='';
        ConstrainFilePath='';
        PinAssignFileName='';
        PinAssignFilePath='';

    end

    methods

        function obj=ConstrainEmitter(hTurnkey)

            obj=obj@downstream.ConstraintEmitterBase(hTurnkey.hD);

            obj.hTurnkey=hTurnkey;

        end

        function generateUCF(obj)
            switch(obj.hTurnkey.hD.hToolDriver.hTool.ToolName)
            case{'Altera QUARTUS II','Intel Quartus Pro'}

                fid=obj.initialConstrainFile;
                obj.generateClockConstrain(fid);
                fclose(fid);
                obj.registerUCFFiles;


                fid=obj.initialPinAssignFile;
                obj.generateFPGAPinMappingConstrain(fid);
                obj.generateInterfaceSpecificConstrain(fid);
                fclose(fid);
                obj.hTurnkey.TurnkeyFileList{end+1}=obj.PinAssignFileName;

            otherwise

                fid=obj.initialConstrainFile;

                obj.generateClockConstrain(fid);

                obj.generateFPGAPinMappingConstrain(fid);

                obj.generateInterfaceSpecificConstrain(fid);

                fclose(fid);

                obj.registerUCFFiles;
            end
        end

    end

    methods(Access=protected,Hidden=true)

        function registerUCFFiles(obj)


            obj.hTurnkey.TurnkeyFileList{end+1}=obj.ConstrainFileName;

            attachedFileName=obj.hTurnkey.hBoard.AttachConstrainFile;
            if~isempty(attachedFileName)
                pluginDir=obj.hTurnkey.hBoard.PluginPath;
                codegenDir=obj.hTurnkey.hD.hCodeGen.CodegenDir;
                sourcePath=fullfile(pluginDir,attachedFileName);
                targetPath=fullfile(codegenDir,attachedFileName);
                copyfile(sourcePath,targetPath,'f');
                obj.hTurnkey.TurnkeyFileList{end+1}=attachedFileName;
            end
        end
        function registerPinFiles(obj)


            obj.hTurnkey.TurnkeyFileList{end+1}=obj.PinAssignFileName;

            attachedFileName=obj.hTurnkey.hBoard.AttachConstrainFile;
            if~isempty(attachedFileName)
                pluginDir=obj.hTurnkey.hBoard.PluginPath;
                codegenDir=obj.hTurnkey.hD.hCodeGen.CodegenDir;
                sourcePath=fullfile(pluginDir,attachedFileName);
                targetPath=fullfile(codegenDir,attachedFileName);
                copyfile(sourcePath,targetPath,'f');
                obj.hTurnkey.TurnkeyFileList{end+1}=attachedFileName;
            end
        end


        function generateFPGAPinMappingConstrain(obj,fid)

            fprintf(fid,'\n# FPGA Pin Location Constraints\n\n');


            hDI=obj.hTurnkey.hD;
            hClockModule=hDI.getClockModule;
            constrainCell=hClockModule.generateFPGAPinConstrain;
            obj.emitFPGAPinMapping(fid,constrainCell);

            interfaceIDList=obj.hTurnkey.getSupportedInterfaceIDList;

            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.hTurnkey.getInterface(interfaceID);



                if~hInterface.isInterfaceInUse(obj.hTurnkey)||...
                    hInterface.isConstrainAttached
                    continue;
                end


                constrainCell=hInterface.generateFPGAPinConstrain(obj.hTurnkey.hElab);

                obj.emitFPGAPinMapping(fid,constrainCell);
            end

        end

        function generateInterfaceSpecificConstrain(obj,fid)



            interfaceIDList=obj.hTurnkey.getSupportedInterfaceIDList;

            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.hTurnkey.getInterface(interfaceID);



                if~hInterface.isInterfaceInUse(obj.hTurnkey)||...
                    hInterface.isConstrainAttached
                    continue;
                end


                hInterface.generateInterfaceSpecificConstrain(fid,obj.hTurnkey.hElab);
            end

        end


        function fid=initialConstrainFile(obj)


            constrainFileNamePostfix=obj.hTurnkey.hBoard.ConstrainFileNamePostfix;
            toolName=obj.hTurnkey.hD.get('Tool');

            if isempty(constrainFileNamePostfix)


                switch lower(toolName)
                case 'xilinx vivado'
                    constrainFileNamePostfix='top.xdc';
                case 'xilinx ise'
                    constrainFileNamePostfix='top.ucf';
                case{'altera quartus ii','intel quartus pro'}
                    constrainFileNamePostfix='top.sdc';
                case 'microchip libero soc'
                    constrainFileNamePostfix='top.pdc';
                otherwise
                    error(message('hdlcommon:workflow:UnsupportedTool',toolName));
                end
            else


                if strcmpi(toolName,'Xilinx Vivado')
                    [~,postfixName]=fileparts(constrainFileNamePostfix);
                    constrainFileNamePostfix=sprintf('%s.xdc',postfixName);
                end
            end

            obj.ConstrainFileName=sprintf('%s_%s',obj.hTurnkey.hElab.getDUTCompName,constrainFileNamePostfix);


            obj.ConstrainFilePath=fullfile(obj.hTurnkey.hD.hCodeGen.CodegenDir,obj.ConstrainFileName);


            fid=obj.createConstrainFile(obj.ConstrainFilePath);
            obj.printUCFTitle(fid);

        end

        function fid=initialPinAssignFile(obj)



            fileNamePostfix=obj.hTurnkey.hBoard.PinAssignFileNamePostfix;
            if isempty(fileNamePostfix)


                fileNamePostfix='top.qsf';
            end
            obj.PinAssignFileName=sprintf('%s_%s',obj.hTurnkey.hElab.getDUTCompName,fileNamePostfix);


            obj.PinAssignFilePath=fullfile(obj.hTurnkey.hD.hCodeGen.CodegenDir,obj.PinAssignFileName);


            fid=obj.createConstrainFile(obj.PinAssignFilePath);
            obj.printUCFTitle(fid);

        end

        function fid=createConstrainFile(~,ConstrainFilePath)

            fid=fopen(ConstrainFilePath,'w');
            if fid==-1
                error(message('hdlcommon:workflow:UnableCreateConstrainFile',ConstrainFilePath));
            end
        end


        function printUCFTitle(obj,fid)
            fprintf(fid,'# %s\n\n',obj.hTurnkey.hBoard.BoardName);
        end

        function emitFPGAPinMapping(obj,fid,constrainCell)










            for ii=1:length(constrainCell)
                pinMapping=constrainCell{ii};
                numStr=length(pinMapping);


                portStr=pinMapping{1};
                fpgaPinStr=pinMapping{2};


                if isempty(portStr)||isempty(fpgaPinStr)
                    continue;
                end

                switch(obj.hTurnkey.hD.hToolDriver.hTool.ToolName)
                case{'Altera QUARTUS II','Intel Quartus Pro'}
                    portStr=strrep(portStr,'<','[');
                    portStr=strrep(portStr,'>',']');
                    fprintf(fid,'set_location_assignment PIN_%s -to %s\n',fpgaPinStr,portStr);
                    if numStr>=3
                        for mm=3:numStr
                            fprintf(fid,'set_instance_assignment -name %s -to %s\n',...
                            pinMapping{mm},portStr);
                        end
                    end
                case 'Xilinx Vivado'
                    portStr=strrep(portStr,'<','[');
                    portStr=strrep(portStr,'>',']');
                    fprintf(fid,'set_property PACKAGE_PIN %s [get_ports {%s}]\n',...
                    fpgaPinStr,portStr);
                    if numStr>=3
                        for mm=3:numStr
                            otherStr=pinMapping{mm};
                            otherStr=regexprep(otherStr,'\s*=\s*',' ');
                            fprintf(fid,'set_property %s [get_ports {%s}]\n',...
                            otherStr,portStr);
                        end
                    end



                case 'Microchip Libero SoC'
                    portStr=strrep(portStr,'<','[');
                    portStr=strrep(portStr,'>',']');
                    hDI=obj.hTurnkey.hD;





                    if strcmpi(hDI.get('Family'),'PolarFireSoC')
                        if numStr==2
                            fprintf(fid,'set_io -port_name {%s} -pin_name %s -fixed true \n',portStr,fpgaPinStr);
                        elseif numStr>2
                            fprintf(fid,'set_io -port_name {%s} -pin_name %s -fixed true ',portStr,fpgaPinStr);
                            fprintf(fid,'\n');
                        end
                    else
                        if numStr==2
                            fprintf(fid,'set_io {%s} -pinname %s -fixed yes \n',portStr,fpgaPinStr);
                        elseif numStr>2
                            fprintf(fid,'set_io {%s} -pinname %s -fixed yes ',portStr,fpgaPinStr);
                            fprintf(fid,'\n');
                        end
                    end

                otherwise
                    if numStr==2
                        fprintf(fid,'NET "%s" LOC = "%s";\n',portStr,fpgaPinStr);
                    elseif numStr>2
                        otherStrs=pinMapping(3:end);
                        fprintf(fid,'NET "%s" LOC = "%s"',portStr,fpgaPinStr);
                        fprintf(fid,'  |  %s',otherStrs{:});
                        fprintf(fid,';\n');
                    end
                end
            end
        end



    end


end


