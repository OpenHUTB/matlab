function codeoptions=hdlcommentcodeoptions(optionscell,commentchars)
    idx=find(strcmpi(optionscell,'EnableFPGAWorkflow'),1);
    if~isempty(idx)&&(mod(idx,2)==1)
        optionscell(idx)=[];
        optionscell(idx)=[];
    end

    idx=find(strcmpi(optionscell,'FPGAWorkflowParameters'),1);
    if~isempty(idx)&&(mod(idx,2)==1)
        optionscell(idx)=[];
        optionscell(idx)=[];
    end

    codeoptions='';
    skip_next=0;
    tbfdstimwaslast=0;
    tbcoeffstimwaslast=0;
    for n=1:length(optionscell)
        if mod(n,2)==1
            codeoptions=[codeoptions,commentchars,' '];
        end
        if skip_next
            codeoptions=[codeoptions,' User data, length ',num2str(length(optionscell{n}))];
            skip_next=0;
        else
            switch lower(class(optionscell{n}))
            case 'double'
                if tbfdstimwaslast
                    codeoptions=[codeoptions,' User data, length ',num2str(length(optionscell{n}))];
                    tbfdstimwaslast=0;
                else
                    tmp=optionscell{n};
                    if size(tmp,2)>1||size(tmp,1)>1
                        codeoptions=[codeoptions,'['];
                        for m=1:size(tmp,1)
                            if m==size(tmp,1)
                                codeoptions=[codeoptions,num2str(tmp(m,:)),']'];
                            else
                                codeoptions=[codeoptions,num2str(tmp(m,:)),'; '];
                            end
                        end
                    else
                        codeoptions=[codeoptions,num2str(optionscell{n})];
                    end
                end
            case 'char'
                tmp=strrep(optionscell{n},char(10),'\n');
                tmp=strrep(tmp,'\','\\');
                tmp=strrep(tmp,'%','%%');
                codeoptions=[codeoptions,tmp];
                if strcmpi(optionscell{n},'testbenchfracdelaystimulus')
                    tbfdstimwaslast=1;
                elseif strcmpi(optionscell{n},'testbenchcoeffstimulus')
                    tbcoeffstimwaslast=1;
                end
                if strcmpi(optionscell{n},'testbenchuserstimulus')||strcmpi(optionscell{n},'UserComment')
                    skip_next=1;
                end
            case 'cell'
                tmp=optionscell{n};
                if tbcoeffstimwaslast



                    for m=1:length(tmp)
                        if isvector(tmp{m})
                            szvec=size(tmp{m});
                            if szvec(2)==1
                                ScaleValue_comment=num2str(tmp{m}.');
                            else
                                ScaleValue_comment=num2str(tmp{m});
                            end
                            codeoptions=[codeoptions,'\n',commentchars,'          ScaleValue: [',ScaleValue_comment,']'];
                        else
                            sosMatrix_comment=num2str(tmp{m});
                            sos_size=size(sosMatrix_comment);
                            codeoptions=[codeoptions,'\n',commentchars,'          SOS Matrix: '];
                            for count_i=1:sos_size(1)
                                codeoptions=[codeoptions,'\n',commentchars,'                   ',sosMatrix_comment(count_i,:)];
                            end
                        end
                    end
                    tbcoeffstimwaslast=0;
                else
                    cellcodeoptions=[];
                    cellcontentsnotchar=0;
                    for m=1:length(tmp)
                        if~ischar(tmp{m})&&~(isstring(tmp{m})&&isscalar(tmp{m}))
                            cellcontentsnotchar=1;
                        else
                            cellcodeoptions=[cellcodeoptions,tmp{m},' '];
                        end
                    end
                    if cellcontentsnotchar
                        codeoptions=[codeoptions,'Cell array of ',num2str(length(tmp)),' elements'];
                    else
                        codeoptions=[codeoptions,cellcodeoptions];
                    end

                end
            case 'embedded.numerictype'

                tmp=optionscell{n};
                s=sprintf('numerictype(%d,%d,%d)',tmp.SignednessBool,tmp.WordLength,tmp.FractionLength);
                codeoptions=[codeoptions,s];
            otherwise
                codeoptions=[codeoptions,'Object handle of class ',class(optionscell{n}),'.'];

            end
        end
        if mod(n,2)==0
            codeoptions=[codeoptions,'\n'];
        else
            codeoptions=[codeoptions,': '];
        end

    end

