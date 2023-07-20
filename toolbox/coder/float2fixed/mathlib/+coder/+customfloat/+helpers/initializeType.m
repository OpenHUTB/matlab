%#codegen



function obj=initializeType(s,cfType)
    coder.allowpcode('plain');

    obj=CustomFloat(zeros(s,'like',fi([],0,cfType.WordLength,0)),cfType,'typecast');
end