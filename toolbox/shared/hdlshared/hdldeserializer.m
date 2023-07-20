function[hdlbody,hdlsignals]=hdldeserializer(input,output,loaden,shiftmode,start,outvld,initValue,processName)














    output_sltype=hdlsignalsltype(output);
    [output_size,outbp,outsigned]=hdlwordsize(output_sltype);
    input_sltype=hdlsignalsltype(input);
    [input_size,inbp,insigned]=hdlwordsize(input_sltype);
    if input_size>1|output_size<1
        error(message('HDLShared:directemit:deserinvalidinputoutput'));
    end

    if nargin<4
        error(message('HDLShared:directemit:invalidargs'))
    elseif nargin==4
        start=[];
        outvld=[];
        initValue=0;
        processName='DESERIALIZER';
    elseif nargin==5
        outvld=[];
        initValue=0;
        processName='DESERIALIZER';
    elseif nargin==6
        initValue=0;
        processName='DESERIALIZER';
    elseif nargin==7
        processName='DESERIALIZER';
    elseif nargin>8
        error(message('HDLShared:directemit:toomanyargs'))
    end

    [hdlbody,hdlsignals]=hdlshiftregister(input,output,loaden,[],outvld,start,'deserializer',shiftmode,initValue,processName);
