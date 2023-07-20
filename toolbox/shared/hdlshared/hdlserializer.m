function[hdlbody,hdlsignals]=hdlserializer(input,output,loaden,shiftmode,outvld,initValue,processName)













    output_sltype=hdlsignalsltype(output);
    [output_size,outbp,outsigned]=hdlwordsize(output_sltype);
    input_sltype=hdlsignalsltype(input);
    [input_size,inbp,insigned]=hdlwordsize(input_sltype);
    if output_size>1|input_size<2
        error(message('HDLShared:directemit:serinvalidinputoutput'));
    end

    if nargin<4
        error(message('HDLShared:directemit:serializertoofewargs'))
    elseif nargin==4
        outvld=[];
        initValue=0;
        processName='SERIALIZER';
    elseif nargin==5
        initValue=0;
        processName='SERIALIZER';
    elseif nargin==6
        processName='SERIALIZER';
    elseif nargin>7
        error(message('HDLShared:directemit:toomanyargs'))
    end

    [hdlbody,hdlsignals]=hdlshiftregister(input,output,loaden,[],outvld,[],'serializer',shiftmode,initValue,processName);
