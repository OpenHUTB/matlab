


classdef HiddenBlockObject<slci.results.BlockObject


    properties(SetAccess=protected,GetAccess=public)


        fOrigBlock='';
    end


    methods

        function obj=HiddenBlockObject(blkHandle)
            if nargin==0
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'HIDDENBLOCKOBJECT');
            end
            obj=obj@slci.results.BlockObject(blkHandle);
            obj.Key=slci.results.HiddenBlockObject.constructKey(blkHandle);
        end
    end

    methods(Access=public,Hidden=true)

        function aDispName=getDispName(obj,datamgr)

            repModelwith=obj.fReportConfig.getRepModelName();
            mdl=datamgr.getMetaData('ModelName');
            replacedName=regexprep(obj.getBlockFullName(),mdl,repModelwith,'once');
            aDispName=slci.internal.encodeString([replacedName,'(hidden block)'],...
            'all','encode');
        end

        function hlink=getLink(obj,datamgr)
            origKey=obj.getOrigBlock();
            if isempty(origKey)
                hlink=[];
            else
                origObject=datamgr.getObject('BLOCK',origKey);
                hlink=origObject.getLink(datamgr);
            end
        end

        function setOrigBlock(obj,aOrigBlk)
            if isa(aOrigBlk,'slci.results.BlockObject')||...
                isa(aOrigBlk,'slci.results.ChartObject')
                obj.fOrigBlock=aOrigBlk.getKey();
            else
                assert(false,'Invalid original block for hidden block object');
            end
        end

        function aOrigKey=getOrigBlock(obj)
            aOrigKey=obj.fOrigBlock;
        end

    end

    methods(Access=public,Static=true,Hidden=true)

        function key=constructKey(blkHandle)
            key=sprintf('%10.10f',blkHandle);
        end

    end

end
