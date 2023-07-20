function reportTbValidateErrors(this,dut,genRTLTB)





    if nargin<3
        genRTLTB=true;
    end

    v=this.validate(dut,genRTLTB);

    if~isempty(v)
        idx_vector=strcmp('Error',{v.level});
        idx=find(1==idx_vector);

        errs=v(idx);%#ok<FNDSB>
        if~isempty(errs)


            dut.CodeGenSuccessful=false;
            error(errs(1).MessageID,errs(1).message);
        end

        idx_vector=strcmp('Warning',{v.level});
        idx=find(1==idx_vector);

        warns=v(idx);%#ok<FNDSB>
        if~isempty(warns)
            for ii=1:length(warns)
                warning(warns(ii).MessageID,warns(ii).message);
            end
        end

        idx_vector=strcmp('Message',{v.level});
        idx=find(1==idx_vector);

        disps=v(idx);%#ok<FNDSB>
        if~isempty(disps)
            for ii=1:length(disps)
                hdldisp(disps(ii).message,3);
            end
        end
    end


