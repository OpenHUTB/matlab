function v=validateFilterParams(this,hC)







    v=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');

    cpdt=get_param(bfp,'CompiledPortDataTypes');
    in_sltype=char(cpdt.Inport(1));
    inputWL=hdlgetsizesfromtype(in_sltype);

    if strcmpi(block.FilterSource,'Filter object')
        dfiltName=block.FilterObject;
        if~isempty(dfiltName)
            ud=block.UserData;
            if~isfield(ud,'filter');
                error(message('hdlcoder:validate:undefinedDFILT',dfiltName));
            end
        end
    end



    if inputWL~=0
        if strcmpi(block.FilterSource,'Specify via dialog')||...
            strcmpi(block.FilterSource,'Dialog parameters')||...
            strcmpi(block.FilterSource,'Auto')

            if(strcmpi(block.firstCoeffMode,'Slope and bias scaling')||...
                strcmpi(block.prodOutputMode,'Slope and bias scaling')||...
                strcmpi(block.accumMode,'Slope and bias scaling')||...
                strcmpi(block.outputMode,'Slope and bias scaling'))
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validate:SlopeBiasUnsupported'));
            end
        end
    end

    if any([v.Status])
        return;
    end






    v=[v,validateFilterImplParams(this,hC)];

