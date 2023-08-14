function output=hdlevalpircodegen(input)
















    fcn=input.CodeGenFunction;
    params=input.CodeGenParams;

    hDriver=hdlcurrentdriver;
    oldNetwork=hDriver.getCurrentNetwork;

    hN=params{2}.Owner;

    hDriver.setCurrentNetwork(hN);




    context=params{1}.preEmit(hDriver,params{2});
    output=feval(fcn,params{:});
    params{1}.postEmit(hDriver,params{2},context);
    hDriver.setCurrentNetwork(oldNetwork);

    fn=fieldnames(output);
    for ii=1:length(fn)
        hdlstr=output.(fn{ii});
        if isempty(hdlstr)
            hdlstr='';
        else
            hdlstr=strrep(hdlstr,'\n',char(10));
        end
        output.(fn{ii})=hdlstr;
    end
