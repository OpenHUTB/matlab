classdef AfterCodeGenGlobals<handle







    properties(Access=private)
        IsNewGeneratedCode;
        IsPil;
    end

    methods(Static=true,Access=private)

        function varargout=manageInstance(varargin)
            persistent theInstance;

            command=varargin{1};

            switch(command)
            case 'get'
                if isempty(theInstance)
                    theInstance=codertarget.tools.AfterCodeGenGlobals;
                end
                varargout{1}=theInstance;

            case 'set'
                theInstance=varargin{2};

            otherwise
                assert(false);
            end
        end

    end

    methods(Static=true)

        function val=getIsPil




            instance=codertarget.tools.AfterCodeGenGlobals.manageInstance('get');
            val=instance.IsPil;
            assert(~isempty(val),'Method must be called from a supported hook point')
        end

        function setIsPil(lIsPil)



            instance=codertarget.tools.AfterCodeGenGlobals.manageInstance('get');
            instance.IsPil=lIsPil;
        end

        function val=getIsNewGeneratedCode




            instance=codertarget.tools.AfterCodeGenGlobals.manageInstance('get');
            val=instance.IsNewGeneratedCode;
            assert(~isempty(val),'Method must be called from a supported hook point')
        end

        function setIsNewGeneratedCode(lIsNewGeneratedCode)




            instance=codertarget.tools.AfterCodeGenGlobals.manageInstance('get');
            instance.IsNewGeneratedCode=lIsNewGeneratedCode;
        end

        function clear



            codertarget.tools.AfterCodeGenGlobals.manageInstance('set',[]);
        end


    end

end
