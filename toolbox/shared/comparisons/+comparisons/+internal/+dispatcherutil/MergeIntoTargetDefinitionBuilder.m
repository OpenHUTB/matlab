classdef MergeIntoTargetDefinitionBuilder<handle




    properties(Access=private)
        Config{mustBeMergeIntoTarget}=comparisons.internal.merge.MergeIntoTarget.empty()
        Theirs{mustBeTextScalarOrEmpty}=[]
        Base{mustBeTextScalarOrEmpty}=[]
        Mine{mustBeTextScalarOrEmpty}=[]
        Type{mustBeTextScalarOrEmpty}=[]
    end

    methods(Access=public)

        function setConfig(obj,config)
            obj.Config=config;
        end

        function setTheirs(obj,theirs)
            obj.Theirs=theirs;
        end

        function setBase(obj,base)
            obj.Base=base;
        end

        function setMine(obj,mine)
            obj.Mine=mine;
        end

        function setType(obj,type)
            obj.Type=type;
        end

        function jDefinition=build(obj)
            if any(cellfun(@isempty,{obj.Theirs,obj.Mine,obj.Config,obj.Type}))
                error('MergeIntoTargetDefinitionBuilder:MissingValues',...
                'Theirs, mine, config and type must be set to build definition.');
            end

            builder=makeComparisonDefinitionBuilder();

            builder=obj.addSources(builder);
            builder=obj.addMergeData(builder);
            builder=disableSaveAndClose(builder);
            builder.setComparisonType(...
            comparisons.internal.dispatcherutil.getJComparisonType(obj.Type));

            jDefinition=builder.build();
        end

    end

    methods(Access=private)

        function builder=addSources(obj,builder)
            if~isempty(obj.Base)
                builder=addSource(builder,obj.Base);
            end
            builder=addSource(builder,obj.Theirs);
            builder=addSource(builder,obj.Mine);
        end

        function builder=addMergeData(obj,builder)
            import com.mathworks.comparisons.scm.CParameterSourceControlMergeData;
            builder.addComparisonParameter(...
            CParameterSourceControlMergeData.getInstance(),obj.makeMergeData());
        end

        function mergeData=makeMergeData(obj)
            builder=makeImmutableSourceControlMergeDataBuilder();

            builder.setTheirsFile(java.io.File(obj.Theirs));
            builder.setMineFile(java.io.File(obj.Mine));
            if~isempty(obj.Base)
                builder.setBaseFile(java.io.File(obj.Base));
            end
            builder.setTargetFile(java.io.File(obj.Config.targetPath));

            import com.mathworks.comparisons.main.MatlabCallback;
            import com.mathworks.comparisons.main.MatlabPostMergeAction;
            cb=MatlabCallback(obj.Config.postMergeCallback);
            builder.setPostMergeAction(MatlabPostMergeAction(cb));

            mergeData=builder.build();
        end

    end
end

function mustBeMergeIntoTarget(config)
    mustBeA(config,'comparisons.internal.merge.MergeIntoTarget');
end

function mustBeTextScalarOrEmpty(text)
    if isempty(text)
        return;
    else
        mustBeTextScalar(text);
    end
end

function builder=makeComparisonDefinitionBuilder()
    builder=com.mathworks.comparisons.compare.ComparisonDefinitionBuilder();
end

function builder=makeImmutableSourceControlMergeDataBuilder()
    builder=javaObject('com.mathworks.comparisons.scm.ImmutableSourceControlMergeData$Builder');
end

function builder=addSource(builder,path)
    import com.mathworks.comparisons.source.impl.LocalFileSource
    builder.addComparisonSource(LocalFileSource(java.io.File(path),path));
end

function builder=disableSaveAndClose(builder)
    import com.mathworks.comparisons.scm.CParameterDisableSaveAndClose;
    builder.addComparisonParameter(...
    CParameterDisableSaveAndClose.getInstance(),java.lang.Boolean(true));
end
