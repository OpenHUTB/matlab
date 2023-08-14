






function bp=getBlockPathFromBlock(block,varargin)
    if nargin>0
        block=convertStringsToChars(block);
    end

    [m,n]=size(block);

    if(m==1&&n==1)||ischar(block)

        if ishandle(block)
            bh=block;
        else
            bh=get_param(block,'handle');
        end

        if isempty(varargin)
            editor=SLM3I.SLDomain.getLastActiveEditorFor(get_param(get_param(bh,'Parent'),'handle'));
        else
            editor=varargin{1};
        end

        if isempty(editor)
            bp=Simulink.BlockPath(getfullname(bh));
        else
            id=editor.getHierarchyId;
            bp=Simulink.BlockPath.fromHierarchyIdAndHandle(id,bh);
            if isempty(bp.convertToCell)
                bp=Simulink.BlockPath(getfullname(bh));
            end
        end
    else

        bp(m,n)=Simulink.BlockPath;


        if iscell(block)
            for i=1:m
                for j=1:n
                    bp(i,j)=sltrace.utils.getBlockPathFromBlock(block{i,j},varargin{:});
                end
            end
        else
            for i=1:m
                for j=1:n
                    bp(i,j)=sltrace.utils.getBlockPathFromBlock(block(i,j),varargin{:});
                end
            end
        end
    end
end