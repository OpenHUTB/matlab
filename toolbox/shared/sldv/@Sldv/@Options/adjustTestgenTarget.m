



function obj=adjustTestgenTarget(this,simMode,needCopy)


    persistent simMode2TestgenEnum;
    if isempty(simMode2TestgenEnum)
        keys={...
        'Normal',...
        'SIL',...
'ModelRefSIL'...
        };
        values={...
        Sldv.utils.Options.TestgenTargetModelStr,...
        Sldv.utils.Options.TestgenTargetGeneratedCodeStr,...
        Sldv.utils.Options.TestgenTargetGeneratedModelRefCodeStr...
        };
        simMode2TestgenEnum=containers.Map(keys,values);
    end


    narginchk(2,3);


    obj=this;


    if~sldv.code.internal.isXilFeatureEnabled()||obj.Mode~="TestGeneration"
        return
    end


    simMode=convertStringsToChars(simMode);
    validatestring(simMode,{'Normal','SIL','ModelRefSIL'},2);

    if nargin<3
        needCopy=false;
    end


    obj.TestgenTarget=simMode2TestgenEnum(simMode);

    if needCopy
        obj=deepCopy(obj);
    end
