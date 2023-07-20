function hdlType=hdltype(this,fitype)






    if strfind(fitype,'std')
        hdlType=resolveSTD(fitype);
    elseif strfind(fitype,'real')
        hdlType=fitype;
    elseif isempty(this.findprop('generic'))||~isfield(this.generic,fitype)
        if strfind(fitype,'integer')
            hdlType=fitype;
        elseif strfind(fitype,'fix')
            hdlType=hdlblockdatatype(fitype);
        elseif strfind(fitype,'string')
            hdlType=fitype;
        elseif strfind(fitype,'natural')
            hdlType=fitype;
        elseif contains(fitype,'boolean')&&hdlgetparameter('isvhdl')


            hdlType='std_logic';
        else
            hdlType=hdlportdatatype(fitype);
        end

    elseif hdlgetparameter('isvhdl')
        hdlType=['std_logic_vector(',fitype,' - 1 DOWNTO 0)'];
    else
        hdlType=['wire [',fitype,' - 1 : 0]'];
    end
end



function hdlType=resolveSTD(fitype)
    if strfind(fitype,'sstype')
        bigendian=false;
        len=str2double(fitype(5:end));
    else
        bigendian=true;
        len=str2double(fitype(4:end));
    end

    if hdlgetparameter('isvhdl')
        if len==1
            hdlType='std_logic';
        elseif bigendian
            hdlType=['std_logic_vector(',sprintf('%d',len-1),' DOWNTO 0)'];
        else
            hdlType=['std_logic_vector(0 TO ',sprintf('%d',len-1),')'];
        end
    else
        if len==1
            hdlType='wire';
        elseif bigendian
            hdlType=['wire[',sprintf('%d',len-1),' : 0]'];
        else
            hdlType=['wire[0 :',sprintf('%d',len-1),']'];
        end
    end
end