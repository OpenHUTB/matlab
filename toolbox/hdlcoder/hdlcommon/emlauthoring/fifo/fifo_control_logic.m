function[write_address,write_enable,read_address,empty,full,num]=fifo_control_logic(fifo_size,address_size,has_reset,varargin)
%#codegen



    coder.allowpcode('plain');
    if has_reset
        push=varargin{1};
        pop=varargin{2};
        rst=varargin{3};
    else
        push=varargin{1};
        pop=varargin{2};
        rst=false;
    end

    F=hdlfimath();
    T_ADDRESS=numerictype(0,address_size,0);
    ADDRESS_MAX=fi(2^address_size-1,T_ADDRESS,F);
    ADDRESS_COMP=fi(ADDRESS_MAX-(fifo_size-1)+1,T_ADDRESS,F);
    NEXT2LAST_VALUE=fi(fifo_size-1,T_ADDRESS,F);


    counter_bitwidth=ceil(log2(fifo_size+1));
    T_COUNTER=numerictype(0,counter_bitwidth,0);
    COUNTER_COMP=fi(2^(counter_bitwidth)-1,T_COUNTER,F);


    persistent front_indx front_dir;
    if isempty(front_indx)
        front_indx=fi(0,T_ADDRESS,F);
        front_dir=fi(1,T_ADDRESS,F);
    end

    persistent back_indx back_dir;
    if isempty(back_indx)
        back_indx=fi(0,T_ADDRESS,F);
        back_dir=fi(1,T_ADDRESS,F);
    end

    persistent sample_count;
    if isempty(sample_count)
        sample_count=fi(0,T_COUNTER,F);
    end


    full=sample_count==fifo_size;
    empty=sample_count==0;
    num=sample_count;


    write_address=back_indx;
    read_address=front_indx;
    write_enable=push&&(pop||~full);
    read_enable=pop&&~empty;


    if rst
        front_indx(:)=fi(0,T_ADDRESS,F);
    elseif read_enable
        front_indx(:)=front_indx+front_dir;
    end
    if front_indx==NEXT2LAST_VALUE
        front_dir=ADDRESS_COMP;
    else
        front_dir=fi(1,T_ADDRESS,F);
    end


    if rst
        back_indx(:)=fi(0,T_ADDRESS,F);
    elseif write_enable
        back_indx(:)=back_indx+back_dir;
    end
    if back_indx==NEXT2LAST_VALUE
        back_dir=ADDRESS_COMP;
    else
        back_dir=fi(1,T_ADDRESS,F);
    end


    if rst
        sample_count(:)=fi(0,T_COUNTER,F);
    elseif write_enable&&~read_enable
        sample_count(:)=sample_count+fi(1,T_COUNTER,F);
    elseif~write_enable&&read_enable
        sample_count(:)=sample_count+COUNTER_COMP;
    end
