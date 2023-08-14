



classdef MtreeAttributes<handle

    properties
MTreeRoot
Attributes
    end

    properties(Constant)
        UNKNOWN=-2;
        UNDEF=-1;
        DOUBLE=0;
        CHAR=1;
        INT=2;
        ENUM=3;
        BOOLEAN=4;
        FIXPT=5;
        STRUCT=6;
    end

    methods(Access=public)
        function this=MtreeAttributes(tree)

            this.MTreeRoot=tree.root;

            default=struct(...
            'MtreeString','',...
            'IsCastRedundant',false,...
            'UseColonSyntax',false,...
            'TentativeType',[],...
            'IsConstant',false,...
            'MxLocInfo',[],...
            'SimMin',[],...
            'SimMax',[],...
            'IsAlwaysInteger',[],...
            'ScriptString','',...
            'Kind',[],...
            'CalledFunction',[],...
            'SimulationHitCount',[],...
            'ForIndexAssignedLater',[],...
            'isExecutedInSimulation',false,...
            'isDeadCodeStart',false,...
            'isDeadCodeEnd',false,...
            'HitOrCallCount',0,...
            'FormattedCode',''...
            );
            N=length(this.MTreeRoot.wholetree.indices);
            this.Attributes=default;
            this.Attributes(1:N)=default;
            for ii=1:N
                this.Attributes(ii)=default;
            end
        end


        function bVal=isLogged(this,node)
            attribs=subsref(this,node);
            if~isempty(attribs)&&~isempty(attribs.SimMin)&&~isempty(attribs.SimMax)
                bVal=true;
            else
                bVal=false;
            end
        end

        function this=subsasgn(this,node,val)
            assert(strcmp(node(1).type,'()'));
            n=node(1).subs{1};
            ind=n.indices;
            if length(node)>1
                if length(node)>2
                    error('implementation not found');
                end
                if strcmp(node(2).type,'.')
                    this.Attributes(ind).(node(2).subs)=val;
                else
                    error('implementation not found');
                end
            else
                this.Attributes(ind)=val;
            end
        end

        function val=subsref(this,subsData)
            if length(subsData)>2
                error('implementation not found');
            end
            if(strcmp(subsData(1).type,'()'));
                assert(length(subsData(1).subs)==this.supportedSubsRefLen(),'Internal Error: incorrect number of subscript indices');
                node=subsData(1).subs{1};
                ind=node.indices;
                val=this.Attributes(ind);
                if length(subsData)>1
                    if strcmp(subsData(2).type,'.')
                        val=val.(subsData(2).subs);
                    else
                        error('implementation not found');
                    end
                end
            elseif(strcmp(subsData(1).type,'.'));
                if length(subsData)>1
                    error('implementation not found');
                end
                val=this.(subsData(1).subs);
            else
                error('implementation not found');
            end
        end



        function n=numel(this,varargin)
            n=this.supportedSubsRefLen();
        end
    end

    methods(Access=private)
        function val=supportedSubsRefLen(~)
            val=1;
        end
    end

    methods(Static)













        function res=IsImpossibleRange(rMin,rMax)
            res=(rMin==Inf)&&(rMax==-Inf);
        end
    end

end
