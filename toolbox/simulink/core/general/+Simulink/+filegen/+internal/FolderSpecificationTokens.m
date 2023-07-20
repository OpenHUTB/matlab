classdef(Hidden)FolderSpecificationTokens<handle





    properties(GetAccess=private,SetAccess=immutable)
        Values;
    end

    methods(Static,Hidden)
        function hiddenTokens=getHiddenTokens()
            hiddenTokens={'NODEID'};
        end
    end

    methods(Access=private)
        function registerToken(this,id,value)
            this.Values(['$(',id,')'])=value;
        end
    end

    methods
        function this=FolderSpecificationTokens(modelName,isProtected,resolveLoadDependentTokens,stf,hardwareDevice)

            this.Values=containers.Map('KeyType','char','ValueType','char');







            this.registerToken('CODEGENFOLDER',Simulink.fileGenControl('get','CodeGenFolder'));
            this.registerToken('CACHEFOLDER',Simulink.fileGenControl('get','CacheFolder'));
            this.registerToken('MODELNAME',modelName);

            if~resolveLoadDependentTokens
                this.registerToken('MDLREFINSTRDIR','');
                return;
            end



            reader=coder.internal.stf.FileReader.getInstance(stf);
            [~,stfName]=fileparts(stf);
            reader.parseSettings(modelName);

            if nargin<5||isempty(hardwareDevice)

                if isProtected
                    cs=Simulink.ProtectedModel.getConfigSet(modelName);
                else
                    cs=getActiveConfigSet(modelName);
                end


                hardwareDevice=get_param(cs,'TargetHWDeviceType');
            end

            this.registerToken('STF',stfName);
            this.registerToken('MDLBUILDSUFFIX',reader.GenSettings.BuildDirSuffix);
            this.registerToken('MDLREFBUILDSUFFIX',reader.GenSettings.ModelReferenceDirSuffix);
            this.registerToken('TARGETENVIRONMENT',Simulink.filegen.internal.FolderSpecificationTokens.resolveTargetEnvironemntToken(hardwareDevice,stf));
            this.registerToken('NODEID',Simulink.filegen.internal.FolderSpecificationTokens.resolveNodeIdToken(modelName));
            this.registerToken('MDLREFINSTRDIR',Simulink.filegen.internal.Helpers.getMdlRefInstrumentationDir(modelName));
            this.registerToken('ACCELINSTRDIR',Simulink.filegen.internal.Helpers.getAccelInstrumentationDir(modelName));
        end

        function value=getValueForToken(this,tokenId)
            if this.Values.isKey(tokenId)
                value=this.Values(tokenId);
            else
                value=tokenId;
            end
        end

        function replaceTokenValue(this,tokenId,newValue)
            if this.Values.isKey(tokenId)
                this.Values(tokenId)=newValue;
            end
        end







        function result=isSubsetOf(this,other)

            commonTokens=intersect(this.Values.keys,other.Values.keys);

            for i=1:length(commonTokens)
                token=commonTokens{i};
                if~strcmp(this.Values(token),other.Values(token))


                    result=false;
                    return;
                end
            end








            result=this.Values.Count<=other.Values.Count;
        end
    end

    methods(Static,Access=private)

        function value=resolveTargetEnvironemntToken(hardwareDevice,stf)

            if strcmp(hardwareDevice,'Unspecified')
                hardwareDevice='MATLAB Host';
            end



            hh=targetrepository.getHardwareImplementationHelper();
            device=hh.getDevice(hardwareDevice);








            invalidCharsRegExp='[\s()\\/<>.]';
            if isempty(device)
                value=hardwareDevice;
            elseif(device.AliasList.Size==0)
                value=sprintf('%s-%s',device.Manufacturer,device.Name);
            else
                value=device.AliasList.at(1);
            end


            value=regexprep(value,invalidCharsRegExp,'');



            [~,stfName]=fileparts(stf);
            if strcmp(stfName,'ert')
                return;
            end

            value=[value,'_',stfName];
        end

        function value=resolveNodeIdToken(modelName)

            [hasMultipleNodes,nodeToBuild]=...
            Simulink.DistributedTarget.DistributedTargetUtils.hasMultipleSoftwareNodes(modelName);
            if hasMultipleNodes
                value=['_',nodeToBuild];
            else
                value='';
            end
        end
    end
end



