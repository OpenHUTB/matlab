function[status,msg]=ne_ic_jacobian(ss,in,~,~)











    status=0;
    msg='';


    pin=ss.inputs;
    pin.T=in.T;
    pin.U=in.U;
    pin.V=in.V;
    pin=ss.ICS(pin);
    pin=ss.INIT(pin);


    [pin,base]=ss.expand(pin);


    pin.M=base.MODE(pin);


    dxfp=base.DXF_P(pin);
    dxf=ne_tosparse(base.DXF_P(pin),base.DXF(pin));


    dxmp=base.DXM_P(pin);
    dxm=ne_tosparse(base.DXM_P(pin),base.DXM(pin));
    [ndxm,nx]=size(dxmp);
    [i,~]=find(base.M_P(pin));
    i=reshape(i,length(i),1);
    mul=sparse(double(repmat(i',nx,1)==repmat((1:nx)',1,ndxm)));
    dxmp=logical(mul*double(dxmp));
    dxm=mul*dxm;


    jacobian=sparse(dxm+dxf);
    pattern=sparse(dxmp|dxfp);


    bad=~isfinite(jacobian);
    rows=find(any(bad'));
    [m,~]=size(bad);

    vv=pm_message('physmod:simscape:engine:mli:ne_ic_jacobian:VariableValues');
    nl=sprintf('\n');

    for row=rows


        iwant=false(1,m);
        iwant(row)=true;
        one_err_string=ne_get_one_err_string(iwant,...
        base.EquationData,...
        base.EquationRange);
        msg=[msg,nl,one_err_string];%#ok


        vars=pattern(row,:);
        hyperlinks=ne_variable_hyperlink(base,vars);
        vars=find(vars);
        vals=pin.X(vars);
        max_size=max(arrayfun(@(x)length(mat2str(x)),vals));
        for j=1:length(hyperlinks)
            val=mat2str(pin.X(vars(j)));
            indent=max_size-length(val);
            hyperlinks{j}=[repmat(' ',1,indent),val,' : ',hyperlinks{j},nl];
        end
        msg=[msg,vv,nl,nl,hyperlinks{:}];%#ok

    end

end
