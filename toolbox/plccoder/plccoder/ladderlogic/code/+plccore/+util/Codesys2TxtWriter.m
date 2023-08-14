classdef Codesys2TxtWriter<plccore.util.TxtWriter



    methods
        function obj=Codesys2TxtWriter
            obj@plccore.util.TxtWriter;
            obj.Kind='Codesys2TxtWriter';
        end

        function beginGenProgram(obj,name)
            code=sprintf('PROGRAM %s',name);
            obj.writeLine(code);
        end

        function endGenProgram(obj)
            obj.writeNewline;
            code=sprintf('END_PROGRAM');
            obj.writeLine(code);
        end

        function beginGenFB(obj,name)
            code=sprintf('FUNCTION_BLOCK %s',name);
            obj.writeLine(code);
        end

        function endGenFB(obj)
            obj.writeNewline;
            code=sprintf('END_FUNCTION_BLOCK');
            obj.writeLine(code);
        end

        function beginVarDecl(obj,var_decl_category)
            code=sprintf('%s',var_decl_category);
            obj.writeLine(code);
        end

        function endVarDecl(obj)
            code=sprintf('END_VAR');
            obj.writeLine(code);
        end

        function genVarDecl(obj,var)
            import plccore.visitor.Codesys2Emitter_InitialValueVisitor;
            obj.indent;
            init_val=var.initialValue;
            init_val_txt='';
            if~isempty(init_val)
                ivv=Codesys2Emitter_InitialValueVisitor;
                init_val_txt=init_val.accept(ivv,[]);
            end
            code=sprintf('%s: %s%s;',var.name,var.type.toString,init_val_txt);
            obj.writeLine(code);
        end

        function beginLadderBody(obj,num_rungs)
            obj.writeLine('_LD_BODY');
            code=sprintf('_NETWORKS : %d;',num_rungs);
            obj.writeLine(code);
        end

        function beginRung(obj)
            obj.writeLine('_NETWORK');
            obj.writeNewline;
            obj.writeLine('_COMMENT');
            obj.writeLine('''''');
            obj.writeLine('_END_COMMENT');
        end

        function beginRungInputSection(obj)
            obj.writeLine('_LD_ASSIGN');
        end

        function endRungInputSection(obj)
            obj.writeLine('_EXPRESSION');
            obj.writeLine('_POSITIV');
            obj.writeNewline;
            obj.writeNewline;
        end

        function genRungInputEmpty(obj)
            obj.writeLine('_EMPTY');
        end

        function genRungPositiveContact(obj,var_name)
            obj.genRungContact(var_name,'_POSITIV');
        end

        function genRungNegativeContact(obj,var_name)
            obj.genRungContact(var_name,'_NEGATIV');
        end

        function genRungContact(obj,var_name,contact_kind)
            obj.writeLine('_LD_CONTACT');
            obj.writeLine(sprintf('%s',var_name));
            obj.writeLine('_EXPRESSION');
            obj.writeLine(contact_kind);
        end

        function beginRungSeq(obj,num_op)
            obj.writeLine('_LD_AND');
            obj.writeLine(sprintf('_LD_OPERATOR : %d',num_op));
        end

        function beginRungPar(obj,num_op)
            obj.writeLine('_LD_OR');
            obj.writeLine(sprintf('_LD_OPERATOR : %d',num_op));
        end

        function endRungSeqPar(obj)
            obj.writeLine('_EXPRESSION');
            obj.writeLine('_POSITIV');
        end

        function genRungOutputSection(obj,num_output)
            obj.writeLine('ENABLELIST : 0');
            obj.writeLine('ENABLELIST_END');
            obj.writeLine(sprintf('_OUTPUTS : %d',num_output));
        end

        function genRungCoil(obj,var_name)
            obj.writeLine('_OUTPUT');
            obj.writeLine('_POSITIV');
            obj.writeLine('_NO_SET');
            obj.writeLine(sprintf('%s',var_name));
        end

        function genRungSetCoil(obj,var_name)
            obj.writeLine('_OUTPUT');
            obj.writeLine('_POSITIV');
            obj.writeLine('_SET');
            obj.writeLine(sprintf('%s',var_name));
        end

        function genRungResetCoil(obj,var_name)
            obj.writeLine('_OUTPUT');
            obj.writeLine('_NEGATIV');
            obj.writeLine('_SET');
            obj.writeLine(sprintf('%s',var_name));
        end

        function genRungTimer(obj,timer_call)
            obj.genRungFBCall(timer_call);
        end

        function genRungFBCallArgExpr(obj,expr)
            if(isa(expr,'plccore.expr.ConstExpr'))
                val=expr.value;
                if(isa(val,'plccore.common.TimeValue'))
                    val_txt=sprintf('t#%s%s',val.value,val.unit);
                else
                    val_txt=val.value;
                end
                obj.writeLine(val_txt);
                return;
            end

            assert(isa(expr,'plccore.expr.VarExpr'));
            obj.writeLine(sprintf('%s',expr.toString));
        end

        function genRungFBCall(obj,fb_call)
            obj.writeLine('_FUNCTIONBLOCK');
            fb_inst=fb_call.instance;
            assert(isa(fb_inst,'plccore.expr.VarExpr'));
            obj.writeLine(sprintf('%s',fb_inst.toString));
            obj.genRungFBCallInputs(fb_call);
            obj.writeLine('_EXPRESSION');
            obj.writeLine('_POSITIV');
            obj.writeLine(fb_call.pou.name);
            obj.genRungFBCallOutputs(fb_call);
        end

        function genRungFBCallInputs(obj,fb_call)
            obj.writeLine(sprintf('_BOX_EXPR : %d',numel(fb_call.inputs)+1));
            obj.writeLine('_EMPTY');
            for i=1:numel(fb_call.inputs)
                obj.writeLine('_OPERAND');
                obj.writeLine('_EXPRESSION');
                obj.writeLine('_POSITIV');
                obj.genRungFBCallArgExpr(fb_call.inputs{i});
            end
        end

        function genRungFBCallOutputs(obj,fb_call)
            obj.writeLine(sprintf('_OUTPUTS : %d',numel(fb_call.outputs)));
            for i=1:numel(fb_call.outputs)
                obj.writeLine('_OUTPUT');
                obj.writeLine('_POSITIV');
                obj.writeLine('_NO_SET');
                if(isempty(fb_call.outputs{i}))
                    obj.writeLine('_EMPTY');
                else
                    output_expr=fb_call.outputs{i};
                    assert(isa(output_expr,'plccore.expr.VarExpr'));
                    obj.writeLine(sprintf('%s',output_expr.toString));
                end
            end
        end

        function beginGenGlobalVar(obj)
            code=sprintf('VAR_GLOBAL');
            obj.writeLine(code);
        end

        function endGenGlobalVar(obj)
            code=sprintf('END_VAR');
            obj.writeLine(code);
        end
    end
end


