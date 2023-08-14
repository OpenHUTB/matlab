classdef GeneratorCPP<handle








    properties(Access=private)
        ModelName;
        Version;
    end

    methods(Access=public)



        function this=GeneratorCPP(modelName,Version)
            this.ModelName=modelName;
            this.Version=Version;
        end




        function info=generate(this,fullFilePath,modelClassInstanceName,customizeGroups,supportStructureElements,support64bitIntegers,includeAUTOSARElements,includeDefaultEventList,useModifiedData,varargin)

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

            instanceName='';
            instancePath='';

            DataFromBuild=struct();
            if nargin>6
                ecuAddressExtension=varargin{6};
            end

            if isempty(useModifiedData)
                DataFromBuild=coder.internal.asap2.Builder(this.ModelName,codeDescRepo,this.Version,modelClassInstanceName,customizeGroups,supportStructureElements,support64bitIntegers,ecuAddressExtension,includeAUTOSARElements,includeDefaultEventList);
                data=coder.internal.asap2.DataCPP(DataFromBuild);
            else
                data=useModifiedData.DataFromUser;
            end
            if isempty(fullFilePath)


                info=data;
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


