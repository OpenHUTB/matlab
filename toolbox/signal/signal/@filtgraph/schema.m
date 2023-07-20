function schema







    schema.package('filtgraph');

    findpackage('sigdatatypes');




    if isempty(findtype('Orientation'))
        schema.EnumType('Orientation',{'left','right','up','down'});
    end






    if isempty(findtype('ExpansionOrientation'))
        schema.EnumType('ExpansionOrientation',{'lr','rl','ud','du'});
    end





    if isempty(findtype('BlockType'))
        schema.EnumType('BlockType',{'DUMMY','connector','input','output','gain','sum'...
        ,'delay','convertio','cast','convert','from','goto','caststage','upsample'...
        ,'downsample','interpcommutator','decimcommutator','mult','ratetransition','firsrccommutator',...
        'repeatingsequencestair','farrowsrccommutator','constant','mathfun','fracdelay',...
        'comparetoconstant','fixptfracdelay','extractbits','demux','portselector','terminator'});







    end


    if isempty(findtype('dgQuantumParameter'))
        schema.UserType('dgQuantumParameter','MATLAB array',@check_dgQuantumParameter);
    end


    function check_dgQuantumParameter(value)

        if isempty(value)
            return
        elseif ischar(value)&&(strcmpi(value,'double')||strcmpi(value,'single'))
            return;
        else
            isvector=any(size(value)==1);
            if isvector
                for m=1:length(value)
                    value1=value(m);
                    if isstruct(value1)
                        return;
                    else
                        error(message('signal:filtgraph:schema:DataTypeError','double','single'));
                    end
                end
            else
                error(message('signal:filtgraph:schema:DataDimensionError'));
            end
        end
