function v=checkhdl(this,varargin)






    v=this.checkOneBitInput;
    if v.Status
        return
    end

    v=this.checkAllCoeffsZero;
    if v.Status
        return
    end

    v=this.checkInvalidProps(varargin{:});
    if v.Status

        if~isempty(strfind(lower(v.Message),'serialpartition'))&&isa(this,'hdlfilter.df1sos')

            v.Message=[v.Message,newline,getString(message('HDLShared:hdlfilter:iirserial'))];
        end

        return
    end
    numsections=this.NumSections;
    scales=this.ScaleValues;
    numcoeffall=hdlgetallfromsltype(this.numcoeffSLtype);
    coeffsvsize=numcoeffall.size;
    filterorders=this.SectionOrder;

    coeffs=this.Coefficients;

    for section=1:numsections
        firstscaleint=scales(section);
        if coeffsvsize==0
            if firstscaleint==0
                msgID='HDLShared:hdlfilter:iirscaleerror';
                msg=getString(message(msgID));
...
...
...
...
                v=struct('Status',1,'Message',msg,'MessageID',msgID);
                return
            end
        else
            if firstscaleint==0
                msgID='HDLShared:hdlfilter:iirscaleerror';
                msg=getString(message(msgID));
...
...
...
...
                v=struct('Status',1,'Message',msg,'MessageID',msgID);
                return
            end
        end


        if filterorders(section)==0
            msgID='HDLShared:hdlfilter:zero_order';

            msg=getString(message(msgID));
            v=struct('Status',1,'Message',msg,'MessageID',msgID);
            return
        elseif(filterorders(section)~=1&&filterorders(section)~=2)
            msgID='HDLShared:hdlfilter:other_order';

            msg=getString(message(msgID,num2str(filterorders(section))));
            v=struct('Status',1,'Message',msg,'MessageID',msgID);
            return
        end

        [~,den]=getcoeffs(coeffs,section);
        if den(1)~=1
            msgID='HDLShared:hdlfilter:a1error';

            msg=getString(message(msgID));
            v=struct('Status',1,'Message',msg,'MessageID',msgID);
            return
        end

    end

    v=this.checkComplex;
    if v.Status
        return
    end

    v=this.checkSerialAttributes;
    if v.Status
        return
    end
    function[num,den]=getcoeffs(coeffs,section)
        num=coeffs(section,1:3);
        den=coeffs(section,4:6);



