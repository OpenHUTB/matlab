


classdef(Abstract,...
    AllowedSubclasses={
    ?sltest.assessments.Signal
    ?sltest.assessments.Constant
    ?sltest.assessments.Alias
    ?sltest.assessments.IfThenElse
    ?sltest.assessments.Unary
    ?sltest.assessments.Binary
    })Expression<matlab.mixin.internal.Scalar&matlab.mixin.CustomDisplay

    properties(SetAccess=private,Hidden)
internal
    end

    methods(Access=protected,Hidden)
        function header=getHeader(self)
            header=sprintf('  %s\n',message("sltest:assessments:AssessmentHeader",self.internal.stringLabel()).getString());
        end
    end

    methods(Hidden)
        function visit(self,functionHandle)
            functionHandle(self);
        end

        function res=transform(self,functionHandle)
            res=functionHandle(self,[]);
        end
    end

    methods(Hidden)
        syncWithSDI(self,quantitative)
        res=getResultData(self,startTime,endTime)
        tree=getSDITree(self,quantitative)
        addPatternFlag(self,context,metadata,flag)
        flagList=getPatternFlag(self,context,metadata)
    end

    methods(Hidden)
        function self=saveobj(self)

            if self.internal.hasMetadata()
                self.internal=struct('metadata',self.internal.metadata);
            else
                self.internal=[];
            end
        end

        function self=initializeInternal(self)
            self=self.loadobj(self);
        end
    end

    methods(Abstract,Access=protected,Hidden)
        internal=constructInternal(self)
    end

    methods(Static,Hidden)
        function obj=loadobj(obj)

            if isempty(obj.internal)
                obj.internal=obj.constructInternal();
            elseif isstruct(obj.internal)
                metadata=obj.internal.metadata;
                obj.internal=obj.constructInternal();
                obj.internal.setMetadata(metadata);
            else
                assert(false);
            end
        end

        function[convertedData,enumName]=castEnumData(data)
            assert(isenum(data));
            enumName=class(data);
            try
                enumtype=Simulink.data.getEnumTypeInfo(class(data),'StorageType');
            catch
                error(message('sltest:assessments:UnsupportedDataType',enumName));
            end

            if(strcmp(enumtype,'int'))
                enumtype='int32';
            end

            castFunc=str2func(enumtype);
            convertedData=castFunc(data);
        end

        function def=getEnumDefinition(data)
            assert(isenum(data));
            enumName=class(data);
            try
                enumtype=Simulink.data.getEnumTypeInfo(class(data),'StorageType');
            catch
                error(message('sltest:assessments:UnsupportedDataType',enumName));
            end

            if(strcmp(enumtype,'int'))
                enumtype='int32';
            end
            [m,s]=enumeration(enumName);


            castFunc=str2func(enumtype);
            m=castFunc(m);
            def.EnumName=enumName;
            def.EnumValues=m;
            def.EnumValueNames=s;
        end
    end
end
