classdef Generator<handle








    properties(Access=private)
        ModelName;
        Version;
    end

    methods(Access=public)



        function this=Generator(modelName,Version)
            this.ModelName=modelName;
            this.Version=Version;
        end




        function info=generate(this,fullFilePath,modelClassInstanceName,...
            customizeGroups,supportStructureElements,...
            support64bitIntegers,includeAUTOSARElements,includeDefaultEventList,useModifiedData,varargin)

            buildDir=RTW.getbuildDir(this.ModelName);
            codeDescriptor=coder.internal.getCodeDescriptorInternal(buildDir.BuildDirectory,this.ModelName,247362);
            codeDescRepo=buildDir.BuildDirectory;
            if Simulink.CodeMapping.isCppClassInterface(this.ModelName)
                codeInfo=codeDescriptor.getComponentInterface();
                assert(numel(codeInfo.InternalData)>0,sprintf('The code info is invalid for model %s.',this.ModelName));
                modelClassInstanceName=codeInfo.InternalData(1).Implementation.Identifier;
            end

            if isempty(this.Version)
                this.Version='1.71';
            end

            if strcmp(this.Version,'1.31')
                builder=coder.internal.asap2.Builder13(this.ModelName);
            elseif strcmp(this.Version,'1.4')
                builder=coder.internal.asap2.Builder14(this.ModelName);
            elseif strcmp(this.Version,'1.51')
                builder=coder.internal.asap2.Builder15(this.ModelName);
            elseif strcmp(this.Version,'1.6')
                builder=coder.internal.asap2.Builder16(this.ModelName);
            elseif strcmp(this.Version,'1.61')
                builder=coder.internal.asap2.Builder161(this.ModelName);
            elseif strcmp(this.Version,'1.7')
                builder=coder.internal.asap2.Builder17(this.ModelName);
            else
                builder=coder.internal.asap2.Builder171(this.ModelName);
            end
            if nargin>6
                ecuAddressExtension=varargin{6};
            end
            if ecuAddressExtension~=int64(32768)&&...
                ~builder.isEcuAddressExtensionSupported

                DAStudio.error('RTW:asap2:IncompatibleKeyword');
            end

            instanceName='';
            instancePath='';

            if isempty(useModifiedData)
                data=builder.getData();
                data.Support64bitIntegers=support64bitIntegers;
                data.SupportStructureElements=supportStructureElements;
                data.IncludeAUTOSARElements=includeAUTOSARElements;
                data.IncludeDefaultEventList=includeDefaultEventList;
                builder.buildRecursive(codeDescriptor,codeDescRepo,[],modelClassInstanceName,instanceName,instancePath,this.ModelName,customizeGroups);
            else
                data=useModifiedData.DataFromUser;
            end
            if isempty(fullFilePath)


                info=builder.getData();
            else
                info=data.ObjectsWithInvalidDataType;
                if strcmp(this.Version,'1.31')
                    writer=coder.internal.asap2.Writer13(data);
                elseif strcmp(this.Version,'1.4')
                    writer=coder.internal.asap2.Writer14(data);
                elseif strcmp(this.Version,'1.51')
                    writer=coder.internal.asap2.Writer15(data);
                elseif strcmp(this.Version,'1.6')
                    writer=coder.internal.asap2.Writer16(data);
                elseif strcmp(this.Version,'1.61')
                    writer=coder.internal.asap2.Writer161(data);
                elseif strcmp(this.Version,'1.7')
                    writer=coder.internal.asap2.Writer17(data);
                else
                    writer=coder.internal.asap2.Writer171(data);
                end
                writer.write(this.Version,fullFilePath,varargin{:});
            end

        end

    end

end


