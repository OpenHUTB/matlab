




classdef HookInfo<handle
    properties
        SourceFiles={}
        NonSourceFiles={}
        ExportedSymbols={}
    end

    methods
        function obj=HookInfo(srcFileList,otherFileList,modelName,mdlRefTgtType)
            obj.SourceFiles=srcFileList;
            obj.NonSourceFiles=otherFileList;

            lSystemTargetFile=get_param(modelName,'SystemTargetFile');
            infoStruct=coder.internal.infoMATPostBuild('loadNoConfigSet',...
            'binfo',...
            modelName,...
            mdlRefTgtType,...
            lSystemTargetFile);

            if~isempty(infoStruct.mdlInfos)

                idStructs=infoStruct.mdlInfos.mdlInfo;
                obj.ExportedSymbols=cell(1,length(idStructs));
                for i=1:length(idStructs)
                    obj.ExportedSymbols{i}=idStructs{i}.Id;
                end
            else
                obj.ExportedSymbols={};
            end
        end
    end
end

