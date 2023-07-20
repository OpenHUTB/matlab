function functionHandle=getTransformFunctionHandle(transform)




    if contains(transform,'classreg.learning.transform')




        switch transform
        case 'classreg.learning.transform.logit'
            functionHandle=@(x)(1./(1+exp(-x)));
        case 'classreg.learning.transform.doublelogit'
            functionHandle=@(x)(1./(1+exp(-2.*x)));
        case 'classreg.learning.transform.invlogit'
            functionHandle=@(x)log(x./(1-x));
        case 'classreg.learning.transform.sign'
            functionHandle=@(x)sign(x);
        case 'classreg.learning.transform.symmetriclogit'
            functionHandle=@(x)(2./(1+exp(-x)))-1;
        case 'classreg.learning.transform.symmetric'
            functionHandle=@(x)(2.*x-1);
        otherwise


            functionHandle=[];
        end
    else
        functionHandle=str2func(transform);
    end
end



