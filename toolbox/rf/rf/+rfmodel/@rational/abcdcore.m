function[A,B,C,D,sharedPoles]=abcdcore(fit)





    validateattributes(fit,{'rfmodel.rational'},{'square'})



    nPorts=size(fit,1);
    D=real(reshape([fit.D],nPorts,nPorts));

    sharedPoles=all(length(fit(1).A)==cellfun(@length,{fit(:).A}))&&...
    all(fit(1).A==[fit(:).A],'all');


    if sharedPoles
        poles=fit(1).A;
        nPoles=size(poles,1);
        nA=nPorts*nPoles;
        C=zeros(nPorts,nA);
        if nA>0
            [VAr,DAr]=cdf2rdf(eye(nPoles),diag(poles(:,1)));
            A=kron(speye(nPorts),sparse(real(DAr)));
            B=kron(speye(nPorts),real(VAr\ones(nPoles,1)));
            rstart=1;
            for j=1:nPorts
                rend=rstart+nPoles;
                r=rstart:rend-1;
                for i=1:nPorts
                    hij=fit(i,j);
                    C(i,r)=real(hij.C.'*VAr);
                end
                rstart=rend;
            end
        else
            A=sparse(nA,nA);
            B=sparse(nA,nPorts);
        end
        return
    end


    allPoles=vertcat(fit(:).A);
    nA=length(allPoles);
    A=zeros(nA);
    B=zeros(nA,nPorts);
    C=zeros(nPorts,nA);
    rstart=1;
    for j=1:nPorts
        for i=1:nPorts
            hij=fit(i,j);
            nPoles=length(hij.A);
            rend=rstart+nPoles;
            r=rstart:rend-1;
            [VAr,DAr]=cdf2rdf(eye(nPoles),diag(hij.A));
            A(r,r)=real(DAr);
            B(r,j)=real(VAr\ones(length(r),1));
            C(i,r)=real(hij.C.'*VAr);
            rstart=rend;
        end
    end
    A=sparse(A);
    B=sparse(B);

