function v=checkSerialAttributes(this)







    v=struct('Status',0,'Message','','MessageID','');
    csource=this.getHDLParameter('filter_coefficient_source');
    uff=this.getHDLParameter('userspecified_foldingfactor');
    nummults=this.getHDLParameter('filter_nummultipliers');
    if strcmpi(this.Implementation,'serial')&&strcmpi(csource,'processorinterface')

        msg=getString(message('HDLShared:hdlfilter:invalidserialprocint'));
        v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:invalidserialprocint');
        return
    end
    spmatrix=this.getSerialPartMatrix;
    validffs=str2double(spmatrix(:,1))';
    validnummults=str2double(spmatrix(:,2))';

    if uff~=1&&~any(validffs==uff)

        msg=getString(message('HDLShared:hdlfilter:invalidFF',num2str(sort(validffs))));
        v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:invalidFF');
        return
    end
    if nummults~=-1&&~any(validnummults==nummults)

        msg=getString(message('HDLShared:hdlfilter:invalidMnumMults',num2str(sort(validnummults))));
        v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:invalidMnumMults');
        return
    end

    if nummults~=-1&&uff~=1

        msg=getString(message('HDLShared:hdlfilter:bothFFMultsspecified'));
        v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:bothFFMultsspecified');
        return
    end



