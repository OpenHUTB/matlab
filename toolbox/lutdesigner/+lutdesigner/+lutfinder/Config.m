classdef Config<handle

    properties(SetAccess=immutable)
        Id char
        BlockType char
        MaskType char
        NumDims char
        Table char
        Axes(:,1)cell
    end

    methods(Static)
        function obj=fromSetting(s)
            if isempty(s)
                obj=lutdesigner.lutfinder.Config.empty(size(s));
            else
                obj=arrayfun(@(s)lutdesigner.lutfinder.Config(...
                s.BlockType,s.MaskType,s.NumDims,s.Table,s.Axes...
                ),s);
            end
        end

        function id=createId(blockType,maskType)
            id=sprintf("%s:%s",blockType,maskType);
        end
    end

    methods
        function this=Config(btype,mtype,ndims,table,axes)
            this.BlockType=btype;
            this.MaskType=mtype;
            this.NumDims=ndims;
            this.Table=table;
            if isstring(axes)
                axes=arrayfun(@(axis)char(axis),axes,'UniformOutput',false);
            end
            this.Axes=axes;
            this.Id=this.createId(btype,mtype);
        end

        function s=toSetting(this)
            if isempty(this)
                s=repmat(struct(...
                'BlockType','',...
                'MaskType','',...
                'NumDims','',...
                'Table','',...
                'Axes',''...
                ),size(this));
            else
                s=arrayfun(@(obj)scalarToSetting(obj),this(:));
            end
        end

        function disp(this)
            if isempty(this)
                fprintf("%s: \n\n    empty\n\n",class(this));
            else
                fprintf("%s: \n\n",class(this));
                disp(struct2table(toSetting(this(:))));
            end
        end
    end

    methods(Access=private)
        function s=scalarToSetting(this)
            s=struct(...
            'BlockType',this.BlockType,...
            'MaskType',this.MaskType,...
            'NumDims',this.NumDims,...
            'Table',this.Table...
            );
            s.Axes=this.Axes;
        end
    end
end
