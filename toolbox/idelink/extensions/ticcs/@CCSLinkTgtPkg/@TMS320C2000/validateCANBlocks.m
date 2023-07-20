function validateCANBlocks(h,IRmodelInfo,ubound_A,modestring_A,varargin)










    isUsingB=(nargin==6);
    if isUsingB
        ubound_B=varargin{1};
        modestring_B=varargin{2};
    end

    numCANs=IRmodelInfo.numCANs;
    if numCANs>0

        mailboxesUsed_A=zeros(1,ubound_A+1);
        if isUsingB
            mailboxesUsed_B=zeros(1,ubound_B+1);
        end

        for i=1:numCANs,
            if strcmp(IRmodelInfo.CAN{i}.useModule,'eCAN_A')

                mBoxNo_A=IRmodelInfo.CAN{i}.mailboxNo;
                validateMailboxNum('A',mBoxNo_A,ubound_A,modestring_A);

                if~(mailboxesUsed_A(mBoxNo_A+1))
                    mailboxesUsed_A(mBoxNo_A+1)=1;
                end

            elseif isUsingB

                mBoxNo_B=IRmodelInfo.CAN{i}.mailboxNo;
                validateMailboxNum('B',mBoxNo_B,ubound_B,modestring_B);

                if~(mailboxesUsed_B(mBoxNo_B+1))
                    mailboxesUsed_B(mBoxNo_B+1)=1;
                end
            end
        end
    end

    function validateMailboxNum(this,mBoxNo,ubound,modestring)
        if(mBoxNo<0||mBoxNo>ubound||mod(mBoxNo,1)~=0)
            error(message('TICCSEXT:util:InvalidMailboxNumberSpecific',num2str(mBoxNo),this,modestring,this,ubound));
        end