


classdef CodeView<handle

    properties
cv_c
cv_hdl
    end

    properties(Access=private)
fStudio
fModelHandle
        fListeners={}
    end

    methods

        function obj=CodeView(st)
            obj.init(st);





        end


        function delete(obj)

            for i=1:numel(obj.fListeners)
                delete(obj.fListeners{i});
            end
            obj.fListeners={};

        end
    end

    methods

        show(obj,option);
        refresh(obj,option);
        turnOff(obj);
        toggleAnnotation(obj);

        addAnnotation(obj,varargin)
        onFileChange(obj,codeLanguge,file)
        onCodeViewEvent(obj,codeLanguage,file)
        hiliteAnnotation(obj,codeLanguage,codeline)
        updateAnnotation(obj,codeLanguage,data)


        onCodeViewEventC(obj,varargin)
        onCodeViewEventHDL(obj,varargin)


        function out=getModelHandle(obj)
            out=obj.fModelHandle;
        end


        function out=getStudio(obj)
            out=obj.fStudio;
        end


        function out=getCV(obj,codeLanguage)
            out=[];
            if strcmpi(codeLanguage,'c')
                out=obj.cv_c;
            elseif strcmpi(codeLanguage,'hdl')
                out=obj.cv_hdl;
            end
        end
    end

    methods(Access=private)

        init(obj,st);
        setAnnotationFlag(obj,cv,flag);
        refreshAnnotation(obj,codeLanguage);
    end
end