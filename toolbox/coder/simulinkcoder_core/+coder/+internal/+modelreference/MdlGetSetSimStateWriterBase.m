




classdef MdlGetSetSimStateWriterBase<coder.internal.modelreference.FunctionInterfaceWriter

    methods(Access=public)
        function this=MdlGetSetSimStateWriterBase(functionInterface,modelInterfaceUtils,codeInfoUtils,writer)
            this@coder.internal.modelreference.FunctionInterfaceWriter(functionInterface,modelInterfaceUtils,codeInfoUtils,writer);
        end

        function write(this)
            this.Writer.writeLine('\n#if !defined(MDL_SIM_STATE)');
            this.Writer.writeLine('\n# define MDL_SIM_STATE');
            this.Writer.writeLine('\n#endif // !defined(MDL_SIM_STATE)\n');
            this.writeFunctionHeader;
            this.writeFunctionBody;
            this.writeFunctionTrailer;
        end
    end


    methods(Access=protected,Abstract=true)
        writeFunctionBody(this)
    end

    methods(Access=protected)
        function writeFunctionTrailer(this)
            this.Writer.writeLine('}');
        end


        function call=getSsGetDWorkCall(this,isConst)
            if slfeature('ModelReferenceHonorsSimTargetLang')>0&&strcmp(get_param(this.ModelInterface.Name,'SimTargetLang'),'C++')
                dWorkType=this.ModelInterface.DWorkType;

                if(isConst)
                    constStr='const ';
                else
                    constStr='';
                end

                extraCastStart=['static_cast<',constStr,dWorkType,'*>('];
                extraCastEnd=')';
            else
                extraCastStart='';
                extraCastEnd='';
            end

            call=[extraCastStart,'ssGetDWork(S, 0)',extraCastEnd];
        end

        function writeLocalXPreamble(this,xDataType,xIsConst,isSingleInstance)
            if xIsConst
                this.declareVariable('',['const ',xDataType],'localX','ssGetContStates(S)');
            else
                this.declareVariable('',xDataType,'localX','ssGetContStates(S)');
            end

            if isSingleInstance
                this.Writer.writeLine('const int_T numStates = ssGetNumContStates(S);\n');
                this.Writer.writeLine(['const size_t numBytes = numStates*sizeof(',xDataType,');\n']);
            else
                this.Writer.writeLine(['const size_t numBytes = sizeof(',xDataType,');\n']);
            end
        end
    end

end










