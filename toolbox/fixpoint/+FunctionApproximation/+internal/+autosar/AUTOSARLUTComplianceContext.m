classdef AUTOSARLUTComplianceContext



...
...
...
...
...
...
...



    properties
        InputTypes(1,:){mustBeValidType(InputTypes)}=numerictype('single')
        OutputType(1,1){mustBeValidType(OutputType)}=numerictype('single')
        Interpolation FunctionApproximation.InterpolationMethod="Linear"
        BreakpointSpecification FunctionApproximation.BreakpointSpecification="ExplicitValues"
        StorageTypes(1,:){mustBeValidType(StorageTypes)}=[numerictype('single'),numerictype('single')]
    end

    properties(Dependent)
AllInputsSame
AllTypes
AllTypesSame
AllWLs
IFLMode
IFXMode
NumInputs
OutputWL
InputWLs
TargetRoutineLibrary
    end

    properties(Constant)
        ValidIFXWLs=[8,16]
    end

    methods
        function wls=get.InputWLs(this)
            wls=arrayfun(@(x)x.WordLength,this.InputTypes);
        end

        function wl=get.OutputWL(this)
            wl=this.OutputType.WordLength;
        end

        function n=get.NumInputs(this)
            n=numel(this.InputTypes);
        end

        function types=get.AllTypes(this)

            types=[this.InputTypes,this.OutputType];
        end

        function types=get.AllWLs(this)
            types=[this.InputWLs,this.OutputWL];
        end

        function areSame=get.AllTypesSame(this)
            allTypes=this.AllTypes;
            areSame=true;
            for i=2:(this.NumInputs+1)
                areSame=areSame&&isequal(allTypes(i),allTypes(1));
                if~areSame
                    break;
                end
            end
        end

        function areSame=get.AllInputsSame(this)
            allInputs=this.InputTypes;
            areSame=true;
            for i=2:this.NumInputs
                areSame=areSame&&isequal(allInputs(i),allInputs(1));
                if~areSame
                    break;
                end
            end
        end

        function isIFX=get.IFXMode(this)
            allTypes=this.AllTypes;
            allWLs=this.AllWLs;
            isIFX=~isempty(this.InputTypes)&&~isempty(this.OutputType);
            for i=1:(this.NumInputs+1)
                if isfloat(allTypes(i))||~any(ismember(allWLs(i),this.ValidIFXWLs))
                    isIFX=false;
                    break;
                end
            end
        end

        function isIFL=get.IFLMode(this)
            allTypes=this.AllTypes;
            isIFL=~isempty(this.InputTypes)&&~isempty(this.OutputType);
            for i=1:(this.NumInputs+1)
                if~issingle(allTypes(i))
                    isIFL=false;
                    break;
                end
            end
        end

        function routine=get.TargetRoutineLibrary(this)
            if this.IFLMode
                routine='IFL';
            elseif this.IFXMode
                routine='IFX';
            else
                routine='';
            end
        end
    end
end

function mustBeValidType(type)
    if~isempty(type)
        assert(isa(type,'embedded.numerictype'),'Must be embedded.numerictype');
    end
end


