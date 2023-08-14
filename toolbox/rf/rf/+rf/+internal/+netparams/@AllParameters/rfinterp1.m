function obj=rfinterp1(obj,newfreqs,extrap)




    rf.internal.checkfreq(newfreqs)
    numnewfreq=numel(newfreqs);

    oldfreqs=obj.Frequencies;
    olddata=obj.Parameters;


    oldfreqs(end+1,:)=oldfreqs(end)+eps(oldfreqs(end));
    olddata=cat(3,olddata,olddata(:,:,end));

    numports=obj.NumPorts;
    newdata=zeros(numports,numports,numnewfreq);

    if nargin==3&&strcmpi(extrap,'extrap')
        i=(newfreqs<obj.Frequencies(1));
        j=(newfreqs>obj.Frequencies(end));
        k=~i&~j;

        if any(i)
            freqs=[-oldfreqs(1);oldfreqs(1)];
            for cc=1:numports
                for rr=1:numports
                    vec=[conj(olddata(rr,cc,1));olddata(rr,cc,1)];
                    newvec=interp1(freqs,vec,newfreqs(i));
                    newdata(rr,cc,i)=reshape(newvec,1,1,[]);
                end
            end
        end

        if any(k)
            for cc=1:numports
                for rr=1:numports
                    oldvec=squeeze(olddata(rr,cc,:));
                    newvec=interp1(oldfreqs,oldvec,newfreqs(k));
                    newdata(rr,cc,k)=reshape(newvec,1,1,sum(k));
                end
            end
        end

        if any(j)

            newdata(:,:,j)=repmat(olddata(:,:,end),[1,1,sum(j)]);
        end
    else
        for cc=1:numports
            for rr=1:numports
                oldvec=squeeze(olddata(rr,cc,:));
                newvec=interp1(oldfreqs,oldvec,newfreqs);
                newdata(rr,cc,:)=reshape(newvec,1,1,numnewfreq);
            end
        end
    end

    obj.StoredData={newdata,newfreqs};
