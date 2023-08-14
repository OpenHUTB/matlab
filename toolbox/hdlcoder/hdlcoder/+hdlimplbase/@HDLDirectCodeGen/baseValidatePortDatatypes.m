function v=baseValidatePortDatatypes(this,ports)
















    v=hdlvalidatestruct;

    [noports,any_real,all_real,any_double,~,any_single,~,any_half,~]=this.checkForDoublePorts(ports);

    if~noports
        if(any_real&&~all_real)
            v=hdlvalidatestruct(1,...
            message('hdlcoder:validate:mixeddoubleUnhandled'));
        elseif(any_double&&any_single)||(any_single&&any_half)||(any_double&&any_half)
            v=hdlvalidatestruct(1,...
            message('hdlcoder:validate:mixeddoubleUnhandled'));
        end
    end
end
