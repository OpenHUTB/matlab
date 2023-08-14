



classdef SFunCgEmitter<legacycode.lct.gen.CodeEmitter


    properties(Constant,Hidden)
        DataKind2ApiKindMap=containers.Map(...
        {'Input','Output','DWork','Parameter'},...
        {'input','output','dWork','param'}...
        )
    end


    methods




        function this=SFunCgEmitter(lctObj)

            narginchk(1,1);
            this@legacycode.lct.gen.CodeEmitter(lctObj);
        end




        emit(this,varargin)

    end


    methods(Access=protected)


        emitClass(this,codeWriter)
        emitMethodBody(this,codeWriter,funKind)
    end

end
