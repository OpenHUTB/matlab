classdef mathworks_codegen_LUTRangeCheckCode<edittime.Violation
    methods
        function self=mathworks_codegen_LUTRangeCheckCode(system,blkHandle,checkID)
            self=self@edittime.Violation(blkHandle,system,checkID);
            self.createDiagnostic();
            self.setType(edittime.ViolationType.MAWarning);
        end

        function createDiagnostic(obj)
            blkType=get_param(obj.blkHandle,'BlockType');
            blkParam='RemoveProtectionInput';
            blkActionMessage='Remove protection against out-of-range input in generated code';
            if(strcmp(blkType,'Interpolation_n-D'))
                blkParam='RemoveProtectionIndex';
                blkActionMessage='Remove protection against out-of-range index in generated code';
            end
            obj.diagnostic=MSLDiagnostic(message('sledittimecheck:edittimecheck:mathworks_codegen_LUTRangeCheckCode',...
            regexprep(getfullname(obj.blkHandle),'[\n\r]+',' '),blkParam,blkActionMessage));
        end
        function size=addToPopupSize(obj)
            size=[0,160];
        end
        function[map_path,topic_id]=getCSH(obj)
            map_path='mapkey:ma.ecoder';
            topic_id='MATitleIdentLUTRangeCheckCode';
        end
    end
end
