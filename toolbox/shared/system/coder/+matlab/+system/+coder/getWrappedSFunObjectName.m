classdef getWrappedSFunObjectName


%#codegen
    methods(Static)
        function wrappedClassName=do(className)
            coder.allowpcode('plain');
            coder.extrinsic('matlab.system.coder.getWrappedSFunObjectName.impl');

            wrappedClassName=coder.const(matlab.system.coder.getWrappedSFunObjectName.impl(className));
        end

        function wrappedClassName=impl(className)
            wrappedClassName='';
            mc=meta.class.fromName(className);
            if(exist('matlab.system.SFunSystem','class')&&mc<?matlab.system.SFunSystem)||...
                (exist('matlab.system.CoreBlockSystem','class')&&mc<?matlab.system.CoreBlockSystem)
                parts=split(string(className),".");
                if numel(parts)>1
                    parts(end-1)=parts(end-1)+"codegen";
                    wrappedClassName=char(join(parts,"."));
                end
            end
            out=exist(wrappedClassName,'class')~=0;
            if~out
                wrappedClassName='';
            end
        end
    end
end
