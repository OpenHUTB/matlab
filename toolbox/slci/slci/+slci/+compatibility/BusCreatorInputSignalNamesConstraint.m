

classdef BusCreatorInputSignalNamesConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(~)
            out='The names of signals in the bus creator must match the input signal names.';
        end

        function obj=BusCreatorInputSignalNamesConstraint()
            obj.setEnum('BusCreatorInputSignalNames');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            inputs=aObj.ParentBlock().getParam('Inputs');
            inputSignalNames=aObj.ParentBlock().getParam('InputSignalNames');




            inputCell=strsplit(inputs,',');
            parsedInputs=regexp(inputCell,'''(.*)''','tokens');
            if any(cellfun(@(x)isempty(x),parsedInputs))
                return;
            end


            parsedInputs=cellfun(@(x)(x{1}),parsedInputs);


            parsedInputs=strrep(parsedInputs,'<','');
            parsedInputs=strrep(parsedInputs,'>','');

            assert(numel(parsedInputs)==numel(inputSignalNames));

            inputSignalNames=strrep(inputSignalNames,'<','');
            inputSignalNames=strrep(inputSignalNames,'>','');
            for i=1:numel(inputSignalNames)
                if~strcmpi(inputSignalNames{i},parsedInputs{i})

                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum(),...
                    aObj.ParentBlock().getName());
                    return;
                end
            end
        end
    end
end
