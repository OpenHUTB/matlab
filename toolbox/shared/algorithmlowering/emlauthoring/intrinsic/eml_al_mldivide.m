function y=eml_al_mldivide(u1,u2)



%#codegen

    coder.allowpcode('plain');
    y=u1\u2;


end


function y=local_mldivide(u1,u2)

    [lu,piv]=lu_NxN(u1);

    x=forward_substitution(lu,u2,piv,true);

    y=backward_substitution(lu,x,false);

end


function[A,piv]=lu_NxN(u1)


    A=u1;
    n=cast(size(A,1),eml_index_class);
    piv=cast(1:n,eml_index_class);






    for k=1:n


        p=k;





        Amax=abs(A(k,k));
        for i=k+1:n
            q=abs(A(i,k));
            if q>Amax
                p=i;
                Amax=q;
            end
        end



        if(p~=k)

            for j=1:n

                t=A(p,j);A(p,j)=A(k,j);A(k,j)=t;
            end


            t1=piv(p);piv(p)=piv(k);piv(k)=t1;
        end



        Adiag=A(k,k);
        if(Adiag~=0)


            Adiag=1/Adiag;
            for i=k+1:n
                A(i,k)=A(i,k)*Adiag;
            end


            for j=k+1:n

                for i=k+1:n
                    A(i,j)=A(i,j)-A(i,k)*A(k,j);
                end
            end

        end


    end


end




function[X]=forward_substitution(L,B,piv,unit_lower)






    N=cast(size(L,1),eml_index_class);
    P=cast(size(B,2),eml_index_class);
    X=coder.nullcopy(eml_expand(eml_scalar_eg(B),size(B)));

    if(isa(B,'double'))
        opType='double';
    else
        opType='single';
    end

    for k=1:P
        for i=1:N
            s=cast(0,opType);

            xj=cast(1,eml_index_class);

            Lrow=i;
            Lcol=cast(1,eml_index_class);
            for j=i:-1:2
                s=s+L(Lrow,Lcol)*X(xj,k);
                Lcol=Lcol+1;
                xj=xj+1;
            end

            if(unit_lower==1)
                X(xj,k)=B(piv(i),k)-s;
            else
                X(xj,k)=(B(piv(i),k)-s)/L(Lrow,Lcol);
            end

        end

    end

end


function y=backward_substitution(U,B,unit_upper)

    if(isa(B,'double'))
        opType='double';
    else
        opType='single';
    end

    N=cast(size(U,1),eml_index_class);
    P=cast(size(B,2),eml_index_class);
    y=coder.nullcopy(eml_expand(eml_scalar_eg(B),size(B)));

    for k=P:-1:1

        Urow=cast(N,opType);

        for i=1:N

            xj=cast(N,eml_index_class);

            s=cast(0,opType);

            Ucol=cast(N,eml_index_class);
            for j=i:-1:2
                s=s+U(Urow,Ucol)*y(xj,k);
                Ucol=Ucol-1;
                xj=xj-1;
            end

            if(unit_upper)
                y(xj,k)=B(Ucol,k)-s;
            else
                y(xj,k)=(B(Ucol,k)-s)/U(Urow,Ucol);
            end

            Urow=Urow-1;

        end

    end


end
