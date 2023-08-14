classdef CxxFEOptionsManager<handle

    properties(Constant)
        instance=CGXE.CustomCode.CxxFEOptionsManager;
    end

    properties(Access=private)
        cFeOpts=[];
        cxxFeOpts=[];
        fAddMwInc;
        fForceLCC64;
    end

    methods
        function obj=CxxFEOptionsManager()
        end

        function feOpts=getCachedDefaultSelectedMEXCompilerFeOpts(obj,lang,addMWInc,forceLcc64)
            if nargin<3
                addMWInc=true;
            end
            if nargin<4
                forceLcc64=false;
            end
            isCpp=strcmpi(lang,'C++');
            langstr=strrep(lang,'+','x');
            cachedFeOptsIsValid=obj.isCachedFeOptsValid(langstr,addMWInc,forceLcc64);
            if~isCpp&&~isempty(obj.cFeOpts)&&cachedFeOptsIsValid
                feOpts=obj.cFeOpts.deepCopy();
            elseif isCpp&&~isempty(obj.cxxFeOpts)&&cachedFeOptsIsValid
                feOpts=obj.cxxFeOpts.deepCopy();
            else
                feOpts=internal.cxxfe.util.getFrontEndOptions('lang',lang,...
                'useMexSettings',true,'addMWInc',addMWInc,'forceLcc64',forceLcc64);
                obj.fAddMwInc.(langstr)=addMWInc;
                obj.fForceLCC64.(langstr)=forceLcc64;
                if isCpp
                    obj.cxxFeOpts=feOpts.deepCopy();
                else
                    obj.cFeOpts=feOpts.deepCopy();
                end
            end
        end

        function isValid=isCachedFeOptsValid(obj,langstr,addMWInc,forceLcc64)
            isValid=false;
            if isfield(obj.fAddMwInc,langstr)&&isfield(obj.fForceLCC64,langstr)
                isValid=(obj.fAddMwInc.(langstr)==addMWInc)&&(obj.fForceLCC64.(langstr)==forceLcc64);
            end
        end
    end

    methods(Static)
        function reset()
            obj=CGXE.CustomCode.CxxFEOptionsManager.instance;
            obj.cFeOpts=[];
            obj.cxxFeOpts=[];
        end
    end
end