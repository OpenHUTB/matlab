function this=Message(msgShort,msgLong)










    persistent CANONICAL_MESSAGE

    if isempty(CANONICAL_MESSAGE)
        CANONICAL_MESSAGE=feval(mfilename('class'));
    end

    this=CANONICAL_MESSAGE;

    if nargin>0
        this.MessageShort=msgShort;
        if nargin>1
            this.MessageLong=msgLong;
        end
    end
