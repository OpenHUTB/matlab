

function T=createRigid3DMat(rot,trans)
%#codegen






    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');

    T=zeros(4,'like',rot);
    coder.gpu.kernel;
    for i=1:3
        for j=1:3
            T(j,i)=rot(j,i);
        end
    end

    for i=1:3
        T(4,i)=trans(i);
    end
    T(4,4)=1;
end