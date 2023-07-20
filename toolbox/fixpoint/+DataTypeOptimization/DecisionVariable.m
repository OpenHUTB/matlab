classdef DecisionVariable<handle












    properties(SetAccess=private)
definitionDomain

    end

    properties(SetAccess=private,Hidden)
group

    end

    methods
        function this=DecisionVariable(definitionDomain,group)

            this.definitionDomain=definitionDomain;
            this.group=group;

        end

        function bitWidth=getWordLengthBitWidth(this,fractionDomainIndex)
            bitWidth=this.definitionDomain.wordLengthVector(fractionDomainIndex);

        end

        function total=getTotalBitWidth(this,fractionDomainIndex)


            total=this.getWordLengthBitWidth(fractionDomainIndex)*double(this.group.members.Count);
        end

    end

    methods(Hidden)
        function show(this)

            fprintf('Group %i\n',this.group.id);
            members=this.group.members.values;
            for mIndex=1:numel(members)
                fprintf('\t %s ',members{mIndex}.getDisplayLabel);
                if isa(members{mIndex},'fxptds.AbstractSimulinkResult')
                    fprintf(':::');
                    blkObj=members{mIndex}.UniqueIdentifier.getObject();
                    bp=Simulink.BlockPath(blkObj.getFullName);
                    disp(bp,1);
                else
                    fprintf('\n');
                end
            end
            this.definitionDomain.show();

        end
    end

end

