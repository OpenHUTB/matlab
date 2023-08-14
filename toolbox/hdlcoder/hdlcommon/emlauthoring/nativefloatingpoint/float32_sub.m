%#codegen
function[S,E,M]=float32_sub(AS,AE,AM,BS,BE,BM,Simp)


    coder.allowpcode('plain')

    [S,E,M]=float32_add(AS,AE,AM,~BS,BE,BM,Simp);
end
