function schema





    pk=findpackage('filtstates');
    c=schema.class(pk,'cic');


    c.Handle='off';


    p=schema.prop(c,'Integrator','mxArray');
    set(p,...
    'FactoryValue',0,...
    'SetFunction',@set_integrator,...
    'AccessFlags.AbortSet','Off');



    p=schema.prop(c,'Comb','mxArray');
    set(p,...
    'FactoryValue',0,...
    'SetFunction',@set_comb,...
    'AccessFlags.AbortSet','Off');



    function int=set_integrator(this,int)

        [rows,cols]=size(int);

        if isnumeric(int)||isa(int,'embedded.fi')


            if isa(int,'double')
                int=int32(int);
            end


            for indx=1:rows
                for jndx=1:cols
                    val(indx,jndx)=filtstates.state(int(indx,jndx));
                end
            end
            int=val;
        elseif isa(int,'filtstates.state')










        else
            error(message('signal:filtstates:cic:schema:invalidIntegratorStates'));
        end


        function comb=set_comb(this,comb)

            nsections=size(this.Integrator,1);


            if isnumeric(comb)||isa(comb,'embedded.fi')


                if isa(comb,'double')
                    comb=int32(comb);
                end
                [rows,cols]=size(comb);







                M=floor(rows/nsections);
                for indx=1:cols
                    for jndx=1:nsections
                        val(jndx,indx)=...
                        filtstates.state(comb(1+(jndx-1)*M:jndx*M,indx));
                    end
                end
                comb=val;
            elseif~isa(comb,'filtstates.state')
                error(message('signal:filtstates:cic:schema:invalidCombStates'));
            end


