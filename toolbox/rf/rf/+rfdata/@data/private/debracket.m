function option_line=debracket(h,option_line)




    [token,rem]=strtok(option_line,'(');
    rem=deblank(rem);

    if(~isempty(rem)&&strcmp(rem(1),'(')&&strcmp(rem(end),')'))
        option_line=rem(2:end-1);
    end