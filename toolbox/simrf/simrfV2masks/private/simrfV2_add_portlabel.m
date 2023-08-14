function MaskDisplay=simrfV2_add_portlabel(MaskDisplay,numLConn,...
    namesLConn,numRConn,namesRConn,isgrounded)




    tempstr='';
    if isgrounded
        for ii=1:numLConn
            tempstr=sprintf('%s\nport_label(''LConn'', %d,''%s'')',...
            tempstr,ii,namesLConn{ii});
        end
        for ii=1:numRConn
            tempstr=sprintf('%s\nport_label(''RConn'', %d,''%s'')',...
            tempstr,ii,namesRConn{ii});
        end

    else
        for ii=1:2:numLConn
            kk=ceil(ii/2);
            tempstr=sprintf('%s\nport_label(''LConn'', %d,''%s%s'')',...
            tempstr,ii,namesLConn{kk},'+');
        end
        for ii=2:2:numLConn
            kk=ii/2;
            tempstr=sprintf('%s\nport_label(''LConn'', %d,''%s%s'')',...
            tempstr,ii,namesLConn{kk},'-');
        end
        for ii=1:2:numRConn
            kk=ceil(ii/2);
            tempstr=sprintf('%s\nport_label(''RConn'', %d,''%s%s'')',...
            tempstr,ii,namesRConn{kk},'+');
        end
        for ii=2:2:numRConn
            kk=ii/2;
            tempstr=sprintf('%s\nport_label(''RConn'', %d,''%s%s'')',...
            tempstr,ii,namesRConn{kk},'-');
        end

    end

    MaskDisplay=regexprep([MaskDisplay,tempstr],'^\n','');

end