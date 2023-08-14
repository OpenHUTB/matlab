function output=optstr_struct(str)





    output=[];

    if(isempty(str))
        return;
    end

    r=str;
    j=1;
    while(1)
        [t,r]=strtok(r);
        equals=findstr(t,'=');
        dasha=findstr(t,'-a');

        if~isempty(equals)&&~isempty(dasha)

            equals=equals(1);
            dasha=dasha(1);

            fieldName=t(dasha+2:equals-1);



            if~isempty(equals)&&(length(t)>=equals+1)&&isequal(t(equals+1),'"')











                sptrue=(length(t)==equals+1);


                eqtrue=0;
                s=regexp(t,'\\"');
                if~isempty(s)
                    eqtrue=(s(end)==length(t)-1);
                end


                nqtrue=~isequal(t(end),'"');

                if sptrue||eqtrue||nqtrue

                    k=regexp(r,'[^\\]"','once');
                    if~isempty(k)

                        k=k+1;
                        t=strcat(t,r(1:k));
                        r=r(k+1:end);
                    end
                end
            end

            fieldValue=t(equals+1:end);
            output(j).name=fieldName;
            output(j).value=fieldValue;
            output(j).enable='on';
            j=j+1;
        end

        if(isempty(r))
            break;
        end
    end