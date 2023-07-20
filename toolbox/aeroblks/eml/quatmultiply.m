function qout=quatmultiply(q,r)
%#codegen


    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');
    eml_invariant(nargin>0,eml_message('MATLAB:minrhs'));
    eml_invariant(isreal(q),eml_message('aeroblks:aeroblkquateml:isNotReal'));
    eml_invariant(size(q,2)==4,eml_message('aeroblks:aeroblkquateml:wrongDimension'));
    if nargin==1

        qout=q;
        for k=1:size(q,1)
            qk1=qout(k,1);


            qout(k,1)=qout(k,1)*qout(k,1)-qout(k,2)*qout(k,2)-...
            qout(k,3)*qout(k,3)-qout(k,4)*qout(k,4);




            qout(k,2)=(qout(k,2)*qk1)*2;
            qout(k,3)=(qout(k,3)*qk1)*2;
            qout(k,4)=(qout(k,4)*qk1)*2;
        end
    else
        eml_invariant(isreal(r),eml_message('aeroblks:aeroblkquateml:isNotReal2'));
        eml_invariant(size(r,2)==4,eml_message('aeroblks:aeroblkquateml:wrongDimension2'));
        eml_invariant(size(r,1)==size(q,1)||(size(r,1)==1||size(q,1)==1),...
        eml_message('aeroblks:aeroblkquateml:wrongRows'));
        m=max(size(q,1),size(r,1));
        qout=zeros([m,4],class(cast(0,class(q))+cast(0,class(r))));
        if isempty(q)||isempty(r)
            return
        end


        q1=q(1);q2=q(2);q3=q(3);q4=q(4);
        r1=r(1);r2=r(2);r3=r(3);r4=r(4);
        for k=1:m
            if size(q,1)>1
                q1=q(k,1);q2=q(k,2);q3=q(k,3);q4=q(k,4);
            end
            if size(r,1)>1
                r1=r(k,1);r2=r(k,2);r3=r(k,3);r4=r(k,4);
            end


            qout(k,1)=q1*r1-q2*r2-q3*r3-q4*r4;


            qout(k,2)=q1*r2+r1*q2+(q3*r4-q4*r3);
            qout(k,3)=q1*r3+r1*q3+(q4*r2-q2*r4);
            qout(k,4)=q1*r4+r1*q4+(q2*r3-q3*r2);
        end
    end
