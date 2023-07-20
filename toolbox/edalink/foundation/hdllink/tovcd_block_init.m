function[myModelName,mySigNames]=tovcd_block_init



    myModelName=bdroot;

    mySigNames=get_param(gcb,'InputSignalNames');



    mySigNames=regexprep(mySigNames,'\s+','_');
    numports=length(mySigNames);

    sig_idx=1;
    signal_limit=100000;


    for i=1:numports
        if(isempty(mySigNames{i}))
            ctr=i;
            autoname=sprintf('%s_%d','In',ctr);
            while any(strcmpi(autoname,mySigNames))&&(ctr<signal_limit)
                ctr=ctr+1;
                autoname=sprintf('%s_%d','In',ctr);
            end
            if ctr==signal_limit
                error(message('HDLLink:tovcd_block_init:ToVCDNameConflict'));
            end
            mySigNames{i}=autoname;

        end
    end
