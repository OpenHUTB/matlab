classdef(Sealed=true)Information<handle





    properties(Hidden=true)


        simInterfaceChecksum;
        modelName;
        slprjVersion;
        interfaceVariableChecksum;
        interfaceVariableChecksumForCodeGen;
        tunableParameters;


        parameterArguments;


        modes;
        modelToBuildDirMap;
        subModels;
        report;
        callbackMgr;
        nonInlineSFcns;


        defaultTarget;
        targetToTargetInfoMap;
        obfuscateCode;
        codeInterface;
        hasSILSupport=false;
        hasPILSupport=false;
        hasHDLSupport=false;
        hasCSupport=false;
        hasSILPILSupportOnly=false;

        binariesAndHeadersOnly;
        allFilesForStandaloneBuild;


        webview;


        isSimEncrypted;
        isRTWEncrypted;
        isViewEncrypted;
        isModifyEncrypted;
        isHDLEncrypted;


        relationships;
    end

    methods(Hidden=true)

        function obj=updateImplOnlyInformation(obj,protectedModelCreator)
            obj.modelName=protectedModelCreator.ModelName;


            obj.updateEncryptionInfo(protectedModelCreator);


            obj.defaultTarget=protectedModelCreator.Target;
            if isprop(protectedModelCreator,'originalInformation')


                obj.updateTargetInfoForEdit(protectedModelCreator);
            else


                obj.createNewTargetInfo(protectedModelCreator);

            end


            obj.updateUserOptions(protectedModelCreator);


            obj.relationships=protectedModelCreator.relationshipClasses;
        end

        function obj=Information(protectedModelCreator)
            obj.subModels=protectedModelCreator.SubModels;
            obj.setNonInlineSfcs(protectedModelCreator);
            obj=obj.updateImplOnlyInformation(protectedModelCreator);
            obj.interfaceVariableChecksum=protectedModelCreator.getInterfaceVariableChecksum();
            obj.interfaceVariableChecksumForCodeGen=obj.interfaceVariableChecksum;
            if slfeature('ProtectedModelTunableParameters')>1&&protectedModelCreator.supportsCodeGen()
                obj.interfaceVariableChecksumForCodeGen=protectedModelCreator.getInterfaceVariableChecksumForCodeGen();
            end
            obj.tunableParameters=protectedModelCreator.getSimulationTunableParams();
        end

        function setRTWInterfaceChecksum(obj,rtwInterfaceChecksum)
            rtwInfoStruct=obj.getCurrentTargetInfo();
            rtwInfoStruct.codeGenTargetInterfaceChecksum=rtwInterfaceChecksum;
            obj.targetToTargetInfoMap(obj.defaultTarget)=rtwInfoStruct;
        end

        function out=getRTWInterfaceChecksum(obj)
            rtwInfoStruct=obj.getCurrentTargetInfo();
            out=rtwInfoStruct.codeGenTargetInterfaceChecksum;
        end

        function out=hasCustomRTWFiles(obj)
            rtwInfoStruct=obj.getCurrentTargetInfo();
            out=rtwInfoStruct.customRTWFiles;
        end

        function out=isERTTarget(obj)
            rtwInfoStruct=obj.getCurrentTargetInfo();
            out=rtwInfoStruct.isERTTarget;
        end

        function out=getBuildDirMap(obj)
            import Simulink.ModelReference.ProtectedModel.*;

            rtwInfoStruct=obj.getCurrentTargetInfo();
            out=rtwInfoStruct.modelToBuildDirMap;
        end

        function setBuildDirMap(obj,map)
            import Simulink.ModelReference.ProtectedModel.*;

            rtwInfoStruct=obj.getCurrentTargetInfo();
            rtwInfoStruct.modelToBuildDirMap=map;
            obj.targetToTargetInfoMap(getCurrentTarget(obj.modelName))=rtwInfoStruct;

        end

        function out=getBuildDirFromModel(obj,model)
            import Simulink.ModelReference.ProtectedModel.*;
            rtwInfoStruct=obj.getCurrentTargetInfo();
            [~,currentModel,~]=fileparts(model);
            out=rtwInfoStruct.modelToBuildDirMap(currentModel);
        end
    end

    methods(Access=private)
        function setNonInlineSfcs(obj,protectedModelCreator)
            field1='mexFileName';
            field2='checksum';
            sFcnNames=protectedModelCreator.getNonInlineSfcs();
            obj.nonInlineSFcns=struct(field1,sFcnNames,field2,{''});
            for i=1:numel(sFcnNames)
                mexFileName=sFcnNames{i};
                mexFile=which(mexFileName);
                checksum=sl('file2hash',mexFile);
                obj.nonInlineSFcns(i).checksum=checksum;

            end
        end
        function rtwInfoStruct=initInfoStruct(obj,protectedModelCreator,updating)
            import Simulink.ModelReference.ProtectedModel.*;
            rtwInfoStruct=obj.getDefaultTargetStruct();
            rtwInfoStruct.isERTTarget=protectedModelCreator.IsERTTarget;
            rtwInfoStruct.customRTWFiles=protectedModelCreator.CustomRTWFiles;

            for i=1:length(protectedModelCreator.SubModels)
                [~,currentModel,~]=fileparts(protectedModelCreator.SubModels{i});
                if strcmp(protectedModelCreator.Modes,'ViewOnly')&&updating





                    if~isempty(intersect(getSupportedTargets(protectedModelCreator.ModelName),'sim'))
                        currentT=getCurrentTarget(protectedModelCreator.ModelName);
                        setCurrentTarget(protectedModelCreator.ModelName,'sim');
                        oc=onCleanup(@()setCurrentTarget(protectedModelCreator.ModelName,currentT));
                        rtwInfoStruct.modelToBuildDirMap(currentModel)=protectedModelCreator.getBuildDir(currentModel);
                    end
                else
                    rtwInfoStruct.modelToBuildDirMap(currentModel)=protectedModelCreator.MapFromModelNameToBuildDir(currentModel);
                end
            end
        end

        function updateUserOptions(obj,protectedModelCreator)
            import Simulink.ModelReference.ProtectedModel.*;
            obj.obfuscateCode=protectedModelCreator.ObfuscateCode;
            obj.report=protectedModelCreator.Report;
            obj.webview=protectedModelCreator.Webview;
            obj.codeInterface=protectedModelCreator.CodeInterface;
            obj.hasSILSupport=protectedModelCreator.HasSILSupport;
            obj.hasPILSupport=protectedModelCreator.HasPILSupport;
            obj.hasSILPILSupportOnly=protectedModelCreator.HasSILPILSupportOnly;
            obj.hasHDLSupport=protectedModelCreator.HasHDLSupport;
            obj.hasCSupport=protectedModelCreator.HasCSupport;
            obj.binariesAndHeadersOnly=protectedModelCreator.BinariesAndHeadersOnly;
            obj.allFilesForStandaloneBuild=protectedModelCreator.AllFilesForStandaloneBuild;
            obj.modes=protectedModelCreator.Modes;
            if isempty(protectedModelCreator.CallbackMgr)
                obj.callbackMgr=CallbackManager({});
            else
                obj.callbackMgr=protectedModelCreator.CallbackMgr;
            end
        end

        function updateTargetInfoForEdit(obj,protectedModelCreator)

            rtwInfoStruct=obj.initInfoStruct(protectedModelCreator,true);


            obj.targetToTargetInfoMap=protectedModelCreator.originalInformation.targetToTargetInfoMap;
            obj.removeExtraTargets(protectedModelCreator);


            if~isa(protectedModelCreator,'Simulink.ModelReference.ProtectedModel.TargetRemover')
                obj.targetToTargetInfoMap(protectedModelCreator.Target)=rtwInfoStruct;
            end
        end

        function createNewTargetInfo(obj,protectedModelCreator)

            obj.targetToTargetInfoMap=containers.Map;


            rtwInfoStruct=obj.initInfoStruct(protectedModelCreator,false);

            if protectedModelCreator.isViewOnly()


                viewOnlyStruct=rtwInfoStruct;
                viewOnlyStruct.customRTWFiles=false;
                viewOnlyStruct.codeGenTargetInterfaceChecksum=[];
                viewOnlyStruct.isERTTarget='off';
                obj.targetToTargetInfoMap('viewonly')=viewOnlyStruct;
                return;
            elseif protectedModelCreator.supportsCodeGen()


                simOnlyStruct=rtwInfoStruct;
                simOnlyStruct.customRTWFiles=false;
                simOnlyStruct.codeGenTargetInterfaceChecksum=[];
                simOnlyStruct.isERTTarget='off';
                obj.targetToTargetInfoMap('sim')=simOnlyStruct;
            end


            obj.targetToTargetInfoMap(protectedModelCreator.Target)=rtwInfoStruct;
        end

        function updateEncryptionInfo(obj,protectedModelCreator)
            obj.isSimEncrypted=protectedModelCreator.isSimEncrypted;
            obj.isRTWEncrypted=protectedModelCreator.isRTWEncrypted;
            obj.isViewEncrypted=protectedModelCreator.isViewEncrypted;
            obj.isModifyEncrypted=protectedModelCreator.isModifyEncrypted;
            obj.isHDLEncrypted=protectedModelCreator.isHDLEncrypted;
        end

        function removeExtraTargets(obj,protectedModelCreator)
            if~strcmp(protectedModelCreator.Modes,'CodeGeneration')

                targetKeys=keys(obj.targetToTargetInfoMap);
                for i=1:length(targetKeys)
                    if~(strcmp(targetKeys{i},'sim')||strcmp(targetKeys{i},'viewonly'))
                        obj.targetToTargetInfoMap.remove(targetKeys{i});
                    end
                end


                if strcmp(protectedModelCreator.Modes,'ViewOnly')
                    if isKey(obj.targetToTargetInfoMap,'sim')
                        obj.targetToTargetInfoMap.remove('sim');
                    end
                end
            end
        end

        function out=getCurrentTargetInfo(obj)
            import Simulink.ModelReference.ProtectedModel.*;
            currentTarget=getCurrentTarget(obj.modelName);
            if isKey(obj.targetToTargetInfoMap,currentTarget)
                out=obj.targetToTargetInfoMap(currentTarget);
            else
                DAStudio.error('Simulink:protectedModel:TargetNotFoundInPackage',currentTarget,obj.modelName);
            end
        end
    end

    methods(Access=private,Static)
        function out=getDefaultTargetStruct()
            out.codeGenTargetInterfaceChecksum=[];
            out.isERTTarget=false;
            out.customRTWFiles=false;
            out.modelToBuildDirMap=containers.Map;
        end
    end
end



