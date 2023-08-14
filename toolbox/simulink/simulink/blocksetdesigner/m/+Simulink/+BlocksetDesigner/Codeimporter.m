classdef Codeimporter<Simulink.BlocksetDesigner.Block




    properties
    end

    methods(Access=public,Hidden=true)

        function obj=Codeimporter()
            obj=obj@Simulink.BlocksetDesigner.Block();
        end

        function ccallerLibInfo=create(obj,codeImporterInfo)
            existingCCallerBlkHandles=Simulink.findBlocksOfType(codeImporterInfo.LibraryFileName,'CCaller');
            for idx=1:numel(existingCCallerBlkHandles)
                hdl=existingCCallerBlkHandles(idx);
                portSpecObj=get_param(hdl,'FunctionPortSpecification');
                ccallerBlkInfo(idx).BlockName=get_param(hdl,'FunctionName');
                ccallerBlkInfo(idx).CPrototype=portSpecObj.CPrototype;
            end
            ccallerLibInfo.LibName=codeImporterInfo.LibraryFileName;
            ccallerLibInfo.OpenFunction=codeImporterInfo.LibraryFileName;
            ccallerLibInfo.Id=['ccallerlibrary','_',char(matlab.lang.internal.uuid)];
            ccallerLibInfo.Type='codeimporter';
            ccallerLibInfo.ccallerBlocks=ccallerBlkInfo;
            ccallerLibInfo.ParentId=codeImporterInfo.ParentIdForBlocksetDesigner;
        end
    end

end