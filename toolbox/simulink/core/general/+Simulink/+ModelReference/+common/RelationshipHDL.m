




classdef RelationshipHDL<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipHDL(~)

            obj@Simulink.ModelReference.common.Relationship;
            obj.RelationshipName='hdl';
            obj.DirName='hdl';
        end

        function cleanedUpDirName=correctFileSepInDirName(~,dirname)


            if ispc
                cleanedUpDirName=strrep(dirname,'/',filesep);
            else
                cleanedUpDirName=strrep(dirname,'\',filesep);
            end
        end

        function populateProtectedGMModel(obj,protectedModelCreator)
            gmModelName=protectedModelCreator.ModelName;
            gmPrefix=hdlget_param(gmModelName,'generatedmodelnameprefix');
            gmPrefixAtHead=['^',gmPrefix];
            origModelName=regexprep(gmModelName,gmPrefixAtHead,'');
            protectedModelName=slInternal('getPackageNameForModel',origModelName);
            protectedGMModelName=[gmPrefix,protectedModelName];
            codegenDirName=hdlget_param(gmModelName,'TargetDirectory');
            codegenDirName=correctFileSepInDirName(obj,codegenDirName);
            protGMModelPattern=fullfile(pwd,codegenDirName,origModelName,protectedGMModelName);

            obj.addPartUsingFilePattern(protGMModelPattern,'');
        end


        function populate(obj,protectedModelCreator)

            modelname=protectedModelCreator.ModelName;
            codegenDirName=hdlget_param(modelname,'TargetDirectory');
            vhdlExtension=hdlget_param(modelname,'VHDLFileExtension');
            vlogExtension=hdlget_param(modelname,'VerilogFileExtension');
            compileFilePostFix=hdlget_param(modelname,'HDLCompileFilePostfix');
            mapFilePostfix=hdlget_param(modelname,'HDLMapFilePostfix');
            codegenDirName=correctFileSepInDirName(obj,codegenDirName);


            vhdlNamePattern=['*',vhdlExtension];
            vlogNamePattern=['*',vlogExtension];
            hdlfilepattern1=fullfile(pwd,codegenDirName,protectedModelCreator.ModelName,vhdlNamePattern);
            hdlfilepattern2=fullfile(pwd,codegenDirName,protectedModelCreator.ModelName,vlogNamePattern);
            compileScriptPattern=['*',compileFilePostFix];
            mapFilePattern=['*',mapFilePostfix];
            statusFilePattern=fullfile(pwd,codegenDirName,protectedModelCreator.ModelName,'hdlcodegenstatus.mat');
            compileScriptsPattern=fullfile(pwd,codegenDirName,protectedModelCreator.ModelName,compileScriptPattern);
            mapPattern=fullfile(pwd,codegenDirName,protectedModelCreator.ModelName,mapFilePattern);

            obj.addPartUsingFilePattern(hdlfilepattern1,'');
            obj.addPartUsingFilePattern(hdlfilepattern2,'');
            obj.addPartUsingFilePattern(statusFilePattern,'');
            obj.addPartUsingFilePattern(compileScriptsPattern,'');
            obj.addPartUsingFilePattern(mapPattern,'');


            synthesisTarget='';
            synthesisTool=hdlget_param(modelname,'SynthesisTool');
            if strcmpi(synthesisTool,'Altera Quartus II')
                synthesisTarget='Altera';
            elseif strcmpi(synthesisTool,'Xilinx ISE')
                synthesisTarget='Xilinx';
            end
            if~isempty(synthesisTarget)
                megaFunctionStruct1=dir(fullfile(pwd,codegenDirName,protectedModelCreator.ModelName,synthesisTarget,'**',vhdlNamePattern));
                patternToRemove=fullfile(pwd,codegenDirName,protectedModelCreator.ModelName,filesep);
                megaFunctionStruct2=dir(fullfile(pwd,codegenDirName,protectedModelCreator.ModelName,synthesisTarget,'**',vlogNamePattern));
                megaFunctionStruct3=dir(fullfile(pwd,codegenDirName,protectedModelCreator.ModelName,synthesisTarget,'**','*.qip'));
                megaFunctionStruct4=dir(fullfile(pwd,codegenDirName,protectedModelCreator.ModelName,synthesisTarget,'**','*.cmp'));
                megaFunctionStruct5=dir(fullfile(pwd,codegenDirName,protectedModelCreator.ModelName,synthesisTarget,'**','*_signature.txt'));

                addMegaFunctionPattern(obj,patternToRemove,megaFunctionStruct1);
                addMegaFunctionPattern(obj,patternToRemove,megaFunctionStruct2);
                addMegaFunctionPattern(obj,patternToRemove,megaFunctionStruct3);
                addMegaFunctionPattern(obj,patternToRemove,megaFunctionStruct4);
                addMegaFunctionPattern(obj,patternToRemove,megaFunctionStruct5);
            end
        end

        function addMegaFunctionPattern(obj,patternToRemove,megaFunctionStruct)
            for ii=1:numel(megaFunctionStruct)
                pattern=fullfile(megaFunctionStruct(ii).folder,megaFunctionStruct(ii).name);
                newPath=regexprep(pattern,patternToRemove,'');
                newPath=fileparts(newPath);
                obj.addPartUsingFilePattern(pattern,newPath);
            end
        end
    end
    methods(Static)
        function out=getEncryptionCategory()
            out='HDL';
        end


        function out=getRelationshipYear()
            out='2017';
        end

    end
end



