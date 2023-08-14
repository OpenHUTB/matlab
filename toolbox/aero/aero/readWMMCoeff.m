function[c,dc,epoch,fm,fn,k,maxdef,snorm]=readWMMCoeff(coeffFile,varargin)












    C=zeros(13);
    CD=zeros(13);
    SNORM=zeros(13);
    fn=zeros(1,13);
    fm=zeros(1,13);
    K=zeros(13,13);


    [fid,msg]=fopen(coeffFile,'r');
    if fid==-1
        error(message('aero:wrldmagm:customFileOpenError',coeffFile,msg));
    end
    cleanup=onCleanup(@()fclose(fid));

    try
        header=textscan(fid,'%f %s %s',1);
        epoch=header{1};
    catch
        error(message('aero:wrldmagm:customFileReadError',coeffFile));
    end

    MAXDEG=12;
    MAXORD=MAXDEG+1;




    try
        scan=textscan(fid,'%u %u %f %f %f %f',1);
        [N,M,GNM,HNM,DGNM,DHNM]=deal(scan{:});

        while(N<99)
            if(M<=N)
                C(N+1,M+1)=GNM;
                CD(N+1,M+1)=DGNM;
                if(M~=0)
                    C(M,N+1)=HNM;
                    CD(M,N+1)=DHNM;
                end
            end
            scan=textscan(fid,'%u %u %f %f %f %f',1);
            [N,M,GNM,HNM,DGNM,DHNM]=deal(scan{:});
        end
    catch ME
        error(message('aero:wrldmagm:customFileReadError',coeffFile));
    end


    SNORM(1,1)=1.;
    for N=2:MAXORD
        SNORM(N,1)=SNORM(N-1,1)*double(2*(N-1)-1)/double(N-1);
        J=2;
        for M=1:N
            K(N,M)=double((N-2)^2-(M-1)^2)/double((2*(N-1)-1)*(2*(N-1)-3));
            if(M>1)
                FLNMJ=double(((N-1)-(M-1)+1)*J)/double((N-1)+(M-1));
                SNORM(N,M)=SNORM(N,M-1)*sqrt(FLNMJ);
                J=1;
                C(M-1,N)=SNORM(N,M)*C(M-1,N);
                CD(M-1,N)=SNORM(N,M)*CD(M-1,N);
            end
            C(N,M)=SNORM(N,M)*C(N,M);
            CD(N,M)=SNORM(N,M)*CD(N,M);
        end
        fn(N)=double(N);
        fm(N)=double(N-1);
    end
    K(2,2)=0.;

    snorm=SNORM(:)';
    k=K';
    c=C';
    dc=CD';
    maxdef=MAXDEG;

    if nargin>1
        save(varargin{1},'c','dc','epoch','fm','fn','k','maxdef','snorm');
    end

end
