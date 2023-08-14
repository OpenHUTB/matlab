





function value=getCoderInlineValue(ast)
    assert(isa(ast,'slci.ast.SFAstMatlabFunctionDef'));
    enumVal=ast.getInline();
    assert(isa(enumVal,'slci.compatibility.CoderInlineEnum'));
    switch enumVal
    case slci.compatibility.CoderInlineEnum.Unknown
        value=int32(slci.compatibility.CoderInlineEnum.Default);
    case{slci.compatibility.CoderInlineEnum.Default,...
        slci.compatibility.CoderInlineEnum.Never,...
        slci.compatibility.CoderInlineEnum.Always}
        value=int32(enumVal);
    otherwise
        assert(false,'Invalid Coder.Inline value');
    end
end
