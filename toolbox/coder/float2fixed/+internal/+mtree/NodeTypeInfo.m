




classdef NodeTypeInfo




    properties
        Ins(1,:)internal.mtree.Type=internal.mtree.Type.empty
        Outs(1,:)internal.mtree.Type=internal.mtree.Type.empty;
    end

    methods
        function this=NodeTypeInfo(ins,outs)


            if nargin>0
                if nargin==1
                    otherNodeTypeInfo=ins;
                    ins=otherNodeTypeInfo.Ins;
                    outs=otherNodeTypeInfo.Out;
                end

                if isempty(ins)
                    ins=internal.mtree.Type.empty;
                end

                if isempty(outs)
                    outs=internal.mtree.Type.empty;
                end

                this.Ins=ins;
                this.Outs=outs;
            end
        end

        function overflowMode=getOverflowMode(this)
            if~isempty(this.Outs)
                overflowMode=getOverflowMode(this.Outs(1));
            else
                error('no output types to get overflow mode from');
            end
        end

        function roundMode=getRoundMode(this)
            if~isempty(this.Outs)
                roundMode=getRoundMode(this.Outs(1));
            else
                error('no output types to get round mode from');
            end
        end
    end

end
