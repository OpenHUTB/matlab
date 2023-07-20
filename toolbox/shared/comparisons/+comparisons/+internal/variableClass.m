function str=variableClass(var)%#ok<INUSD>







    w=whos('var');
    str=w.class;
    if w.complex
        str=['complex ',str];
    end
    if w.sparse
        str=['sparse ',str];
    end
end
