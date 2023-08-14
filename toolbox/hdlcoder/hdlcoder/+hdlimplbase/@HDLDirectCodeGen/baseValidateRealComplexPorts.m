function v=baseValidateRealComplexPorts(this,ports)




















    v=hdlvalidatestruct;

    [noports,any_complex,all_complex]=this.checkForRealComplexPorts(ports);

    if~noports
        if(any_complex&&~all_complex)
            v=hdlvalidatestruct(1,...
            message('hdlcoder:validate:mixedrealcomplexUnhandled'));
        end
    end
